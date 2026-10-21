package com.interview.simulator.user.service;

import com.interview.simulator.user.entity.User;
import com.interview.simulator.user.repository.UserRepository;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

/**
 * Résout l'utilisateur courant.
 *
 * - Utilisateur connecté (JWT) → son propre compte : ses simulations sont rattachées
 *   à son identité et alimentent son dashboard.
 * - Invité (sans token) → {@code default_user} : le trial fonctionne mais rien n'est
 *   rattaché à une identité réelle, et l'invité n'a accès à aucun historique/dashboard.
 */
@Service
public class UserResolver {

    public static final String GUEST_USERNAME = "default_user";

    private final UserRepository userRepository;

    public UserResolver(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    /**
     * Utilisateur courant, ou {@code default_user} créé au besoin (comportement MVP historique).
     */
    @Transactional
    public User resolveOrCreate() {
        return authenticatedUser()
                .orElseGet(() -> userRepository.findByUsername(GUEST_USERNAME)
                        .orElseGet(() -> userRepository.save(new User(GUEST_USERNAME, "dev@example.com"))));
    }

    /**
     * Utilisateur courant pour les lectures (stats), sans créer de compte invité.
     * Retourne {@code empty} si personne n'est connecté et que {@code default_user}
     * n'existe pas encore.
     */
    public Optional<User> currentAuthenticatedOrNull() {
        return authenticatedUser();
    }

    public Optional<User> currentOrNull() {
        Optional<User> authenticated = authenticatedUser();
        if (authenticated.isPresent()) {
            return authenticated;
        }
        return userRepository.findByUsername(GUEST_USERNAME);
    }

    private Optional<User> authenticatedUser() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !authentication.isAuthenticated()) {
            return Optional.empty();
        }
        String username = authentication.getName();
        if (username == null || username.isBlank() || "anonymousUser".equals(username)) {
            return Optional.empty();
        }
        return userRepository.findByUsername(username);
    }
}
