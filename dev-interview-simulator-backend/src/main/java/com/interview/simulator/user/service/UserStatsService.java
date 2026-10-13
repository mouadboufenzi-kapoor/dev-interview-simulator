package com.interview.simulator.user.service;

import com.interview.simulator.category.entity.Category;
import com.interview.simulator.simulation.entity.Simulation;
import com.interview.simulator.simulation.entity.SimulationAnswer;
import com.interview.simulator.simulation.entity.SimulationChallenge;
import com.interview.simulator.simulation.entity.SimulationStatus;
import com.interview.simulator.simulation.repository.SimulationRepository;
import com.interview.simulator.user.dto.UserStatsResponse;
import com.interview.simulator.user.entity.User;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class UserStatsService {

    private static final int RECENT_WINDOW = 3;
    private static final int MIN_ANSWERS_FOR_RELIABLE_RATE = 3;
    private static final DateTimeFormatter DATE_TIME_FORMAT = DateTimeFormatter.ISO_LOCAL_DATE_TIME;

    private final UserResolver userResolver;
    private final SimulationRepository simulationRepository;

    public UserStatsService(UserResolver userResolver, SimulationRepository simulationRepository) {
        this.userResolver = userResolver;
        this.simulationRepository = simulationRepository;
    }

    @Transactional(readOnly = true)
    public UserStatsResponse getStats(int page, int size) {
        User user = userResolver.currentOrNull().orElse(null);
        if (user == null) {
            return emptyStats(page, size);
        }

        // Tri par startedAt DESC côté requête
        List<Simulation> simulations = simulationRepository.findAllByUserIdWithChallenges(user.getId());

        long totalSimulations = simulations.size();
        long completedSimulations = simulations.stream()
                .filter(s -> s.getStatus() == SimulationStatus.COMPLETED)
                .count();

        long totalAnswers = 0;
        long correctAnswers = 0;
        Map<Long, long[]> byCategory = new HashMap<>();   // categoryId -> [answered, correct]
        Map<Long, String> categoryNames = new HashMap<>();
        Map<String, long[]> byType = new HashMap<>();     // type -> [answered, correct]

        for (Simulation simulation : simulations) {
            for (SimulationChallenge sc : simulation.getSimulationChallenges()) {
                SimulationAnswer answer = sc.getAnswer();
                if (answer == null) {
                    continue;
                }
                totalAnswers++;
                boolean correct = answer.isCorrect();
                if (correct) {
                    correctAnswers++;
                }

                String type = sc.getChallenge().getType().name();
                long[] typeStats = byType.computeIfAbsent(type, k -> new long[2]);
                typeStats[0]++;
                if (correct) {
                    typeStats[1]++;
                }

                for (Category category : sc.getChallenge().getCategories()) {
                    long[] categoryStats = byCategory.computeIfAbsent(category.getId(), k -> new long[2]);
                    categoryStats[0]++;
                    if (correct) {
                        categoryStats[1]++;
                    }
                    categoryNames.put(category.getId(), category.getName());
                }
            }
        }

        Double globalRate = rate(correctAnswers, totalAnswers);

        // Tendance : 3 dernières simulations terminées vs les 3 précédentes
        List<Simulation> completed = simulations.stream()
                .filter(s -> s.getStatus() == SimulationStatus.COMPLETED)
                .toList();
        Double recentRate = null;
        Double previousRate = null;
        String trend = null;
        if (completed.size() > RECENT_WINDOW) {
            recentRate = averageRate(completed.subList(0, RECENT_WINDOW));
            previousRate = averageRate(
                    completed.subList(RECENT_WINDOW, Math.min(completed.size(), 2 * RECENT_WINDOW)));
            if (recentRate != null && previousRate != null) {
                double delta = recentRate - previousRate;
                trend = delta >= 2 ? "UP" : delta <= -2 ? "DOWN" : "STABLE";
            }
        }

        // Score de session : moyenne et meilleur taux par session TERMINÉE
        // (macro par session, contrairement au taux global qui est par réponse).
        Double averageSuccessRate = null;
        Double bestSuccessRate = null;
        if (!completed.isEmpty()) {
            double sumRates = 0;
            double bestRate = 0;
            for (Simulation simulation : completed) {
                int totalQuestions = simulation.getSimulationChallenges().size();
                int correctCount = (int) simulation.getSimulationChallenges().stream()
                        .filter(sc -> sc.getAnswer() != null && sc.getAnswer().isCorrect())
                        .count();
                double sessionRate = totalQuestions == 0 ? 0 : (correctCount * 100.0) / totalQuestions;
                sumRates += sessionRate;
                bestRate = Math.max(bestRate, sessionRate);
            }
            averageSuccessRate = Math.round(sumRates / completed.size() * 10.0) / 10.0;
            bestSuccessRate = Math.round(bestRate * 10.0) / 10.0;
        }

        // Par catégorie : uniquement les catégories pratiquées,
        // triées du plus faible au plus fort taux (les points faibles d'abord)
        List<UserStatsResponse.StatEntry> byCategoryEntries = new ArrayList<>();
        for (Map.Entry<Long, long[]> entry : byCategory.entrySet()) {
            long answered = entry.getValue()[0];
            long correct = entry.getValue()[1];
            Double categoryRate = rate(correct, answered);
            if (categoryRate != null) {
                byCategoryEntries.add(new UserStatsResponse.StatEntry(
                        entry.getKey(),
                        categoryNames.get(entry.getKey()),
                        (int) answered,
                        (int) correct,
                        categoryRate
                ));
            }
        }
        byCategoryEntries.sort((a, b) -> {
            int byRate = Double.compare(a.successRate(), b.successRate());
            return byRate != 0 ? byRate : Integer.compare(b.answered(), a.answered());
        });

        // Points faibles : uniquement des taux réellement perfectibles (< 100 %),
        // en priorisant les compétences avec assez de réponses (>= 3) pour être fiables.
        List<UserStatsResponse.StatEntry> reliable = byCategoryEntries.stream()
                .filter(entry -> entry.answered() >= MIN_ANSWERS_FOR_RELIABLE_RATE
                        && entry.successRate() < 100)
                .toList();
        List<UserStatsResponse.StatEntry> weakSource = reliable.isEmpty()
                ? byCategoryEntries.stream().filter(entry -> entry.successRate() < 100).toList()
                : reliable;
        List<UserStatsResponse.StatEntry> weakPoints = weakSource.stream()
                .limit(3)
                .toList();

        // Par type de format, même tri (plus faible en premier)
        List<UserStatsResponse.TypeStat> byTypeEntries = new ArrayList<>();
        for (Map.Entry<String, long[]> entry : byType.entrySet()) {
            long answered = entry.getValue()[0];
            long correct = entry.getValue()[1];
            Double typeRate = rate(correct, answered);
            if (typeRate != null) {
                byTypeEntries.add(new UserStatsResponse.TypeStat(
                        entry.getKey(), (int) answered, (int) correct, typeRate));
            }
        }
        byTypeEntries.sort((a, b) -> {
            int byRate = Double.compare(a.successRate(), b.successRate());
            return byRate != 0 ? byRate : Integer.compare(b.answered(), a.answered());
        });

        // Historique paginé : simulations les plus récentes d'abord (tri de la requête)
        long totalElements = simulations.size();
        int totalPages = (int) Math.ceil((double) totalElements / size);
        int safePage = totalPages == 0 ? 0 : Math.min(Math.max(page, 0), totalPages - 1);
        int fromIndex = safePage * size;
        int toIndex = Math.min(fromIndex + size, simulations.size());
        List<UserStatsResponse.RecentSimulation> pageContent = simulations.subList(fromIndex, toIndex).stream()
                .map(this::toRecentSimulation)
                .toList();
        UserStatsResponse.PagedSimulations pagedSimulations = new UserStatsResponse.PagedSimulations(
                pageContent, safePage, size, totalElements, totalPages);

        return new UserStatsResponse(
                totalSimulations,
                completedSimulations,
                totalAnswers,
                correctAnswers,
                globalRate,
                recentRate,
                previousRate,
                trend,
                averageSuccessRate,
                bestSuccessRate,
                byCategoryEntries,
                byTypeEntries,
                weakPoints,
                pagedSimulations
        );
    }

    private UserStatsResponse.RecentSimulation toRecentSimulation(Simulation simulation) {
        int answered = 0;
        int correct = 0;
        for (SimulationChallenge sc : simulation.getSimulationChallenges()) {
            SimulationAnswer answer = sc.getAnswer();
            if (answer != null) {
                answered++;
                if (answer.isCorrect()) {
                    correct++;
                }
            }
        }
        return new UserStatsResponse.RecentSimulation(
                simulation.getId(),
                simulation.getMode() != null ? simulation.getMode().name() : null,
                simulation.getDifficulty() != null ? simulation.getDifficulty().name() : null,
                simulation.getSimulationChallenges().size(),
                correct,
                simulation.getTotalScore() != null ? simulation.getTotalScore() : 0,
                simulation.getStatus() != null ? simulation.getStatus().name() : null,
                simulation.getStartedAt() != null ? simulation.getStartedAt().format(DATE_TIME_FORMAT) : null
        );
    }

    private Double rate(long correct, long answered) {
        return answered == 0 ? null : Math.round((correct * 1000.0) / answered) / 10.0;
    }

    private Double averageRate(List<Simulation> simulations) {
        long answered = 0;
        long correct = 0;
        for (Simulation simulation : simulations) {
            for (SimulationChallenge sc : simulation.getSimulationChallenges()) {
                if (sc.getAnswer() != null) {
                    answered++;
                    if (sc.getAnswer().isCorrect()) {
                        correct++;
                    }
                }
            }
        }
        return rate(correct, answered);
    }

    private UserStatsResponse emptyStats(int page, int size) {
        return new UserStatsResponse(
                0, 0, 0, 0,
                null, null, null, null, null, null,
                List.of(), List.of(), List.of(),
                new UserStatsResponse.PagedSimulations(List.of(), 0, size, 0, 0)
        );
    }
}
