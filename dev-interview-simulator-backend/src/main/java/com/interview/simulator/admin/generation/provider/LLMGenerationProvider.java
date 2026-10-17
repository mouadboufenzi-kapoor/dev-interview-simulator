package com.interview.simulator.admin.generation.provider;

/**
 * Contrat commun aux fournisseurs de generation LLM.
 * Le texte renvoye par {@link #generateText(String)} est la reponse brute du modele :
 * son interpretation (parsing JSON, validations) appartient au service de generation.
 */
public interface LLMGenerationProvider {

    /**
     * @return true si le fournisseur est active et configuré (cle presente) ;
     *         false si la generation doit repondre 503 sans appel reseau.
     */
    boolean isConfigured();

    /**
     * Envoie le prompt au fournisseur et renvoie la reponse textuelle brute.
     *
     * @throws com.interview.simulator.exception.ApiException selon le contrat d'erreur partage
     *         (429 quota, 502 fournisseur indisponible ou reponse illisible, 504 timeout)
     */
    String generateText(String prompt);
}