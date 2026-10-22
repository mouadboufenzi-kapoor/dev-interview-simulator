package com.interview.simulator.user.service;

import com.interview.simulator.simulation.repository.SimulationRepository;
import com.interview.simulator.user.dto.UserStatsResponse;
import com.interview.simulator.user.entity.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

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
            return emptyStats(size);
        }

        Long userId = user.getId();
        Object[] simulationCounts = unwrapRow(simulationRepository.findUserSimulationCounts(userId));
        Object[] answerCounts = unwrapRow(simulationRepository.findUserAnswerCounts(userId));
        long totalSimulations = number(simulationCounts[0]);
        long completedSimulations = number(simulationCounts[1]);
        long totalAnswers = number(answerCounts[0]);
        long correctAnswers = number(answerCounts[1]);

        List<UserStatsResponse.StatEntry> categories = toStatEntries(
                unwrapRows(simulationRepository.findUserCategoryStats(userId)));
        List<UserStatsResponse.StatEntry> skills = toStatEntries(
                unwrapRows(simulationRepository.findUserSkillStats(userId)));
        List<UserStatsResponse.TypeStat> byType = unwrapRows(
                simulationRepository.findUserTypeStats(userId)).stream()
                .map(row -> new UserStatsResponse.TypeStat(
                        (String) row[0], (int) number(row[1]), (int) number(row[2]),
                        rate(number(row[2]), number(row[1]))))
                .sorted((first, second) -> compareRates(
                        first.successRate(), first.answered(), second.successRate(), second.answered()))
                .toList();

        Double recentRate = null;
        Double previousRate = null;
        String trend = null;
        List<Object[]> recentCompleted = unwrapRows(
                simulationRepository.findRecentCompletedSimulationRates(userId));
        if (recentCompleted.size() > RECENT_WINDOW) {
            recentRate = averageRate(recentCompleted.subList(0, RECENT_WINDOW));
            previousRate = averageRate(recentCompleted.subList(RECENT_WINDOW, 2 * RECENT_WINDOW));
            if (recentRate != null && previousRate != null) {
                double delta = recentRate - previousRate;
                trend = delta >= 2 ? "UP" : delta <= -2 ? "DOWN" : "STABLE";
            }
        }

        Object[] rateSummary = unwrapRow(simulationRepository.findCompletedSimulationRateSummary(userId));
        Double averageSuccessRate = rateSummary[0] == null ? null : round(number(rateSummary[0]));
        Double bestSuccessRate = rateSummary[1] == null ? null : round(number(rateSummary[1]));

        Page<Object[]> simulations = simulationRepository.findRecentSimulationsByUserId(
                userId, PageRequest.of(Math.max(page, 0), size));
        List<UserStatsResponse.RecentSimulation> recentSimulations = simulations.getContent().stream()
                .map(this::unwrapRow)
                .map(this::toRecentSimulation)
                .toList();
        UserStatsResponse.PagedSimulations pagedSimulations = new UserStatsResponse.PagedSimulations(
                recentSimulations,
                simulations.getNumber(),
                size,
                simulations.getTotalElements(),
                simulations.getTotalPages());

        return new UserStatsResponse(
                totalSimulations,
                completedSimulations,
                totalAnswers,
                correctAnswers,
                rate(correctAnswers, totalAnswers),
                recentRate,
                previousRate,
                trend,
                averageSuccessRate,
                bestSuccessRate,
                categories,
                byType,
                weakPoints(categories, skills),
                pagedSimulations);
    }

    private List<UserStatsResponse.StatEntry> toStatEntries(List<Object[]> rows) {
        return rows.stream()
                .map(row -> new UserStatsResponse.StatEntry(
                        number(row[0]), (String) row[1], (int) number(row[2]),
                        (int) number(row[3]), rate(number(row[3]), number(row[2]))))
                .sorted((first, second) -> compareRates(
                        first.successRate(), first.answered(), second.successRate(), second.answered()))
                .toList();
    }

    private List<UserStatsResponse.WeakPointEntry> weakPoints(
            List<UserStatsResponse.StatEntry> categories,
            List<UserStatsResponse.StatEntry> skills) {
        List<UserStatsResponse.WeakPointEntry> reliable = new ArrayList<>();
        categories.stream()
                .filter(entry -> entry.answered() >= MIN_ANSWERS_FOR_RELIABLE_RATE && entry.successRate() < 100)
                .map(entry -> weakPoint(entry, "CATEGORY"))
                .forEach(reliable::add);
        skills.stream()
                .filter(entry -> entry.answered() >= MIN_ANSWERS_FOR_RELIABLE_RATE && entry.successRate() < 100)
                .map(entry -> weakPoint(entry, "SKILL"))
                .forEach(reliable::add);
        reliable.sort((first, second) -> compareRates(
                first.successRate(), first.answered(), second.successRate(), second.answered()));

        List<UserStatsResponse.WeakPointEntry> all = new ArrayList<>(reliable);
        categories.stream()
                .filter(entry -> entry.successRate() < 100)
                .map(entry -> weakPoint(entry, "CATEGORY"))
                .forEach(all::add);
        skills.stream()
                .filter(entry -> entry.successRate() < 100)
                .map(entry -> weakPoint(entry, "SKILL"))
                .forEach(all::add);
        return all.stream()
                .distinct()
                .sorted((first, second) -> {
                    int reliability = Boolean.compare(
                            second.answered() >= MIN_ANSWERS_FOR_RELIABLE_RATE,
                            first.answered() >= MIN_ANSWERS_FOR_RELIABLE_RATE);
                    return reliability != 0 ? reliability : compareRates(
                            first.successRate(), first.answered(), second.successRate(), second.answered());
                })
                .toList();
    }

    private UserStatsResponse.WeakPointEntry weakPoint(
            UserStatsResponse.StatEntry entry,
            String source) {
        return new UserStatsResponse.WeakPointEntry(
                entry.id(), entry.name(), entry.answered(), entry.correct(), entry.successRate(), source);
    }

    private UserStatsResponse.RecentSimulation toRecentSimulation(Object[] row) {
        LocalDateTime startedAt = row[7] instanceof LocalDateTime dateTime
                ? dateTime
                : row[7] instanceof java.sql.Timestamp timestamp ? timestamp.toLocalDateTime() : null;
        return new UserStatsResponse.RecentSimulation(
                number(row[0]),
                (String) row[1],
                (String) row[2],
                (int) number(row[3]),
                (int) number(row[4]),
                (int) number(row[5]),
                (String) row[6],
                startedAt == null ? null : startedAt.format(DATE_TIME_FORMAT));
    }

    private Double averageRate(List<Object[]> rows) {
        long answered = 0;
        long correct = 0;
        for (Object[] row : rows) {
            answered += number(row[0]);
            correct += number(row[1]);
        }
        return rate(correct, answered);
    }

    private int compareRates(double firstRate, int firstAnswered, double secondRate, int secondAnswered) {
        int byRate = Double.compare(firstRate, secondRate);
        return byRate != 0 ? byRate : Integer.compare(secondAnswered, firstAnswered);
    }

    private Object[] unwrapRow(Object[] row) {
        return row.length == 1 && row[0] instanceof Object[] nested ? nested : row;
    }

    private List<Object[]> unwrapRows(List<Object[]> rows) {
        return rows.stream().map(this::unwrapRow).toList();
    }

    private long number(Object value) {
        return value == null ? 0 : ((Number) value).longValue();
    }

    private double round(double value) {
        return Math.round(value * 10.0) / 10.0;
    }

    private Double rate(long correct, long answered) {
        return answered == 0 ? null : Math.round((correct * 1000.0) / answered) / 10.0;
    }

    private UserStatsResponse emptyStats(int size) {
        return new UserStatsResponse(
                0, 0, 0, 0,
                null, null, null, null, null, null,
                List.of(), List.of(), List.of(),
                new UserStatsResponse.PagedSimulations(List.of(), 0, size, 0, 0));
    }
}
