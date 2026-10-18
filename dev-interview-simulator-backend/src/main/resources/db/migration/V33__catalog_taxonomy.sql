-- =====================================================================
-- V33 — Taxonomie du catalogue (catégories et skills)
--
-- Placee dans db/migration (config Flyway unique : classpath:db/migration,
-- classpath:db/seed). Numero V33 : superieur a tous les seeds (V21, V22,
-- V26, V27 recreent React/Git/Docker/Testing/Code Review) et a V31/V32,
-- donc executee en dernier sur une base neuve comme sur une base existante.
--
-- Idempotent : re-executable sans erreur (ON CONFLICT DO NOTHING,
-- WHERE nom ancien, DELETE sans effet si deja fait).
--
-- Ordre des instructions (NE PAS REORDONNER) :
--   1) Ajout des nouveaux skills
--   2) Renommage Testing -> Test Design
--   3) Fusion Code Review -> Code Quality (reaffectation des liens sans
--      doublon de clé) + description Code Quality
--   4) Rattachements : Architecture Reasoning (type ARCHITECTURE),
--      Trade-off Analysis (champ tradeoff renseigne)
--   5) Problem Solving par defaut (questions dont les SEULS skills etaient
--      React, Git ou Docker) — AVANT les suppressions
--   6) Suppressions des liens puis des skills React, Git, Docker,
--      Code Review
--   7) Description DevOps resserree
-- =====================================================================

-- 1) Ajouts
INSERT INTO skills (name, description) VALUES
 ('Architecture Reasoning', 'Raisonnement sur les choix structurants d''un système'),
 ('Trade-off Analysis', 'Comparaison argumentée d''options contradictoires')
ON CONFLICT (name) DO NOTHING;

-- 2) Renommage
UPDATE skills SET name = 'Test Design', description = 'Conception de tests : stratégie, cas limites, mocking, TDD' WHERE name = 'Testing';

-- 3) Fusion Code Review vers Code Quality
INSERT INTO challenge_skills (challenge_id, skill_id)
SELECT cs.challenge_id, tgt.id
FROM challenge_skills cs
JOIN skills src ON src.id = cs.skill_id AND src.name = 'Code Review'
JOIN skills tgt ON tgt.name = 'Code Quality'
ON CONFLICT DO NOTHING;
UPDATE skills SET description = 'Évaluer et produire du code lisible, maintenable et bien structuré' WHERE name = 'Code Quality';

-- 4) Rattachements
INSERT INTO challenge_skills (challenge_id, skill_id)
SELECT ch.id, s.id FROM challenges ch JOIN skills s ON s.name = 'Architecture Reasoning'
WHERE ch.type = 'ARCHITECTURE'
ON CONFLICT DO NOTHING;
INSERT INTO challenge_skills (challenge_id, skill_id)
SELECT ch.id, s.id FROM challenges ch JOIN skills s ON s.name = 'Trade-off Analysis'
WHERE ch.tradeoff IS NOT NULL AND btrim(ch.tradeoff) <> ''
ON CONFLICT DO NOTHING;

-- 5) Problem Solving par défaut pour les questions dont les seuls skills étaient React, Git ou Docker
INSERT INTO challenge_skills (challenge_id, skill_id)
SELECT ch.id, ps.id
FROM challenges ch
JOIN skills ps ON ps.name = 'Problem Solving'
WHERE EXISTS (SELECT 1 FROM challenge_skills cs JOIN skills s ON s.id = cs.skill_id
              WHERE cs.challenge_id = ch.id AND s.name IN ('React', 'Git', 'Docker'))
  AND NOT EXISTS (SELECT 1 FROM challenge_skills cs JOIN skills s ON s.id = cs.skill_id
              WHERE cs.challenge_id = ch.id AND s.name NOT IN ('React', 'Git', 'Docker'))
ON CONFLICT DO NOTHING;

-- 6) Suppressions
DELETE FROM challenge_skills cs USING skills s
WHERE s.id = cs.skill_id AND s.name IN ('React', 'Git', 'Docker', 'Code Review');
DELETE FROM skills WHERE name IN ('React', 'Git', 'Docker', 'Code Review');

-- 7) Description DevOps
UPDATE categories SET description = 'Cloud, observabilité, déploiement, environnements et infrastructure.' WHERE name = 'DevOps';
