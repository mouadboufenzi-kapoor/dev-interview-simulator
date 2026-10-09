package com.interview.simulator.profile.repository;

import com.interview.simulator.profile.entity.Profile;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ProfileRepository extends JpaRepository<Profile, Long> {
    List<Profile> findByActiveTrueOrderByNameAsc();
}
