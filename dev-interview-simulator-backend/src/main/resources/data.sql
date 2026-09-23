INSERT INTO categories (name, description) VALUES
('Java', 'Core Java, JVM, Concurrency, and modern Java features')
ON CONFLICT (name) DO NOTHING;

INSERT INTO categories (name, description) VALUES
('Spring Boot', 'Spring Framework, Dependency Injection, Boot auto-config, and REST APIs')
ON CONFLICT (name) DO NOTHING;

INSERT INTO categories (name, description) VALUES
('SQL / PostgreSQL', 'Relational database design, queries, indexes, and performance')
ON CONFLICT (name) DO NOTHING;

INSERT INTO categories (name, description) VALUES
('JPA / Hibernate', 'ORM mapping, entity lifecycle, lazy loading, and N+1 query problem')
ON CONFLICT (name) DO NOTHING;

INSERT INTO categories (name, description) VALUES
('API / Backend', 'REST principles, HTTP status codes, payload design, and API security')
ON CONFLICT (name) DO NOTHING;

INSERT INTO categories (name, description) VALUES
('Architecture', 'Design patterns, SOLID principles, monolith vs microservices')
ON CONFLICT (name) DO NOTHING;

INSERT INTO categories (name, description) VALUES
('Testing', 'Unit testing, Integration testing, Mocking, and Test-Driven Development')
ON CONFLICT (name) DO NOTHING;

INSERT INTO categories (name, description) VALUES
('DevOps', 'CI/CD pipelines, Docker, environment configuration, and deployment')
ON CONFLICT (name) DO NOTHING;

INSERT INTO categories (name, description) VALUES
('Distributed Systems', 'Consistency, CAP theorem, caching, messaging, and fault tolerance')
ON CONFLICT (name) DO NOTHING;

INSERT INTO categories (name, description) VALUES
('System Design', 'Scalability, load balancing, database partitioning, and high availability')
ON CONFLICT (name) DO NOTHING;

-- Initialisation des Skills
INSERT INTO skills (name, description) VALUES
('Problem Solving', 'Ability to break down complex engineering problems')
ON CONFLICT (name) DO NOTHING;

INSERT INTO skills (name, description) VALUES
('Debugging', 'Finding root cause of runtime anomalies and failures')
ON CONFLICT (name) DO NOTHING;

INSERT INTO skills (name, description) VALUES
('Performance Analysis', 'Identifying bottlenecks in memory, CPU, DB, or network')
ON CONFLICT (name) DO NOTHING;

INSERT INTO skills (name, description) VALUES
('Code Quality', 'Readability, maintainability, and clean code standards')
ON CONFLICT (name) DO NOTHING;

-- Utilisateur par défaut pour le MVP (sans auth)
INSERT INTO users (username, email, created_at, updated_at) VALUES
('default_user', 'dev@example.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (username) DO NOTHING;

-- =========================================
-- Seed des Challenges (idempotent via NOT EXISTS)
-- =========================================

-- Challenge 1 : Java / Debugging - QCM Junior
INSERT INTO challenges (title, type, difficulty, context, question, explanation, estimated_time_seconds, active, points, created_at, updated_at)
SELECT 'NullPointerException dans un stream', 'SITUATIONAL_QCM', 'JUNIOR',
       'Tu debugges un pipeline de traitement de données en production.',
       'Un collègue te montre ce code : list.stream().map(Item::getName).collect(Collectors.toList()) qui lève une NullPointerException. Quelle est la cause la plus probable ?',
       'Si un élément de la liste (ou le résultat de getName()) est null, .map() ne le gère pas automatiquement et l''exception peut survenir plus loin dans le pipeline.',
       90, true, 10, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM challenges WHERE title = 'NullPointerException dans un stream');

