INSERT INTO interview_scenarios (title, description, mode, active)
SELECT
    'Design a High-Scale Food Delivery Platform',
    'Conçois progressivement une plateforme de livraison de repas à grande échelle.',
    'ARCHITECTURE',
    TRUE
WHERE NOT EXISTS (
    SELECT 1
    FROM interview_scenarios
    WHERE title = 'Design a High-Scale Food Delivery Platform'
);

INSERT INTO challenges (
    title, type, selection_type, difficulty, context, question,
    revealed_information, tradeoff, explanation,
    estimated_time_seconds, active, points, scenario_id, step_order,
    created_at, updated_at
)
SELECT
    'Food Delivery - Architecture générale',
    'ARCHITECTURE',
    'SINGLE_CHOICE',
    'INTERMEDIATE',
    'Tu dois concevoir une plateforme de livraison de repas utilisée par des clients, restaurants et livreurs.',
    'Quel découpage initial proposes-tu pour les principaux composants du système ?',
    'Le trafic est séparé entre consultation des restaurants, création de commande, paiement et suivi de livraison.',
    'Un découpage par domaines permet de faire évoluer indépendamment les parcours les plus sollicités.',
    'Un découpage par domaines réduit le couplage entre les parcours métier et facilite leur évolution indépendante.',
    180,
    TRUE,
    20,
    s.id,
    1,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM interview_scenarios s
WHERE s.title = 'Design a High-Scale Food Delivery Platform'
  AND NOT EXISTS (
      SELECT 1 FROM challenges
      WHERE title = 'Food Delivery - Architecture générale'
  );

INSERT INTO challenges (
    title, type, selection_type, difficulty, context, question,
    revealed_information, tradeoff, explanation,
    estimated_time_seconds, active, points, scenario_id, step_order,
    created_at, updated_at
)
SELECT
    'Food Delivery - Scalabilité',
    'ARCHITECTURE',
    'SINGLE_CHOICE',
    'INTERMEDIATE',
    'Le nombre de restaurants et de commandes augmente fortement dans plusieurs régions.',
    'Comment fais-tu évoluer le stockage et le trafic pour absorber cette croissance ?',
    'Les commandes sont majoritairement consultées dans leur région de création et les pics de trafic sont localisés.',
    'Le partitionnement régional réduit la contention mais complexifie les requêtes transversales.',
    'La stratégie doit isoler les charges régionales tout en prévoyant les besoins de consultation globale.',
    180,
    TRUE,
    20,
    s.id,
    2,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM interview_scenarios s
WHERE s.title = 'Design a High-Scale Food Delivery Platform'
  AND NOT EXISTS (
      SELECT 1 FROM challenges
      WHERE title = 'Food Delivery - Scalabilité'
  );

INSERT INTO challenges (
    title, type, selection_type, difficulty, context, question,
    revealed_information, tradeoff, explanation,
    estimated_time_seconds, active, points, scenario_id, step_order,
    created_at, updated_at
)
SELECT
    'Food Delivery - Caching',
    'ARCHITECTURE',
    'SINGLE_CHOICE',
    'INTERMEDIATE',
    'La consultation des restaurants et des menus représente la majorité des lectures.',
    'Quelle stratégie de cache proposes-tu pour diminuer la charge sur les bases de données ?',
    'Les menus changent peu, mais une modification doit être visible rapidement dans la région concernée.',
    'Un cache à courte durée améliore les performances mais accepte une faible fenêtre de cohérence éventuelle.',
    'Le cache doit être associé à une durée de vie et à une invalidation adaptées au rythme de modification des menus.',
    150,
    TRUE,
    20,
    s.id,
    3,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM interview_scenarios s
WHERE s.title = 'Design a High-Scale Food Delivery Platform'
  AND NOT EXISTS (
      SELECT 1 FROM challenges
      WHERE title = 'Food Delivery - Caching'
  );

INSERT INTO challenges (
    title, type, selection_type, difficulty, context, question,
    revealed_information, tradeoff, explanation,
    estimated_time_seconds, active, points, scenario_id, step_order,
    created_at, updated_at
)
SELECT
    'Food Delivery - Commandes asynchrones',
    'ARCHITECTURE',
    'SINGLE_CHOICE',
    'INTERMEDIATE',
    'La validation d''une commande déclenche le paiement, la préparation et la recherche d''un livreur.',
    'Comment coordonnes-tu ces traitements sans bloquer la requête HTTP principale ?',
    'La commande est persistée avant publication d''un événement et chaque consommateur est idempotent.',
    'L''asynchronisme améliore la résilience, mais impose la gestion des reprises, doublons et états intermédiaires.',
    'La persistance avant publication et l''idempotence permettent de reprendre les traitements sans créer de doublons.',
    180,
    TRUE,
    20,
    s.id,
    4,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM interview_scenarios s
WHERE s.title = 'Design a High-Scale Food Delivery Platform'
  AND NOT EXISTS (
      SELECT 1 FROM challenges
      WHERE title = 'Food Delivery - Commandes asynchrones'
  );

