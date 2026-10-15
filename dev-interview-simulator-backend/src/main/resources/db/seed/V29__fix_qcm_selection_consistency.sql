-- =====================================================================
-- V29 — Correction de cohérence QCM : selection_type vs bonnes réponses
--
-- Audit statique du catalogue (277 QCM) — 88 incohérences :
--   A) 85 QCM déclarés SINGLE_CHOICE mais portant 2 à 4 options
--      is_correct = TRUE (lots V16-V20 + V28). Questions composées
--      (« quelle cause et quel réglage ? ») : le contenu est correct,
--      c'est le mode de sélection qui est faux → MULTIPLE_CHOICE.
--   B) 3 QCM déclarés MULTIPLE_CHOICE avec une seule option vraie :
--      - 'Collections final non modifiable ?'   → SINGLE (+ question au singulier)
--      - 'React : useReducer plutôt que useState' → SINGLE
--      - 'SD : les politiques d''écriture du cache' → la réponse unique
--        éclatée en 3 options vraies (write-through / write-back /
--        write-around), le MULTIPLE est conservé (question au pluriel).
--
-- Aucune option vraie n'est supprimée, aucun contenu n'est reformulé
-- hors la question V16 et l'éclatement V25 (décrit ci-dessus).
--
-- Idempotence : UPDATE bornés à l'état attendu, INSERT sous NOT EXISTS.
-- Les seeds V16-V28 ne sont PAS modifiés (migrations déjà appliquées —
-- un édit casserait le checksum Flyway) ; cette V29 s'applique à la fois
-- aux bases existantes et aux installations neuves (après V28).
--
-- Contrôle attendu après exécution : 0 ligne
--   SELECT c.title, c.selection_type, count(*) FILTER (WHERE o.is_correct) AS bonnes
--   FROM challenges c JOIN challenge_options o ON o.challenge_id = c.id
--   WHERE c.type = 'SITUATIONAL_QCM'
--   GROUP BY c.title, c.selection_type
--   HAVING (c.selection_type = 'SINGLE_CHOICE'   AND count(*) FILTER (WHERE o.is_correct) <> 1)
--       OR (c.selection_type = 'MULTIPLE_CHOICE' AND count(*) FILTER (WHERE o.is_correct) <  2);
-- =====================================================================

-- ---------------------------------------------------------------------
-- A) 85 QCM composés → MULTIPLE_CHOICE
-- ---------------------------------------------------------------------
UPDATE challenges
SET selection_type = 'MULTIPLE_CHOICE', updated_at = CURRENT_TIMESTAMP
WHERE type = 'SITUATIONAL_QCM'
  AND selection_type = 'SINGLE_CHOICE'
  AND title IN (
  'ConcurrentModificationException dans une boucle',
  'UnsupportedOperationException inattendu',
  'allOf et la première exception',
  'parallelStream en environnement serveur',
  'thenApply ou thenCompose',
  'Spring : 400 au lieu de 500 sur entrée invalide',
  'Spring : 401 généralisé après ajout de Spring Security',
  'Spring : @Async par défaut',
  'Spring : LazyInitializationException',
  'Spring : NPE après new sur une classe annotée',
  'Spring : appel interne et @Transactional',
  'Spring : cache partagé sur la mauvaise clé',
  'Spring : connexions Hikari jamais rendues',
  'Spring : deux hachages différents pour le même mot de passe',
  'Spring : décorateur de réponse en 500',
  'Spring : exception métier attrapée = rollback manqué',
  'Spring : fermeture manquante au shutdown',
  'Spring : fixedRate vs fixedDelay',
  'Spring : la variable d''environnement est ignorée',
  'Spring : migration jakarta.* après saut de version',
  'Spring : profils d''environnement',
  'Spring : transaction longue qui grève le pool',
  'Spring : échec concurrent sur version optimiste',
  'Spring : exceptions perdues en @Async',
  'Spring : prototype injecté dans un singleton',
  'SQL : OFFSET profond sur une table chargée',
  'SQL : ORDER BY absent sur une pagination',
  'SQL : UNION contre UNION ALL',
  'SQL : clé étrangère sans index',
  'SQL : compteur concurrent et mise à jour perdue',
  'SQL : deadlock entre deux transactions',
  'SQL : le filtre sur NULL ne filtre jamais',
  'SQL : lignes dupliquées après un LEFT JOIN',
  'SQL : mise à jour globale sans ciblage',
  'SQL : montants en DOUBLE PRECISION',
  'SQL : motif LIKE et types d''index',
  'SQL : niveaux d''isolation et lecture fantôme',
  'SQL : ordre des colonnes d''un index composite',
  'SQL : upsert et course entre deux écritures',
  'SQL : le planificateur choisit un seq scan',
  'SQL : anomalies de sérialisation sous forte charge',
  'SQL : cast implicite dans une jointure',
  'SQL : expression sur colonne = index ignoré',
  'SQL : index BRIN sur une table temporelle',
  'SQL : plan dégradé après montée de volumétrie',
  'SQL : sous-requête corrélée exécutée par ligne',
  'SQL : autovacuum ne suit plus la charge',
  'JPA : insertions massives sans batch',
  'JPA : association bidirectionnelle — quel côté porte la clé',
  'JPA : clé de jointure supplémentaire en ManyToMany',
  'JPA : entité détachée modifiée sans effet',
  'JPA : entités dans un HashSet',
  'JPA : enum stocké en ORDINAL',
  'JPA : horodatages en base et en Java',
  'JPA : l''id n''est renseigné qu''après le flush',
  'JPA : tri dynamique depuis un paramètre utilisateur',
  'JPA : « No path defined » dans une requête JPQL',
  'JPA : états d''entité — réattacher un objet',
  'JPA : cascade REMOVE sur un objet partagé',
  'JPA : flush automatique inopiné',
  'JPA : ordre d''insertion et clés étrangères',
  'JPA : pagination avec jointures fetchées',
  'JPA : requête native contre JPQL',
  'JPA : suppression par retrait de collection',
  'JPA : séquences et batch — hi-lo',
  'API : PUT ou PATCH pour modifier deux champs',
  'API : message CORS illisible dans la console',
  'API : CORS, wildcard et credentiels',
  'API : 429 et Retry-After',
  'API : BFF et front qui parle au micro-service interne',
  'API : Idempotency-Key sur les POST critiques',
  'API : SSE, WebSocket ou polling',
  'API : absent, null ou chaîne vide en PATCH',
  'API : concurrence sur la même ressource (If-Match)',
  'API : corps de requête sans limite',
  'API : enveloppe de liste paginée',
  'API : identifiant de chemin non numérique',
  'API : isolation multi-tenant et IDOR',
  'API : rate limiting derrière un proxy',
  'API : traitement long et 202 Accepted',
  'API : un client casse après un renommage de champ',
  'CI : file de merge et main toujours verte',
  'CI : pipelines sélectifs en monorepo',
  'CI : schéma et application ne se déploient pas au même rythme',
  'CI : infrastructure as code dans le pipeline'
);

