ALTER TABLE challenges
    ADD COLUMN IF NOT EXISTS scenario_id BIGINT,
    ADD COLUMN IF NOT EXISTS step_order INTEGER,
    ADD COLUMN IF NOT EXISTS revealed_information TEXT,
    ADD COLUMN IF NOT EXISTS tradeoff TEXT;

ALTER TABLE challenges
    DROP CONSTRAINT IF EXISTS challenges_type_check;

ALTER TABLE challenges
    ADD CONSTRAINT challenges_type_check
    CHECK (type IN ('SITUATIONAL_QCM', 'PROBLEM_SOLVING', 'CODE_REVIEW', 'ARCHITECTURE'));

ALTER TABLE simulations
    DROP CONSTRAINT IF EXISTS simulations_mode_check;

ALTER TABLE simulations
    ADD CONSTRAINT simulations_mode_check
    CHECK (mode IN ('SITUATIONAL_QCM', 'PROBLEM_SOLVING', 'CODE_REVIEW', 'ARCHITECTURE'));

CREATE TABLE IF NOT EXISTS interview_scenarios (
    id BIGSERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL UNIQUE,
    description TEXT,
    mode VARCHAR(30) NOT NULL,
    active BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE INDEX IF NOT EXISTS idx_interview_scenarios_mode_active
    ON interview_scenarios (mode, active);

ALTER TABLE challenges
    DROP CONSTRAINT IF EXISTS fk_challenges_scenario;

ALTER TABLE challenges
    ADD CONSTRAINT fk_challenges_scenario
    FOREIGN KEY (scenario_id) REFERENCES interview_scenarios(id);

ALTER TABLE interview_scenarios
    DROP CONSTRAINT IF EXISTS interview_scenarios_mode_check;

ALTER TABLE interview_scenarios
    ADD CONSTRAINT interview_scenarios_mode_check
    CHECK (mode = 'ARCHITECTURE');

ALTER TABLE challenges
    DROP CONSTRAINT IF EXISTS challenges_architecture_step_order_check;

ALTER TABLE challenges
    ADD CONSTRAINT challenges_architecture_step_order_check
    CHECK (step_order IS NULL OR step_order > 0);

CREATE UNIQUE INDEX IF NOT EXISTS uq_challenges_scenario_step_order
    ON challenges (scenario_id, step_order)
    WHERE scenario_id IS NOT NULL AND step_order IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_challenges_scenario_order
    ON challenges (scenario_id, step_order);
