package com.interview.simulator.user.repository;

import com.interview.simulator.user.entity.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByUsername(String username);
    Optional<User> findByEmail(String email);
    Optional<User> findByGoogleSub(String googleSub);
    boolean existsByUsername(String username);
    boolean existsByEmail(String email);

    long countByUsernameNot(String username);

    long countByUsernameNotAndCreatedAtAfter(String username, LocalDateTime createdAt);

    @Query("""
        SELECT u FROM User u
        WHERE u.username <> :guestUsername
        """)
    Page<User> findForAdmin(@Param("guestUsername") String guestUsername, Pageable pageable);

    @Query("""
        SELECT u FROM User u
        WHERE u.username <> :guestUsername
          AND (LOWER(u.username) LIKE LOWER(CONCAT('%', :search, '%'))
               OR LOWER(u.email) LIKE LOWER(CONCAT('%', :search, '%')))
        """)
    Page<User> searchForAdmin(
            @Param("guestUsername") String guestUsername,
            @Param("search") String search,
            Pageable pageable);
}