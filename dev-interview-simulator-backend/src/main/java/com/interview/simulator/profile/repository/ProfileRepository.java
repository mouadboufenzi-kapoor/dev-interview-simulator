package com.interview.simulator.profile.repository;

import com.interview.simulator.profile.entity.Profile;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.Set;

@Repository
public interface ProfileRepository extends JpaRepository<Profile, Long> {
    List<Profile> findByActiveTrueOrderByNameAsc();

    List<Profile> findAllByOrderByNameAsc();

    boolean existsByCode(String code);

    Optional<Profile> findByCode(String code);

    Set<Profile> findByCodeIn(Set<String> codes);

    boolean existsByCodeAndIdNot(String code, Long id);

    boolean existsByName(String name);

    boolean existsByNameAndIdNot(String name, Long id);

    long countByActiveTrue();
}
