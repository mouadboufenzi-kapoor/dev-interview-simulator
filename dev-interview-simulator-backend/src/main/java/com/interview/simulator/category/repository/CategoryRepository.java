package com.interview.simulator.category.repository;

import com.interview.simulator.category.entity.Category;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Set;

@Repository
public interface CategoryRepository extends JpaRepository<Category, Long> {

    Set<Category> findByNameIn(Set<String> names);

    java.util.List<Category> findAllByOrderByNameAsc();
}