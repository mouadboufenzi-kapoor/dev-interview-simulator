package com.interview.simulator.auth.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.math.BigInteger;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.security.KeyFactory;
import java.security.PublicKey;
import java.security.interfaces.RSAPublicKey;
import java.time.Duration;
import java.time.Instant;
import java.util.Base64;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;

/**
 * Verifie un ID token Google (Google Identity Services) cote serveur.
 *
 * Verification complete, jamais de confiance au payload decode seul :
 *  1. signature RS256 contre les cles publiques JWKS de Google (cache) ;
 *  2. aud == GOOGLE_CLIENT_ID ;
 *  3. iss dans {accounts.google.com, https://accounts.google.com} ;
 *  4. exp non depasse (gere par la parsing jjwt) ;
 *  5. email_verified == true.
 *
 * Aucun secret Google n'est necessaire ici (option A du guide) : seules les
 * cles PUBLIques de Google sont utilisees. L'ID token n'est jamais stocke.
 */
@Service
public class GoogleIdTokenVerifier {

    private static final Logger logger = LoggerFactory.getLogger(GoogleIdTokenVerifier.class);

    private static final String JWKS_URI = "https://www.googleapis.com/oauth2/v3/certs";
    private static final Set<String> ALLOWED_ISSUERS =
            Set.of("accounts.google.com", "https://accounts.google.com");
    private static final Duration JWKS_CACHE_TTL = Duration.ofMinutes(30);
    private static final Duration HTTP_TIMEOUT = Duration.ofSeconds(5);

    private final String clientId;
    private final ObjectMapper objectMapper;
    private final HttpClient httpClient;

    /** Cles JWKS en cache : kid -> cle publique. */
    private final Map<String, RSAPublicKey> jwksCache = new HashMap<>();
    private Instant jwksFetchedAt;

    public GoogleIdTokenVerifier(
            @Value("${app.security.google.client-id:}") String clientId,
            ObjectMapper objectMapper) {
        this.clientId = clientId;
        this.objectMapper = objectMapper;
        this.httpClient = HttpClient.newBuilder().connectTimeout(HTTP_TIMEOUT).build();
    }

    /**
     * Profil Google verifie, tel qu'extrait du token une fois valide.
     */
    public record GoogleProfile(
            String sub,
            String email,
            String givenName,
            String familyName,
            String picture) {
    }

    /**
     * Verifie le token et retourne le profil verifie.
     *
     * @throws ResponseStatusException 401 si le token est absent/invalide/expire,
     *         email non verifiee, ou si la configuration Google manque.
     */
    public GoogleProfile verify(String idToken) {
        if (clientId == null || clientId.isBlank()) {
            logger.error("GOOGLE_CLIENT_ID manquant : connexion Google non configurée.");
            throw new ResponseStatusException(HttpStatus.SERVICE_UNAVAILABLE,
                    "Connexion Google non configurée.");
        }
        if (idToken == null || idToken.isBlank()) {
            throw unauthorized();
        }

        try {
            String kid = extractKid(idToken);
            RSAPublicKey key = resolveKey(kid);

            // La parsing jjwt verifie la signature + l'expiration.
            Claims claims = Jwts.parser()
                    .verifyWith(key)
                    .build()
                    .parseSignedClaims(idToken)
                    .getPayload();

            // aud : le token doit avoir ete emis POUR notre application.
            Set<String> audiences = claims.getAudience();
            if (audiences == null || !audiences.contains(clientId)) {
                throw unauthorized();
            }
            if (!ALLOWED_ISSUERS.contains(claims.getIssuer())) {
                throw unauthorized();
            }

            String email = claims.get("email", String.class);
            Object emailVerified = claims.get("email_verified");
            boolean verified = Boolean.TRUE.equals(emailVerified)
                    || "true".equalsIgnoreCase(String.valueOf(emailVerified));
            if (email == null || email.isBlank() || !verified) {
                // Refus : un compte Google non verifie pourrait revendiquer l'email d'un autre.
                throw new ResponseStatusException(HttpStatus.UNAUTHORIZED,
                        "L'adresse e-mail Google doit être vérifiée.");
            }
            String sub = claims.getSubject();
            if (sub == null || sub.isBlank()) {
                throw unauthorized();
            }

            return new GoogleProfile(
                    sub,
                    email,
                    claims.get("given_name", String.class),
                    claims.get("family_name", String.class),
                    claims.get("picture", String.class));
        } catch (ResponseStatusException e) {
            throw e;
        } catch (Exception e) {
            // Ne jamais logger le contenu du token.
            logger.debug("Échec de vérification du token Google : {}", e.getMessage());
            throw unauthorized();
        }
    }

