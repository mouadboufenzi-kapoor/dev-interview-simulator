-- ===============================================
-- Catalogue V1 — Profil Développeur — catégories manquantes
-- V25 : System Design (22 défis — 15 QCM, 4 problem-solving,
--       3 raisonnements séquentiels)
-- Idempotent : WHERE NOT EXISTS sur challenges.title (jamais utilisé).
-- Même structure que l'import JSON futur : challenges + challenge_options
--   (content / is_correct / display_order / explanation) + liens
--   categories / skills / profiles.
-- Aucune redondance :
--   - V6 = « Stratégie de cache Cache-Aside » (lecture) et « Requête lente » ;
--   - V18 = partitionnement de TABLE et EXPLAIN (niveau SQL) ;
--   - V23 = nanoservice, latence de bout en bout, SLO chiffrés ;
--   - V24 = clé de sharding, quorum, répliques, reprise de file ;
--   - V20 = rate limiting, pagination, export volumineux, BFF ;
--   - V22 = tests de performance (seuils et métriques de test).
-- ===============================================

INSERT INTO challenges (
    title, type, selection_type, difficulty, context, question,
    explanation, estimated_time_seconds, active, points,
    created_at, updated_at
)
SELECT * FROM (VALUES
('SD : estimer avant de dessiner', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'JUNIOR',
 'Pour concevoir une messagerie, on demande des ordres de grandeur : requêtes par seconde, stockage par jour. Personne n''a de chiffres et personne ne sait par où commencer.',
 'Quelle est la démarche d''estimation attendue ?',
 'Ordres de grandeur à la main levée avec des règles de pouce (1 utilisateur ≈ X messages/jour, taille moyenne, pic ×N) → débit et stockage estimés → comparaison avec des capacités connues → hypothèses listées. L''objectif n''est pas le chiffre exact mais la cohérence : 100 M de messages/jour ≈ 500/s en moyenne, un facteur 5 pour le pic. Estimer d''abord oriente tout le dimensionnement qui suit.',
 140, true, 10, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('SD : politiques de load balancing', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'JUNIOR',
 'Trois instances derrière un load balancer ; chaque instance garde en mémoire le contexte de ses sessions. Le trafic part inégalement et une bascule provoque des pertes de session.',
 'Quelle politique et quel réglage retenir ?',
 'La politique dépend de l''état : round-robin ou least-connections quand les instances sont interchangeables ; l''affinité (sticky) ne compense qu''un état mal placé — elle débalance et rend la bascule dure. La correction structurelle : externaliser l''état (store partagé ou token), instances redevenant interchangeables, et laisser la politique optimiser la charge (least-connections, pondération).',
 140, true, 10, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('SD : vertical ou horizontal', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'JUNIOR',
 'Une base passe de 4 à 32 vCPU ; la facture suit et l''équipe n''a jamais envisagé autre chose que « plus grand ».',
 'Quels critères distinguent les deux voies de montée en charge ?',
 'Vertical : simple, sans changement applicatif, mais plafond matériel, coût croissant et point de panne unique. Horizontal : quasi illimité, redondance possible, mais exige de répartir l''état (sharding, réplication, cohérence) et du code adapté. Le vrai critère : où vit l''état et quel plafond on accepte — monter tant que c''est rentable, découper l''état avant le plafond.',
 140, true, 10, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('SD : l''état externalisé et le statelessness', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Pour ajouter une quatrième instance, l''équipe découvre que sessions, files de travail et uploads vivent dans le répertoire local de chaque machine.',
 'Quel principe d''architecture s''applique ici ?',
 'L''échelle horizontale suppose des instances sans état local : session en store partagé (ou token signé), files sur un broker, fichiers en stockage objet — chaque machine devient remplaçable. L''affinité de session n''est qu''un pansement : elle débalance le trafic et complique la bascule. État local = impossibilité de scaler proprement.',
 150, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('SD : les politiques d''écriture du cache', 'SITUATIONAL_QCM', 'MULTIPLE_CHOICE', 'INTERMEDIATE',
 'Cache-Aside couvre la lecture ; reste l''écriture : la base reste source de vérité mais les invalidations partent en rafale et certaines lectures servent des valeurs anciennes.',
 'Quelles politiques d''écriture du cache existent et que chacune coûte-t-elle ?',
 'Write-through : écriture cache puis base synchrone — cohérence simple, latence d''écriture au prix du cache. Write-back : cache d''abord, flush différé — écriture rapide, mais fenêtre de perte et charge de réconciliation. Write-around : saut du cache à l''écriture — pas d''invalidation, mais première lecture froide. Le choix porte sur le rapport lecture/écriture et la perte tolérée, jamais sur l''habitude.',
 160, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('SD : CDN — fraîcheur, purge et shielding', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Un site met à jour ses visuels ; certains internautes voient l''ancien fichier une journée. L''équipe conclut à un « bug du CDN ».',
 'Qu''explique le comportement et quels leviers maîtriser ?',
 'Le CDN sert sa copie selon le TTL : sans purge ni nommage immuable, l''ancienne version reste servie — ce n''est pas un bug, c''est une fraîcheur non contractualisée. Leviers : TTL différencié par type de ressource, assets versionnés (nom hashé = nouvelle URL, purge inutile), purge ciblée pour l''immuable, en-têtes explicites (Cache-Control), et shielding — le bord n''appelle l''origine qu''une fois.',
 150, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('SD : où vivent les fichiers', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Des images de 8 Mo sont stockées sur le disque du serveur d''application et servies par le backend ; chaque déploiement écrase régulièrement des fichiers.',
 'Quelle architecture pour les fichiers ?',
 'Les fichiers vivent hors des instances : stockage objet (clé, versioning, réplication, accès signé) avec la base ne gardant qu''une référence, et un CDN devant pour le débit de lecture. Les instances redeviennent jetables, le stockage se dimensionne séparément. Le disque local d''une machine est un point de perte garanti ; des BLOB en base grevent la base et ses sauvegardes.',
 150, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('SD : autoscaling — métriques et anti-patterns', 'SITUATIONAL_QCM', 'MULTIPLE_CHOICE', 'INTERMEDIATE',
 'Une autoscaling règle sur le CPU. Pendant une saturation par files d''attente, le CPU reste à 40 % : aucune instance ne monte, la file grossit.',
 'Quels réglages et précautions sont justes ?',
 'La métrique doit mesurer le travail en attente — profondeur/âge des files, requêtes par instance, latence — le CPU n''est qu''un symptôme tardif. Précautions : bornes min/max, stabilisation (éviter les oscillations), réchauffement des nouvelles instances (caches froids), et anticipation sur courbe plutôt que seuil dépassé — l''autoscale qui réagit au pic est déjà en retard.',
 160, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('SD : points uniques de défaillance', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Cartographie : une seule instance de cache partagé, une seule passerelle de paiement, un seul volume derrière trois services. Chaque composant est réputé « fiable ».',
 'Que vaut cette architecture et par quoi la remplacer ?',
 'Chaque point unique est le plafond de disponibilité du système entier (sa probabilité de panne devient la vôtre). Redondance N+1 avec bascule automatique, cluster ou dégradation sans cache, passerelle secondaire en attente, stockage répliqué — et bascules exercées : une redondance jamais testée reste théorique. « Très fiable » ne supprime pas le point unique, ça réduit juste sa fréquence.',
 150, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('SD : générer un fil d''actualité — push ou pull', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Un réseau social doit afficher les publications de ses abonnés. Deux écoles : écrire le fil à la publication (push) ou le calculer à l''affichage (pull).',
 'Comment choisir, et quel mélange est courant ?',
 'Push : lecture instantanée, mais écriture proportionnelle au nombre d''abonnés — coûteux pour les comptes populaires et le stockage. Pull : écriture simple, lecture coûteuse pour ceux qui suivent des milliers de comptes. Mélange classique : push pour les abonnés ordinaires, calcul ciblé (ou cache long) pour les géants. Le critère : distribution des abonnements et rapport lecture/écriture.',
 150, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('SD : SQL ou NoSQL selon le pattern d''accès', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Un catalogue doit garantir des transactions strictes sur les commandes ; l''équipe propose une base documentaire « parce que c''est plus simple à scaler ».',
 'Quel raisonnement est sain ?',
 'On choisit par forme de données et garanties : relations + intégrité + transactions multi-objets → relationnel ; documents bornés, accès par clé, horizontal simple → documentaire ; navigations de relations denses → graphe ; séries → temporel. La plupart des systèmes mélangent : relationnel pour le cœur transactionnel, autre chose à la périphérie. « Plus simple à scaler » ne décide que du volet distribué, pas du modèle.',
 150, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('SD : cache stampede et avalanche', 'SITUATIONAL_QCM', 'MULTIPLE_CHOICE', 'ADVANCED',
 'À 14 h, 200 000 clés de cache expirent au même moment ; la base reçoit 40 000 requêtes/s et s''effondre. Chaque visiteur relance la requête la plus lourde.',
 'Quels phénomènes se produisent et comment les prévenir ?',
 'Avalanche : expiration massive synchrone (TTLs alignés) ; stampede : la même clé relancée par des dizaines de requêtes concurrentes. Prévenir : décalage des TTL (jitter), single-flight (un seul reconstruit, les autres attendent la même promesse), réchauffage avant expiration (refresh-ahead), et protection aval (bornes, file). Sans reconstitution prévue, l''expiration devient un incident.',
 160, true, 20, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('SD : event sourcing — quand et à quel prix', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'ADVANCED',
 'Une équipe veut event-sourcer un module de tarification « pour avoir l''historique complet », alors que la lecture dominante porte sur un état courant simple.',
 'Quand l''event sourcing est-il justifié, et que coûte-t-il ?',
 'Justifié quand l''événement EST le domaine : audit réglementaire, rejeu, projections multiples — on stocke les faits, l''état courant devient une projection. Coût : événements à versionner, projections à reconstruire, lectures par agrégation, complexité opérationnelle. Pour un état courant simple, CRUD + journal d''audit donne l''historique pour une fraction du coût : c''est un choix de modèle, pas un accessoire.',
 160, true, 20, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('SD : la dégradation conçue', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'ADVANCED',
 'Face à une dépendance lente, le site affiche un écran blanc jusqu''au timeout de 30 secondes. Aucune dégradation n''avait été imaginée en conception.',
 'Que dit ce constat et comment le traiter au design ?',
 'La résilience se conçoit : hiérarchiser les parcours (cœur : commander ; périphérie : avis, recommandations), un repli par dépendance (donnée en cache, dernier état connu, fonctionnalité coupée, message explicite), des timeouts courts et une dégradation pilotable (flags). Un écran blanc signifie qu''aucune décision de repli n''a été prise à l''avance : le temps de panne se transforme en temps d''erreur visible.',
 160, true, 20, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('SD : cycles de vie du stockage', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'ADVANCED',
 'Douze ans de données tiennent dans la même table chaude ; 95 % ne sont jamais lues mais coûtent en sauvegarde, en index et en réplication.',
 'Quelle politique structurer ?',
 'Hiérarchie de vie : chaud (actif, indexé, répliqué), tiède (consulté ponctuellement), froid/archives (rétention légale, lecture rare, stockage bon marché). Critères : fréquence d''accès, exigence de restitution (RTO), rétention réglementaire, coût par Go. Outiller la transition et tester les purges — garder tout « au cas où » se paie deux fois chaque jour : stockage ET sauvegarde.',
 160, true, 20, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('SD : concevoir la session d''une application multi-services', 'PROBLEM_SOLVING', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Le front parle à un BFF qui appelle cinq services ; la session doit survivre aux déploiements et rester révocable (déconnexion, rôle retiré). L''équipe hésite entre session serveur, JWT long et cookie.',
 'Décrivez l''architecture de session : qui émit, qui valident, durées, révocation, état partagé.',
 'Architecture : jeton court (minutes) signé, validé par signature et claims (avec cache de révocation court) ; refresh dans un cookie httpOnly/SameSite pour survivre sans stockage côté JavaScript ; révocation réelle via liste courte ou serveur de sessions — le JWT long non révocable est le piège classique ; état de session partagé si sessions serveur (jamais en mémoire d''instance — cf. statelessness) ; rotation du refresh et logout complet côté BFF, le front ne manipulant jamais les jetons de service.',
 900, true, 30, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('SD : absorber le pic d''un lancement', 'PROBLEM_SOLVING', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Une page produit vedette part en promotion : 20× le trafic normal pendant 30 minutes. Le site tient la moyenne ; le pic n''a jamais été testé.',
 'Décrivez la démarche : profil de charge, mesures, leviers par étage, file pour l''écriture rare, pilotage pendant le pic.',
 'Démarche : (1) traduire 20× en chiffres (req/s, débit, latences visées) ; (2) tester représentativement — des services réels chargés, pas un script statique — et relever les goulots ; (3) leviers par étage : cache/CDN sur le statique et le catalogue, bornes sur les endpoints, dégradation du non critique, pool d''instances anticipé ; (4) file d''attente pour les écritures rares (commande) afin de lisser sans perdre ; (5) pendant le pic : tableau de bord (latence, erreurs, profondeur de file), seuils d''arrêt et repli piloté (flags). Mesurer puis sécuriser — jamais l''inverse.',
 900, true, 30, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('SD : compteur distribué de vues', 'PROBLEM_SOLVING', 'SINGLE_CHOICE', 'ADVANCED',
 'Un fil affiche des millions de vues ; incrémenter une ligne par affichage sature la base (verrous sur la ligne chaude). Besoin : affichage à la seconde près, écarts < 1 % tolérés.',
 'Décrivez l''architecture du compteur : agrégation, persistance, point chaud, correction, affichage.',
 'Architecture : agrégation en mémoire par instance (batch toutes les N secondes ou N vues) pour faire effondrer le débit écriture ; persistance par lots (upsert groupé) ou store de compteurs dédié ; hot key combattue par découpage (compteur shardé par plage/région, fusion à l''lecture) ; fenêtres d''écritures contiguës (append) ; affichage via cache court assumé décalé ; réconciliation périodique pour la correction. Le besoin réel n''est pas l''exactitude immédiate mais l''ordre de grandeur à la seconde — dimensionner pour ça.',
 900, true, 30, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('SD : séparer transactionnel et analytique', 'PROBLEM_SOLVING', 'SINGLE_CHOICE', 'ADVANCED',
 'Des rapports analytiques sur des mois de données tournent en concurrence avec les commandes : I/O et verrous se nuisent. L''équipe ajoute des index, sans effet durable.',
 'Décrivez la séparation OLTP/OLAP : flux d''alimentation, modèle cible, isolation des charges, rafraîchissement.',
 'Séparation : le transactionnel conserve son modèle normalisé et sa charge ; l''analytique reçoit sa copie dans son propre magasin (entrepôt ou mart) alimenté en asynchrone (CDC sur le journal, événements, ou extraction planifiée), modélisé pour agrégations (colonnes, mesures pré-calculées). Choix du flux selon le RPO visé (quasi temps réel vs J+1), fraîcheur affichée comme contrat, reprise par rejeu du flux en cas d''incident. Retirer la lecture analytique de l''OLTP traite la cause ; empiler des index ne change pas le modèle.',
 900, true, 30, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('SD : roadmap de scalabilité par paliers', 'SEQUENTIAL_REASONING', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Une plateforme doublera sa base utilisateurs dans l''année ; l''équipe veut une trajectoire de montée en charge ordonnée plutôt qu''une refonte unique.',
 'Place ces étapes dans l''ordre de la trajectoire recommandée.',
 'La trajectoire va des faits au plus engageant : mesurer les goulots réels, sécuriser les points uniques, décharger la lecture (levier le moins risqué), puis répartir l''écriture (le plus transformateur) — et enfin institutionnaliser la mesure pour le palier suivant. Répartir l''état en premier, c''est payer la transformation la plus lourde avant d''avoir les preuves.',
 300, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('SD : introduire un read model CQRS', 'SEQUENTIAL_REASONING', 'SINGLE_CHOICE', 'ADVANCED',
 'Un parcours de lecture agrège six sources et dépasse son objectif de latence ; l''équipe envisage un modèle de lecture dédié.',
 'Place ces étapes dans l''ordre de la mise en place recommandée.',
 'Le CQRS introduit se prouve d''abord : chiffrer le coût de la lecture actuelle, définir la projection et sa fraîcheur contractuelle, construire l''alimentation avec point de reprise, basculer la lecture en double lecture avec comparaison et retour possible, puis opérer (reconstruction à volonté, décalage surveillé). Une projection qu''on ne peut pas reconstruire est un second problème de vérité.',
 360, true, 20, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('SD : réduire la facture cloud sans dégrader les SLO', 'SEQUENTIAL_REASONING', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'La facture d''infrastructure croît de 30 % par an alors que l''usage plafonne ; direction demande des économies sans incident.',
 'Place ces étapes dans l''ordre de la démarche recommandée.',
 'D''abord rendre le coût lisible (par composant et usage réel), puis identifier les dérives (ressources sous-utilisées, stockage et réplication superflu, trafic sortant inutile), hiérarchiser les leviers par gain × risque (right-size, réservations, cache, stockage froid), appliquer par lots sous surveillance des SLO avant/après, et verrouiller les acquis (budgets, alertes de coût, dimensionnement par défaut). Couper sans visibilité paie toujours un incident.',
 300, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
) AS v(title, type, selection_type, difficulty, context, question, explanation, estimated_time_seconds, active, points, created_at, updated_at)
WHERE NOT EXISTS (SELECT 1 FROM challenges c WHERE c.title = v.title);

-- -----------------------------------------------
-- Options des QCM (SINGLE : 1 correcte — MULTIPLE : 2 correctes)
-- -----------------------------------------------

-- SD : estimer avant de dessiner
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Règles de pouce → débit et stockage en ordres de grandeur → hypothèses explicites, avant tout dessin', true, 1,
 'L''estimation oriente le dimensionnement : les hypothèses se vérifient ensuite.'),
('Attendre l''architecture existante pour mesurer précisément', false, 2,
 'Le dimensionnement EST ce qui dessine l''architecture : la boucle est inversée.'),
('Prendre les chiffres d''un concurrent comme cible', false, 3,
 'Jeu d''utilisateurs et profils diffèrent : l''ordre de grandeur se dérive du sien.'),
('Dimensionner pour la moyenne annuelle puis ajuster en production', false, 4,
 'La moyenne ne paie jamais le pic — c''est le pic qui fait tomber le service.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'SD : estimer avant de dessiner'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- SD : politiques de load balancing
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Instances interchangeables : round-robin ou least-connections ; l''affinité ne compense qu''un état mal placé', true, 1,
 'La politique optimise la charge seulement quand rien n''attache les requêtes à une machine.'),
('Toujours l''affinité par IP pour conserver le contexte', false, 2,
 'Elle débalance (un même client, une machine) et complique la bascule — le problème vient d''être traité.'),
('Le round-robin équilibre toujours, quelle que soit la durée des requêtes', false, 3,
 'Des requêtes inégales réparties également donnent une charge inégale.'),
('Choisir la politique la plus simple et ne jamais la revoir', false, 4,
 'La politique répond à un état et à une charge : les deux évoluent.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'SD : politiques de load balancing'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- SD : vertical ou horizontal
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Vertical = plafond et point unique ; horizontal = échelle et redondance contre état à répartir — le choix porte sur l''état', true, 1,
 'Ce qui décide : où vit l''état et quel plafond on accepte.'),
('L''horizontal est toujours préférable : multiplier les instances règle tout', false, 2,
 'Sans répartition de l''état, ajouter des instances ne change ni les verrous ni la cohérence.'),
('Le vertical ne coûte jamais plus cher que la mutualisation', false, 3,
 'La grande machine se paie au prix fort — et reste un point de panne.'),
('Les deux voies sont interchangeables sans changement applicatif', false, 4,
 'Passer à l''horizontal exige répartition, cohérence et code — c''est un projet.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'SD : vertical ou horizontal'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- SD : l'état externalisé et le statelessness
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Externaliser session, files et fichiers pour rendre les instances remplaçables — le sticky ne masque que le problème', true, 1,
 'Instances jetables = échelle et bascule libres ; l''état vit là où il se réplique.'),
('Ajouter l''affinité de session sur le load balancer pour que tout continue de marcher', false, 2,
 'Compense sans corriger : débalancement, bascule difficile, réplication d''état toujours absente.'),
('Synchroniser le répertoire local entre instances toutes les minutes', false, 3,
 'Fenêtre de divergence garantie et contention réseau — de la copie sans contrat.'),
('Conserver l''état local et n''ajouter qu''une seule instance en secours', false, 4,
 'Le secours reprend des états périmés : la redondance reste décorative.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'SD : l''état externalisé et le statelessness'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- SD : les politiques d'écriture du cache
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Write-through paie la latence d''écriture, write-back le risque de perte, write-around la lecture froide', true, 1,
 'Chaque politique achète une garantie avec une autre : le choix porte sur lecture/écriture et perte tolérée.'),
('Le write-through est supérieur aux deux autres en toutes circonstances', false, 2,
 'Sa latence et son débit borné par le cache le disqualifient sur l''écriture intensive.'),
('Le write-back est sans risque si le flush a lieu toutes les secondes', false, 3,
 'La fenêtre d''une seconde reste une fenêtre de perte — la garantie n''existe pas.'),
('Ces politiques ne concernent que les bases, pas les caches applicatifs', false, 4,
 'Elles se déclinent précisément sur les caches — la base n''est que la source de vérité.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'SD : les politiques d''écriture du cache'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- SD : CDN — fraîcheur, purge et shielding
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('TTL contractuel, assets versionnés (nom hashé) et purge ciblée ; le shield borne la charge d''origine', true, 1,
 'Fraîcheur décidée par type de ressource, URLs immuables pour éviter les purges, origine protégée.'),
('Désactiver le CDN partout pour servir toujours l''origine', false, 2,
 'Supprime la latence de bord et remet le débit de lecture sur l''origine — cure pire que le mal.'),
('Attendre l''expiration naturelle du TTL quel que soit le type de ressource', false, 3,
 'Un TTL unique ne sert ni l''immutable (trop long) ni l''éditable (trop court).'),
('Le CDN doit détecter lui-même les changements sur l''origine', false, 4,
 'Aucune détection : il sert sa copie jusqu''à expiration ou purge explicite.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'SD : CDN — fraîcheur, purge et shielding'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- SD : où vivent les fichiers
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Stockage objet + référence en base + CDN en lecture : les instances restent jetables et le débit se dimensionne à part', true, 1,
 'Chaque responsabilité se scale indépendamment ; le déploiement ne détruit plus rien.'),
('Monter le disque de l''instance et le sauvegarder quotidiennement', false, 2,
 'Le disque reste local à la machine : remplacement, plantage ou déploiement = perte.'),
('Stocker les images en BLOB dans la base pour la cohérence transactionnelle', false, 3,
 'Greffe la base, ses sauvegardes et sa réplication — hors usage prévue des BLOB lourds.'),
('Répliquer le répertoire d''uploads manuellement entre les instances', false, 4,
 'Copie non contractuelle : versions divergentes, conflits, aucun service de fichiers.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'SD : où vivent les fichiers'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- SD : autoscaling — métriques et anti-patterns
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Mesurer le travail en attente (profondeur de file, requêtes, latence), borner le pool, réchauffer les nouvelles instances', true, 1,
 'Le travail en attente précède la saturation du CPU — et les bornes évitent la dérive de coût.'),
('Stabilisation et réchauffement : éviter les oscillations et les instances froides qui amplifient le pic', true, 2,
 'Un autoscale nerveux oscille ; une instance froide sert moins au moment où il en faut plus.'),
('Abaisser le seuil CPU à 30 % pour réagir plus tôt', false, 3,
 'Toujours trop tard et trop hors sujet : le CPU n''augmente qu''après la file.'),
('Désactiver les bornes max pour absorber n''importe quel pic', false, 4,
 'La facture et le pool voisin deviennent incontrôlables — le pic remplace le coût par un autre incident.'),
('L''autoscaling règle tous les cas : il suffit de l''activer', false, 5,
 'Sans métrique juste ni réchauffement, il réagit mal ou trop tard.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'SD : autoscaling — métriques et anti-patterns'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- SD : points uniques de défaillance
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Chaque point unique plafonne la disponibilité du tout : redondance N+1 avec bascule testée et dégradation sans cache', true, 1,
 'La panne de l''unique devient la vôtre — d''où la redondance EXERCÉE et le repli.'),
('Le risque est faible tant que chaque élément est fiable', false, 2,
 '« Fiable » réduit la fréquence, pas le plafond : l''unique reste le goulot de la panne.'),
('Ajouter des réplicas sans mécanisme de bascule suffit', false, 3,
 'Un réplica jamais élu ne protège personne : la bascule EST la redondance.'),
('Dupliquer partout double la disponibilité mécaniquement', false, 4,
 'Sans bascule fiable ni absence de point commun, la copie ne compte pas.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'SD : points uniques de défaillance'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- SD : générer un fil d'actualité — push ou pull
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Push pour les comptes ordinaires, calcul ciblé pour les géants : le mélange suit la distribution des abonnements', true, 1,
 'Le cas de figure réel est bimodal : c''est le mélange qui sert les deux.'),
('Toujours calculer à l''affichage : plus simple et tient à tous les volumes', false, 2,
 'La lecture devient O(abonnements) pour chacun — le goulot se déplace vers l''affichage.'),
('Toujours écrire le fil à la publication, quel que soit le nombre d''abonnés', false, 3,
 'Le compte à dix millions d''abonnés écrit dix millions de lignes par publication.'),
('Le choix n''a pas d''impact sur le stockage ni sur l''écriture', false, 4,
 'Il détermine exactement ces deux coûts — c''est tout l''arbitrage.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'SD : générer un fil d''actualité — push ou pull'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- SD : SQL ou NoSQL selon le pattern d'accès
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Choisir par pattern d''accès et garanties : relationnel pour l''intégrité transactionnelle, documentaire/graphe/temporel là où la forme l''exige', true, 1,
 'Les garanties et la forme des accès décident ; « scaler » n''est qu''un critère parmi d''autres.'),
('Prendre du documentaire pour toutes les données : la migration vers l''horizontale est plus simple', false, 2,
 'On abandonne l''intégrité transactionnelle des commandes pour un avantage hypothétique.'),
('Le relationnel ne peut jamais être partitionné à grande échelle', false, 3,
 'Il partitionne très bien (clé/répartition) — le choix se fait sur le modèle, pas sur un mythe.'),
('Une seule base suffit au projet entier : uniformité obligatoire', false, 4,
 'Le mix relationnel + spécialisée est la norme : le mot « uniformité » cache le refus de trancher.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'SD : SQL ou NoSQL selon le pattern d''accès'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- SD : cache stampede et avalanche
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('TTL décalés (jitter), single-flight sur la reconstruction, réchauffage avant expiration', true, 1,
 'Un seul reconstruit, les autres attendent la même promesse — et l''expiration n''est plus collective.'),
('Protéger l''amont : bornes et file pendant la reconstitution, pour que la base tienne', true, 2,
 'Le goulot aval reste le risque : on protège le système au moment de sa vulnérabilité.'),
('Augmenter la taille du cache pour que tout tienne en mémoire', false, 3,
 'Repousse l''échéance sans traiter la synchro des expirations ni la concurrence.'),
('Rejeter les requêtes pendant l''expiration pour laisser respirer la base', false, 4,
 'Transformer un pic de charge en interruption de service : le remède est le dégât.'),
('Porter le TTL à un an : les expirations seront rares', false, 5,
 'Aligne les expirations sur la même année — l''avalanche devient annuel mais double.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'SD : cache stampede et avalanche'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- SD : event sourcing — quand et à quel prix
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Justifié quand les événements sont le domaine (rejeu, audit, projections multiples) ; sinon CRUD + journal d''audit coûte moins cher', true, 1,
 'Le coût de l''événementiel se paie en versioning, projections et rejeu — utile seulement si le rejeu compte.'),
('Toujours préférable : l''historique complet en fait la solution supérieure', false, 2,
 'Un historique s''obtient aussi par journal d''audit — sans refondre les lectures.'),
('Il ne change rien à l''architecture : on remplace des INSERT par des événements', false, 3,
 'Lectures (projections), schéma d''événements et exploitation changent radicalement.'),
('Il n''est jamais justifié : les projections sont trop fragiles', false, 4,
 'Audit réglementaire et multi-projections sont exactement ses terrains de prédilection.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'SD : event sourcing — quand et à quel prix'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- SD : la dégradation conçue
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Hiérarchie des parcours et repli par dépendance (cache, dernier état connu, feature coupée) avec timeouts bornés et flags', true, 1,
 'Chaque dépendance a son scénario de repli — conçu avant la panne, piloté pendant.'),
('Augmenter le timeout global à 60 s pour laisser le temps à la dépendance', false, 2,
 'Plus d''attente = plus d''erreur visible : le site affiche son écran blanc plus longtemps.'),
('Afficher une page d''erreur standard partout : c''est plus cohérent', false, 3,
 'C''est renoncer au cœur du parcours alors que le panier aurait pu fonctionner.'),
('La dégradation s''improvise pendant l''incident : la concevoir figerait les choix', false, 4,
 'L''improvisation pendant la panne coûte exactement ce que l''équipe constate : 30 s de blanc.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'SD : la dégradation conçue'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- SD : cycles de vie du stockage
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Politique par fréquence d''accès, RTO et rétention : chaud/tiède/froid avec transition automatisée et purges testées', true, 1,
 'Chaque palier paie son accès : le chaud coûte cher parce qu''il sert, le froid coûte peu parce qu''il dort.'),
('Conserver tout en chaud : la lecture la plus rapide vaut le coût', false, 2,
 'Index, réplication et sauvegarde de 95 % de données mortes : la fraîcheur paie pour rien.'),
('Supprimer dès que la donnée n''a pas servi depuis 30 jours', false, 3,
 'La rétention légale et les besoins d''audit ignorent la fréquence d''accès.'),
('Archiver manuellement à la fin de chaque année', false, 4,
 'Traitement annuel non testé : ni traçable, ni réversible, ni mesuré.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'SD : cycles de vie du stockage'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- -----------------------------------------------
-- Raisonnements séquentiels (3)
-- -----------------------------------------------

-- SD : roadmap de scalabilité par paliers
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Mesurer le palier réel : goulots par étage (application, base, réseau), pas des prédictions', true, 1,
 'La trajectoire part des faits : le goulot du moment dicte le palier suivant.'),
('Supprimer les points uniques et sécuriser la bascule (redondance testée)', true, 2,
 'Avant de grossir : ce qui casse en unique casse dix fois plus fort en volume.'),
('Décharger la lecture (cache, réplicas, dénormalisation ciblée)', true, 3,
 'Le levier le moins transformateur — souvent il suffit à gagner un palier.'),
('Répartir l''écriture (partitionnement) quand la lecture ne suffit plus', true, 4,
 'Le plus engageant vient en dernier : il exige les preuves des paliers précédents.'),
('Institutionnaliser : observabilité, autoscaling, tests de charge à chaque palier', true, 5,
 'Le palier suivant se mesure en continu — la trajectoire devient une habitude.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'SD : roadmap de scalabilité par paliers'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- SD : introduire un read model CQRS
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Identifier la lecture coûteuse et chiffrer son coût réel (le pourquoi du changement)', true, 1,
 'Sans chiffre du coût actuel, aucun gain du read model ne pourra être prouvé.'),
('Définir la projection cible : contenu et garanties de fraîcheur', true, 2,
 'La fraîcheur contractuelle empêche de découvrir trop tard que le décalage dérange.'),
('Construire l''alimentation (événements/CDC) avec reprise depuis un point de départ', true, 3,
 'Un flux sans reprise laisse un trou — la projection naîtrait incomplète.'),
('Basculer la lecture progressivement (double lecture, comparaison, retour possible)', true, 4,
 'Comparer les deux chemins avant de trancher — et pouvoir revenir.'),
('Opérer : reconstruire la projection à volonté, surveiller décalage et erreurs', true, 5,
 'La reconstruction à volonté est la preuve qu''il n''y a qu''un seul vrai problème de vérité.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'SD : introduire un read model CQRS'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- SD : réduire la facture cloud sans dégrader les SLO
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Répartir le coût par composant et par usage réel (qui consomme quoi, et quand)', true, 1,
 'Sans ventilation, toute économie est une devinette — et se paie en service.'),
('Identifier les dérives : ressources sous-utilisées, stockage/réplication superflu, trafic sortant inutile', true, 2,
 'Les dérives classiques sont mesurables : c''est là que sont les gains rapides.'),
('Hiérarchiser les leviers par gain × risque (right-size, réservations, cache, stockage froid)', true, 3,
 'L''ordre d''attaque suit le rapport gain/risque, pas l''ordre de facilité apparente.'),
('Appliquer par lots, sous surveillance des SLO avant et après chaque lot', true, 4,
 'Chaque lot est réversible et mesuré : la qualité ne paie pas les économies.'),
('Verrouiller : budgets, alertes de coût, dimensionnements par défaut', true, 5,
 'Sans verrou, la facture repart au prochain cycle — l''économie se garde comme un SLO.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'SD : réduire la facture cloud sans dégrader les SLO'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- -----------------------------------------------
-- Liens catégories / skills / profiles (idempotents)
-- -----------------------------------------------

INSERT INTO challenge_categories (challenge_id, category_id)
SELECT c.id, cat.id
FROM challenges c, categories cat
WHERE cat.name = 'System Design'
  AND c.title LIKE 'SD %'
  AND NOT EXISTS (SELECT 1 FROM challenge_categories cc WHERE cc.challenge_id = c.id AND cc.category_id = cat.id);

INSERT INTO challenge_skills (challenge_id, skill_id)
SELECT c.id, s.id
FROM challenges c, skills s
WHERE c.title LIKE 'SD %'
  AND c.type IN ('PROBLEM_SOLVING', 'SEQUENTIAL_REASONING')
  AND s.name = 'Problem Solving'
  AND NOT EXISTS (SELECT 1 FROM challenge_skills cs WHERE cs.challenge_id = c.id AND cs.skill_id = s.id);

INSERT INTO challenge_profiles (challenge_id, profile_id)
SELECT c.id, p.id
FROM challenges c, profiles p
WHERE p.code = 'DEVELOPER'
  AND c.title LIKE 'SD %'
  AND NOT EXISTS (SELECT 1 FROM challenge_profiles cp WHERE cp.challenge_id = c.id AND cp.profile_id = p.id);

-- Vérification rapide attendue : 22 défis System Design (15/4/3 par type).
-- SELECT c.type, count(*) FROM challenges c WHERE c.title LIKE 'SD %' GROUP BY c.type;
