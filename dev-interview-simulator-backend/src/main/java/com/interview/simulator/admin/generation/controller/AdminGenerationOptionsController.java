package com.interview.simulator.admin.generation.controller;

import com.interview.simulator.admin.generation.dto.GenerationOptionsResponse;
import com.interview.simulator.admin.generation.provider.GenerationProviderRegistry;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * Catalogue des fournisseurs et modeles cotes backend, destine au formulaire de
 * generation admin. Route sous /api/admin/** (ROLE_ADMIN via SecurityConfig).
 * Aucun appel LLM au chargement : la liste vient uniquement de la configuration,
 * sans exposer de cle API.
 */
@RestController
@Validated
@RequestMapping("/api/admin/generation")
public class AdminGenerationOptionsController {

    private final GenerationProviderRegistry generationProviderRegistry;

    public AdminGenerationOptionsController(GenerationProviderRegistry generationProviderRegistry) {
        this.generationProviderRegistry = generationProviderRegistry;
    }

    @GetMapping("/options")
    public GenerationOptionsResponse options() {
        return new GenerationOptionsResponse(
                generationProviderRegistry.defaultProviderId(),
                generationProviderRegistry.options());
    }
}