-- ===============================================
-- Catalogue V1 — Profil Développeur — catégories manquantes
-- V24 : Distributed Systems (22 défis — 15 QCM, 4 problem-solving,
--       3 raisonnements séquentiels)
-- Idempotent : WHERE NOT EXISTS sur challenges.title (jamais utilisé).
-- Même structure que l'import JSON futur : challenges + challenge_options
--   (content / is_correct / display_order / explanation) + liens
--   categories / skills / profiles.
-- Aucune redondance :
--   - V6 = « Stratégie de cache Cache-Aside » (seul défis distribués existant) ;
--   - V20 = 429/backoff, idempotency-key, rate limiting, 502/503/504,
--     202/webhook, incident en cascade (circuit breaker), BFF, SSE ;
--   - V23 = étapes Notify/EditDoc/Ride (ordonnancement, throttle, rejeu) ;
--   - V8 = réservation atomique et consommateur idempotent ;
--   - V18 = partitionnement de TABLE (déclaratif) ≠ clé de sharding ici.
-- ===============================================

INSERT INTO challenges (
    title, type, selection_type, difficulty, context, question,
    explanation, estimated_time_seconds, active, points,
    created_at, updated_at
)
SELECT * FROM (VALUES
('Distribué : le réseau ne fait aucune promesse', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'JUNIOR',
 'Un service appelle un autre ; la réponse ne revient pas. L''équipe conclut à un échec et relance aussitôt la même opération.',
 'Quel modèle de panne la situation illustre-t-il ?',
 'Le réseau peut perdre, retarder, dupliquer ou couper n''importe quel message : après un timeout, l''état du distant est INCONNU, pas « échoué ». Les seules réponses possibles sont « reçue » et « inconnue » — d''où idempotence, clé de déduplication et relances bornées. Relancer à l''aveugle sur une opération non idempotente, c''est créer le double envoi.',
 130, true, 10, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Distribué : lire depuis une réplique', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'JUNIOR',
 'Une lecture part vers une réplique en lecture seule pendant que l''utilisateur vient d''écrire ; il ne voit pas sa modification et signale un bug.',
 'Que se passe-t-il et comment l''expliquer ?',
 'La réplique applique les écritures avec un décalage (lag) : la lecture sert l''état d''avant — une valeur périmée, pas une donnée perdue. C''est le prix de la réplication en lecture : décharger le primaire au prix d''une fraîcheur garantie. Un parcours « lire après écrire » doit aller vers la source forte (primaire ou garantie de session).',
 130, true, 10, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Distribué : ce que coûtent les neuf chiffres', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'JUNIOR',
 'Le prestataire annonce 99,9 % de disponibilité mensuelle ; l''équipe l''estime « largement suffisant, ça ne nous arrive pas ».',
 'Que vaut 99,9 % sur un mois de 30 jours ?',
 '99,9 % = 0,1 % × 30 j ≈ 43 minutes d''arrêt par mois (99 % ≈ 7,2 h ; 99,99 % ≈ 4,3 min ; 99,999 % ≈ 26 s). Chaque neuf supplémentaire divise le budget d''arrêt par dix et multiplie le prix de la redondance. Chiffrer avant de promettre — et le pourcentage porte sur le calendrier complet, heures ouvrées ou non.',
 130, true, 10, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Distribué : ce que CAP dit vraiment', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'En réunion, on résume : « notre système est en CP, donc il ne peut pas connaître d''indisponibilités ».',
 'Quelle lecture du théorème est correcte ?',
 'CAP dit : pendant une PARTITION réseau, un système doit choisir entre cohérence (C) et disponibilité (A). Il ne parle que de ce cas, et « être CP » décrit un comportement sous panne — pas une garantie de uptime. Hors partition, C et A se négocient selon les cas d''usage (et PACELC évoque le coût en latence le reste du temps).',
 150, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Distribué : attendre la cohérence éventuelle', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Après une écriture confirmée, un autre service lit la valeur ancienne 800 ms plus tard et conclut à un bug de persistance.',
 'Quel contrat la lecture doit-elle respecter ?',
 'La cohérence éventuelle ne garantit aucune lecture fraîche immédiate : la convergence vient « éventuellement ». Un lecteur qui doit voir sa propre écriture exige une lecture forte (source primaire ou read-your-writes). Traiter un retard annoncé comme une panne, c''est confondre le contrat du système avec sa défaillance.',
 140, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Distribué : quorum de lecture et d''écriture', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Cluster de 5 réplicas, écritures W=1 et lectures R=1 : des lectures tombent parfois sur des valeurs antérieures.',
 'Quel réglage réduit le risque de lecture périmée, et à quel prix ?',
 'Pour que la lecture croise nécessairement la dernière écriture, il faut W + R > N (3 + 3 > 5 sur 5 réplicas) : toute lecture atteint au moins un nœud à jour. Le prix : latence (attendre plus de nœuds), débit (plus de réplicas sollicités) et tolérance en écriture réduite — il faut la majorité pour écrire.',
 150, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Distribué : choisir la clé de partitionnement', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Une table de commandes passe sur 16 shards ; la clé retenue est la date de création. Un quart des nœuds reçoit 60 % de la charge.',
 'Quel diagnostic et quel remède ?',
 'Hotspot temporel : les écritures « maintenant » tombent toutes sur le shard du jour. La clé hashée sur l''identifiant équilibre, au prix de la localité temporelle (les requêtes récentes rayonnent) ; une clé composite (hash + fenêtre) ménage les deux selon les accès dominants. Choisir une clé de sharding, c''est arbitrer entre équilibre, localité et facilité de rééquilibrage.',
 150, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Distribué : sémantiques de livraison des messages', 'SITUATIONAL_QCM', 'MULTIPLE_CHOICE', 'INTERMEDIATE',
 'Une file distribuée livre des événements de facturation ; l''équipe croit qu''une case à cocher du broker active « exactement une fois » de bout en bout.',
 'Quelles affirmations sont exactes ?',
 'Aucun chemin bout en bout ne fournit « exactement une fois » : le transport offre au mieux « au moins une fois » (ou « au plus une fois » avec pertes), et l''effet métier exactement-une-fois résulte du traitement idempotent ou dédupliqué côté consommateur. At-most-once convient au best-effort, jamais à l''écriture comptable. La case du broker ne couvre que son périmètre.',
 160, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Distribué : quand le consommateur suit plus lentement', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Le lag de la file de traitement passe de 2 minutes à 4 heures ; les utilisateurs n''obtiennent plus leurs résultats. On propose d''ajouter des consommateurs.',
 'Quelle lecture et quelles actions sont justes ?',
 'Le lag croît quand l''entrée dépasse le débit traité. Avant de scaler : mesurer le goulot réel — traitement lent, rejeux en boucle, ou dépendance aval bornée (une API tierce à quota ne s''accélère pas en dupliquant les appelants) —, puis protéger (backpressure, bornes, politique de retenue). Ajouter des instances ne aide que si le traitement est parallélisable et l''aval capable de suivre.',
 150, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Distribué : réplication n''est pas sauvegarde', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Un script erroné a détruit des lignes ; la corruption s''est répliquée sur les trois réplicas en 40 secondes. L''équipe ne comprend pas : « on a trois copies ».',
 'Pourquoi la réplication n''a-t-elle pas protégé, et qu''est-ce qui protège ?',
 'La réplication protège contre la panne d''un nœud, pas contre l''erreur logique : elle copie fidèlement la corruption, souvent plus vite qu''un humain ne peut réagir. Il faut des sauvegardes horodatées (snapshots, PITR) avec rétention testée pour rejouer avant le point de contamination. Réplication = continuité de service ; sauvegarde = retour en arrière possible.',
 150, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Distribué : split-brain pendant une coupure', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'ADVANCED',
 'Le lien entre deux nœuds tombe ; chacun juge l''autre mort. Pendant 90 secondes, les deux acceptent des écritures, puis le lien revient.',
 'Quel est le risque et le garde-fou ?',
 'Split-brain : deux primaires écrivent en parallèle ; à la reconnexion, divergences et perte possible d''une branche. Garde-fous : majorité/quorum pour décider (un nœud isolé sans majorité refuse d''écrire — il préfère l''arrêt à la corruption) et fencing (tokens/leases) pour que l''ancien primaire, devenu zombie, ne puisse plus rien valider.',
 160, true, 20, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Distribué : ce qu''achète un consensus', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'ADVANCED',
 'L''équipe introduit Raft « pour rendre le système infaillible ». Le propos est enthousiaste mais imprécis.',
 'Qu''achète réellement le consensus, et à quel coût ?',
 'Un consensus (leader élu, journal répliqué à majorité) achète des décisions univoques et un ordre total même pendant les partitions : qui est primaire, quel est l''état — plus de deux vérités. Coût : majorités et élections (round-trips, latence), le leader centralise les écritures (goulot potentiel), et sans majorité il n''y a plus de décision. Il supprime l''ambiguïté, pas les pannes.',
 160, true, 20, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Distribué : écrire actif-actif en multi-région', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'ADVANCED',
 'Une application passe en écriture active-active sur deux régions ; des utilisateurs modifient le même profil des deux côtés, parfois la même seconde.',
 'Quel problème structurel cette architecture introduit-elle ?',
 'Sans ordre global, deux régions écrivent la même donnée : conflits à arbitrer (dernier arrivé gagne = pertes silencieuses, ou règles de fusion métier), réconciliation, et soit latence inter-régionale, soit acceptation des divergences. Le vrai choix : actif-passif (cohérence simple, bascule régionale) contre actif-actif (écriture continue partout, conflits à porter). La disponibilité d''écriture des deux côtés se paie en gestion de conflits.',
 160, true, 20, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Distribué : détecter qu''un nœud est mort', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'ADVANCED',
 'Sous forte charge, un nœud sain est déclaré mort pendant 3 secondes ; le système l''évincé, le réintègre, puis reproduit le cycle.',
 'Quel est le problème et quelle approche réduit le risque ?',
 'La détection de mort est un jugement sous incertidence : un réseau lent ressemble à un nœud mort. Un seuil fixe et court produit des faux positifs et de l''agitation (élections répétées). Approches saines : suspicion adaptative (score de fiabilité, tolérance aux rechutes), timeout généreux, et rendre les transitions peu coûteuses — quand l''état change rarement, mieux vaut détecter tard que provoquer une promotion inutile.',
 160, true, 20, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Distribué : reprendre un flux traité à moitié après incident', 'PROBLEM_SOLVING', 'SINGLE_CHOICE', 'ADVANCED',
 'Un déploiement a interrompu le consommateur d''un flux d''événements métier ; 40 minutes d''événements sont en file et certains traités à moitié (effets partiels visibles).',
 'Décrivez la procédure de reprise : point de vérité, effets partiels, drainage, vérification.',
 'Procédure : (1) identifier le point de reprise exact — le dernier événement PLEINEMENT traité, pas le dernier reçu ; (2) inventorier les effets partiels possibles (écritures sans suite, appels externes) et prévoir leur déduplication ; (3) rejouer depuis ce point avec traitement idempotent — jamais « continuer où on s''était arrêté » à l''aveugle ; (4) vérifier par comptes et échantillons que chaque effet n''existe qu''une fois ; (5) relancer progressivement en surveillant lag et erreurs avant de rendre la cadence. Piège : repartir du dernier offset committé alors que les traitements d''avant l''incident étaient partiels.',
 900, true, 30, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Distribué : choisir le niveau de cohérence par cas d''usage', 'PROBLEM_SOLVING', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Le débat « forte ou éventuelle ? » oppose deux camps : toujours forte, ou jamais. Trois besoins coexistent : solde bancaire, panier d''achat, fil d''actualité.',
 'Comment décider par cas d''usage, et quelles garanties offrir concrètement aux utilisateurs ?',
 'Décision par la lecture à satisfaire : solde → cohérence forte (source primaire, écriture confirmée avant affichage) ; panier → read-your-writes sur la session, convergence asynchrone acceptable entre appareils ; fil d''actualité → éventuelle (secondes de retard cosmétiques). « Toujours forte » paie des coûts partout pour trois besoins réels ; « jamais forte » ment sur l''argent. Fournir la garantie par le contrat et l''interface (état visible, fraîcheur affichée), pas par généralisation technique.',
 900, true, 30, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Distribué : migrer vers un sharding sans coupure', 'PROBLEM_SOLVING', 'SINGLE_CHOICE', 'ADVANCED',
 'Une base unique atteint ses limites (verrous, taille, débit). Il faut répartir les données sur plusieurs shards sans interrompre lectures ni écritures.',
 'Décrivez la trajectoire par étapes : répartition, backfill, double-lecture, bascule, rééquilibrage.',
 'Trajectoire : (1) définir la clé de sharding et la table de routage sur la distribution réelle mesurée ; (2) déployer le routage en double lecture (shard + ancien, comparaison silencieuse) pour valider sans risque ; (3) backfill par lots idempotents, puis rejeu continu des mutations survenues depuis le point de départ ; (4) bascule : fenêtre d''écriture courte ou double-écriture contrôlée, cordonnée et vérifiée (comptes, échantillons, écarts = arrêt) ; (5) couper l''ancien chemin, et outiller le split de shard dès le départ — un sharding non rééquilibrable est une dette certaine. Piège : backfill sans rejeu = données perdues à la bascule.',
 900, true, 30, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Distribué : dimensionner une file d''attente', 'PROBLEM_SOLVING', 'SINGLE_CHOICE', 'ADVANCED',
 'Une file reçoit 300 messages/s en pic et en traite 200 ; rétention 24 h. Une campagne ×4 arrive la semaine prochaine.',
 'Décrivez la démarche de dimensionnement : débit, retenue, bornes, rétention, alertes.',
 'Démarche : (1) mesurer entrée vs sortie réels, pics compris — ici entrée > sortie : la file grossit déjà, la campagne aggrave ; (2) traiter l''écart avant tout (paralléliser le traitement, supprimer la cause lente) — dimensionner ne soigne pas un goulot aval ; (3) borner : plafond de profondeur et politique explicite au-delà (backpressure, rejet maîtrisé, perte assumée) — jamais le crash implicite ; (4) dimensionner le débit sortant pour pic + marge, et la rétention pour la fenêtre de rejeu réellement utile ; (5) alerter sur profondeur et sur l''âge du message le plus ancien — l''âge est le temps d''attente subi par l''utilisateur.',
 900, true, 30, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Distribué : basculer la primaire en cas de panne', 'SEQUENTIAL_REASONING', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Le nœud primaire d''un cluster de données s''arrête ; le service doit continuer à écrire dans les minutes qui suivent.',
 'Place ces étapes dans l''ordre de la procédure de bascule recommandée.',
 'La bascule saine va de la preuve de panne à la surveillance en mode dégradé : confirmer (une coupure brève ne vaut pas failover), choisir une réplique réellement à jour sous fencing de l''ancien primaire, réorienter et vérifier, puis surveiller et préparer le retour. Une promotion réflexe sur une réplique en retard transforme une panne en perte de données.',
 300, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Distribué : auditer la tolérance aux pannes', 'SEQUENTIAL_REASONING', 'SINGLE_CHOICE', 'ADVANCED',
 'Direction demande l''état de la tolérance aux pannes de la plateforme avant l''ouverture d''une nouvelle région.',
 'Place ces étapes dans l''ordre de la démarche d''audit.',
 'L''audit va de la cartographie à la preuve : dépendances et points uniques, scénarios de panne concrets par composant (réseau, process, région, donnée), évaluation des mécanismes réels (redondance, timeouts bornés, replis, files), angles morts hiérarchisés, puis validation par exercice — failover testé, chaos ciblé. Ce qui n''a jamais été exercé n''existe que sur le papier, et un audit sans plan de correction change rien au prochain incident.',
 360, true, 20, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Distribué : rétablir des réplications divergées', 'SEQUENTIAL_REASONING', 'SINGLE_CHOICE', 'ADVANCED',
 'Un contrôle nocturne détecte des divergences entre la source et deux réplicas sur des comptes critiques ; l''écriture continue sur la source.',
 'Place ces étapes dans l''ordre de la procédure de rétablissement.',
 'Le rétablissement va de la contention à la preuve : figer les zones divergées (et les écritures qui les touchent), établir la source de vérité sur règles et preuves (pas « le plus récent »), comparer par lot pour lister les écarts exacts, corriger par réécriture contrôlée et tracée — jamais une resynchronisation globale à l''aveugle — puis prouver la convergence par contrôles avant de rétablir le flux.',
 360, true, 20, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Distribué : 2PC ou saga pour une opération répartie', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Une commande exige deux écritures atomiques — paiement et réservation — réparties sur deux services. L''équipe débat entre transaction répartie à deux phases (2PC) et saga.',
 'Quel mécanisme retenir, et pourquoi le 2PC a-t-il tant de mal dans un système réparti ?',
 'Le 2PC impose une synchronisation bloquante : verrous maintenus chez les participants, coordonnateur en point de blocage, latence inter-régions ajoutée — son coût monte précisément là où l''échelle et la disponibilité comptent. Le saga orchestre des transactions locales en chaîne avec compensations en cas d''arrêt : disponible et partitionnable, au prix d''états intermédiaires visibles à gérer (statuts, pistes d''attente, reprise). Le choix oppose garantie atomique forte à périmètre fermé, contre échelle et continuité avec cohérence éventuelle.',
 150, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
) AS v(title, type, selection_type, difficulty, context, question, explanation, estimated_time_seconds, active, points, created_at, updated_at)
WHERE NOT EXISTS (SELECT 1 FROM challenges c WHERE c.title = v.title);

-- -----------------------------------------------
-- Options des QCM (SINGLE : 1 correcte — MULTIPLE : 2 correctes)
-- -----------------------------------------------

-- Distribué : le réseau ne fait aucune promesse
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Timeout = inconnu, pas échoué : l''appel a peut-être été traité, il faut raisonner en incertitude', true, 1,
 'Seules existent « réponse reçue » et « inconnu » — d''où idempotence et clé de déduplication.'),
