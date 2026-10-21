package com.interview.simulator.simulation.service;

import com.interview.simulator.challenge.entity.Challenge;
import com.interview.simulator.challenge.entity.ChallengeOption;
import com.interview.simulator.challenge.entity.ChallengeType;
import com.interview.simulator.simulation.dto.SimulationChallengeResponse;
import org.junit.jupiter.api.Test;

import java.lang.reflect.Method;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

class ArchitecturePresentationOptionsTest {

    @Test
    void shufflesArchitectureOptionsWithoutChangingTheirStoredOrder() throws Exception {
        Challenge challenge = new Challenge();
        challenge.setType(ChallengeType.ARCHITECTURE);
        challenge.getOptions().add(option("Correct answer", true, 1));
        challenge.getOptions().add(option("Alternative A", false, 2));
        challenge.getOptions().add(option("Alternative B", false, 3));
        challenge.getOptions().add(option("Alternative C", false, 4));

        SimulationService service = new SimulationService(
                null, null, null, null, null, null, null, null, null);
        Method presentationOptions = SimulationService.class
                .getDeclaredMethod("presentationOptions", Challenge.class);
        presentationOptions.setAccessible(true);

        List<String> originalContentOrder = challenge.getOptions().stream()
                .map(ChallengeOption::getContent)
                .toList();
        boolean correctOptionMovedFromFirst = false;

        for (int attempt = 0; attempt < 64; attempt++) {
            @SuppressWarnings("unchecked")
            List<SimulationChallengeResponse.OptionResponse> presented =
                    (List<SimulationChallengeResponse.OptionResponse>) presentationOptions.invoke(service, challenge);

            assertEquals(4, presented.size());
            assertEquals(4, presented.stream().map(SimulationChallengeResponse.OptionResponse::content)
                    .distinct().count());
            for (SimulationChallengeResponse.OptionResponse option : presented) {
                int storedPosition = originalContentOrder.indexOf(option.content()) + 1;
                assertTrue(storedPosition > 0);
                assertEquals(storedPosition, option.displayOrder());
            }
            if (!"Correct answer".equals(presented.get(0).content())) {
                correctOptionMovedFromFirst = true;
            }
        }

        assertTrue(correctOptionMovedFromFirst, "Architecture options should not keep the correct choice first every time");
        assertEquals(originalContentOrder, challenge.getOptions().stream().map(ChallengeOption::getContent).toList());
        assertEquals(1, challenge.getOptions().get(0).getDisplayOrder(),
                "The stored order used by server-side correction must remain unchanged");
    }

    private ChallengeOption option(String content, boolean correct, int displayOrder) {
        ChallengeOption option = new ChallengeOption();
        option.setContent(content);
        option.setCorrect(correct);
        option.setDisplayOrder(displayOrder);
        return option;
    }
}
