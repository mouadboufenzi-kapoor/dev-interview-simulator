package com.interview.simulator.admin.generation.provider;

import com.interview.simulator.admin.generation.dto.GenerationOptionsResponse.ProviderOption;
import com.interview.simulator.admin.generation.service.GeminiGenerationClient;
import com.interview.simulator.exception.ApiException;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;

import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.stream.Collectors;

@Component
public class GenerationProviderRegistry {

    /** Cible validee d'une generation : fournisseur + modele (null = modele par defaut). */
    public record Resolved(LLMGenerationProvider provider, String model) {
    }

    private record Entry(LLMGenerationProvider provider, String label, List<String> models) {
    }

    private final Map<String, Entry> entries = new LinkedHashMap<>();
    private final String defaultProviderId;

    public GenerationProviderRegistry(
            GeminiGenerationClient gemini,
            GroqGenerationProvider groq,
            @Value("${app.generation.provider:gemini}") String defaultProviderId,
            @Value("${app.generation.gemini.models:gemini-3.8-flash}") List<String> geminiModels,
            @Value("${app.generation.groq.models:openai/gpt-oss-120b}") List<String> groqModels) {
        this.entries.put("gemini", new Entry(gemini, "Gemini", clean(geminiModels)));
        this.entries.put("groq", new Entry(groq, "Groq", clean(groqModels)));
        this.defaultProviderId = defaultProviderId == null || defaultProviderId.isBlank()
                ? "gemini"
                : defaultProviderId.trim().toLowerCase(Locale.ROOT);
        if (!this.entries.containsKey(this.defaultProviderId)) {
            throw new IllegalStateException(
                    "Fournisseur LLM inconnu pour app.generation.provider : '" + defaultProviderId
                            + "'. Valeurs disponibles : " + String.join(", ", this.entries.keySet()) + ".");
        }
    }

    /** Fournisseur par defaut du serveur (GENERATION_PROVIDER). */
    public String defaultProviderId() {
        return defaultProviderId;
    }

    /** Catalogue pour l'admin : ordre de configuration conserve, aucun appel reseau. */
    public List<ProviderOption> options() {
        return entries.entrySet().stream()
                .map(e -> new ProviderOption(
                        e.getKey(),
                        e.getValue().label(),
                        e.getValue().provider().isConfigured(),
                        e.getKey().equals(defaultProviderId),
                        e.getValue().models()))
                .toList();
    }

    /**
     * Valide le couple fourni par l'admin et renvoie la cible a utiliser.
     * providerId null/vide = fournisseur par defaut du serveur ; modelId null/vide =
     * modele par defaut du fournisseur. Fournisseur inconnu ou modele non autorise
     * pour ce fournisseur => 400 avec la liste des valeurs possibles (aucune cle).
     */
    public Resolved resolve(String providerId, String modelId) {
        String id = providerId == null || providerId.isBlank()
                ? defaultProviderId
                : providerId.trim().toLowerCase(Locale.ROOT);
        Entry entry = entries.get(id);
        if (entry == null) {
            throw new ApiException(HttpStatus.BAD_REQUEST,
                    "Fournisseur de génération inconnu : '" + providerId
                            + "'. Fournisseurs disponibles : " + String.join(", ", entries.keySet()) + ".");
        }
        if (modelId == null || modelId.isBlank()) {
            return new Resolved(entry.provider(), null);
        }
        String model = modelId.trim();
        if (!entry.models().contains(model)) {
            throw new ApiException(HttpStatus.BAD_REQUEST,
                    "Modèle '" + model + "' non autorisé pour le fournisseur " + id
                            + ". Modèles configurés : " + String.join(", ", entry.models()) + ".");
        }
        return new Resolved(entry.provider(), model);
    }

    /** IDs nets (espaces supprimes, doublons evites) dans l'ordre de configuration. */
    private static List<String> clean(List<String> models) {
        if (models == null || models.isEmpty()) {
            return List.of();
        }
        LinkedHashSet<String> unique = models.stream()
                .map(String::trim)
                .filter(model -> !model.isEmpty())
                .collect(Collectors.toCollection(LinkedHashSet::new));
        return List.copyOf(unique);
    }
}