-- ---------------------------------------------------------------------
-- B1) 'Collections final non modifiable ?' → SINGLE : une seule
--     affirmation est vraie ; question reformulée au singulier.
-- ---------------------------------------------------------------------
UPDATE challenges
SET selection_type = 'SINGLE_CHOICE', updated_at = CURRENT_TIMESTAMP
WHERE type = 'SITUATIONAL_QCM'
  AND selection_type = 'MULTIPLE_CHOICE'
  AND title = 'Collections final non modifiable ?';

UPDATE challenges
SET question = 'Quelle affirmation est exacte ?', updated_at = CURRENT_TIMESTAMP
WHERE title = 'Collections final non modifiable ?'
  AND question LIKE 'Quelles affirmations%';

-- ---------------------------------------------------------------------
-- B2) 'React : useReducer plutôt que useState' → SINGLE : une seule
--     réponse vraie, question déjà au singulier.
-- ---------------------------------------------------------------------
UPDATE challenges
SET selection_type = 'SINGLE_CHOICE', updated_at = CURRENT_TIMESTAMP
WHERE type = 'SITUATIONAL_QCM'
  AND selection_type = 'MULTIPLE_CHOICE'
  AND title = 'React : useReducer plutôt que useState';

-- ---------------------------------------------------------------------
-- B3) 'SD : les politiques d''écriture du cache' → MULTIPLE conservé
--     (question au pluriel) : la réponse unique éclatée en 3 politiques.
-- ---------------------------------------------------------------------
UPDATE challenge_options o
SET content = 'Write-through : chaque écriture traverse le cache puis la base — visibilité immédiate, latence d''écriture payée à chaque opération',
    explanation = 'Sûreté de l''écriture et lecture fraîche immédiate, au prix du débit d''écriture.'
FROM challenges c
WHERE o.challenge_id = c.id
  AND c.title = 'SD : les politiques d''écriture du cache'
  AND o.content = 'Write-through paie la latence d''écriture, write-back le risque de perte, write-around la lecture froide';

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.ord, v.explanation
FROM challenges c,
(VALUES
('Write-back : le cache absorbe les écritures et les réplique en différé — débit d''écriture maximal, risque de perte tant que le flush n''a pas eu lieu', true, 5,
 'La fenêtre entre l''écriture cache et le flush reste une fenêtre de perte assumée.'),
('Write-around : l''écriture contourne le cache — aucun coût d''écriture supplémentaire, mais lecture froide jusqu''à la prochaine écriture', true, 6,
 'Adapté aux données rarement relues juste après écriture.')
) AS v(content, is_correct, ord, explanation)
WHERE c.title = 'SD : les politiques d''écriture du cache'
  AND NOT EXISTS (
    SELECT 1 FROM challenge_options o
    WHERE o.challenge_id = c.id AND o.display_order = v.ord
  );