    private ResponseStatusException unauthorized() {
        return new ResponseStatusException(HttpStatus.UNAUTHORIZED,
                "Connexion Google invalide ou expirée.");
    }

    /** Extrait le key id de l'en-tete JWT (premiere partie base64url). */
    private String extractKid(String idToken) throws Exception {
        String[] parts = idToken.split("\\.");
        if (parts.length != 3) {
            throw new IllegalArgumentException("Token JWT malformé.");
        }
        byte[] header = Base64.getUrlDecoder().decode(parts[0]);
        JsonNode node = objectMapper.readTree(header);
        JsonNode kid = node.get("kid");
        if (kid == null || kid.isNull()) {
            throw new IllegalArgumentException("kid absent.");
        }
        return kid.asText();
    }

    /** Recupere la cle publique correspondant au kid (cache 30 min, refresh si kid inconnu). */
    private synchronized RSAPublicKey resolveKey(String kid) throws Exception {
        RSAPublicKey cached = jwksCache.get(kid);
        if (cached != null && jwksFetchedAt != null
                && jwksFetchedAt.plus(JWKS_CACHE_TTL).isAfter(Instant.now())) {
            return cached;
        }
        refreshJwks();
        RSAPublicKey key = jwksCache.get(kid);
        if (key == null) {
            // Rotation des cles Google : on retente une fois une fois la liste rechargee.
            throw new IllegalStateException("Aucune clé JWKS pour ce kid.");
        }
        return key;
    }

    private void refreshJwks() throws Exception {
        HttpRequest request = HttpRequest.newBuilder(URI.create(JWKS_URI))
                .timeout(HTTP_TIMEOUT)
                .header("Accept", "application/json")
                .GET()
                .build();
        HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
        if (response.statusCode() != 200) {
            throw new IllegalStateException("JWKS indisponible (HTTP " + response.statusCode() + ").");
        }
        JsonNode keys = objectMapper.readTree(response.body()).path("keys");
        Map<String, RSAPublicKey> refreshed = new HashMap<>();
        for (JsonNode jwk : keys) {
            if (!"RSA".equals(jwk.path("kty").asText())) {
                continue;
            }
            String kid = jwk.path("kid").asText(null);
            if (kid == null) {
                continue;
            }
            try {
                refreshed.put(kid, toRsaPublicKey(jwk));
            } catch (Exception e) {
                logger.debug("Clé JWKS illisible (kid={}) : {}", kid, e.getMessage());
            }
        }
        if (refreshed.isEmpty()) {
            throw new IllegalStateException("JWKS sans clé valide.");
        }
        jwksCache.clear();
        jwksCache.putAll(refreshed);
        jwksFetchedAt = Instant.now();
    }

    /** Construit la cle publique RSA depuis les champs JWK n/e (base64url). */
    private RSAPublicKey toRsaPublicKey(JsonNode jwk) throws Exception {
        byte[] modulus = Base64.getUrlDecoder().decode(jwk.get("n").asText());
        byte[] exponent = Base64.getUrlDecoder().decode(jwk.get("e").asText());
        PublicKey key = KeyFactory.getInstance("RSA")
                .generatePublic(new java.security.spec.RSAPublicKeySpec(
                        new BigInteger(1, modulus), new BigInteger(1, exponent)));
        return (RSAPublicKey) key;
    }
}
