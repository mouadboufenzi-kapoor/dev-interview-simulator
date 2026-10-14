package com.interview.simulator.auth.controller;

import com.interview.simulator.auth.dto.AuthResponse;
import com.interview.simulator.auth.dto.GoogleLoginRequest;
import com.interview.simulator.auth.dto.LoginRequest;
import com.interview.simulator.auth.dto.RegisterRequest;
import com.interview.simulator.auth.service.AuthService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/register")
    public ResponseEntity<AuthResponse> register(@Valid @RequestBody RegisterRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(authService.register(request));
    }

    @PostMapping("/login")
    public AuthResponse login(@Valid @RequestBody LoginRequest request) {
        return authService.login(request);
    }

    /**
     * Connexion/inscription via Google : le frontend envoie le ID token GIS,
     * le backend le verifie (JWKS/aud/iss/exp/email_verified) puis renvoie le
     * MEME AuthResponse qu'un login classique.
     */
    @PostMapping("/google")
    public AuthResponse googleLogin(@Valid @RequestBody GoogleLoginRequest request) {
        return authService.googleLogin(request.idToken());
    }
}
