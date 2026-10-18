package com.interview.simulator.admin.generation.dto;

import java.util.List;

/**
 * Catalogue des fournisseurs et modeles exploitables par l'admin a chaque generation.
 * Ne contient jamais de cle API : uniquement identifiants, libelles et indicateurs.
 */
public record GenerationOptionsResponse(
        String defaultProvider,
        List<ProviderOption> providers) {

    public record ProviderOption(
            String id,
            String label,
            boolean configured,
            boolean defaultProvider,
            List<String> models) {
    }
}