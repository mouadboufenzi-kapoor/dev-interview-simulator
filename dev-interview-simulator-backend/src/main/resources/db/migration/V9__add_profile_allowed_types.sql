CREATE TABLE IF NOT EXISTS profile_challenge_types (
    profile_id BIGINT NOT NULL,
    challenge_type VARCHAR(30) NOT NULL,
    PRIMARY KEY (profile_id, challenge_type),
    CONSTRAINT fk_profile_challenge_types_profile
        FOREIGN KEY (profile_id) REFERENCES profiles (id)
        ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_profile_challenge_types_type
    ON profile_challenge_types (challenge_type);
