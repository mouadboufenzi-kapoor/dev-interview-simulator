package com.interview.simulator.admin.generation.controller;

import com.interview.simulator.admin.challenge.dto.ChallengeImportReport;
import com.interview.simulator.admin.challenge.dto.ChallengeImportReport.ExecutedCounts;
import com.interview.simulator.admin.challenge.dto.ChallengeImportReport.PlannedCounts;
import com.interview.simulator.admin.generation.service.ChallengeGenerationService;
import com.interview.simulator.auth.service.JwtService;
import com.interview.simulator.user.repository.UserRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.http.MediaType;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

import java.util.List;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(AdminGenerationController.class)
class AdminGenerationControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockitoBean
    private ChallengeGenerationService challengeGenerationService;

    @MockitoBean
    private JwtService jwtService;

    @MockitoBean
    private UserDetailsService userDetailsService;

    @MockitoBean
    private UserRepository userRepository;

    @Test
    @WithMockUser(roles = "ADMIN")
    void generate_ShouldRejectCountAboveTen() throws Exception {
        mockMvc.perform(post("/api/admin/challenges/generate")
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {"difficulty":"JUNIOR","type":"SITUATIONAL_QCM","count":11}
                                """))
                .andExpect(status().isBadRequest());

        verify(challengeGenerationService, never()).generate(any());
    }

    @Test
    @WithMockUser(roles = "ADMIN")
    void generate_ShouldRejectMissingRequiredParameters() throws Exception {
        mockMvc.perform(post("/api/admin/challenges/generate")
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {"count":3}
                                """))
                .andExpect(status().isBadRequest());

        verify(challengeGenerationService, never()).generate(any());
    }

    @Test
    @WithMockUser(roles = "ADMIN")
    void generate_ShouldReturnImportReport() throws Exception {
        when(challengeGenerationService.generate(any())).thenReturn(new ChallengeImportReport(
                false,
                new PlannedCounts(3, 0),
                new ExecutedCounts(3, 0),
                List.of(), List.of(), List.of()));

        mockMvc.perform(post("/api/admin/challenges/generate")
                        .with(csrf())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {"difficulty":"JUNIOR","type":"SITUATIONAL_QCM","count":3}
                                """))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.planned.created").value(3))
                .andExpect(jsonPath("$.executed.created").value(3));
    }
}
