-- =====================================================================
-- Catalogue V1 — Ajout des catégories manquantes (stratégie validée)
-- React, Git, Docker, CI / CD : catégories explicitement demandées pour la
-- matrice V1 du profil DEVELOPER. Idempotent : UNIQUE (name) + DO NOTHING.
-- Appliqué en V15, donc AVANT les seeds de contenu V16..V28.
-- =====================================================================

INSERT INTO categories (name, description)
VALUES
    ('React', 'React, composants, hooks, état, rendu et écosystème front-end moderne.'),
    ('Git', 'Workflow Git, branches, merge/rebase, historique et collaboration.'),
    ('Docker', 'Images, conteneurs, Dockerfile, volumes, réseaux et bonnes pratiques de conteneurisation.'),
    ('CI / CD', 'Pipelines d''intégration et de livraison continue, automatisation, tests et déploiement.')
ON CONFLICT (name) DO NOTHING;
