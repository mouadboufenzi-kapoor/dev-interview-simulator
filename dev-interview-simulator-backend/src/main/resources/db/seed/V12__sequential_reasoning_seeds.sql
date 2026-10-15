-- ===============================================
-- Raisonnement séquentiel (type V11) — défis de démonstration
-- Modèle : les étapes sont des challenge_options —
--   display_order = ordre ATTENDU, is_correct = TRUE (toutes les étapes font
--   partie de la réponse), explanation = raison de l'étape à ce rang.
-- ===============================================

INSERT INTO challenges (title, type, difficulty, context, question, explanation, estimated_time_seconds, active, points, created_at, updated_at)
SELECT 'Diagnostic d''un bug en production', 'SEQUENTIAL_REASONING', 'INTERMEDIATE',
       'Un endpoint REST commence à retourner des 500 par intermittence depuis la mise en production de ce matin.',
       'Remets ces étapes de diagnostic dans l''ordre logique que suivrait un ingénieur expérimenté.',
       'Le bon diagnostic va du signal (logs) vers la reproduction, puis de l''hypothèse à la preuve (test) : on ne corrige jamais sans reproduction ni test de non-régression.',
       180, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM challenges WHERE title = 'Diagnostic d''un bug en production');

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, 'Consulter les logs et isoler la stack trace', true, 1,
       'On part toujours du signal observable : les logs donnent le contexte exact de l''erreur.'
FROM challenges c WHERE c.title = 'Diagnostic d''un bug en production'
  AND NOT EXISTS (SELECT 1 FROM challenge_options WHERE challenge_id = c.id AND display_order = 1);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, 'Identifier la dernière modification déployée (changelog / git log)', true, 2,
       'Un bug apparu après une mise en production a très probablement une cause dans la dernière diff.'
FROM challenges c WHERE c.title = 'Diagnostic d''un bug en production'
  AND NOT EXISTS (SELECT 1 FROM challenge_options WHERE challenge_id = c.id AND display_order = 2);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, 'Reproduire le bug en local avec des données similaires', true, 3,
       'Sans reproduction, aucune hypothèse ne peut être ni confirmée ni infirmée.'
FROM challenges c WHERE c.title = 'Diagnostic d''un bug en production'
  AND NOT EXISTS (SELECT 1 FROM challenge_options WHERE challenge_id = c.id AND display_order = 3);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, 'Formuler une hypothèse de cause racine', true, 4,
       'La reproduction permet d''isoler les variables et d''émettre une hypothèse précise, testable.'
FROM challenges c WHERE c.title = 'Diagnostic d''un bug en production'
  AND NOT EXISTS (SELECT 1 FROM challenge_options WHERE challenge_id = c.id AND display_order = 4);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, 'Écrire un test qui reproduit le bug, corriger, puis vérifier la non-régression', true, 5,
       'Le test fige le diagnostic : il prouve le correctif et protège contre toute récidive.'
FROM challenges c WHERE c.title = 'Diagnostic d''un bug en production'
  AND NOT EXISTS (SELECT 1 FROM challenge_options WHERE challenge_id = c.id AND display_order = 5);

INSERT INTO challenge_categories (challenge_id, category_id)
SELECT c.id, cat.id FROM challenges c, categories cat
WHERE c.title = 'Diagnostic d''un bug en production' AND cat.name = 'Java'
  AND NOT EXISTS (SELECT 1 FROM challenge_categories WHERE challenge_id = c.id AND category_id = cat.id);

INSERT INTO challenge_skills (challenge_id, skill_id)
SELECT c.id, s.id FROM challenges c, skills s
WHERE c.title = 'Diagnostic d''un bug en production' AND s.name = 'Debugging'
  AND NOT EXISTS (SELECT 1 FROM challenge_skills WHERE challenge_id = c.id AND skill_id = s.id);

