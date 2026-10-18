package com.interview.simulator.admin.challenge.validation;

import com.interview.simulator.challenge.entity.ContentStatus;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

/**
 * Verrou de qualité unique : une question ne peut pas porter le statut
 * VALIDATED sans au moins une catégorie et au moins une compétence.
 *
 * Les statuts DRAFT et ARCHIVED (et tout autre statut que VALIDATED) ne
 * sont jamais bloqués : un brouillon ou un import en DRAFT restent possibles
 * sans rattachement.
 *
 * La méthode renvoie null quand la règle est satisfaite, sinon un message
 * précisant ce qui manque (catégorie, compétence, ou les deux). Chaque appelant
 * décide de la conséquence : ApiException côté admin, QuestionOutcome.error
 * côté import — le message reste identique partout.
 */
public final class ValidatedStatusValidator {

    private ValidatedStatusValidator() {
    }

    public static String violationMessage(ContentStatus status, Collection<?> categories, Collection<?> skills) {
        if (status != ContentStatus.VALIDATED) {
            return null;
        }
        List<String> missing = new ArrayList<>();
        if (categories == null || categories.isEmpty()) {
            missing.add("catégorie");
        }
        if (skills == null || skills.isEmpty()) {
            missing.add("compétence");
        }
        if (missing.isEmpty()) {
            return null;
        }
        return "Une question VALIDATED doit avoir au moins une catégorie et au moins une compétence. Manquant : "
                + String.join(" et ", missing) + ".";
    }
}
