package com.interview.simulator.auth.service;

import com.interview.simulator.auth.dto.AuthResponse;
import com.interview.simulator.auth.dto.LoginRequest;
import com.interview.simulator.auth.dto.RegisterRequest;
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
}
