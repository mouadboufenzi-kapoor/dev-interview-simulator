package com.interview.simulator.auth.service;

import com.interview.simulator.auth.dto.AuthResponse;
import com.interview.simulator.auth.dto.LoginRequest;
import com.interview.simulator.auth.dto.RegisterRequest;
import com.interview.simulator.profile.repository.ProfileRepository;
import com.interview.simulator.user.entity.User;
import com.interview.simulator.user.entity.UserRole;
import com.interview.simulator.user.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.HttpStatus;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.server.ResponseStatusException;

import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class AuthServiceTest {

    @Mock
    private UserRepository userRepository;

    @Mock
    private PasswordEncoder passwordEncoder;

    @Mock
    private AuthenticationManager authenticationManager;

    @Mock
    private JwtService jwtService;

    @Mock
    private ProfileRepository profileRepository;

    @Mock
    private GoogleIdTokenVerifier googleIdTokenVerifier;

    @InjectMocks
    private AuthService authService;

    private User mockUser;

    @BeforeEach
    void setUp() {
        mockUser = new User("testuser", "test@example.com");
        mockUser.setPasswordHash("hashed_password");
        mockUser.setRole(UserRole.USER);
    }

    @Test
    void register_ShouldCreateUserWithUserRole() {
        RegisterRequest request = new RegisterRequest("newuser", "new@example.com", "password123");
        
        when(userRepository.existsByUsername("newuser")).thenReturn(false);
        when(userRepository.existsByEmail("new@example.com")).thenReturn(false);
        when(passwordEncoder.encode("password123")).thenReturn("hashed_password");
        when(jwtService.generateToken(any(User.class))).thenReturn("mock_token");

        AuthResponse response = authService.register(request);

        assertNotNull(response);
        assertEquals("mock_token", response.token());
        assertEquals("newuser", response.username());
        assertEquals(UserRole.USER.name(), response.role());
        verify(userRepository, times(1)).save(any(User.class));
    }

    @Test
    void register_ShouldThrowExceptionWhenUsernameExists() {
        RegisterRequest request = new RegisterRequest("existinguser", "new@example.com", "password123");
        when(userRepository.existsByUsername("existinguser")).thenReturn(true);

        ResponseStatusException exception = assertThrows(ResponseStatusException.class, () -> {
            authService.register(request);
        });

        assertEquals(HttpStatus.CONFLICT, exception.getStatusCode());
        verify(userRepository, never()).save(any(User.class));
    }

    @Test
    void login_ShouldReturnAuthResponseOnSuccess() {
        LoginRequest request = new LoginRequest("testuser", "password123");
        Authentication auth = mock(Authentication.class);
        
        when(authenticationManager.authenticate(any(UsernamePasswordAuthenticationToken.class))).thenReturn(auth);
        when(auth.getName()).thenReturn("testuser");
        when(userRepository.findByUsername("testuser")).thenReturn(Optional.of(mockUser));
        when(jwtService.generateToken(mockUser)).thenReturn("mock_token");

        AuthResponse response = authService.login(request);

        assertNotNull(response);
        assertEquals("mock_token", response.token());
        assertEquals("testuser", response.username());
    }

    // ---------------------------------------------------------------------
    // Google OAuth — find-or-create (3 cas du guide)
    // ---------------------------------------------------------------------

    private GoogleIdTokenVerifier.GoogleProfile googleProfile(String sub, String email) {
        return new GoogleIdTokenVerifier.GoogleProfile(sub, email, "Prénom", "Nom", null);
    }

    /** Cas 1 : déjà connecté par Google auparavant → simple émission de JWT. */
    @Test
    void googleLogin_ShouldReuseExistingUserWhenGoogleSubKnown() {
        when(googleIdTokenVerifier.verify("id-token")).thenReturn(googleProfile("sub-123", "test@example.com"));
        when(userRepository.findByGoogleSub("sub-123")).thenReturn(Optional.of(mockUser));
        when(jwtService.generateToken(mockUser)).thenReturn("mock_token");

        AuthResponse response = authService.googleLogin("id-token");

        assertEquals("mock_token", response.token());
        assertEquals("testuser", response.username());
        verify(userRepository, never()).save(any(User.class));
    }

    /** Cas 2 : même email qu'un compte email/mot de passe → ON LIE google_sub (linking). */
    @Test
    void googleLogin_ShouldLinkGoogleSubToExistingLocalAccount() {
        when(googleIdTokenVerifier.verify("id-token")).thenReturn(googleProfile("sub-123", "test@example.com"));
        when(userRepository.findByGoogleSub("sub-123")).thenReturn(Optional.empty());
        when(userRepository.findByEmail("test@example.com")).thenReturn(Optional.of(mockUser));
        when(jwtService.generateToken(mockUser)).thenReturn("mock_token");

        AuthResponse response = authService.googleLogin("id-token");

        assertEquals("mock_token", response.token());
        // Le compte local existant est lié, pas recréé : historique/role/profil conserves.
        assertEquals("sub-123", mockUser.getGoogleSub());
        verify(userRepository, times(1)).save(mockUser);
    }

    /** Cas 3 : email inconnu → création du compte Google-only (password_hash null). */
    @Test
    void googleLogin_ShouldCreateGoogleOnlyUserWhenEmailUnknown() {
        when(googleIdTokenVerifier.verify("id-token"))
                .thenReturn(googleProfile("sub-123", "new.user@example.com"));
        when(userRepository.findByGoogleSub("sub-123")).thenReturn(Optional.empty());
        when(userRepository.findByEmail("new.user@example.com")).thenReturn(Optional.empty());
        when(userRepository.existsByUsername("new.user")).thenReturn(false);
        when(jwtService.generateToken(any(User.class))).thenReturn("mock_token");

        AuthResponse response = authService.googleLogin("id-token");

        assertEquals("mock_token", response.token());
        assertEquals("new.user", response.username());
        verify(userRepository).save(argThat(user ->
                "sub-123".equals(user.getGoogleSub())
                        && user.getPasswordHash() == null
                        && user.getRole() == UserRole.USER));
    }

    /** Collision de username (UNIQUE NOT NULL) → suffixe numerique, jamais d'ecrasement. */
    @Test
    void googleLogin_ShouldUniquifyUsernameOnCollision() {
        when(googleIdTokenVerifier.verify("id-token"))
                .thenReturn(googleProfile("sub-123", "taken@example.com"));
        when(userRepository.findByGoogleSub("sub-123")).thenReturn(Optional.empty());
        when(userRepository.findByEmail("taken@example.com")).thenReturn(Optional.empty());
        when(userRepository.existsByUsername("taken")).thenReturn(true);
        when(userRepository.existsByUsername("taken2")).thenReturn(false);
        when(jwtService.generateToken(any(User.class))).thenReturn("mock_token");

        AuthResponse response = authService.googleLogin("id-token");

        assertEquals("taken2", response.username());
    }
}