-- Challenge 2 : Spring Boot / Problem Solving - QCM Intermediate
INSERT INTO challenges (title, type, difficulty, context, question, explanation, estimated_time_seconds, active, points, created_at, updated_at)
SELECT 'Bean non injecté au démarrage', 'SITUATIONAL_QCM', 'INTERMEDIATE',
       'Ton application Spring Boot refuse de démarrer.',
       'Tu obtiens une erreur "No qualifying bean of type X found". Quelle est la cause la plus courante ?',
       'La classe n''est pas annotée avec @Component/@Service/@Repository, ou elle n''est pas dans le scan de @ComponentScan.',
       120, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM challenges WHERE title = 'Bean non injecté au démarrage');

-- Challenge 3 : SQL/PostgreSQL / Performance Analysis - QCM Junior
INSERT INTO challenges (title, type, difficulty, context, question, explanation, estimated_time_seconds, active, points, created_at, updated_at)
SELECT 'Requête lente sur une grosse table', 'SITUATIONAL_QCM', 'JUNIOR',
       'Une requête SELECT sur une table de 2 millions de lignes met 8 secondes.',
       'Quelle est la première chose à vérifier pour optimiser cette requête ?',
       'Vérifier si un index existe sur les colonnes utilisées dans la clause WHERE, via un EXPLAIN ANALYZE.',
       90, true, 10, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM challenges WHERE title = 'Requête lente sur une grosse table');

-- Challenge 4 : JPA/Hibernate / Debugging - Problem Solving Intermediate
INSERT INTO challenges (title, type, difficulty, context, question, explanation, estimated_time_seconds, active, points, created_at, updated_at)
SELECT 'Problème N+1 en production', 'PROBLEM_SOLVING', 'INTERMEDIATE',
       'Ton endpoint /orders devient de plus en plus lent quand le nombre de commandes augmente.',
       'En regardant les logs Hibernate, tu vois une requête par commande pour charger son client associé. Comment identifies-tu et corriges-tu ce problème ?',
       'Il s''agit du problème N+1 lié au lazy loading. On le corrige avec un JOIN FETCH dans la requête JPQL, ou en utilisant @EntityGraph.',
       180, true, 20, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM challenges WHERE title = 'Problème N+1 en production');

-- Challenge 5 : Architecture / Code Quality - Problem Solving Advanced
INSERT INTO challenges (title, type, difficulty, context, question, explanation, estimated_time_seconds, active, points, created_at, updated_at)
SELECT 'Service devenu un God Object', 'PROBLEM_SOLVING', 'ADVANCED',
       'Une classe OrderService de 2000 lignes gère la création de commandes, l''envoi d''emails, la facturation et les stocks.',
       'Comment refactoriser cette classe en respectant les principes SOLID ?',
       'Appliquer le principe de responsabilité unique (SRP) en extrayant chaque responsabilité (email, facturation, stock) dans des services dédiés, orchestrés par OrderService.',
       240, true, 25, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM challenges WHERE title = 'Service devenu un God Object');

-- Challenge 6 : API/Backend / Problem Solving - QCM Intermediate
INSERT INTO challenges (title, type, difficulty, context, question, explanation, estimated_time_seconds, active, points, created_at, updated_at)
SELECT 'Mauvais code HTTP retourné', 'SITUATIONAL_QCM', 'INTERMEDIATE',
       'Un endpoint retourne 200 OK même quand la ressource demandée n''existe pas.',
       'Quel code HTTP devrait être retourné à la place, et pourquoi ?',
       '404 Not Found, car le code de statut doit refléter fidèlement l''état de la ressource pour que les clients API puissent réagir correctement.',
       60, true, 10, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM challenges WHERE title = 'Mauvais code HTTP retourné');


-- =========================================
-- Liens Challenge <-> Category
-- =========================================
INSERT INTO challenge_categories (challenge_id, category_id)
SELECT c.id, cat.id FROM challenges c, categories cat
WHERE c.title = 'NullPointerException dans un stream' AND cat.name = 'Java'
  AND NOT EXISTS (SELECT 1 FROM challenge_categories WHERE challenge_id = c.id AND category_id = cat.id);

