-- Suite de V11 (type SEQUENTIAL_REASONING) : la table simulations porte sa
-- PROPRE contrainte CHECK sur le mode, distincte de challenges_type_check.
-- V11 n'avait étendu que celle des challenges — l'insertion d'une simulation
-- SEQUENTIAL_REASONING échouait sur simulations_mode_check (DataIntegrityViolation
-- → 409 « L'opération ne peut pas être effectuée avec ces données »).
-- Même pattern DROP/ADD que V2/V3.

ALTER TABLE simulations DROP CONSTRAINT IF EXISTS simulations_mode_check;
ALTER TABLE simulations ADD CONSTRAINT simulations_mode_check
    CHECK (mode IN ('SITUATIONAL_QCM', 'PROBLEM_SOLVING', 'CODE_REVIEW', 'ARCHITECTURE', 'SEQUENTIAL_REASONING'));
