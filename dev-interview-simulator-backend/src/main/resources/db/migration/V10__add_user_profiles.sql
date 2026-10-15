-- Squelette multiprofil (oct. 2026) : rattachement des utilisateurs aux profils.
-- user_profiles        = table de jointure User <-> Profile (M:N), socle du futur
--                        « un utilisateur -> plusieurs profils métier ».
-- active_profile_id    = profil actif de l'utilisateur (nullable : null = aucun
--                        profil actif, comportement strictement identique à avant).
-- Aucun profil n'est cree ici : DEVELOPER est le seul profil reel de l'application.

CREATE TABLE IF NOT EXISTS user_profiles (
    user_id BIGINT NOT NULL,
    profile_id BIGINT NOT NULL,
    PRIMARY KEY (user_id, profile_id),
    CONSTRAINT fk_user_profiles_user
        FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT fk_user_profiles_profile
        FOREIGN KEY (profile_id) REFERENCES profiles(id)
);

ALTER TABLE users
    ADD COLUMN IF NOT EXISTS active_profile_id BIGINT;

ALTER TABLE users
    DROP CONSTRAINT IF EXISTS fk_users_active_profile;

ALTER TABLE users
    ADD CONSTRAINT fk_users_active_profile
        FOREIGN KEY (active_profile_id) REFERENCES profiles(id);

-- Backfill : chaque utilisateur existant (dont default_user) est rattache au
-- profil DEVELOPER, qui devient son profil actif. Idempotent.
INSERT INTO user_profiles (user_id, profile_id)
SELECT u.id, p.id
FROM users u
CROSS JOIN profiles p
WHERE p.code = 'DEVELOPER'
ON CONFLICT (user_id, profile_id) DO NOTHING;

UPDATE users u
SET active_profile_id = p.id
FROM profiles p
WHERE p.code = 'DEVELOPER'
  AND u.active_profile_id IS NULL;
