package com.interview.simulator.auth.service;

import com.interview.simulator.user.entity.User;
import com.interview.simulator.user.entity.UserRole;
import io.jsonwebtoken.ExpiredJwtException;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.time.Duration;

import static org.junit.jupiter.api.Assertions.*;

class JwtServiceTest {

    private JwtService jwtService;
    private User testUser;
    private final String testSecret = "this-is-a-very-long-test-secret-key-for-jwt";

    @BeforeEach
    void setUp() {
        jwtService = new JwtService(testSecret, Duration.ofHours(1));
        testUser = new User("testuser", "test@example.com");
        testUser.setRole(UserRole.USER);
    }

    @Test
    void generateToken_ShouldReturnValidToken() {
        String token = jwtService.generateToken(testUser);
        assertNotNull(token);
        
        String username = jwtService.extractUsername(token);
        assertEquals("testuser", username);
        
        assertTrue(jwtService.isValid(token, testUser));
    }

    @Test
    void isValid_ShouldReturnFalseForDifferentUser() {
        String token = jwtService.generateToken(testUser);
        
        User anotherUser = new User("another", "another@example.com");
        assertFalse(jwtService.isValid(token, anotherUser));
    }

    @Test
    void extractUsername_ShouldThrowExceptionForExpiredToken() throws InterruptedException {
        // Create a JwtService with 1 millisecond expiration
        JwtService fastExpiringJwtService = new JwtService(testSecret, Duration.ofMillis(1));
        String token = fastExpiringJwtService.generateToken(testUser);
        
        // Wait for token to expire
        Thread.sleep(10);
        
        assertThrows(ExpiredJwtException.class, () -> fastExpiringJwtService.extractUsername(token));
    }
}
