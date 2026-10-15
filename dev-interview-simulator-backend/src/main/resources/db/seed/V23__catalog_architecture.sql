-- ===============================================
-- Catalogue V1 — Profil Développeur — catégories manquantes
-- V23 : Architecture (38 défis — 10 QCM, 5 problem-solving,
--       5 raisonnements séquentiels, 18 étapes réparties sur
--       3 nouveaux scénarios d'architecture)
--   Scénarios : Design a Real-Time Collaborative Editor (6 étapes)
--               Design a Multi-Channel Notification Platform (6 étapes)
--               Design a Ride-Sharing Matching Service (6 étapes)
-- Idempotent : WHERE NOT EXISTS sur interview_scenarios.title
--   et challenges.title (jamais utilisés), UPDATE borné à scenario_id NULL.
-- Modèle identique à V8 (scenario_id + step_order + revealed_information
--   + tradeoff) : compatible avec le futur import JSON.
-- Aucune redondance avec V6/V8/V16-V22 : BFF, SSE/polling, IDOR
--   multi-tenant, incident en cascade et idempotence HTTP sont en V20 ;
--   la réservation atomique de stock est en V8 (étape Ride ≠ réservation,
--   elle traite l'ordre des positions).
-- ===============================================

-- -----------------------------------------------
-- 3 nouveaux scénarios
-- -----------------------------------------------

INSERT INTO interview_scenarios (title, description, mode, active)
SELECT * FROM (VALUES
('Design a Real-Time Collaborative Editor',
 'Conçois progressivement un éditeur de documents collaboratif temps réel (rédaction simultanée, présence, partage).',
 'ARCHITECTURE', TRUE),
('Design a Multi-Channel Notification Platform',
 'Conçois progressivement une plateforme de notifications multi-canaux (push, e-mail, SMS), transactionnelles et de masse.',
 'ARCHITECTURE', TRUE),
('Design a Ride-Sharing Matching Service',
 'Conçois progressivement un service de mise en relation passagers et chauffeurs (géolocalisation, matching, tarification).',
 'ARCHITECTURE', TRUE)
) AS v(title, description, mode, active)
WHERE NOT EXISTS (SELECT 1 FROM interview_scenarios s WHERE s.title = v.title);

-- -----------------------------------------------
-- 18 étapes d'architecture (rattachées ensuite par UPDATE idempotent)
-- -----------------------------------------------

INSERT INTO challenges (
    title, type, selection_type, difficulty, context, question,
    revealed_information, tradeoff, explanation,
    estimated_time_seconds, active, points, scenario_id, step_order,
    created_at, updated_at
)
SELECT * FROM (VALUES
('EditDoc - Architecture générale', 'ARCHITECTURE', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Tu conçois un éditeur de documents où plusieurs utilisateurs modifient le même texte en même temps, avec présence et partage.',
 'Quel découpage initial proposes-tu pour les responsabilités du système ?',
 'Les écritures sont fréquentes et petites, la lecture d''historique est rare, le partage change peu mais doit être immédiat.',
 'Découper synchronisation et documents isole le critique, au prix d''un contrat explicite entre les deux pour chaque mutation.',
 'Séparer document (stockage, versions), synchronisation temps réel (mutations, diffusion), présence (sessions) et partage/permissions : chaque responsabilité évolue à son rythme, et le chemin critique de l''édition n''emporte ni l''historique ni les exports.',
 180, TRUE, 20, NULL::bigint, NULL::int, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('EditDoc - Conflits d''édition concurrente', 'ARCHITECTURE', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Deux utilisateurs saisissent dans le même paragraphe à la même seconde ; la version serveur unique rejette l''un des deux.',
 'Quelle approche de résolution des conflits adoptes-tu, et à quel prix ?',
 'Les éditions sont courtes, le curseur et le texte doivent rester alignés, et la reconnexion est fréquente.',
 'La transformation des opérations conserve la saisie sans blocage mais impose un protocole strict ; le verrouillage est plus simple mais dégrade l''expérience.',
 'Transformer ou composer les opérations (insertion/suppression) permet d''appliquer chaque édition dans l''ordre arbitré par le serveur sans perdre de frappe : la sémantique du texte devient le contrat. Le verrou de blocage est plus simple à implémenter mais fige le second éditeur.',
 180, TRUE, 20, NULL::bigint, NULL::int, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('EditDoc - Persistance et récupération', 'ARCHITECTURE', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Les mutations arrivent en continu ; relire un document de 5 000 révisions en rejetant tout le journal devient lent.',
 'Quel schéma de persistance proposes-tu ?',
 'Le document courant est lu à chaque ouverture ; les anciennes révisions sont consultées ponctuellement.',
 'Instantanés périodiques + journal = écriture bornée et lecture rapide, au prix d''une logique de reconstruction à tester.',
 'Sauvegarder un instantané périodique et ne conserver actif que le journal depuis : la reconstruction applique les deltas récents sur le point de départ — temps borné quel que soit l''âge. Le journal intégral reste pour l''historique, mais hors du chemin chaud.',
 150, TRUE, 20, NULL::bigint, NULL::int, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('EditDoc - Présence et diffusion', 'ARCHITECTURE', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'La liste des utilisateurs connectés et leurs curseurs doivent se mettre à jour en continu pour des centaines de sessions sur un même document.',
 'Comment organiser présence et diffusion des curseurs sans saturer la base ?',
 'Les positions de curseur changent plusieurs fois par seconde ; elles n''ont pas besoin d''être durcies en base.',
 'La diffusion en mémoire côté nœud de session est très rapide mais nécessite une répartition stable des sessions par document.',
 'Tenir l''état volatile là où il vit : sessions et curseurs sur le nœud qui détient les sessions du document (répartition par identifiant de document), persistance réservée aux événements utiles (arrivée/départ). La propagation suit le même canal que les éditions — le fanout reste par document.',
 180, TRUE, 20, NULL::bigint, NULL::int, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('EditDoc - Partage pendant l''édition', 'ARCHITECTURE', 'SINGLE_CHOICE', 'ADVANCED',
 'Le propriétaire retire l''accès d''un utilisateur alors que celui-ci a le document ouvert et une connexion active.',
 'Comment faire respecter immédiatement le retrait de permission ?',
 'Les permissions sont stockées côté service partage ; le flux d''édition est déjà ouvert et authentifié.',
 'Révoquer côté diffusion est immédiat pour les sessions ouvertes mais ajoute un contrôle à chaud sur chaque message.',
 'La révocation agit sur deux horizons : refuser toute requête suivante (autorisation vérifiée à chaque requête) et résilier les sessions ouvertes (signal du service partage vers les nœuds de diffusion). Une permission vérifiée seulement à l''ouverture laisse une fenêtre ouverte jusqu''au rechargement.',
 180, TRUE, 20, NULL::bigint, NULL::int, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('EditDoc - Reconnexion et décalage', 'ARCHITECTURE', 'SINGLE_CHOICE', 'ADVANCED',
 'Un utilisateur hors ligne édite 40 secondes puis se reconnecte : ses opérations locales datent d''un état ancien du document.',
 'Comment réconcilier l''état du client reconnecté ?',
 'Les autres ont continué d''éditer pendant l''absence ; les opérations locales sont numérotées par rapport à un ancien point de vue.',
 'Le rejeu avec numéros de séquence est précis mais exige que chaque opération porte son contexte ; recharger en pousse le contenu du serveur simplifie mais perd les saisies locales non reçues.',
 'Client et serveur échangent leurs points de séquence : le client rejoue ses opérations manquantes dans l''ordre (idempotentes, dédupliquées côté serveur) et réapplique celles reçues — écart fermé sans écrasement. Le simple rechargement abandonne les saisies hors ligne.',
 180, TRUE, 20, NULL::bigint, NULL::int, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Notify - Architecture générale', 'ARCHITECTURE', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Tu conçois une plateforme qui reçoit des événements métier et les transforme en notifications push, e-mail et SMS.',
 'Quel découpage initial proposes-tu ?',
 'Les envois viennent de dizaines de services, les canaux ont des contrats fournisseurs différents, les destinataires définissent leurs préférences.',
 'Séparer ingestion, orchestration et canaux rend chaque partie indépendante mais multiplie les contrats internes à maintenir.',
 'Ingestion (API + file), orchestration (règles, préférences, rendu), adaptateurs de canaux et suivi (statuts) : les services métier ne connaissent que l''entrée, les fournisseurs restent interchangeables derrière leur adaptateur.',
 180, TRUE, 20, NULL::bigint, NULL::int, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Notify - Cloisonnement des classes de trafic', 'ARCHITECTURE', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Un envoi marketing de masse ralentit l''envoi des codes de vérification par SMS, provoquant des expirations.',
 'Comment structurer l''acheminement pour protéger le transactionnel ?',
 'Le marketing absorbe des pics prévisibles ; le transactionnel exige une latence stable à toute heure.',
 'Files et concurrences dédiées garantissent la priorité mais multiplient les opérations à surveiller.',
 'Isoler les classes de trafic (transactionnel vs campagne) dans des files et budgets de concurrence distincts : un pic marketing ne peut pas consommer la capacité du transactionnel. La priorité ne se décrète pas dans une file unique — elle se structure.',
 150, TRUE, 20, NULL::bigint, NULL::int, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Notify - Limitation de débit chez les fournisseurs', 'ARCHITECTURE', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Le fournisseur SMS autorise 100 requêtes/s ; une campagne parallèle reçoit des 429 et perd des messages.',
 'Quel mécanisme mets-tu en place ?',
 'Plusieurs services consomment le même compte fournisseur ; les fenêtres de quota sont glissantes.',
 'Le quota partagé côté plateforme évite les rejets fournisseur mais exige un compteur fiable et distribué.',
 'Un limiteur de débit global par compte (fenêtre glissante, compteur partagé) appliqué avant l''appel : la capacité réelle devient un budget géré, avec attente ou rejet maîtrisé au-delà — jamais des 429 perdus en vol.',
 150, TRUE, 20, NULL::bigint, NULL::int, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Notify - Ordonnancement par destinataire', 'ARCHITECTURE', 'SINGLE_CHOICE', 'INTERMEDIATE',
 '« Bienvenue » arrive après « Mot de passe modifié » chez un nouvel inscrit ; les messages d''une même série se croisent.',
 'Comment garantir un ordre utile au destinataire sans globaliser la plateforme ?',
 'L''ordre n''importe que pour un même destinataire (ou agrégat) ; les destinataires sont indépendants les uns des autres.',
 'La clé de partitionnement garantit l''ordre par partition, mais l''équilibre des files devient sensible aux destinataires chauds.',
 'Router par clé de destinataire et traiter chaque partition séquentiellement : l''ordre est garanti là où il compte, la parallélisation entre destinataires reste totale. Une file globale sacrifierait l''échelle ; aucune garantie livrerait des séquences incohérentes.',
 180, TRUE, 20, NULL::bigint, NULL::int, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Notify - Préférences et opt-out effectif', 'ARCHITECTURE', 'SINGLE_CHOICE', 'ADVANCED',
 'Un destinataire se désabonne ; il reçoit encore deux notifications marketing, envoyées par un service qui a mis en cache ses préférences.',
 'Comment rendre l''opt-out immédiat et vérifiable ?',
 'Les préférences sont centrales ; des dizaines de services les lisent avec leur propre cache.',
 'La propagation par événement est rapide et découpée mais exige idempotence et réconciliation périodique.',
 'La préférence vit en un seul endroit, publiée par événement ; chaque émetteur l''applique à la volée et l''orchestrateur revérifie côté autorité juste avant l''envoi. Un journal d''envoi auditable rend l''opt-out prouvable — pas seulement voulu.',
 180, TRUE, 20, NULL::bigint, NULL::int, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Notify - Passage à l''échelle d''une campagne', 'ARCHITECTURE', 'SINGLE_CHOICE', 'ADVANCED',
 'Une campagne à 2 millions de destinataires est programmée ; le rendu personnalisé et l''envoi approchent de la capacité du pic quotidien.',
 'Comment absorber le pic sans dégrader le transactionnel ?',
 'Le pic est annoncé à l''avance ; le transactionnel doit rester intact ; les fournisseurs limitent les débits.',
 'Pré-calcul et lissage coûtent en complexité mais transforment le pic en planure ; le pilotage en réaction pure arrive trop tard.',
 'Pré-calculer et mettre en cache le rendu en amont, répartir l''envoi dans le temps sous un seuil de débit, monter les workers en anticipation et réserver une capacité protégée au transactionnel — le tout piloté par rétroaction (lag de file, taux de rejet) pour ralentir proprement.',
 180, TRUE, 20, NULL::bigint, NULL::int, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Ride - Architecture générale', 'ARCHITECTURE', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Tu conçois un service de VTC : les passagers demandent une course, les chauffeurs sont en mouvement, le prix est estimé puis confirmé.',
 'Quel découpage initial proposes-tu ?',
 'Les positions arrivent en continu, le matching est ultra-critique, l''historique de course se lit rarement.',
 'Séparer localisation, matching et cours est coûteux en appels mais permet de faire évoluer le critique indépendamment.',
 'Localisation (positions, index), matching (candidature, attribution), cours (état, vie, historique), tarification (estimation, calcul final) : le matching a des exigences de latence et de charge incompatibles avec le flux GPS massif.',
 180, TRUE, 20, NULL::bigint, NULL::int, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Ride - Indexation des positions', 'ARCHITECTURE', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Trouver les 5 chauffeurs les plus proches parmi des centaines de milliers de positions fraîches prend plusieurs centaines de millisecondes.',
 'Quelle structure de recherche adopts-tu ?',
 'Le rayon est de quelques kilomètres ; une position vieillit après quelques secondes ; les zones denses concentrent l''essentiel du trafic.',
 'Le partitionnement géographique accélère radicalement le rayon mais impose de gérer les cellules limitrophes et l''équilibre de charge.',
 'Un index géographique (grille ou geohash) sur l''état courant, agrégé par cellule, avec lecture des cellules voisines : la recherche devient locale et bornée. La fraîcheur compte autant que la structure — une cellule exacte remplie de positions mortes récupère les mauvais chauffeurs.',
 150, TRUE, 20, NULL::bigint, NULL::int, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Ride - Politique de matching', 'ARCHITECTURE', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Deux passagers éligibles et peu de chauffeurs : attribuer systématiquement au plus proche crée des détours qui font fuir les autres.',
 'Quelle logique d''attribution construis-tu ?',
 'Le temps d''attente perçu prime ; les détours de deux minutes sont tolérés ; le taux d''acceptation chauffeur compte dans l''équilibre.',
 'Un score composite équilibre l''expérience mais complexifie le réglage et le débogage des attributions.',
 'Un score composite (détour accepté, temps estimé, fiabilité du chauffeur, offre/demande locale) dans une fenêtre de candidature bornée : on optimise la zone, pas chaque course isolée, et on n''attend jamais indéfiniment l''idéal pendant que la demande se dégrade.',
 180, TRUE, 20, NULL::bigint, NULL::int, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Ride - Positions hors séquence', 'ARCHITECTURE', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Les positions GPS arrivent hors ordre à cause du réseau ; une position ancienne remplace la position courante et le chauffeur « recule » de 800 m.',
 'Comment défendre l''état de position contre les mises à jour désordonnées ?',
 'Chaque relevé porte l''horloge du dispositif ; les retards réseau atteignent parfois plusieurs secondes.',
 'Les numéros de séquence par producteur sont simples et exacts mais exigent que chaque source joue le jeu (reprise après redémarrage).',
 'Marquer chaque relevé d''un numéro de séquence par producteur et n''accepter que les plus récents : l''état n''avance jamais en arrière, et un rejeu n''ré-applique jamais une position déjà absorbée. C''est la même discipline que l''idempotence, appliquée à un flux de positions.',
 180, TRUE, 20, NULL::bigint, NULL::int, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Ride - Estimation et tarif', 'ARCHITECTURE', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'L''estimation affichée au passager diffère de 30 % du tarif final facturé ; les réclamations augmentent.',
 'Comment fiabiliser estimation et tarif final ?',
 'L''estimation précède la course ; le tarif final dépend du trajet réel et des conditions du moment ; la tarification dynamique s''applique par zones.',
 'Un calcul déterministe et versionné est auditable mais limite l''ajustement en temps réel sans nouvelle version.',
 'Un moteur de tarif versionné et déterministe : estimation et finalisation partagent les mêmes règles (zone, horaire, trajet), la finalisation ré-appliquant avec les données réelles. Tout écart non justifié et non tracé est un défaut, pas une fatalité.',
 150, TRUE, 20, NULL::bigint, NULL::int, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Ride - Reprise après perte du chauffeur', 'ARCHITECTURE', 'SINGLE_CHOICE', 'ADVANCED',
 'Un chauffeur en course perd le réseau 90 secondes ; à la reconnexion, ses positions, l''état de course et la facturation divergent.',
 'Comment orchestrer la reprise sans fausser l''état de course ?',
 'La course est modifiable des deux côtés (passager et chauffeur) ; la facturation se finalise à l''arrivée ; les messages de statut peuvent être rejoués.',
 'La reprise par rejeu idempotent garantit la cohérence mais exige que chaque événement porte son état versionné.',
 'Réconcilier par rejeu : le client republie ses événements (positions, statuts) idempotents avec numéros de séquence, le serveur répond par l''état de course versionné ; la facturation ne se finalise que sur preuve d''arrivée. On reconstruit l''intervalle manquant — on ne le devine pas.',
 180, TRUE, 20, NULL::bigint, NULL::int, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
) AS v(title, type, selection_type, difficulty, context, question, revealed_information, tradeoff, explanation, estimated_time_seconds, active, points, scenario_id, step_order, created_at, updated_at)
WHERE NOT EXISTS (SELECT 1 FROM challenges c WHERE c.title = v.title);

-- Rattachement idempotent des étapes à leur scénario

UPDATE challenges c
SET scenario_id = s.id, step_order = v.step_no
FROM interview_scenarios s,
(VALUES
('EditDoc - Architecture générale', 1),
('EditDoc - Conflits d''édition concurrente', 2),
('EditDoc - Persistance et récupération', 3),
('EditDoc - Présence et diffusion', 4),
('EditDoc - Partage pendant l''édition', 5),
('EditDoc - Reconnexion et décalage', 6)
) AS v(title, step_no)
WHERE s.title = 'Design a Real-Time Collaborative Editor'
  AND c.title = v.title
  AND c.scenario_id IS NULL;

UPDATE challenges c
SET scenario_id = s.id, step_order = v.step_no
FROM interview_scenarios s,
(VALUES
('Notify - Architecture générale', 1),
('Notify - Cloisonnement des classes de trafic', 2),
('Notify - Limitation de débit chez les fournisseurs', 3),
('Notify - Ordonnancement par destinataire', 4),
('Notify - Préférences et opt-out effectif', 5),
('Notify - Passage à l''échelle d''une campagne', 6)
) AS v(title, step_no)
WHERE s.title = 'Design a Multi-Channel Notification Platform'
  AND c.title = v.title
  AND c.scenario_id IS NULL;

UPDATE challenges c
SET scenario_id = s.id, step_order = v.step_no
FROM interview_scenarios s,
(VALUES
('Ride - Architecture générale', 1),
('Ride - Indexation des positions', 2),
('Ride - Politique de matching', 3),
('Ride - Positions hors séquence', 4),
('Ride - Estimation et tarif', 5),
('Ride - Reprise après perte du chauffeur', 6)
) AS v(title, step_no)
WHERE s.title = 'Design a Ride-Sharing Matching Service'
  AND c.title = v.title
  AND c.scenario_id IS NULL;

-- -----------------------------------------------
-- Options des étapes d'architecture (1 correcte, 2 distracteurs)
-- -----------------------------------------------

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Séparer document, synchronisation temps réel, présence et partage en responsabilités dédiées', true, 1,
 'Le chemin critique de l''édition est isolé ; chaque responsabilité évolue à son rythme.'),
('Traiter édition, présence et permissions dans un seul service unifié', false, 2,
 'Le service critique devient le goulot : une panne de présence arrête l''édition.'),
('Stocker tout en base relationnelle et diffuser les changements par interrogation périodique', false, 3,
 'Le modèle tabulaire convient mal aux mutations fines, et le polling tue le temps réel.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'EditDoc - Architecture générale'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Transformer ou composer les opérations d''édition pour qu''elles convergent sans blocage', true, 1,
 'Le serveur arbitre l''ordre ; chaque client réapplique ses opérations transformées — aucune frappe perdue.'),
('Verrouiller le paragraphe pendant la saisie d''un utilisateur', false, 2,
 'Bloquant : le second éditeur attend, et les verrous multi-documents deviennent un casse-tête.'),
('Garder la dernière sauvegarde serveur et écraser les saisies concurrentes', false, 3,
 'Perte de données silencieuse : une des deux frappes disparaît sans prévenir.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'EditDoc - Conflits d''édition concurrente'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Instantanés périodiques + journal des mutations depuis le dernier instantané', true, 1,
 'La reconstruction ne rejoue que les deltas récents : lecture bornée quel que soit l''âge.'),
('Rejouer l''intégralité du journal de révisions à chaque ouverture', false, 2,
 'Le temps croît avec l''âge du document : ingérable au bout de quelques milliers de révisions.'),
('Ne garder que le document courant, sans historique', false, 3,
 'Perte des révisions et impossibilité de récupérer après corruption ou erreur utilisateur.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'EditDoc - Persistance et récupération'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Tenir la présence en mémoire sur le nœud qui détient les sessions du document, sans la persister', true, 1,
 'État volatile traité là où il vit : ni charge de base, ni écritures sans valeur.'),
('Persister chaque position de curseur en base et diffuser par interrogation', false, 2,
 'Saturation garantie : des dizaines d''écritures par seconde et par curseur pour rien.'),
('Diffuser les curseurs par un bus global multi-documents', false, 3,
 'Le fanout mondial explose en volume alors que seuls les abonnés du document sont concernés.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'EditDoc - Présence et diffusion'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Contrôler l''autorisation à chaque requête ET résilier les sessions ouvertes à la révocation', true, 1,
 'Deux horizons couverts : les nouvelles requêtes et les connexions déjà établies.'),
('Vérifier la permission uniquement à l''ouverture du document', false, 2,
 'Fenêtre de risque : l''accès retiré reste actif jusqu''au rechargement — ou indéfiniment.'),
('Attendre la déconnexion naturelle de l''utilisateur pour appliquer le retrait', false, 3,
 'Aucun délai garanti : la révocation n''en est plus une.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'EditDoc - Partage pendant l''édition'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Échanger les points de séquence, rejouer les opérations locales dans l''ordre et dédupliquer côté serveur', true, 1,
 'Reprise sans perte : chaque mutation porte son contexte et le serveur arbitre l''ordre.'),
('Recharger le document serveur et abandonner les saisies locales', false, 2,
 'Simple mais destructeur : tout le travail hors ligne disparaît.'),
('Réappliquer les saisies locales en écrasant l''état du serveur', false, 3,
 'Écrase le travail des autres : deux vérités concurrentes sans arbitre.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'EditDoc - Reconnexion et décalage'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Ingestion, orchestration (règles/préférences/rendu), adaptateurs de canaux et suivi séparés', true, 1,
 'Les producteurs ne connaissent que l''API d''entrée ; les fournisseurs restent interchangeables.'),
('Un service par fournisseur que chaque équipe appelle directement', false, 2,
 'La logique métier se disperse chez les adaptateurs : changer de fournisseur devient un projet par équipe.'),
('Envoyer les notifications en synchrone depuis les services métier', false, 3,
 'La panne d''un fournisseur remonte chez le producteur : couplage direct et latence de bout en bout.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Notify - Architecture générale'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Files et budgets de concurrence distincts par classe, transactionnel protégé', true, 1,
 'Un pic de campagne ne consomme pas la capacité du SMS critique.'),
('Une seule file ordonnée par date d''envoi', false, 2,
 'Le FIFO n''a aucune notion de gravité : les codes de vérification s''empilent derrière la campagne.'),
('Traiter d''abord la campagne pour vider le plus gros volume', false, 3,
 'Prioriser le volumineux reproduit exactement l''incident décrit.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Notify - Cloisonnement des classes de trafic'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Limiteur de débit partagé par compte (fenêtre glissante) avec file d''attente au-delà du quota', true, 1,
 'Le quota devient un budget géré : au-delà, on attend au lieu de perdre les messages.'),
('Laisser chaque service gérer ses propres tentatives en cas de 429', false, 2,
 'Chacun retente sur le même quota : aggravation et pertes sont garanties.'),
('Fractionner la campagne en blocs plus petits pour passer sous la détection', false, 3,
 'Le quota est un débit, pas un volume : découper ne change rien au rejet.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Notify - Limitation de débit chez les fournisseurs'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Router par clé de destinataire et traiter chaque partition séquentiellement', true, 1,
 'Ordre garanti par destinataire, parallélisme entre destinataires — l''ordre là où il compte.'),
('Une file globale traitée par ordre d''arrivée', false, 2,
 'Le séquentiel global empêche la montée en charge : la file devient le goulot.'),
('Aucune garantie d''ordre : le destinataire déduira le sens de la séquence', false, 3,
 'Impossible à reconstituer côté utilisateur : les séquences arrivent absurdes.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Notify - Ordonnancement par destinataire'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Préférence en source unique publiée par événement + revérification avant envoi côté orchestrateur', true, 1,
 'Toute écriture part immédiatement ; le dernier échelon tranche toujours sur la source de vérité.'),
('Chaque service relit les préférences une fois par jour en traitement de fond', false, 2,
 'Jusqu''à 24 h d''envois après opt-out : faute de consentement, pas détail technique.'),
('Faire confiance au cache local de chaque producteur', false, 3,
 'Le cache local est précisément la donnée périmée : il propage l''erreur au lieu de la corriger.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Notify - Préférences et opt-out effectif'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Pré-calcul du rendu, lissage de l''envoi dans le temps et capacité réservée au transactionnel, pilotés par rétroaction', true, 1,
 'Le pic devient une planure maîtrisée ; le transactionnel garde sa garantie.'),
('Lancer la campagne en rafale dès minuit pour finir vite', false, 2,
 'La rafale frappe le quota fournisseur et la file transactionnelle en même temps.'),
('Ajouter des serveurs au moment où la file explose', false, 3,
 'La réaction arrive après le dégât : le montage des capacités a un délai.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Notify - Passage à l''échelle d''une campagne'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Séparer localisation, matching, cours et tarification selon leurs exigences propres', true, 1,
 'Le matching (critique, latence) évolue sans tirer le reste — et réciproquement.'),
('Un seul service « courses » qui reçoit aussi les positions GPS', false, 2,
 'Le flux GPS massif sature le service métier : deux rythmes de charge incompatibles.'),
('Traiter le matching par lots toutes les minutes', false, 3,
 'Latence d''attribution inacceptable : le passager attend, le chauffeur tourne.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Ride - Architecture générale'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Index géographique par cellule (grille/geohash) avec TTL sur l''état courant et lecture des cellules voisines', true, 1,
 'Recherche locale bornée et fraîcheur garantie : ni scan de distance, ni positions fantômes.'),
('Un index de distance sur toutes les positions avec tri complet', false, 2,
 'Coût croissant avec le parc total — exactement le goulot constaté.'),
('Interroger les chauffeurs connectés un par un pour leur position', false, 3,
 'Le réseau devient le goulot : des milliers d''allers-retours par recherche.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Ride - Indexation des positions'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Attribuer par score composite dans une fenêtre de candidature bornée', true, 1,
 'Équilibre détour, attente et fiabilité à l''échelle de la zone, avec un plafond de délai.'),
('Toujours attribuer au chauffeur géographiquement le plus proche', false, 2,
 'Optimisation locale myope : détours en cascade et refus répétés aux heures de pointe.'),
('Laisser les chauffeurs choisir librement la course la plus attractive', false, 3,
 'Effet de cortège : les bonnes courses partent en une seconde, le reste n''a jamais preneur.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Ride - Politique de matching'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Numéro de séquence par producteur : ignorer les relevés plus anciens, idempotence sur rejeu', true, 1,
 'L''état n''avance jamais en arrière et un rejeu ne ré-applique jamais une position déjà absorbée.'),
('Appliquer chaque position reçue dans l''ordre d''arrivée réseau', false, 2,
 'L''ordre réseau n''est pas l''ordre du monde : le retard est le cas normal.'),
('Écraser la position courante quelle que soit sa date', false, 3,
 'Une position périmée régnera au moindre trou du réseau.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Ride - Positions hors séquence'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Moteur de tarif versionné et partagé estimation/finalisation, écarts tracés et justifiés', true, 1,
 'Une seule source de règles : l''écart devient explicable ligne à ligne.'),
('Un tarif final recalculé librement par le chauffeur en fin de course', false, 2,
 'Aucune redevabilité : la confiance client meurt avec l''arbitraire.'),
('Deux implémentations distinctes : estimation côté application, tarif côté facturation', false, 3,
 'Double vérité : les écarts structurels sont programmés.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Ride - Estimation et tarif'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Réconciliation par rejeu idempotent d''événements versionnés, finalisation sur preuve d''arrivée', true, 1,
 'Rien n''est supposé : l''état manquant est reconstruit et la facturation attend la preuve.'),
('Interrompre la course et la facturer au dernier état reçu', false, 2,
 'Punit la zone blanche réseau : la course était pourtant valide et facturable.'),
('Rejouer les messages dans l''ordre de la file sans contrôle d''idempotence', false, 3,
 'Les rejeux dupliquent statuts et périmètres : course ou facturation faussées.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Ride - Reprise après perte du chauffeur'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- -----------------------------------------------
-- QCM (10) et problem-solving (5) de la catégorie Architecture
-- -----------------------------------------------

INSERT INTO challenges (
    title, type, selection_type, difficulty, context, question,
    explanation, estimated_time_seconds, active, points,
    created_at, updated_at
)
SELECT * FROM (VALUES
('Architecture : le monolithe modulaire d''abord', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'JUNIOR',
 'Une équipe de 6 personnes lance un produit à périmètre encore flottant. Un architecte propose d''emblée 9 microservices « pour ne pas se retrouver bloqués plus tard ».',
 'Quelle position est la plus sage ?',
 'Un monolithe modulaire bien borné (modules par domaine, frontières strictes, déploiement unique) offre la simplicité opérationnelle là où l''équipe est petite et le périmètre incertain — les frontières se déplacent encore. Les microservices paient un dividende quand la coordination l''exige (équipes multiples, SLA distincts, charges différenciées) — pas par anticipation.',
 130, true, 10, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Architecture : découper par domaine ou par couche', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'JUNIOR',
 'L''équipe organise le code et les déploiements en couches : une équipe « contrôleurs », une « services », une « base ». Chaque évolution métier réclame trois validations et trois allers-retours.',
 'Quel découpage sert mieux l''évolution métier ?',
 'Organiser par domaine (silo vertical, une équipe responsable de bout en bout de son périmètre) supprime les allers-retours : l''évolution se règle à l''intérieur d''une frontière. Les couches restent des conventions internes, pas des unités de possession — sinon chaque feature traverse toute l''organisation.',
 130, true, 10, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Architecture : la direction de la dépendance', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Le code métier importe les annotations du framework web et les types de l''ORM ; les tests du cœur exigent désormais une base et un serveur HTTP pour démarrer.',
 'Quel principe de dépendance s''applique ici ?',
 'La dépendance doit pointer vers l''intérieur stable : le domaine définit ses ports, l''infrastructure les implémente. Quand le domaine dépend du framework, tester exige le framework, remplacer l''outillage coûte tout le code métier, et la volatilité de l''outillage contamine le cœur.',
 150, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Architecture : deux modèles pour un même mot', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 '« Compte » signifie le dossier facturation dans la facturation, le profil public dans le social et l''identité de connexion dans l''authentification. Trois équipes « partagent » l''entité Compte.',
 'Quelle approche de modélisation tranche ce conflit ?',
 'Contextes bornés : chaque domaine porte son propre modèle du mot, traduit explicitement aux frontières. Forcer un Compte universel crée un champ qui n''a de sens que pour une équipe, et chaque changement casse deux autres lecteurs.',
 150, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Architecture : tracer le parcours d''une requête', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Une page met 4 secondes ; la requête traverse reverse-proxy, API, deux services et une file. Personne ne sait où partent les 4 secondes.',
 'Quelle mise en place permet d''attribuer la latence ?',
 'Une trace distribuée : identifiant de corrélation généré à l''entrée, propagé (en-têtes) à travers services et file, spans horodatés par hop, agrégés côté observabilité. Des logs cloisonnés par service ne relient jamais l''histoire ; seul le détail par étape révèle le coupable.',
 150, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Architecture : le nanoservice', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'L''inventaire a été découpé en 14 services : service-des-tarifs, service-des-promotions, service-des-stocks-par-magasin… Toute page d''affichage cumule 9 appels réseau.',
 'Quel est le constat correct ?',
 'Le découpage a suivi les verbes du code, pas l''autonomie : des services incapables de vivre seuls ajoutent latence et propagation des pannes sans gagner d''indépendance. La granularité se jauge à l''autonomie de déploiement et de données ; un appel réseau coûte des ordres de grandeur plus qu''un appel interne.',
 150, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Architecture : lire la base d''un autre service', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Pour un tableau de bord, l''équipe rejoint directement les tables du service commande (même cluster). Trois équipes modifient le schéma de ces tables.',
 'Quel problème structurel cette décision crée-t-elle ?',
 'La donnée d''un service appartient à son propriétaire : la lire en direct vole son modèle interne, crée une dépendance de schéma sans contrat ni version, et transforme chaque ALTER en coordination implicite avec des tiers. Alternatives : API du propriétaire, réplication assumée avec son propre contrat, ou vue partagée si le cas l''exige.',
 150, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Architecture : chiffrer les exigences non fonctionnelles', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'ADVANCED',
 'Pour trancher entre trois designs, l''équipe débat de « performant, scalable, résilient » sans qu''un chiffre ne soit jamais posé.',
 'Quelle pratique transforme ce débat en critères de décision ?',
 'Des objectifs mesurables (p95 de latence, disponibilité visée, coût par transaction, RPO/RTO) deviennent les critères comparatifs des options et le SLO de départ, vérifié après mise en service. Sans chiffre, tout design est défendable : « scalable » ne rejette aucune proposition.',
 150, true, 20, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Architecture : le coût de sortie d''une dépendance externe', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'ADVANCED',
 'Une équipe adopte un service de paiement hôte : SDK appelé depuis le cœur métier, données au format propriétaire, files dédiées. Un an plus tard, le tarif augmente de 40 %.',
 'Quel enseignement tirer pour les décisions d''adoption ?',
 'Le coût de sortie se paie à l''adoption : intégrer via un port applicatif, garder la donnée dans un schéma maîtrisé, isoler le format propriétaire derrière un adaptateur, évaluer le remplacement avant l''engagement. Ici, le SDK dans le cœur rend la bascule un projet de réécriture — la renégociation part de la dépendance.',
 150, true, 20, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Architecture : un ADR qui décide vraiment', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'ADVANCED',
 'Face à deux designs, l''équipe rédige trois pages de contexte puis écrit « nous retenons l''option B pour sa flexibilité ». Six mois plus tard, personne ne sait pourquoi.',
 'Que doit contenir la décision pour rester utilisable ?',
 'Un ADR utile : contexte et forces en jeu, options réellement considérées, critères d''arbitrage, décision, conséquences assumées et conditions de réexamen — le tout court. Il répond à « pourquoi a-t-on choisi ça ? » dans six mois et dit quand rouvrir le dossier sur des faits, pas sur des souvenirs.',
 150, true, 20, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Architecture : séparer progressivement un module du monolithe', 'PROBLEM_SOLVING', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Le module « tarifs » du monolithe est le plus demandé par deux équipes et bloque les déploiements communs. Il faut l''extraire sans interrompre le service.',
 'Décrivez la démarche d''extraction par étapes : frontière, transition, bascule, retrait.',
 'Démarche : (1) dessiner la frontière autour des données et des cas d''usage réels (qui lit et écrit tarifs) ; (2) extraire d''abord en interne — module fortement borné, interface unique, tests de contrat — sans changer le déploiement ; (3) introduire un adaptateur d''appel de même signature que l''ancien chemin pour basculer le trafic progressivement ; (4) migrer l''accès aux données (lecture par contrat, écriture ciblée) puis couper l''accès direct ; (5) autonomiser le déploiement avec observabilité et SLO dédiés. Piège classique : migrer les données d''abord — on s''enferme avant d''avoir la frontière.',
 900, true, 30, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Architecture : isoler une plateforme multi-tenant', 'PROBLEM_SOLVING', 'SINGLE_CHOICE', 'ADVANCED',
 'Une SaaS B2B passe de clients unitaires à des grands comptes exigeant isolation et résidence des données. Le modèle actuel : tables partagées, colonne tenant.',
 'Comparez les modèles d''isolation et décrivez la trajectoire de migration sans exposer un tenant à un autre.',
 'Modèles : partagé avec colonne (économique, bruit de voisinage, contrôle strict requis), table/partition par tenant (isolation nette, coût et nombre de tables), schéma ou base par tenant (forte isolation, opérations à automatiser au-delà de quelques centaines). Trajectoire : contrôle d''appartenance systématique sur tous les chemins (toujours), clé de partition sur les chemins chauds, mesure du voisinage (tenant bruyant), migration des tenants sensibles d''abord avec double lecture et bascule vérifiée. Critère de choix : nombre de tenants, sensibilité, coût d''opération — pas la mode. Attention : le contrôle d''accès reste requis quel que soit le modèle (le voisinage n''est pas une autorisation).',
 900, true, 30, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Architecture : trancher une faisabilité technique incertaine', 'PROBLEM_SOLVING', 'SINGLE_CHOICE', 'ADVANCED',
 'Le produit veut une recherche « instantanée » dans 50 M de documents ; aucune équipe n''a de certitude sur l''atteignable. Deux mois avant l''engagement commercial, il faut dire oui, non ou sous conditions.',
 'Décrivez la démarche du spike (prototype de décision) : hypothèse, périmètre, mesure, décision.',
 'Démarche : (1) reformuler l''hypothèse falsifiable (« p95 < 300 ms sur 50 M de documents avec telles ressources ») et les contraintes non négociables ; (2) isoler le périmètre minimal représentatif — échantillon réel, vraies distributions de requêtes, pas une démo sur données jouets ; (3) construire le chemin critique plutôt que les fonctionnalités ; (4) mesurer selon les critères convenus (latence, coût, effort d''exploitation) et comparer aux alternatives (index existant, service managé) ; (5) décider go / non-go / sous-conditions avec preuves et date de fraîcheur des mesures. Le piège : le spike qui devient la production sans jamais transiter par la décision.',
 900, true, 30, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Architecture : découper pour réduire les conflits d''équipes', 'PROBLEM_SOLVING', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Trois équipes travaillent sur le même monolithe : conflits de merge quotidiens, revues en file, déploiements bloqués par les autres. Les responsabilités métier sont pourtant connues.',
 'Décrivez la démarche de redécoupage à partir de la réalité du travail (flux, cohésion de changement, frontières).',
 'Démarche : (1) mesurer — qui change quoi ensemble (paires de fichiers co-modifiés, tickets), où sont les conflits et les files de revue ; (2) regrouper par cohésion de changement : ce qui évolue ensemble vit ensemble ; (3) dessiner les frontières là où les allers-retours sont rares (contrats stables entre les îlots) ; (4) outiller la possession — ownership, builds et tests par îlot, déploiements indépendants là où possible ; (5) suivre les indicateurs (conflits, délai de revue, déploiements bloqués). L''organisation dessine l''architecture (Conway) : autant le faire délibérément plutôt que subir le premier découpage venu.',
 900, true, 30, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Architecture : fusionner deux services devenus redondants', 'PROBLEM_SOLVING', 'SINGLE_CHOICE', 'ADVANCED',
 'Deux services gèrent les « notifications templates » : nés d''une scission d''équipe il y a trois ans, ils partagent 80 % de code copié et divergent sur les formats de sortie.',
 'Décrivez la démarche de consolidation sans régression ni coupure.',
 'Démarche : (1) rouvrir la raison de la scission (équipe, SLA, charge) — si elle tient encore, la fusion est la mauvaise idée ; (2) cartographier les deux modèles, les divergences réelles et les lecteurs ; (3) définir le modèle cible unique — arbitrage métier explicite sur chaque divergence, pas une moyenne technique ; (4) construire le service cible avec contrats compatibles à l''entrée, migrer les lecteurs un à un avec bascule et retour possible ; (5) retirer l''ancien — désactivation mesurée, suppression du code copié. Piège : fusionner les données d''abord sans contrats — un big bang de données sans filet.',
 900, true, 30, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
) AS v(title, type, selection_type, difficulty, context, question, explanation, estimated_time_seconds, active, points, created_at, updated_at)
WHERE NOT EXISTS (SELECT 1 FROM challenges c WHERE c.title = v.title);

-- -----------------------------------------------
-- Options des QCM (SINGLE : 1 correcte)
-- -----------------------------------------------

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Démarrer en monolithe modulaire aux frontières de domaine tracées, extraire quand la coordination l''exige', true, 1,
 'Le coût des frontières se paie au moment où il rapporte — pas par anticipation sur une équipe de six.'),
('Découper immédiatement en 9 services : le coût de l''extraction future est plus élevé', false, 2,
 'On paie d''emblée tout le coût (déploiements, contrats, obscurité) pour une économie future non prouvée.'),
('Rester en un bloc indifférencié : le découpage est toujours prématuré', false, 3,
 'Sans frontières internes, l''extraction devient impossible — le piège opposé.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Architecture : le monolithe modulaire d''abord'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Par domaine : une équipe responsable de bout en bout de son périmètre', true, 1,
 'Une évolution se règle à l''intérieur d''une seule frontière — validations et allers-retours supprimés.'),
('Par couche technique : spécialisation et réutilisation maximales', false, 2,
 'Chaque feature traverse trois équipes : la coordination devient le goulot.'),
('Les deux, indifféremment : le choix est cosmétique', false, 3,
 'Il décide de la structure de coordination — rien de cosmétique là-dedans.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Architecture : découper par domaine ou par couche'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Le domaine définit ses abstractions, l''infrastructure les implémente — la dépendance pointe vers l''intérieur', true, 1,
 'Cœur testable sans framework, remplacement d''outillage localisé aux adaptateurs.'),
('Le domaine peut importer le framework : les couches techniques sont stables', false, 2,
 'Le framework change souvent — c''est précisément la volatilité qu''on refuse au cœur.'),
('Les deux sens dépendent l''un de l''autre pour éviter les adaptations', false, 3,
 'Le couplage symétrique supprime toute indépendance de remplacement.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Architecture : la direction de la dépendance'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Un modèle par contexte borné, traduit explicitement aux frontières', true, 1,
 'Chaque domaine nomme ses concepts : plus de champ qui change de sens selon l''équipe.'),
('Une entité Compte partagée, enrichie par toutes les équipes', false, 2,
 'Le champ commun devient un sac à toutes les évolutions — chaque ajout casse deux lecteurs.'),
('Dupliquer les tables sans traduction, chaque équipe faisant comme elle veut', false, 3,
 'Sans traduction explicite, les rapprochements se font à la main — la sémantique se perd.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Architecture : deux modèles pour un même mot'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Identifiant de corrélation propagé de service en service, spans horodatés agrégés en trace', true, 1,
 'Une seule histoire de bout en bout : chaque hop révèle sa part de latence.'),
('Des logs détaillés dans chaque service, consultés séparément', false, 2,
 'Rien ne relie les histoires : impossible de reconstituer un parcours éclaté.'),
('Mesurer la latence totale à l''entrée du proxy', false, 3,
 'Total sans ventilation : on sait que ça dure, jamais où.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Architecture : tracer le parcours d''une requête'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Le découpage suit le code et non l''autonomie : la granularité se paie en latence et en couplage réseau', true, 1,
 'Neuf allers-retours par page et aucune indépendance gagnée : coût sans dividende.'),
('Il faut plafonner les appels réseau par page : la granularité est bonne', false, 2,
 'Le plafond traite le symptôme : les services restent incapables de vivre seuls.'),
('Le cumul est normal : chaque service a une seule responsabilité', false, 3,
 'Responsabilité étroite ≠ service légitime — c''est l''autonomie qui tranche.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Architecture : le nanoservice'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Une dépendance de schéma sans contrat : chaque ALTER du propriétaire casse silencieusement les lecteurs', true, 1,
 'Sans frontière de contrat, la base devient l''API non négociée des autres équipes.'),
('Aucun problème tant que tout reste sur le même cluster', false, 2,
 'La proximité physique ne crée aucune frontière de version.'),
('C''est acceptable si les équipes se coordonnent avant chaque changement', false, 3,
 'Coordination permanente = couplage organisé : le coût est déplacé, pas supprimé.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Architecture : lire la base d''un autre service'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Formaliser des objectifs mesurables (p95, disponibilité, budget) : critères de comparaison et SLO de départ', true, 1,
 'Les options s''opposent sur des chiffres vérifiables — et se recontrôlent après mise en service.'),
('Ranger le débat : le design le plus flexible couvrira tous les besoins', false, 2,
 'Le « au cas où » est indécidable et se paie à chaque jalon.'),
('Choisir le design qui a les meilleurs benchmarks du fournisseur', false, 3,
 'Le benchmark ne mesure pas vos flux : ça déplace l''arbitrage chez le vendeur.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Architecture : chiffrer les exigences non fonctionnelles'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Évaluer le coût de sortie à l''adoption : port applicatif, schéma maîtrisé, adaptateur isolant le format propriétaire', true, 1,
 'Le levier de renégociation se construit avant l''enfermement — pas après l''augmentation.'),
('Le coût de sortie se mesure après coup : l''adoption doit rester rapide', false, 2,
 'Après couplage du cœur, « rapide » a signifié « sans alternative ».'),
('Souscrire l''engagement le plus long pour sécuriser le tarif', false, 3,
 'Il fixe le prix, pas la dépendance : la sortie reste un projet de réécriture.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Architecture : le coût de sortie d''une dépendance externe'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Options comparées avec critères, conséquences assumées et conditions de réexamen — le tout court', true, 1,
 'Répond à « pourquoi ? » dans six mois et dit quand rouvrir le dossier sur des faits.'),
('Un long document de contexte validé par toutes les équipes', false, 2,
 'Sans décision et critères explicites, le texte ne dit pas ce qui a été tranché, ni pourquoi.'),
('La décision orale consignée après coup dans un compte rendu', false, 3,
 'Le récit après coup oublie les options perdues et les raisons réelles.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Architecture : un ADR qui décide vraiment'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- -----------------------------------------------
-- Raisonnements séquentiels (5)
-- -----------------------------------------------

INSERT INTO challenges (
    title, type, selection_type, difficulty, context, question,
    explanation, estimated_time_seconds, active, points,
    created_at, updated_at
)
SELECT * FROM (VALUES
('Architecture : poser le découpage initial d''un nouveau produit', 'SEQUENTIAL_REASONING', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Un nouveau produit démarre : l''équipe veut éviter à la fois le big ball of mud et le découpage prématuré.',
 'Place ces étapes dans l''ordre de la démarche recommandée.',
 'Le découpage se construit depuis les besoins et les flux réels, se juge aux frontières peu croisées et à l''organisation qui l''exploitera, puis se documente comme révisable : un choix explicite vaut mieux qu''un héritage, et prévoir le redécoupage évite le dogme.',
 300, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Architecture : évaluer une refonte en microservices', 'SEQUENTIAL_REASONING', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Une équipe subit des déploiements bloqués et des incidents liés au couplage ; certains plaident pour une refonte complète en microservices.',
 'Place ces étapes dans l''ordre de la stratégie recommandée.',
 'D''abord chiffrer les douleurs réelles (symptômes, pas opinions), puis écrire les objectifs mesurables, comparer les options — dont le monolithe modulaire amélioré —, expérimenter sur un périmètre à faible risque et décider sur les résultats avec critères de succès et de repli écrits d''avance. La refonte décidée sur sentiment se paie sans preuve.',
 300, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Architecture : changer un modèle de données partagé', 'SEQUENTIAL_REASONING', 'SINGLE_CHOICE', 'ADVANCED',
 'Un modèle lu par cinq services doit changer de structure ; l''équipe hésite entre bascule coupée et migration progressive.',
 'Place ces étapes dans l''ordre d''une migration sans rupture.',
 'La séquence expand/contract : inventaire des consommateurs, cible et compatibilité garanties pendant la transition, extension (double format, double lecture), bascule progressive des lecteurs avec comptage et retour possible, puis contraction — suppression de l''ancien format seulement prouvée inutilisée. Toute autre ordonnance crée une fenêtre d''incompatibilité.',
 360, true, 20, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Architecture : auditer une architecture existante', 'SEQUENTIAL_REASONING', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Direction demande un état des lieux de l''architecture avant le prochain cycle d''investissement.',
 'Place ces étapes dans l''ordre de la démarche d''audit.',
 'L''audit va du réel vers la décision : reconstituer le système déployé (pas le schéma idéal), recueillir les douleurs mesurées, hiérarchiser les risques par probabilité et impact, formuler des propositions graduées (rapides puis structurelles), et finir par un plan avec indicateurs — un audit qui finit en rapport sans mesure ne change rien au cycle suivant.',
 300, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Architecture : réduire la latence de bout en bout', 'SEQUENTIAL_REASONING', 'SINGLE_CHOICE', 'ADVANCED',
 'Un parcours critique est systématiquement au-dessus de son objectif de latence ; plusieurs équipes proposent des optimisations à vue.',
 'Place ces étapes dans l''ordre de la démarche efficace.',
 'La discipline de la latence : mesurer la distribution réelle (p95/p99, la moyenne masque les victimes), ventiler par contribution (réseau, attente base, files, appels imbriqués), attaquer le poste dominant plutôt que le plus confortable, revérifier sous charge à chaque changement, puis poser budget et alarmes pour que le gain tienne. Optimiser sans attribution gaspille l''effort sur des postes mineurs.',
 360, true, 20, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
) AS v(title, type, selection_type, difficulty, context, question, explanation, estimated_time_seconds, active, points, created_at, updated_at)
WHERE NOT EXISTS (SELECT 1 FROM challenges c WHERE c.title = v.title);

-- Options des raisonnements séquentiels (explications par rang)

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Recueillir les besoins et les flux réels attendus (qui fait quoi, à quelle fréquence)', true, 1,
 'On ne coupe rien avant de savoir ce qui circule : les forces précèdent les frontières.'),
('Cartographier acteurs, données et opérations pour repérer les regroupements naturels', true, 2,
 'La cohésion des données et des usages suggère les candidats à la frontière.'),
('Proposer des frontières candidates et les tester contre les flux (peu de croisements attendus)', true, 3,
 'Une bonne frontière laisse passer peu d''allers-retours — c''est son critère principal.'),
('Confronter aux critères d''exploitation : équipes, cadence de déploiement, charge, SLA', true, 4,
 'Le découpage se jauge à l''organisation qui l''exploitera, pas seulement au diagramme.'),
('Tracer la décision (ADR) et prévoir les conditions de redécoupage', true, 5,
 'Un choix explicite et révisable vaut mieux qu''un héritage non questionné.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Architecture : poser le découpage initial d''un nouveau produit'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Mesurer les douleurs réelles : déploiements bloqués, incidents, contenus de fusion', true, 1,
 'Des symptômes chiffrés fondent la décision — les opinions ne valent pas refonte.'),
('Définir les objectifs non fonctionnels recherchés et leurs seuils', true, 2,
 'Sans cible mesurable, aucun design ne peut être jugé atteint ou raté.'),
('Comparer les options, dont le monolithe modulaire amélioré et l''extraction ciblée', true, 3,
 'Laisser une option simple sur la table évite le solutionnisme devenue refonte.'),
('Expérimenter sur un périmètre à faible risque avec mesure avant/après', true, 4,
 'Le pilote transforme les hypothèses en preuves à coût borné.'),
('Décider sur les résultats du pilote, avec critères de succès et de repli écrits d''avance', true, 5,
 'Critères décidés avant les faits : la décision ne se retourne pas après coup.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Architecture : évaluer une refonte en microservices'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Cartographier tous les consommateurs du modèle (services, jobs, exports, rapports)', true, 1,
 'Rien ne change sans inventaire complet : l''oubli devient une régression en prod.'),
('Définir la cible et garantir la compatibilité pendant toute la transition', true, 2,
 'Aucun instant ne doit voir un auteur incompatible avec un lecteur.'),
('Étendre : écrire les deux formats et doubler les lectures sans casser l''ancien', true, 3,
 'Expand : l''ancien chemin continue de fonctionner pendant que le nouveau grandit.'),
('Basculer les lecteurs progressivement, avec comptage et retour possible', true, 4,
 'Chaque bascule est mesurée et réversible — plus de big bang.'),
('Contracter : supprimer l''ancien format quand plus personne ne l''utilise, preuve à l''appui', true, 5,
 'Contract exécuté sur statistique d''usage, pas sur calendrier optimiste.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Architecture : changer un modèle de données partagé'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Reconstituer le système réel déployé (flux, dépendances, processus) et non le schéma idéal', true, 1,
 'La carte du réel est la seule base : le diagramme d''origine ment depuis longtemps.'),
('Recueillir les douleurs mesurées : incidents, lenteurs de déploiement, zones de modification coûteuses', true, 2,
 'Chiffrer les symptômes transforme les rumeurs en diagnostic.'),
('Hiérarchiser les risques (probabilité × impact × fréquence)', true, 3,
 'Prioriser évite le rapport-omnibus où tout est noté et rien n''est tranché.'),
('Formuler des propositions graduées, rapides puis structurelles, selon le risque traité', true, 4,
 'L''effort est proportionné au risque : du quick win d''abord, du structurel là où ça rapporte.'),
('Établir un plan mesuré avec indicateurs de sortie de la dette', true, 5,
 'Un audit qui finit par des mesures et un plan change le cycle suivant — pas seulement le rapport.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Architecture : auditer une architecture existante'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Mesurer la distribution réelle (p95/p99 par parcours), pas la moyenne', true, 1,
 'La moyenne dilue les victimes : c''est la queue de distribution qui se plaint.'),
('Ventiler la latence par contribution (réseau, attente base, files, appels imbriqués)', true, 2,
 'Attribuer avant d''optimiser : on ne répare pas ce qu''on n''a pas localisé.'),
('Attaquer la contribution dominante (aller-retours, index, découpage de file, cache ciblé)', true, 3,
 'L''effort va au poste le plus lourd — l''ordre des gains est mathématique.'),
('Revérifier sous charge représentative après chaque changement', true, 4,
 'L''effet se prouve, il ne se suppose pas : sinon les « optimisations » s''accumulent sans gain.'),
('Poser un budget de latence et des alarmes pour que le gain tienne', true, 5,
 'Sans budget ni alarme, la performance se dégrade dès la prochaine livraison.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Architecture : réduire la latence de bout en bout'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- -----------------------------------------------
-- Liens catégories / skills / profiles (idempotents)
-- -----------------------------------------------

INSERT INTO challenge_categories (challenge_id, category_id)
SELECT c.id, cat.id
FROM challenges c, categories cat
WHERE cat.name = 'Architecture'
  AND (c.title LIKE 'Architecture %'
       OR c.title LIKE 'EditDoc - %'
       OR c.title LIKE 'Notify - %'
       OR c.title LIKE 'Ride - %')
  AND NOT EXISTS (SELECT 1 FROM challenge_categories cc WHERE cc.challenge_id = c.id AND cc.category_id = cat.id);

INSERT INTO challenge_skills (challenge_id, skill_id)
SELECT c.id, s.id
FROM challenges c, skills s
WHERE c.title LIKE 'Architecture %'
  AND c.type = 'SEQUENTIAL_REASONING'
  AND s.name = 'Problem Solving'
  AND NOT EXISTS (SELECT 1 FROM challenge_skills cs WHERE cs.challenge_id = c.id AND cs.skill_id = s.id);

INSERT INTO challenge_profiles (challenge_id, profile_id)
SELECT c.id, p.id
FROM challenges c, profiles p
WHERE p.code = 'DEVELOPER'
  AND (c.title LIKE 'Architecture %'
       OR c.title LIKE 'EditDoc - %'
       OR c.title LIKE 'Notify - %'
       OR c.title LIKE 'Ride - %')
  AND NOT EXISTS (SELECT 1 FROM challenge_profiles cp WHERE cp.challenge_id = c.id AND cp.profile_id = p.id);

-- Vérification rapide attendue : 38 défis Architecture
--   (10 QCM + 3 problem-solving + 5 séquentiels + 18 étapes sur 3 scénarios).
-- SELECT c.type, count(*) FROM challenges c
-- WHERE c.title LIKE 'Architecture %' OR c.title LIKE 'EditDoc - %'
--    OR c.title LIKE 'Notify - %' OR c.title LIKE 'Ride - %'
-- GROUP BY c.type;
-- Étapes rattachées : SELECT s.title, count(*) FROM challenges c
-- JOIN interview_scenarios s ON s.id = c.scenario_id GROUP BY s.title;