INSERT INTO challenge_categories (challenge_id, category_id)
SELECT c.id, cat.id FROM challenges c, categories cat
WHERE c.title = 'Bean non injecté au démarrage' AND cat.name = 'Spring Boot'
  AND NOT EXISTS (SELECT 1 FROM challenge_categories WHERE challenge_id = c.id AND category_id = cat.id);

INSERT INTO challenge_categories (challenge_id, category_id)
SELECT c.id, cat.id FROM challenges c, categories cat
WHERE c.title = 'Requête lente sur une grosse table' AND cat.name = 'SQL / PostgreSQL'
  AND NOT EXISTS (SELECT 1 FROM challenge_categories WHERE challenge_id = c.id AND category_id = cat.id);

INSERT INTO challenge_categories (challenge_id, category_id)
SELECT c.id, cat.id FROM challenges c, categories cat
WHERE c.title = 'Problème N+1 en production' AND cat.name = 'JPA / Hibernate'
  AND NOT EXISTS (SELECT 1 FROM challenge_categories WHERE challenge_id = c.id AND category_id = cat.id);

INSERT INTO challenge_categories (challenge_id, category_id)
SELECT c.id, cat.id FROM challenges c, categories cat
WHERE c.title = 'Service devenu un God Object' AND cat.name = 'Architecture'
  AND NOT EXISTS (SELECT 1 FROM challenge_categories WHERE challenge_id = c.id AND category_id = cat.id);

INSERT INTO challenge_categories (challenge_id, category_id)
SELECT c.id, cat.id FROM challenges c, categories cat
WHERE c.title = 'Mauvais code HTTP retourné' AND cat.name = 'API / Backend'
  AND NOT EXISTS (SELECT 1 FROM challenge_categories WHERE challenge_id = c.id AND category_id = cat.id);


-- =========================================
-- Liens Challenge <-> Skill
-- =========================================
INSERT INTO challenge_skills (challenge_id, skill_id)
SELECT c.id, s.id FROM challenges c, skills s
WHERE c.title = 'NullPointerException dans un stream' AND s.name = 'Debugging'
  AND NOT EXISTS (SELECT 1 FROM challenge_skills WHERE challenge_id = c.id AND skill_id = s.id);

INSERT INTO challenge_skills (challenge_id, skill_id)
SELECT c.id, s.id FROM challenges c, skills s
WHERE c.title = 'Bean non injecté au démarrage' AND s.name = 'Problem Solving'
  AND NOT EXISTS (SELECT 1 FROM challenge_skills WHERE challenge_id = c.id AND skill_id = s.id);

INSERT INTO challenge_skills (challenge_id, skill_id)
SELECT c.id, s.id FROM challenges c, skills s
WHERE c.title = 'Requête lente sur une grosse table' AND s.name = 'Performance Analysis'
  AND NOT EXISTS (SELECT 1 FROM challenge_skills WHERE challenge_id = c.id AND skill_id = s.id);

INSERT INTO challenge_skills (challenge_id, skill_id)
SELECT c.id, s.id FROM challenges c, skills s
WHERE c.title = 'Problème N+1 en production' AND s.name = 'Debugging'
  AND NOT EXISTS (SELECT 1 FROM challenge_skills WHERE challenge_id = c.id AND skill_id = s.id);

INSERT INTO challenge_skills (challenge_id, skill_id)
SELECT c.id, s.id FROM challenges c, skills s
WHERE c.title = 'Service devenu un God Object' AND s.name = 'Code Quality'
  AND NOT EXISTS (SELECT 1 FROM challenge_skills WHERE challenge_id = c.id AND skill_id = s.id);

