CREATE UNIQUE INDEX IF NOT EXISTS uq_challenges_external_id
    ON challenges (external_id);

CREATE UNIQUE INDEX IF NOT EXISTS uq_challenges_content_hash
    ON challenges (content_hash);
