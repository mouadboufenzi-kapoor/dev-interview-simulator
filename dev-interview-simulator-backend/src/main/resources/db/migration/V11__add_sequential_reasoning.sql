-- Type de challenge « Raisonnement séquentiel » (oct. 2026).
-- L'utilisateur remet des étapes dans l'ordre logique (drag & drop).
-- Modèle : les étapes sont les challenge_options existantes —
--   display_order = ordre ATTENDU, is_correct = true, explanation = raison de l'étape.

ALTER TABLE challenges DROP CONSTRAINT IF EXISTS challenges_type_check;
ALTER TABLE challenges ADD CONSTRAINT challenges_type_check
    CHECK (type IN ('SITUATIONAL_QCM', 'PROBLEM_SOLVING', 'CODE_REVIEW', 'ARCHITECTURE', 'SEQUENTIAL_REASONING'));

-- Position de chaque étape dans la RÉPONSE de l'utilisateur, sur la jointure
-- simulation_answer_options. NULL pour les types classiques (QCM, etc.) :
-- compatibilité totale avec le comportement existant.
ALTER TABLE simulation_answer_options ADD COLUMN IF NOT EXISTS answer_position INTEGER;