INSERT INTO challenge_skills (challenge_id, skill_id)
SELECT c.id, s.id FROM challenges c, skills s
WHERE c.title = 'Mauvais code HTTP retourné' AND s.name = 'Problem Solving'
  AND NOT EXISTS (SELECT 1 FROM challenge_skills WHERE challenge_id = c.id AND skill_id = s.id);


-- =========================================
-- Options pour les Challenges de type QCM
-- =========================================

-- Options Challenge 1
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order)
SELECT c.id, 'Un élément de la liste ou getName() retourne null', true, 1
FROM challenges c WHERE c.title = 'NullPointerException dans un stream'
                    AND NOT EXISTS (SELECT 1 FROM challenge_options WHERE challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order)
SELECT c.id, 'La liste elle-même est null', false, 2
FROM challenges c WHERE c.title = 'NullPointerException dans un stream'
                    AND NOT EXISTS (SELECT 1 FROM challenge_options WHERE challenge_id = c.id AND display_order = 2);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order)
SELECT c.id, 'Collectors.toList() ne supporte pas les streams', false, 3
FROM challenges c WHERE c.title = 'NullPointerException dans un stream'
                    AND NOT EXISTS (SELECT 1 FROM challenge_options WHERE challenge_id = c.id AND display_order = 3);

-- Options Challenge 2
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order)
SELECT c.id, 'La classe n''est pas annotée @Component/@Service et/ou hors du scan', true, 1
FROM challenges c WHERE c.title = 'Bean non injecté au démarrage'
                    AND NOT EXISTS (SELECT 1 FROM challenge_options WHERE challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order)
SELECT c.id, 'Spring Boot ne supporte pas l''injection de dépendances', false, 2
FROM challenges c WHERE c.title = 'Bean non injecté au démarrage'
                    AND NOT EXISTS (SELECT 1 FROM challenge_options WHERE challenge_id = c.id AND display_order = 2);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order)
SELECT c.id, 'Le fichier application.yml est corrompu', false, 3
FROM challenges c WHERE c.title = 'Bean non injecté au démarrage'
                    AND NOT EXISTS (SELECT 1 FROM challenge_options WHERE challenge_id = c.id AND display_order = 3);

-- Options Challenge 3
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order)
SELECT c.id, 'Vérifier la présence d''un index sur les colonnes du WHERE via EXPLAIN ANALYZE', true, 1
FROM challenges c WHERE c.title = 'Requête lente sur une grosse table'
                    AND NOT EXISTS (SELECT 1 FROM challenge_options WHERE challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order)
SELECT c.id, 'Redémarrer le serveur PostgreSQL', false, 2
FROM challenges c WHERE c.title = 'Requête lente sur une grosse table'
                    AND NOT EXISTS (SELECT 1 FROM challenge_options WHERE challenge_id = c.id AND display_order = 2);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order)
SELECT c.id, 'Supprimer la moitié des lignes de la table', false, 3
FROM challenges c WHERE c.title = 'Requête lente sur une grosse table'
                    AND NOT EXISTS (SELECT 1 FROM challenge_options WHERE challenge_id = c.id AND display_order = 3);

-- Options Challenge 6
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order)
SELECT c.id, '404 Not Found', true, 1
FROM challenges c WHERE c.title = 'Mauvais code HTTP retourné'
                    AND NOT EXISTS (SELECT 1 FROM challenge_options WHERE challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order)
SELECT c.id, '500 Internal Server Error', false, 2
FROM challenges c WHERE c.title = 'Mauvais code HTTP retourné'
                    AND NOT EXISTS (SELECT 1 FROM challenge_options WHERE challenge_id = c.id AND display_order = 2);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order)
SELECT c.id, '204 No Content', false, 3
FROM challenges c WHERE c.title = 'Mauvais code HTTP retourné'
                    AND NOT EXISTS (SELECT 1 FROM challenge_options WHERE challenge_id = c.id AND display_order = 3);

