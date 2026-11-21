package com.interview.simulator.simulation.service;

import com.interview.simulator.exception.ApiException;
import com.interview.simulator.simulation.dto.ClaimSimulationsRequest;
import com.interview.simulator.simulation.dto.ClaimSimulationsResponse;
import com.interview.simulator.simulation.entity.Simulation;
import com.interview.simulator.simulation.repository.SimulationRepository;
import com.interview.simulator.user.entity.User;
import com.interview.simulator.user.service.UserResolver;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.HttpStatus;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.HexFormat;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertSame;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class SimulationClaimServiceTest {

    private static final String GUEST_TOKEN = "guest-token-value";

    @Mock private SimulationRepository simulationRepository;
    @Mock private UserResolver userResolver;

    @InjectMocks private SimulationService simulationService;

    @Test
    void claimsSimulationStillOwnedByDefaultUser() {
        User authenticatedUser = user("alice");
        Simulation simulation = simulationOwnedBy(UserResolver.GUEST_USERNAME);
        simulation.setGuestAccessTokenHash(sha256(GUEST_TOKEN));
        when(userResolver.currentAuthenticatedOrNull()).thenReturn(Optional.of(authenticatedUser));
        when(simulationRepository.findByGuestAccessTokenHash(sha256(GUEST_TOKEN)))
                .thenReturn(Optional.of(simulation));

        ClaimSimulationsResponse response = simulationService.claimSimulations(
                new ClaimSimulationsRequest(List.of(GUEST_TOKEN)));

        assertEquals(1, response.claimed());
        assertSame(authenticatedUser, simulation.getUser());
        assertNull(simulation.getGuestAccessTokenHash());
    }

    @Test
    void ignoresUnknownToken() {
        when(userResolver.currentAuthenticatedOrNull()).thenReturn(Optional.of(user("alice")));
        when(simulationRepository.findByGuestAccessTokenHash(sha256(GUEST_TOKEN)))
                .thenReturn(Optional.empty());

        ClaimSimulationsResponse response = simulationService.claimSimulations(
                new ClaimSimulationsRequest(List.of(GUEST_TOKEN)));

        assertEquals(0, response.claimed());
    }

    @Test
    void ignoresSimulationAlreadyOwnedByAnotherAccount() {
        User owner = user("bob");
        Simulation simulation = new Simulation();
        simulation.setUser(owner);
        String storedHash = sha256(GUEST_TOKEN);
        simulation.setGuestAccessTokenHash(storedHash);
        when(userResolver.currentAuthenticatedOrNull()).thenReturn(Optional.of(user("alice")));
        when(simulationRepository.findByGuestAccessTokenHash(storedHash))
                .thenReturn(Optional.of(simulation));

        ClaimSimulationsResponse response = simulationService.claimSimulations(
                new ClaimSimulationsRequest(List.of(GUEST_TOKEN)));

        assertEquals(0, response.claimed());
        assertSame(owner, simulation.getUser());
        assertEquals(storedHash, simulation.getGuestAccessTokenHash());
    }

    @Test
    void rejectsUnauthenticatedCaller() {
        when(userResolver.currentAuthenticatedOrNull()).thenReturn(Optional.empty());

        ApiException exception = assertThrows(ApiException.class, () -> simulationService.claimSimulations(
                new ClaimSimulationsRequest(List.of(GUEST_TOKEN))));

        assertEquals(HttpStatus.UNAUTHORIZED, exception.getStatus());
    }

    private User user(String username) {
        return new User(username, username + "@example.test");
    }

    private Simulation simulationOwnedBy(String username) {
        Simulation simulation = new Simulation();
        simulation.setUser(user(username));
        return simulation;
    }

    private String sha256(String value) {
        try {
            return HexFormat.of().formatHex(MessageDigest.getInstance("SHA-256")
                    .digest(value.getBytes(StandardCharsets.US_ASCII)));
        } catch (NoSuchAlgorithmException exception) {
            throw new IllegalStateException("SHA-256 indisponible.", exception);
        }
    }
}