('Timeout = l''appel n''a certainement pas été traité, on peut relancer sans précaution', false, 2,
 'C''est exactement la croyance qui produit les double-envois.'),
('Le réseau garantit l''ordre et l''unicité de tous les messages échangés', false, 3,
 'Perte, duplication et réordonnancement sont permis — rien n''est garanti.'),
('Un distant qui répond lentement est défaillant et doit être remplacé', false, 4,
 'La latence n''est pas la panne : la distinction fonde les timeouts bornés.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Distribué : le réseau ne fait aucune promesse'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- Distribué : lire depuis une réplique
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Décalage de réplication : la réplique sert l''état d''avant l''écriture — lire après écrire exige la source forte', true, 1,
 'Lag normal de la réplication en lecture ; le parcours sensible doit viser le primaire.'),
('L''écriture a été perdue : elle n''a jamais été appliquée par le primaire', false, 2,
 'La confirmation d''écriture porte sur le primaire : la donnée existe, la copie suit.'),
('La réplique refuse les valeurs trop récentes par conception', false, 3,
 'Aucun tel mécanisme : elle n''a simplement pas encore reçu/appliqué la valeur.'),
('Il faut supprimer la réplique pour rétablir la cohérence', false, 4,
 'La destruction ne change rien au mécanisme de propagation — et retire la capacité de lecture.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Distribué : lire depuis une réplique'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- Distribué : ce que coûtent les neuf chiffres
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('≈ 43 minutes d''arrêt par mois — chaque neuf supplémentaire divise le budget par 10', true, 1,
 '0,1 % × 30 jours = 43 min ; 99,99 % = 4,3 min ; le calcul rend le contrat tangible.'),
('≈ 8 secondes par mois', false, 2,
 'C''est plutôt 99,999 % (26 s) qui approche de cet ordre — un neuf de moins change tout.'),
('≈ 4,3 heures par mois', false, 3,
 'Ce serait ~99,4 % : proche de 99 % (7,2 h), pas de 99,9 %.'),
('Le pourcentage porte sur les heures ouvrées uniquement', false, 4,
 'Le calendrier est complet : les incidents de nuit comptent autant.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Distribué : ce que coûtent les neuf chiffres'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- Distribué : ce que CAP dit vraiment
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Le choix C/A ne se pose QUE pendant une partition : hors partition, CAP ne dit rien des indisponibilités', true, 1,
 'CAP décrit un arbitrage sous panne réseau, pas une politique d''uptime.'),
('CP signifie que le système est toujours cohérent et toujours disponible', false, 2,
 'CP = choix de la cohérence quand la partition frappe — la disponibilité est justement sacrifiée alors.'),
('On peut obtenir C et A simultanément en ajoutant des réplicas', false, 3,
 'Les réplicas ne suppriment pas les partitions — ils en créent d''autres.'),
('CAP distingue les systèmes corrects des systèmes défaillants', false, 4,
 'Tous les systèmes distribués sont concernés : c''est un cadre d''arbitrage, pas un verdict.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Distribué : ce que CAP dit vraiment'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- Distribué : attendre la cohérence éventuelle
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Le contrat éventuel ne garantit pas la lecture fraîche : « lire sa propre écriture » exige une lecture forte', true, 1,
 'Le besoin décide du niveau de cohérence — pas l''inverse.'),
('800 ms de retard prouve une corruption de la donnée répliquée', false, 2,
 'Le retard est le contrat, pas la défaillance : la donnée converge.'),
('La cohérence éventuelle impose une convergence en moins d''une seconde', false, 3,
 '« Éventuellement » ne porte aucun délai — sinon ce serait une garantie forte différée.'),
('Il faut forcer une resynchronisation manuelle des réplicas à chaque lecture', false, 4,
 'Réconcilier à chaque lecture ruine l''objectif même de la réplication en lecture.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Distribué : attendre la cohérence éventuelle'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- Distribué : quorum de lecture et d'écriture
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Élever W et R pour que W + R > N (3 + 3 > 5) : la lecture croise l''écriture, au prix de latence et de débit', true, 1,
 'Le croisement quorum garantit que lecture et dernière écriture se voient — c''est le cœur du réglage.'),
('Descendre W et R à 1 pour que toutes les réponses soient rapides', false, 2,
 'C''est la configuration actuelle : rapide, mais les lectures tombent sur des valeurs anciennes.'),
('Ajouter des réplicas sans toucher aux quorums : le problème disparaît', false, 3,
 'N grandit, W + R non : l''écart s''aggrave encore (W + R > N devient plus difficile).'),
('Fixer R supérieur à N pour interroger plus de réplicas qu''il n''en existe', false, 4,
 'R est borné par N : la valeur n''a aucun sens.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Distribué : quorum de lecture et d''écriture'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- Distribué : choisir la clé de partitionnement
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Hotspot : la date concentre le présent sur un shard — répartir par hash d''id en acceptant de perdre la localité temporelle', true, 1,
 'Le choix de clé arbitre entre équilibre, localité des accès et rééquilibrage.'),
('Le cluster est mal dimensionné : il faut ajouter des nœuds', false, 2,
 'Ajouter des nœuds ne rééquilibre pas une clé qui concentre — le déséquilibre suit le nouveau volume.'),
('Tous les shards doivent recevoir le même volume exact : la clé est secondaire', false, 3,
 'La clé EST la répartition : sans elle, l''égalité n''existe pas.'),
('Répartir les écritures en round-robin dans le temps, sans changer la clé', false, 4,
 'Retarder les écritures pour équilibrer fausse le métier sans corriger la clé.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Distribué : choisir la clé de partitionnement'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- Distribué : sémantiques de livraison des messages
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('« Au moins une fois » + traitement idempotent donne l''effet exactement-une-fois côté métier', true, 1,
 'C''est la combinaison réellement atteignable : le broker livre, le consommateur déduplique.'),
('At-most-once convient aux notifications best-effort, jamais aux écritures comptables', true, 2,
 'La perte est acceptable si l''absence d''effet se remarque ; la facturation ne pardonne rien.'),
('Le transport seul peut garantir exactement une fois de bout en bout, il suffit de l''activer', false, 3,
 'Aucun chemin complet ne l''est : la case ne couvre que le périmètre du broker.'),
('Si le consommateur reçoit un doublon, c''est un bug du broker à corriger', false, 4,
 'La redondance est le contrat du au-moins-une-fois : le doublon est normal, la déduplication vous revient.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Distribué : sémantiques de livraison des messages'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- Distribué : quand le consommateur suit plus lentement
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Diagnostiquer le goulot (traitement, dépendance bornée, rejeux) avant de scaler : le lag croît quand entrée > débit', true, 1,
 'Ajouter des appelants sur une dépendance à quota n''augmente pas le quota — mesurer d''abord.'),
('Toujours ajouter des instances : le lag se résout par la parallélisation', false, 2,
 'Seulement si le traitement est parallélisable et l''aval capable de suivre — sinon on augmente la pression.'),
('Allonger la rétention pour ne rien perdre : le lag se remontera seul', false, 3,
 'La rétention gère la conservation, pas le débit — le retard utilisateur continue de croître.'),
('Vider la file en supprimant les messages les plus anciens', false, 4,
 'Trancher la file détruit la charge utilisateur non servie : perte organisée.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Distribué : quand le consommateur suit plus lentement'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- Distribué : réplication n'est pas sauvegarde
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('La réplication propage aussi les erreurs logiques — il faut sauvegardes horodatées et reprise testée (PITR)', true, 1,
 'Réplication = panne de nœud ; sauvegarde = retour dans le temps avant la corruption.'),
('Les réplicas auraient dû détecter la corruption automatiquement et refuser la copie', false, 2,
 'Ils n''ont aucun moyen de distinguer une écriture légitime d''une erreur applicative.'),
('Trois copies suffisent : la probabilité d''erreur triple est négligeable', false, 3,
 'L''erreur logique est commune aux trois copies : la probabilité ne se divise pas.'),
('Il suffit d''augmenter le nombre de réplicas', false, 4,
 'Copies supplémentaires de la même erreur — le problème change d''échelle, pas de nature.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Distribué : réplication n''est pas sauvegarde'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- Distribué : split-brain pendant une coupure
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Deux primaires concurrents et divergents — trancher par majorité/quorum et fencing contre le zombie', true, 1,
 'Sans majorité, un nœud isolé s''arrête ; le fencing empêche l''ancien primaire de valider au retour.'),
('Les deux côtés continuent d''écrire puis fusionnent automatiquement au retour du lien', false, 2,
 'Fusion de deux états divergents : pertes silencieuses — aucune fusion automatique n''est sûre.'),
('Le nœud isolé doit impérativement rester en écriture pour rester disponible', false, 3,
 'C''est la définition du split-brain accepté : la donnée paie la disponibilité.'),
('À la reconnexion, on garde l''écriture la plus récente par horodatage', false, 4,
 'Les horloges divergent : « le plus récent » n''est pas évaluable, ni sûr.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Distribué : split-brain pendant une coupure'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- Distribué : ce qu'achète un consensus
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Une décision unique et ordonnée même sous partition — au prix des majorités, des élections et d''un leader central', true, 1,
 'Le consensus achète l''unicité des décisions ; il ne supprime ni les pannes ni la latence réseau.'),
('La suppression de toute panne réseau grâce à l''élection automatique', false, 2,
 'L''élection gère la défaillance du leader, pas la partition du réseau — elle peut même la subir.'),
('La garantie qu''aucun nœud ne tombe jamais', false, 3,
 'Les pannes restent le quotidien : le consensus organise la décision malgré elles.'),
('Un gain de débit : le leader répartit la charge d''écriture', false, 4,
 'Le leader CONCENTRE les écritures : c''est souvent le goulot que le consensus installe.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Distribué : ce qu''achète un consensus'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- Distribué : écrire actif-actif en multi-région
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Conflits d''écriture sans ordre global : règles de fusion et réconciliation à porter — ou choisir actif-passif', true, 1,
 'Écriture continue des deux côtés = arbitrage des conflits à assumer (ou renoncer aux deux primaires).'),
('Aucun conflit : les régions appliquent les écritures dans l''ordre chronologique global', false, 2,
 'Il n''existe pas d''horloge globale fiable : l''ordre total n''est pas donné.'),
('Les utilisateurs sont naturellement cloisonnés par région, aucun recoupement possible', false, 3,
 'Voyages, migrations de compte, services machine : les recoupements sont la norme.'),
('Il suffit d''augmenter la fréquence de réplication pour supprimer les conflits', false, 4,
 'La vitesse réduit la fenêtre, jamais l''absence d''ordre — les conflits rares restent des conflits.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Distribué : écrire actif-actif en multi-région'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- Distribué : détecter qu'un nœud est mort
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Un détecteur juge sous incertitude : seuils courts = faux positifs — préférer suspicion adaptative et transitions peu coûteuses', true, 1,
 'Mieux vaut détecter tard que multiplier les promotions intempestives.'),
('Le nœud était réellement défaillant : il faut le redémarrer plus souvent', false, 2,
 'Le cycle victimise un nœud sain : le problème est le jugement, pas le nœud.'),
('Porter le timeout à quelques millisecondes accélère la détection sans effet de bord', false, 3,
 'Plus le seuil est court, plus la charge devient une « panne » — l''agitation empire.'),
('Désactiver les élections et maintenir un primaire permanent', false, 4,
 'Retire la tolérance : la prochaine panne du primaire arrête le système.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Distribué : détecter qu''un nœud est mort'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Saga orchestrée : transactions locales + compensations — disponible et partitionnable, avec états intermédiaires à rendre visibles proprement', true, 1,
 'Le cloud récompense la compensation ; la visibilité des états en vol se traite par conception (statuts, file d''attente, UI).'),
('2PC sans réserve : l''atomicité répartie est gratuite dès que le réseau est correct', false, 2,
 'Le réseau N''EST PAS correct : le 2PC bloque à la panne et ajoute les allers-retours synchrones à chaque écriture.'),
('Les deux mécanismes sont interchangeables : seul le vocabulaire diffère', false, 3,
 'Garanties, disponibilité et modèle d''échec diffèrent radicalement — c''est tout l''arbitrage.'),
('Il suffit de rejouer l''appel en boucle jusqu''à ce que les deux écritures passent', false, 4,
 'Rejouer sans compensation ni idempotence fabrique des états à moitié vrais.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Distribué : 2PC ou saga pour une opération répartie'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- -----------------------------------------------
-- Raisonnements séquentiels (3)
-- -----------------------------------------------

-- Distribué : basculer la primaire en cas de panne
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Confirmer la panne et sa durée — une coupure brève ne mérite pas de bascule', true, 1,
 'Le failover réflexe coûte plus cher que la plupart des coupures courtes.'),
('Choisir la réplique cible en vérifiant son décalage (état à jour, aucune écriture en vol)', true, 2,
 'Promouvoir une réplique en retard = perdre les dernières écritures — pire que la panne.'),
('Promouvoir avec fencing de l''ancien primaire et point de reprise précis', true, 3,
 'Jamais deux primaires : invalider l''ancien AVANT d''élever le nouveau.'),
('Réorienter écriteurs et lecteurs, vérifier intégrité et latence', true, 4,
 'La bascule ne s''achève pas à l''élection : la circulation et les contrôles suivent.'),
('Surveiller en mode dégradé et préparer le retour en réplication (exercice documenté)', true, 5,
 'Le retour anticipé évite de rester dégradé — et se prépare avant d''en avoir besoin.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Distribué : basculer la primaire en cas de panne'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- Distribué : auditer la tolérance aux pannes
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Cartographier dépendances, états partagés et points uniques de passage', true, 1,
 'On ne protège que ce qu''on a repéré : l''inventaire précède le diagnostic.'),
('Pour chaque composant, écrire le scénario de panne concret (réseau, process, région, donnée)', true, 2,
 '« Ça tombe » n''est pas un scénario : réseau lent, OOM et coupure de région n''ont pas les mêmes effets.'),
('Évaluer les mécanismes réellement en place (redondance, timeouts bornés, replis, files)', true, 3,
 'Mesurer ce qui protège aujourd''hui, pas ce qui figure dans l''architecture cible.'),
('Repérer les angles morts (point unique, état non rejouable, bascule jamais testée) et les hiérarchiser', true, 4,
 'Prioriser par risque transforme l''audit en décisions.'),
('Prouver par exercice (failover testé, chaos ciblé) puis planifier les correctifs', true, 5,
 'Non testé = non acquis : l''exercice est la seule preuve d''une tolérance.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Distribué : auditer la tolérance aux pannes'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- Distribué : rétablir des réplications divergées
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Détecter et figer : alerte d''incohérence, arrêt des écritures sur les zones divergées', true, 1,
 'Contenir d''abord : chaque écriture supplémentaire élargit l''écart à réparer.'),
('Établir la source de vérité (règle métier, journal le plus complet, preuves horodatées)', true, 2,
 'Sans arbitre désigné, la réparation choisit son camp au hasard.'),
('Comparer par lot et lister les divergences exactes', true, 3,
 'On ne répare pas ce qu''on n''a pas mesuré : l''inventaire des écarts est l''objet du travail.'),
('Corriger par réécriture contrôlée et traçable (deltas, journal d''application)', true, 4,
 'Réparer de façon auditable permet de reprendre, vérifier et expliquer chaque geste.'),
('Vérifier par contrôles (comptes, sommes, échantillons) puis rétablir le flux', true, 5,
 'La preuve de convergence précède la réouverture — sinon l''écart repart en silence.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Distribué : rétablir des réplications divergées'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- -----------------------------------------------
-- Liens catégories / skills / profiles (idempotents)
-- -----------------------------------------------

INSERT INTO challenge_categories (challenge_id, category_id)
SELECT c.id, cat.id
FROM challenges c, categories cat
WHERE cat.name = 'Distributed Systems'
  AND c.title LIKE 'Distribué %'
  AND NOT EXISTS (SELECT 1 FROM challenge_categories cc WHERE cc.challenge_id = c.id AND cc.category_id = cat.id);

INSERT INTO challenge_skills (challenge_id, skill_id)
SELECT c.id, s.id
FROM challenges c, skills s
WHERE c.title LIKE 'Distribué %'
  AND c.type IN ('PROBLEM_SOLVING', 'SEQUENTIAL_REASONING')
  AND s.name = 'Problem Solving'
  AND NOT EXISTS (SELECT 1 FROM challenge_skills cs WHERE cs.challenge_id = c.id AND cs.skill_id = s.id);

INSERT INTO challenge_profiles (challenge_id, profile_id)
SELECT c.id, p.id
FROM challenges c, profiles p
WHERE p.code = 'DEVELOPER'
  AND c.title LIKE 'Distribué %'
  AND NOT EXISTS (SELECT 1 FROM challenge_profiles cp WHERE cp.challenge_id = c.id AND cp.profile_id = p.id);

-- Vérification rapide attendue : 22 défis Distributed Systems (15/4/3 par type).
-- SELECT c.type, count(*) FROM challenges c WHERE c.title LIKE 'Distribué %' GROUP BY c.type;
