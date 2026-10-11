package com.interview.simulator.admin.stats.controller;

import com.interview.simulator.admin.stats.dto.AdminStatsResponse;
import com.interview.simulator.admin.stats.service.AdminStatsService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/admin/stats")
public class AdminStatsController {

    private final AdminStatsService adminStatsService;

    public AdminStatsController(AdminStatsService adminStatsService) {
        this.adminStatsService = adminStatsService;
    }

    @GetMapping
    public AdminStatsResponse getStats() {
        return adminStatsService.getStats();
    }
}
