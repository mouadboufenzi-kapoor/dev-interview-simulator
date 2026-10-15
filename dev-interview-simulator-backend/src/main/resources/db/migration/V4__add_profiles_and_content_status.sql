CREATE TABLE IF NOT EXISTS profiles (
    id BIGSERIAL PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL UNIQUE,
    description TEXT,
    active BOOLEAN NOT NULL DEFAULT TRUE
);

INSERT INTO profiles (code, name, description, active)
VALUES (
    'DEVELOPER',
    'Développeur',
    'Développement logiciel, conception et résolution de problèmes techniques.',
    TRUE
)
ON CONFLICT (code) DO NOTHING;

ALTER TABLE challenges
    ADD COLUMN IF NOT EXISTS status VARCHAR(20) NOT NULL DEFAULT 'VALIDATED';

UPDATE challenges
SET status = 'VALIDATED'
WHERE status IS NULL;

ALTER TABLE challenges
    DROP CONSTRAINT IF EXISTS challenges_status_check;

ALTER TABLE challenges
    ADD CONSTRAINT challenges_status_check
    CHECK (status IN ('DRAFT', 'VALIDATED', 'ARCHIVED'));

CREATE TABLE IF NOT EXISTS challenge_profiles (
    challenge_id BIGINT NOT NULL,
    profile_id BIGINT NOT NULL,
    PRIMARY KEY (challenge_id, profile_id),
    CONSTRAINT fk_challenge_profiles_challenge
        FOREIGN KEY (challenge_id) REFERENCES challenges(id),
    CONSTRAINT fk_challenge_profiles_profile
        FOREIGN KEY (profile_id) REFERENCES profiles(id)
);

ALTER TABLE simulations
    ADD COLUMN IF NOT EXISTS profile_id BIGINT;

ALTER TABLE simulations
    DROP CONSTRAINT IF EXISTS fk_simulations_profile;

ALTER TABLE simulations
    ADD CONSTRAINT fk_simulations_profile
    FOREIGN KEY (profile_id) REFERENCES profiles(id);
