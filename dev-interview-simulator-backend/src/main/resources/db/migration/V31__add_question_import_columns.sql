ALTER TABLE public.challenges
    ADD COLUMN IF NOT EXISTS external_id VARCHAR(100);

ALTER TABLE public.challenges
    ADD COLUMN IF NOT EXISTS content_hash VARCHAR(64);