-- =============================================================================
-- ENRICHISSEMENT DU DATA.SQL (NOUVEAUX CHALLENGES IDEMPOTENTS)
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Challenge 7 : Java / Memory / Garbage Collection - QCM Intermediate
-- -----------------------------------------------------------------------------
INSERT INTO challenges (title, type, difficulty, context, question, explanation, estimated_time_seconds, active, points, created_at, updated_at)
SELECT 'Garbage Collection et Old Generation', 'SITUATIONAL_QCM', 'INTERMEDIATE',
       'Une application backend subit des pics de latence en raison de pauses Stop-The-World récurrentes.',
       'Dans quel espace mémoire de la JVM (HotSpot) les objets qui survivent à plusieurs cycles de Garbage Collection sont-ils déplacés ?',
       'Les objets nouvellement créés vont dans l''Eden Space (Young Generation). S''ils survivent aux cycles de GC mineurs, ils traversent les Survivor Spaces puis sont promus dans l''Old Generation.',
       90, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM challenges WHERE title = 'Garbage Collection et Old Generation');

-- Categories & Skills
INSERT INTO challenge_categories (challenge_id, category_id)
SELECT c.id, cat.id FROM challenges c, categories cat
WHERE c.title = 'Garbage Collection et Old Generation' AND cat.name = 'Java'
  AND NOT EXISTS (SELECT 1 FROM challenge_categories WHERE challenge_id = c.id AND category_id = cat.id);

INSERT INTO challenge_skills (challenge_id, skill_id)
SELECT c.id, s.id FROM challenges c, skills s
WHERE c.title = 'Garbage Collection et Old Generation' AND s.name = 'Performance Analysis'
  AND NOT EXISTS (SELECT 1 FROM challenge_skills WHERE challenge_id = c.id AND skill_id = s.id);

-- Options
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order)
SELECT c.id, 'Old / Tenured Generation', true, 1
FROM challenges c WHERE c.title = 'Garbage Collection et Old Generation'
                    AND NOT EXISTS (SELECT 1 FROM challenge_options WHERE challenge_id = c.id AND display_order = 1);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order)
SELECT c.id, 'Metaspace', false, 2
FROM challenges c WHERE c.title = 'Garbage Collection et Old Generation'
                    AND NOT EXISTS (SELECT 1 FROM challenge_options WHERE challenge_id = c.id AND display_order = 2);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order)
SELECT c.id, 'Eden Space', false, 3
FROM challenges c WHERE c.title = 'Garbage Collection et Old Generation'
                    AND NOT EXISTS (SELECT 1 FROM challenge_options WHERE challenge_id = c.id AND display_order = 3);


-- -----------------------------------------------------------------------------
-- Challenge 8 : Spring Boot / Transactions / Propagation - QCM Advanced
-- -----------------------------------------------------------------------------
INSERT INTO challenges (title, type, difficulty, context, question, explanation, estimated_time_seconds, active, points, created_at, updated_at)
SELECT 'Gestion des transactions avec REQUIRES_NEW', 'SITUATIONAL_QCM', 'ADVANCED',
       'Une méthode service @Transactional appelles une sous-méthode annotée avec @Transactional(propagation = Propagation.REQUIRES_NEW).',
       'Que se passe-t-il si la sous-méthode lève une RuntimeException non capturée par l''appelant ?',
       'Propagation.REQUIRES_NEW suspend la transaction parente et en crée une nouvelle. Si l''exception n''est pas capturée, elle remonte et provoque le rollback des deux transactions.',
       120, true, 20, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM challenges WHERE title = 'Gestion des transactions avec REQUIRES_NEW');

-- Categories & Skills
INSERT INTO challenge_categories (challenge_id, category_id)
SELECT c.id, cat.id FROM challenges c, categories cat
WHERE c.title = 'Gestion des transactions avec REQUIRES_NEW' AND cat.name = 'Spring Boot'
  AND NOT EXISTS (SELECT 1 FROM challenge_categories WHERE challenge_id = c.id AND category_id = cat.id);

