-- Google OAuth (V1) : colonnes d'identité Google sur les comptes existants.
-- Ajout puralement additif : aucun compte existant n'est modifie (NULL partout).
--
-- google_sub   = identifiant STABLE et unique du compte Google (claim "sub").
--                Cle de matching prioritaire : l'email Google peut changer,
--                le sub non. UNIQUE : un compte Google ne peut etre lie
--                qu'a un seul compte local (account linking).
-- picture_url  = avatar Google (optionnel ; l'UI affiche des initiales).

ALTER TABLE users
    ADD COLUMN IF NOT EXISTS google_sub VARCHAR(255);

ALTER TABLE users
    ADD COLUMN IF NOT EXISTS picture_url VARCHAR(512);

CREATE UNIQUE INDEX IF NOT EXISTS users_google_sub_key
    ON users (google_sub);
