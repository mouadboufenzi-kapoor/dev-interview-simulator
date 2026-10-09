package com.interview.simulator.config;

import com.interview.simulator.auth.service.JwtService;
import com.interview.simulator.user.entity.User;
import com.interview.simulator.user.entity.UserRole;
import org.junit.jupiter.api.Disabled;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@Disabled("Pas de données de test pour le moment")
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class SecurityIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private JwtService jwtService;

    @Test
    void publicEndpoints_ShouldBeAccessibleWithoutAuth() throws Exception {
        mockMvc.perform(get("/api/categories"))
                .andExpect(status().isOk());
    }

    @Test
    void adminEndpoints_ShouldRejectUnauthenticatedUsers() throws Exception {
        mockMvc.perform(get("/api/admin/challenges"))
                .andExpect(status().isForbidden()); // or isUnauthorized
    }

    @Test
    void adminEndpoints_ShouldRejectNormalUsers() throws Exception {
        User user = new User("normaluser", "normal@example.com");
        user.setRole(UserRole.USER);
        user.setEnabled(true);
        String token = jwtService.generateToken(user);

        mockMvc.perform(get("/api/admin/challenges")
                .header("Authorization", "Bearer " + token))
                .andExpect(status().isForbidden());
    }

    @Test
    void adminEndpoints_ShouldAllowAdminUsers() throws Exception {
        User admin = new User("adminuser", "admin@example.com");
        admin.setRole(UserRole.ADMIN);
        admin.setEnabled(true);
        String token = jwtService.generateToken(admin);

        mockMvc.perform(get("/api/admin/challenges")
                .header("Authorization", "Bearer " + token))
                .andExpect(status().isOk());
    }
}
