package com.interview.simulator.admin.user.service;

import com.interview.simulator.admin.user.dto.AdminUserResponse;
import com.interview.simulator.user.entity.User;
import com.interview.simulator.user.repository.UserRepository;
import com.interview.simulator.user.service.UserResolver;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AdminUserService {

    private static final int MAX_PAGE_SIZE = 50;

    private final UserRepository userRepository;

    public AdminUserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @Transactional(readOnly = true)
    public Page<AdminUserResponse> search(String search, int page, int size) {
        int safePage = Math.max(page, 0);
        int safeSize = Math.max(1, Math.min(size, MAX_PAGE_SIZE));
        Pageable pageable = PageRequest.of(
                safePage, safeSize, Sort.by(Sort.Direction.DESC, "createdAt", "id"));
        String term = search == null ? "" : search.trim();

        Page<User> users = term.isEmpty()
                ? userRepository.findForAdmin(UserResolver.GUEST_USERNAME, pageable)
                : userRepository.searchForAdmin(UserResolver.GUEST_USERNAME, term, pageable);

        return users.map(this::toResponse);
    }

    private AdminUserResponse toResponse(User user) {
        return new AdminUserResponse(
                user.getId(),
                user.getUsername(),
                user.getEmail(),
                user.getRole(),
                user.isEnabled(),
                user.getCreatedAt()
        );
    }
}
