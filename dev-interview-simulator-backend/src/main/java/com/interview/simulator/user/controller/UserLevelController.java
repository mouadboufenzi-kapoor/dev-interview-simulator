package com.interview.simulator.user.controller;

import com.interview.simulator.user.dto.UserLevelResponse;
import com.interview.simulator.user.service.UserLevelService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/user/level")
public class UserLevelController {

    private final UserLevelService userLevelService;

    public UserLevelController(UserLevelService userLevelService) {
        this.userLevelService = userLevelService;
    }

    @GetMapping
    public UserLevelResponse getLevel() {
        return userLevelService.getCurrentProgress();
    }
}
