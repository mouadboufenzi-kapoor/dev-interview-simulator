package com.interview.simulator.simulation.repository;

import com.interview.simulator.simulation.entity.SimulationAnswer;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

@Repository
public interface SimulationAnswerRepository extends JpaRepository<SimulationAnswer, Long> {

    /**
     * Raisonnement séquentiel (V11) : position de chaque étape dans l'ordre soumis
     * par l'utilisateur, écrite sur la jointure simulation_answer_options.
     * Nullable en base : la colonne reste NULL pour les réponses QCM/classiques.
     */
    @Modifying
    @Query(value = """
            UPDATE simulation_answer_options
            SET answer_position = :position
            WHERE simulation_answer_id = :answerId AND option_id = :optionId
            """, nativeQuery = true)
    void updateAnswerOptionPosition(@Param("answerId") Long answerId,
                                    @Param("optionId") Long optionId,
                                    @Param("position") int position);
}
