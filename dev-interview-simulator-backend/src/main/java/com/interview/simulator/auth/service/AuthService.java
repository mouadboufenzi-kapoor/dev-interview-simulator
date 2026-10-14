package com.interview.simulator.auth.service;

import com.interview.simulator.auth.dto.AuthResponse;
import com.interview.simulator.auth.dto.LoginRequest;
import com.interview.simulator.auth.dto.RegisterRequest;
import com.interview.simulator.profile.entity.Profile;
import com.interview.simulator.profile.repository.ProfileRepository;
import com.interview.simulator.user.entity.User;
import com.interview.simulator.user.entity.UserRole;
import com.interview.simulator.user.repository.UserRepository;
import org.springframework.http.HttpStatus;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

@Service
public class AuthService {

    /**
     * Squelette multiprofil : profil rattaché par défaut à chaque nouveau compte.
     * DEVELOPER est le seul profil réel de l'application aujourd'hui.
     */
    private static final String DEFAULT_PROFILE_CODE = "DEVELOPER";

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final AuthenticationManager authenticationManager;
    private final JwtService jwtService;
    private final ProfileRepository profileRepository;
    private final GoogleIdTokenVerifier googleIdTokenVerifier;

    public AuthService(UserRepository userRepository,
            PasswordEncoder passwordEncoder,
            AuthenticationManager authenticationManager,
            JwtService jwtService,
            ProfileRepository profileRepository,
            GoogleIdTokenVerifier googleIdTokenVerifier) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.authenticationManager = authenticationManager;
        this.jwtService = jwtService;
        this.profileRepository = profileRepository;
        this.googleIdTokenVerifier = googleIdTokenVerifier;
    }

    public AuthResponse register(RegisterRequest request) {
        if (userRepository.existsByUsername(request.username())) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Username déjà utilisé.");
        }
        if (userRepository.existsByEmail(request.email())) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Email déjà utilisé.");
        }

        User user = new User(request.username(), request.email());
        user.setPasswordHash(passwordEncoder.encode(request.password()));
        user.setRole(UserRole.USER);
        // Squelette multiprofil : le nouveau compte est rattaché au seul profil
        // réel (DEVELOPER), qui devient son profil actif. Profil absent du catalogue
        // => aucun rattachement (jamais de crash), comportement identique à avant.
        profileRepository.findByCode(DEFAULT_PROFILE_CODE).ifPresent(profile -> {
            user.getProfiles().add(profile);
            user.setActiveProfile(profile);
        });
        userRepository.save(user);
        return toResponse(user);
    }

    public AuthResponse login(LoginRequest request) {
        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                        request.usernameOrEmail(),
                        request.password()
                )
        );

        User user = userRepository.findByUsername(authentication.getName())
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.UNAUTHORIZED,
                        "Utilisateur introuvable."
                ));
        return toResponse(user);
    }

    /**
     * Connexion via Google Identity Services.
     *
     * Etapes : verification serveur du ID token -> find-or-create ->
     * rattachement du profil par defaut si creation -> NOTRE JWT (inchange).
     *
     * Trois cas :
     *  1. google_sub connu -> simple emission de JWT (connexion suivante) ;
     *  2. email deja present (compte email/mot de passe) -> ON LIE google_sub a
     *     ce compte (account linking) : historique/role/profil conserves, les
     *     deux methodes de connexion restent utilisables ;
     *  3. email inconnu -> creation du compte local (password_hash = null).
     */
    public AuthResponse googleLogin(String idToken) {
        GoogleIdTokenVerifier.GoogleProfile google = googleIdTokenVerifier.verify(idToken);

        // 1. Deja connecte par Google auparavant.
        java.util.Optional<User> bySub = userRepository.findByGoogleSub(google.sub());
        if (bySub.isPresent()) {
            return toResponse(bySub.get());
        }

        // 2. Email deja en base -> compte classique : on lie le compte Google.
        java.util.Optional<User> byEmail = userRepository.findByEmail(google.email());
        if (byEmail.isPresent()) {
            User linked = byEmail.get();
            linked.setGoogleSub(google.sub());
            if (google.picture() != null && !google.picture().isBlank()) {
                linked.setPictureUrl(google.picture());
            }
            userRepository.save(linked);
            return toResponse(linked);
        }

        // 3. Nouveau compte Google-only.
        User user = new User(resolveUniqueUsername(google), google.email());
        user.setGoogleSub(google.sub());
        user.setPictureUrl(google.picture());
        // password_hash reste NULL : la colonne est nullable depuis V5.
        user.setRole(UserRole.USER);
        // Meme logique que register() : rattachement au profil par defaut.
        profileRepository.findByCode(DEFAULT_PROFILE_CODE).ifPresent(profile -> {
            user.getProfiles().add(profile);
            user.setActiveProfile(profile);
        });
        userRepository.save(user);
        return toResponse(user);
    }

    /**
     * Derive un username unique depuis l'email Google (username est UNIQUE NOT NULL).
     * Jamais d'ecrasement d'un compte existant : suffixe numerique en cas de collision.
     */
    private String resolveUniqueUsername(GoogleIdTokenVerifier.GoogleProfile google) {
        String localPart = google.email().substring(0, google.email().indexOf('@'))
                .toLowerCase(java.util.Locale.ROOT)
                .replaceAll("[^a-z0-9._-]", "");
        if (localPart.isEmpty()) {
            localPart = "user";
        }
        String candidate = localPart;
        int suffix = 2;
        while (userRepository.existsByUsername(candidate)) {
            candidate = localPart + suffix;
            suffix++;
        }
        return candidate;
    }

    private AuthResponse toResponse(User user) {
        return new AuthResponse(
                jwtService.generateToken(user),
                user.getId(),
                user.getUsername(),
                user.getEmail(),
                user.getRole().name(),
                user.getActiveProfile() != null ? user.getActiveProfile().getName() : null
        );
    }
}
