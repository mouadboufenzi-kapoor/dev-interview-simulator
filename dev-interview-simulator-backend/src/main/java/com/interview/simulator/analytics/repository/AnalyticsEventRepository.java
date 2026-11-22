package com.interview.simulator.analytics.repository;

import com.interview.simulator.analytics.entity.AnalyticsEvent;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface AnalyticsEventRepository extends JpaRepository<AnalyticsEvent, Long> {
}
