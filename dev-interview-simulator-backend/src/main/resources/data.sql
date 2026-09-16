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