INSERT INTO challenge_profiles (challenge_id, profile_id)
SELECT c.id, p.id FROM challenges c, profiles p
WHERE c.title = 'Diagnostic d''un bug en production' AND p.code = 'DEVELOPER'
  AND NOT EXISTS (SELECT 1 FROM challenge_profiles WHERE challenge_id = c.id AND profile_id = p.id);

-- -----------------------------------------------

INSERT INTO challenges (title, type, difficulty, context, question, explanation, estimated_time_seconds, active, points, created_at, updated_at)
SELECT 'Créer un test unitaire JUnit 5', 'SEQUENTIAL_REASONING', 'JUNIOR',
       'On te demande d''écrire ton premier test unitaire JUnit 5 pour une méthode de service.',
       'Remets ces étapes dans l''ordre logique d''une démarche de création de test unitaire.',
       'Une démarche de test suit toujours : comportement → structure du test → données → assertions → exécution. Les tests sont écrits pour les comportements, pas pour les lignes de code.',
       120, true, 10, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM challenges WHERE title = 'Créer un test unitaire JUnit 5');

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, 'Identifier précisément le comportement à vérifier', true, 1,
       'On teste un comportement observable, jamais une implémentation : le comportement définit le test.'
FROM challenges c WHERE c.title = 'Créer un test unitaire JUnit 5'
  AND NOT EXISTS (SELECT 1 FROM challenge_options WHERE challenge_id = c.id AND display_order = 1);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, 'Créer la classe de test et annoter la méthode avec @Test', true, 2,
       'La structure du test (classe *Test, méthode @Test) existe avant d''y placer la logique.'
FROM challenges c WHERE c.title = 'Créer un test unitaire JUnit 5'
  AND NOT EXISTS (SELECT 1 FROM challenge_options WHERE challenge_id = c.id AND display_order = 2);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, 'Préparer les données de départ (Given)', true, 3,
       'Les données de l''état initial doivent être en place avant d''appeler le code testé.'
FROM challenges c WHERE c.title = 'Créer un test unitaire JUnit 5'
  AND NOT EXISTS (SELECT 1 FROM challenge_options WHERE challenge_id = c.id AND display_order = 3);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, 'Appeler la méthode testée puis poser les assertions (When / Then)', true, 4,
       'L''action et la vérification viennent une fois les données prêtes : c''est le cœur du test.'
FROM challenges c WHERE c.title = 'Créer un test unitaire JUnit 5'
  AND NOT EXISTS (SELECT 1 FROM challenge_options WHERE challenge_id = c.id AND display_order = 4);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, 'Exécuter le test et ajuster le code ou le test jusqu''au vert', true, 5,
       'La dernière étape valide l''ensemble : un test non exécuté n''est pas encore un test.'
FROM challenges c WHERE c.title = 'Créer un test unitaire JUnit 5'
  AND NOT EXISTS (SELECT 1 FROM challenge_options WHERE challenge_id = c.id AND display_order = 5);

INSERT INTO challenge_categories (challenge_id, category_id)
SELECT c.id, cat.id FROM challenges c, categories cat
WHERE c.title = 'Créer un test unitaire JUnit 5' AND cat.name = 'Testing'
  AND NOT EXISTS (SELECT 1 FROM challenge_categories WHERE challenge_id = c.id AND category_id = cat.id);

INSERT INTO challenge_skills (challenge_id, skill_id)
SELECT c.id, s.id FROM challenges c, skills s
WHERE c.title = 'Créer un test unitaire JUnit 5' AND s.name = 'Code Quality'
  AND NOT EXISTS (SELECT 1 FROM challenge_skills WHERE challenge_id = c.id AND skill_id = s.id);

INSERT INTO challenge_profiles (challenge_id, profile_id)
SELECT c.id, p.id FROM challenges c, profiles p
WHERE c.title = 'Créer un test unitaire JUnit 5' AND p.code = 'DEVELOPER'
  AND NOT EXISTS (SELECT 1 FROM challenge_profiles WHERE challenge_id = c.id AND profile_id = p.id);
