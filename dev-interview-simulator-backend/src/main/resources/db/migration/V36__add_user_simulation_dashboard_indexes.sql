CREATE INDEX IF NOT EXISTS idx_simulations_user_started_id
    ON simulations (user_id, started_at DESC, id DESC);

CREATE INDEX IF NOT EXISTS idx_simulation_challenges_simulation_id
    ON simulation_challenges (simulation_id);