INSERT INTO challenge_skills (challenge_id, skill_id)
SELECT c.id, s.id FROM challenges c, skills s
WHERE c.title = 'Gestion des transactions avec REQUIRES_NEW' AND s.name = 'Problem Solving'
  AND NOT EXISTS (SELECT 1 FROM challenge_skills WHERE challenge_id = c.id AND skill_id = s.id);

-- Options
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order)
SELECT c.id, 'Si l''exception n''est pas capturée, la sous-transaction puis la transaction principale subissent un rollback', true, 1
FROM challenges c WHERE c.title = 'Gestion des transactions avec REQUIRES_NEW'
                    AND NOT EXISTS (SELECT 1 FROM challenge_options WHERE challenge_id = c.id AND display_order = 1);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order)
SELECT c.id, 'La transaction principale est commitée et seule la sous-transaction est annulée', false, 2
FROM challenges c WHERE c.title = 'Gestion des transactions avec REQUIRES_NEW'
                    AND NOT EXISTS (SELECT 1 FROM challenge_options WHERE challenge_id = c.id AND display_order = 2);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order)
SELECT c.id, 'Spring ignore l''exception car il s''agit de deux transactions distinctes', false, 3
FROM challenges c WHERE c.title = 'Gestion des transactions avec REQUIRES_NEW'
                    AND NOT EXISTS (SELECT 1 FROM challenge_options WHERE challenge_id = c.id AND display_order = 3);


-- -----------------------------------------------------------------------------
-- Challenge 9 : SQL / PostgreSQL / Index Partiel - QCM Intermediate
-- -----------------------------------------------------------------------------
INSERT INTO challenges (title, type, difficulty, context, question, explanation, estimated_time_seconds, active, points, created_at, updated_at)
SELECT 'Optimisation SQL sur statut rare', 'SITUATIONAL_QCM', 'INTERMEDIATE',
       'Une table "orders" de 10 millions de lignes a une colonne "status". Seules 1% des lignes ont le statut "PENDING" et tu dois souvent interroger ce statut.',
       'Quel type d''index est le plus optimisé en termes de taille et de performance pour cette recherche ?',
       'Un index partiel (Partial Index) avec une clause WHERE status = ''PENDING'' est idéal car il ne contient que les 1% de lignes nécessaires, économisant beaucoup de mémoire.',
       90, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM challenges WHERE title = 'Optimisation SQL sur statut rare');

-- Categories & Skills
INSERT INTO challenge_categories (challenge_id, category_id)
SELECT c.id, cat.id FROM challenges c, categories cat
WHERE c.title = 'Optimisation SQL sur statut rare' AND cat.name = 'SQL / PostgreSQL'
  AND NOT EXISTS (SELECT 1 FROM challenge_categories WHERE challenge_id = c.id AND category_id = cat.id);

INSERT INTO challenge_skills (challenge_id, skill_id)
SELECT c.id, s.id FROM challenges c, skills s
WHERE c.title = 'Optimisation SQL sur statut rare' AND s.name = 'Performance Analysis'
  AND NOT EXISTS (SELECT 1 FROM challenge_skills WHERE challenge_id = c.id AND skill_id = s.id);

-- Options
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order)
SELECT c.id, 'Un index partiel (Partial Index) avec WHERE status = ''PENDING''', true, 1
FROM challenges c WHERE c.title = 'Optimisation SQL sur statut rare'
                    AND NOT EXISTS (SELECT 1 FROM challenge_options WHERE challenge_id = c.id AND display_order = 1);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order)
SELECT c.id, 'Un index B-Tree standard sur la colonne status complète', false, 2
FROM challenges c WHERE c.title = 'Optimisation SQL sur statut rare'
                    AND NOT EXISTS (SELECT 1 FROM challenge_options WHERE challenge_id = c.id AND display_order = 2);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order)