INSERT INTO challenges (
    title, type, selection_type, difficulty, context, question,
    revealed_information, tradeoff, explanation,
    estimated_time_seconds, active, points, scenario_id, step_order,
    created_at, updated_at
)
SELECT
    'Food Delivery - Concurrence des stocks',
    'ARCHITECTURE',
    'SINGLE_CHOICE',
    'INTERMEDIATE',
    'Deux clients commandent simultanément le dernier article disponible dans un restaurant.',
    'Comment évites-tu de confirmer deux commandes incompatibles ?',
    'La réservation atomique réduit le risque de survente, au prix d''une contention sur les articles très populaires.',
    'Une mise à jour conditionnelle ou un verrouillage court doit garantir qu''une seule réservation réussit.',
    'Une opération atomique sur le stock garantit qu''une seule commande peut réserver le dernier article disponible.',
    180,
    TRUE,
    20,
    s.id,
    5,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM interview_scenarios s
WHERE s.title = 'Design a High-Scale Food Delivery Platform'
  AND NOT EXISTS (
      SELECT 1 FROM challenges
      WHERE title = 'Food Delivery - Concurrence des stocks'
  );

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, 'Séparer les domaines commande, paiement, restaurant et livraison', TRUE, 1,
       'Ce découpage limite le couplage et permet de faire évoluer les domaines indépendamment.'
FROM challenges c
WHERE c.title = 'Food Delivery - Architecture générale'
  AND NOT EXISTS (SELECT 1 FROM challenge_options WHERE challenge_id = c.id AND display_order = 1);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, 'Mettre toute la logique dans un seul contrôleur HTTP', FALSE, 2,
       'Un contrôleur monolithique augmente le couplage et rend les évolutions difficiles.'
FROM challenges c
WHERE c.title = 'Food Delivery - Architecture générale'
  AND NOT EXISTS (SELECT 1 FROM challenge_options WHERE challenge_id = c.id AND display_order = 2);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, 'Partitionner les données et le trafic par région', TRUE, 1,
       'Le partitionnement régional isole les charges et limite la contention entre régions.'
FROM challenges c
WHERE c.title = 'Food Delivery - Scalabilité'
  AND NOT EXISTS (SELECT 1 FROM challenge_options WHERE challenge_id = c.id AND display_order = 1);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, 'Conserver toutes les requêtes sur une seule base sans stratégie de lecture', FALSE, 2,
       'Une base unique sans séparation de charge devient rapidement un goulot d''étranglement.'
FROM challenges c
WHERE c.title = 'Food Delivery - Scalabilité'
  AND NOT EXISTS (SELECT 1 FROM challenge_options WHERE challenge_id = c.id AND display_order = 2);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, 'Mettre en cache les menus avec invalidation à la mise à jour', TRUE, 1,
       'Les menus sont principalement lus et changent moins souvent que les commandes.'
FROM challenges c
WHERE c.title = 'Food Delivery - Caching'
  AND NOT EXISTS (SELECT 1 FROM challenge_options WHERE challenge_id = c.id AND display_order = 1);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, 'Écrire systématiquement chaque lecture dans la base', FALSE, 2,
       'Cette approche augmente inutilement la charge et ne répond pas au besoin de lecture intensive.'
FROM challenges c
WHERE c.title = 'Food Delivery - Caching'
  AND NOT EXISTS (SELECT 1 FROM challenge_options WHERE challenge_id = c.id AND display_order = 2);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, 'Publier un événement après persistance et traiter les consommateurs de façon idempotente', TRUE, 1,
       'La persistance avant publication et l''idempotence rendent les reprises sûres.'
FROM challenges c
WHERE c.title = 'Food Delivery - Commandes asynchrones'
  AND NOT EXISTS (SELECT 1 FROM challenge_options WHERE challenge_id = c.id AND display_order = 1);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, 'Bloquer la requête HTTP jusqu''à la fin du paiement et de la livraison', FALSE, 2,
       'Cela augmente la latence et rend le parcours sensible aux pannes des services dépendants.'
FROM challenges c
WHERE c.title = 'Food Delivery - Commandes asynchrones'
  AND NOT EXISTS (SELECT 1 FROM challenge_options WHERE challenge_id = c.id AND display_order = 2);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, 'Utiliser une mise à jour conditionnelle ou un verrouillage court sur le stock', TRUE, 1,
       'Une opération atomique garantit qu''une seule réservation du dernier article réussit.'
FROM challenges c
WHERE c.title = 'Food Delivery - Concurrence des stocks'
  AND NOT EXISTS (SELECT 1 FROM challenge_options WHERE challenge_id = c.id AND display_order = 1);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, 'Lire le stock puis décrémenter plus tard sans contrôle de concurrence', FALSE, 2,
       'Deux transactions peuvent lire la même valeur et confirmer des commandes incompatibles.'
FROM challenges c
WHERE c.title = 'Food Delivery - Concurrence des stocks'
  AND NOT EXISTS (SELECT 1 FROM challenge_options WHERE challenge_id = c.id AND display_order = 2);

INSERT INTO challenge_categories (challenge_id, category_id)
SELECT c.id, cat.id
FROM challenges c
JOIN categories cat ON cat.name IN ('Architecture', 'Distributed Systems', 'System Design')
WHERE c.title LIKE 'Food Delivery - %'
  AND NOT EXISTS (
      SELECT 1
      FROM challenge_categories cc
      WHERE cc.challenge_id = c.id
        AND cc.category_id = cat.id
  );
