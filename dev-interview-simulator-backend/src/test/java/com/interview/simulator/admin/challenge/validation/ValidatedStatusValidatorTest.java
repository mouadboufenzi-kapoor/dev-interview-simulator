package com.interview.simulator.admin.challenge.validation;

import com.interview.simulator.challenge.entity.ContentStatus;
import org.junit.jupiter.api.Test;

import java.util.List;
import java.util.Set;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;

class ValidatedStatusValidatorTest {

    private static final String PREFIX =
            "Une question VALIDATED doit avoir au moins une catégorie et au moins une compétence. Manquant : ";

    @Test
    void validated_WithoutCategoryAndSkill_NamesBoth() {
        String message = ValidatedStatusValidator.violationMessage(
                ContentStatus.VALIDATED, Set.of(), List.of());

        assertEquals(PREFIX + "catégorie et compétence.", message);
    }

    @Test
    void validated_WithoutCategory_NamesCategoryOnly() {
        String message = ValidatedStatusValidator.violationMessage(
                ContentStatus.VALIDATED, Set.of(), Set.of(new Object()));

        assertEquals(PREFIX + "catégorie.", message);
    }

    @Test
    void validated_WithoutSkill_NamesSkillOnly() {
        String message = ValidatedStatusValidator.violationMessage(
                ContentStatus.VALIDATED, Set.of(new Object()), Set.of());

        assertEquals(PREFIX + "compétence.", message);
    }

    @Test
    void validated_WithCategoryAndSkill_ReturnsNull() {
        assertNull(ValidatedStatusValidator.violationMessage(
                ContentStatus.VALIDATED, Set.of(new Object()), Set.of(new Object())));
    }

    @Test
    void draft_WithoutCategoryAndSkill_IsNeverBlocked() {
        assertNull(ValidatedStatusValidator.violationMessage(
                ContentStatus.DRAFT, Set.of(), Set.of()));
    }

    @Test
    void archived_WithoutCategoryAndSkill_IsNeverBlocked() {
        assertNull(ValidatedStatusValidator.violationMessage(
                ContentStatus.ARCHIVED, Set.of(), Set.of()));
    }
}
