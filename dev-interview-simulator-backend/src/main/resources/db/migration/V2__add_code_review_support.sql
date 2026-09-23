ALTER TABLE challenges
    ADD COLUMN IF NOT EXISTS selection_type VARCHAR(20) DEFAULT 'SINGLE_CHOICE',
    ADD COLUMN IF NOT EXISTS code_snippet TEXT,
    ADD COLUMN IF NOT EXISTS code_language VARCHAR(30);

ALTER TABLE challenge_options
    ADD COLUMN IF NOT EXISTS severity VARCHAR(30),
    ADD COLUMN IF NOT EXISTS explanation TEXT;

ALTER TABLE challenges
    DROP CONSTRAINT IF EXISTS challenges_type_check;

ALTER TABLE challenges
    ADD CONSTRAINT challenges_type_check
    CHECK (type IN ('SITUATIONAL_QCM', 'PROBLEM_SOLVING', 'CODE_REVIEW'));

UPDATE challenges
SET selection_type = 'SINGLE_CHOICE'
WHERE selection_type IS NULL;

ALTER TABLE simulation_answers
    ALTER COLUMN selected_option_id DROP NOT NULL;

CREATE TABLE IF NOT EXISTS simulation_answer_options (
    simulation_answer_id BIGINT NOT NULL,
    option_id BIGINT NOT NULL,
    PRIMARY KEY (simulation_answer_id, option_id),
    CONSTRAINT fk_simulation_answer_options_answer
        FOREIGN KEY (simulation_answer_id) REFERENCES simulation_answers(id),
    CONSTRAINT fk_simulation_answer_options_option
        FOREIGN KEY (option_id) REFERENCES challenge_options(id)
);

INSERT INTO simulation_answer_options (simulation_answer_id, option_id)
SELECT id, selected_option_id
FROM simulation_answers
WHERE selected_option_id IS NOT NULL
  AND NOT EXISTS (
      SELECT 1
      FROM simulation_answer_options sao
      WHERE sao.simulation_answer_id = simulation_answers.id
        AND sao.option_id = simulation_answers.selected_option_id
  );
