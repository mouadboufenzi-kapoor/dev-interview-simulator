package com.interview.simulator.admin.generation.provider;

import com.interview.simulator.admin.generation.service.GeminiGenerationClient;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.NoSuchBeanDefinitionException;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.ApplicationContext;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;

import java.util.Locale;

/**
 * Selection du fournisseur LLM actif via {@code app.generation.provider}.
 *
 * <p>Comportement :
 * <ul>
 *   <li>configuration absente (ou vide) : fournisseur par defaut {@code gemini}, identique au
 *       comportement actuel ;</li>
 *   <li>valeur inconnue : echec explicite au demarrage avec la liste des valeurs disponibles ;</li>
 *   <li>fournisseur valide mais implementation absente de le contexte : echec explicite au
 *       demarrage ;</li>
 *   <li>aucun fallback automatique : seuls les fournisseurs declares ici existent ; ajouter
 *       Groq ou OpenRouter plus tard = une nouvelle implementation de
 *       {@link LLMGenerationProvider} + un {@code case} ci-dessous, sans toucher a
 *       {@code ChallengeGenerationService}.</li>
 * </ul>
 */
@Configuration
public class GenerationProviderConfiguration {

    private static final Logger logger = LoggerFactory.getLogger(GenerationProviderConfiguration.class);

    private static final String DEFAULT_PROVIDER = "gemini";

    @Bean
    @Primary
    public LLMGenerationProvider generationProvider(
            @Value("${app.generation.provider:" + DEFAULT_PROVIDER + "}") String providerName,
            ApplicationContext applicationContext) {

        String provider = providerName == null || providerName.isBlank()
                ? DEFAULT_PROVIDER
                : providerName.trim().toLowerCase(Locale.ROOT);

        return switch (provider) {
            case "gemini" -> requireBean(applicationContext, GeminiGenerationClient.class, provider);
            default -> throw new IllegalStateException(
                    "Fournisseur LLM inconnu pour app.generation.provider : '" + providerName
                            + "'. Valeurs disponibles : " + DEFAULT_PROVIDER
                            + ". Aucun autre fournisseur n'est declare dans cette version.");
        };
    }

    private static LLMGenerationProvider requireBean(
            ApplicationContext applicationContext,
            Class<? extends LLMGenerationProvider> type,
            String providerName) {
        try {
            LLMGenerationProvider provider = applicationContext.getBean(type);
            logger.info("Fournisseur LLM actif pour la generation : {}", providerName);
            return provider;
        } catch (NoSuchBeanDefinitionException e) {
            throw new IllegalStateException(
                    "Le fournisseur LLM '" + providerName
                            + "' est selectionne mais aucune implementation n'est disponible dans le contexte : "
                            + "ajoutez le bean correspondant ou corrigez app.generation.provider "
                            + "(aucun fallback automatique vers un autre fournisseur).", e);
        }
    }
}