SELECT c.id, 'Un index de type FULLTEXT sur toutes les colonnes', false, 3
FROM challenges c WHERE c.title = 'Optimisation SQL sur statut rare'
                    AND NOT EXISTS (SELECT 1 FROM challenge_options WHERE challenge_id = c.id AND display_order = 3);


-- -----------------------------------------------------------------------------
-- Challenge 10 : JPA / Hibernate / Cache de Niveau 1 & 2 - QCM Intermediate
-- -----------------------------------------------------------------------------
INSERT INTO challenges (title, type, difficulty, context, question, explanation, estimated_time_seconds, active, points, created_at, updated_at)
SELECT 'Portée du First-Level Cache', 'SITUATIONAL_QCM', 'INTERMEDIATE',
       'Tu effectues deux queries findById() consécutives sur la même entité au sein d''une même transaction.',
       'Quelle est la portée du cache de niveau 1 (First-Level Cache) dans Hibernate ?',
       'Le cache de premier niveau d''Hibernate est directement lié à la Session (ou EntityManager) courante. Il est nettoyé dès que la session/transaction se termine.',
       90, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM challenges WHERE title = 'Portée du First-Level Cache');

-- Categories & Skills
INSERT INTO challenge_categories (challenge_id, category_id)
SELECT c.id, cat.id FROM challenges c, categories cat
WHERE c.title = 'Portée du First-Level Cache' AND cat.name = 'JPA / Hibernate'
  AND NOT EXISTS (SELECT 1 FROM challenge_categories WHERE challenge_id = c.id AND category_id = cat.id);

INSERT INTO challenge_skills (challenge_id, skill_id)
SELECT c.id, s.id FROM challenges c, skills s
WHERE c.title = 'Portée du First-Level Cache' AND s.name = 'Performance Analysis'
  AND NOT EXISTS (SELECT 1 FROM challenge_skills WHERE challenge_id = c.id AND skill_id = s.id);

-- Options
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order)
SELECT c.id, 'La Session (ou EntityManager) courante', true, 1
FROM challenges c WHERE c.title = 'Portée du First-Level Cache'
                    AND NOT EXISTS (SELECT 1 FROM challenge_options WHERE challenge_id = c.id AND display_order = 1);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order)
SELECT c.id, 'Toute l''application (partagé entre tous les utilisateurs)', false, 2
FROM challenges c WHERE c.title = 'Portée du First-Level Cache'
                    AND NOT EXISTS (SELECT 1 FROM challenge_options WHERE challenge_id = c.id AND display_order = 2);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order)
SELECT c.id, 'La base de données PostgreSQL directement', false, 3
FROM challenges c WHERE c.title = 'Portée du First-Level Cache'
                    AND NOT EXISTS (SELECT 1 FROM challenge_options WHERE challenge_id = c.id AND display_order = 3);


-- -----------------------------------------------------------------------------
-- Challenge 11 : API / Backend / Idempotence HTTP - QCM Junior
-- -----------------------------------------------------------------------------
INSERT INTO challenges (title, type, difficulty, context, question, explanation, estimated_time_seconds, active, points, created_at, updated_at)
SELECT 'Idempotence des verbes HTTP', 'SITUATIONAL_QCM', 'JUNIOR',
       'Conception d''une API REST conforme aux standards.',
       'Parmi les verbes HTTP suivants, lequel N''EST PAS idempotent ?',
       'Un verbe est idempotent si l''exécuter plusieurs fois produit le même effet. POST n''est pas idempotent car appeler POST /users crée un nouvel utilisateur à chaque fois.',
       60, true, 10, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM challenges WHERE title = 'Idempotence des verbes HTTP');

-- Categories & Skills
INSERT INTO challenge_categories (challenge_id, category_id)
SELECT c.id, cat.id FROM challenges c, categories cat
WHERE c.title = 'Idempotence des verbes HTTP' AND cat.name = 'API / Backend'
  AND NOT EXISTS (SELECT 1 FROM challenge_categories WHERE challenge_id = c.id AND category_id = cat.id);

