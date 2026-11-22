package com.interview.simulator.simulation.controller;

import com.interview.simulator.analytics.service.SimulationCreationRateLimiter;
import com.interview.simulator.auth.service.JwtService;
import com.interview.simulator.challenge.entity.ChallengeType;
import com.interview.simulator.simulation.dto.SimulationResponse;
import com.interview.simulator.simulation.entity.SimulationStatus;
import com.interview.simulator.simulation.service.SimulationService;
import com.interview.simulator.user.entity.User;
import com.interview.simulator.user.repository.UserRepository;
import com.interview.simulator.user.service.UserResolver;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.context.annotation.Import;
import org.springframework.http.MediaType;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.test.context.TestPropertySource;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

import java.util.List;
import java.util.Optional;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.mock;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(SimulationController.class)
@AutoConfigureMockMvc(addFilters = false)
@Import(SimulationCreationRateLimiter.class)
@TestPropertySource(properties = {
        "app.simulation.rate-limit.window=PT1H",
        "app.simulation.rate-limit.guest-limit=1",
        "app.simulation.rate-limit.user-limit=1"
})
class SimulationControllerRateLimitTest {

    private static final String REQUEST_BODY =
            "{\"mode\":\"SITUATIONAL_QCM\",\"difficulty\":\"JUNIOR\",\"placement\":false}";

    @Autowired
    private MockMvc mockMvc;

    @MockitoBean
    private SimulationService simulationService;

    @MockitoBean
    private UserResolver userResolver;

    @MockitoBean
    private JwtService jwtService;

    @MockitoBean
    private UserDetailsService userDetailsService;

    @MockitoBean
    private UserRepository userRepository;

    @Test
    void guestCreationIsAllowedThenRejectedWithRetryAfter() throws Exception {
        given(userResolver.currentAuthenticatedOrNull()).willReturn(Optional.empty());
        given(simulationService.startSimulation(any())).willReturn(createdSimulation());

        mockMvc.perform(post("/api/simulations")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(REQUEST_BODY))
                .andExpect(status().isCreated());

        mockMvc.perform(post("/api/simulations")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(REQUEST_BODY))
                .andExpect(status().isTooManyRequests())
                .andExpect(header().string("Retry-After", "3600"))
                .andExpect(jsonPath("$.status").value(429))
                .andExpect(jsonPath("$.message")
                        .value("Trop de tests lancés. Réessaie dans quelques minutes."))
                .andExpect(jsonPath("$.path").value("/api/simulations"));
    }

    @Test
    void authenticatedCreationIsAllowed() throws Exception {
        User user = mock(User.class);
        given(user.getId()).willReturn(7L);
        given(userResolver.currentAuthenticatedOrNull()).willReturn(Optional.of(user));
        given(simulationService.startSimulation(any())).willReturn(createdSimulation());

        mockMvc.perform(post("/api/simulations")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(REQUEST_BODY))
                .andExpect(status().isCreated());
    }

    private static SimulationResponse createdSimulation() {
        return new SimulationResponse(
                1L,
                ChallengeType.SITUATIONAL_QCM,
                null,
                null,
                SimulationStatus.IN_PROGRESS,
                0,
                null,
                List.of(),
                null
        );
    }
}