INSERT INTO challenge_skills (challenge_id, skill_id)
SELECT c.id, s.id FROM challenges c, skills s
WHERE c.title = 'Idempotence des verbes HTTP' AND s.name = 'Problem Solving'
  AND NOT EXISTS (SELECT 1 FROM challenge_skills WHERE challenge_id = c.id AND skill_id = s.id);

-- Options
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order)
SELECT c.id, 'POST', true, 1
FROM challenges c WHERE c.title = 'Idempotence des verbes HTTP'
                    AND NOT EXISTS (SELECT 1 FROM challenge_options WHERE challenge_id = c.id AND display_order = 1);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order)
SELECT c.id, 'PUT', false, 2
FROM challenges c WHERE c.title = 'Idempotence des verbes HTTP'
                    AND NOT EXISTS (SELECT 1 FROM challenge_options WHERE challenge_id = c.id AND display_order = 2);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order)
SELECT c.id, 'DELETE', false, 3
FROM challenges c WHERE c.title = 'Idempotence des verbes HTTP'
                    AND NOT EXISTS (SELECT 1 FROM challenge_options WHERE challenge_id = c.id AND display_order = 3);


-- -----------------------------------------------------------------------------
-- Challenge 12 : Distributed Systems / Cache / Cache-Aside - QCM Advanced
-- -----------------------------------------------------------------------------
INSERT INTO challenges (title, type, difficulty, context, question, explanation, estimated_time_seconds, active, points, created_at, updated_at)
SELECT 'Stratégie de cache Cache-Aside', 'SITUATIONAL_QCM', 'ADVANCED',
       'Mise en place d''un cache Redis devant une base de données SQL pour réduire le temps de réponse.',
       'Dans le pattern "Cache-Aside" (Lazy Loading), qui est responsable de lire la BDD et de mettre à jour le cache lors d''un Cache Miss ?',
       'Dans la stratégie Cache-Aside, c''est l''application backend elle-même qui interroge le cache, lit la BDD en cas de manquement, puis remplit le cache avant de retourner la donnée.',
       120, true, 20, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM challenges WHERE title = 'Stratégie de cache Cache-Aside');

-- Categories & Skills
INSERT INTO challenge_categories (challenge_id, category_id)
SELECT c.id, cat.id FROM challenges c, categories cat
WHERE c.title = 'Stratégie de cache Cache-Aside' AND cat.name = 'Distributed Systems'
  AND NOT EXISTS (SELECT 1 FROM challenge_categories WHERE challenge_id = c.id AND category_id = cat.id);

INSERT INTO challenge_skills (challenge_id, skill_id)
SELECT c.id, s.id FROM challenges c, skills s
WHERE c.title = 'Stratégie de cache Cache-Aside' AND s.name = 'Performance Analysis'
  AND NOT EXISTS (SELECT 1 FROM challenge_skills WHERE challenge_id = c.id AND skill_id = s.id);

-- Options
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order)
SELECT c.id, 'L''application backend', true, 1
FROM challenges c WHERE c.title = 'Stratégie de cache Cache-Aside'
                    AND NOT EXISTS (SELECT 1 FROM challenge_options WHERE challenge_id = c.id AND display_order = 1);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order)
SELECT c.id, 'Le serveur Redis de manière autonome', false, 2
FROM challenges c WHERE c.title = 'Stratégie de cache Cache-Aside'
                    AND NOT EXISTS (SELECT 1 FROM challenge_options WHERE challenge_id = c.id AND display_order = 2);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order)
SELECT c.id, 'La base de données relationnelle via un trigger', false, 3
FROM challenges c WHERE c.title = 'Stratégie de cache Cache-Aside'
                    AND NOT EXISTS (SELECT 1 FROM challenge_options WHERE challenge_id = c.id AND display_order = 3);