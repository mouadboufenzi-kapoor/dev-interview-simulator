-- ===============================================
-- Catalogue V1 — Profil Développeur — catégories manquantes
-- V28 : CI / CD (25 défis — 17 QCM, 3 problem-solving,
--       1 code review, 4 raisonnement séquentiel)
-- Idempotent : WHERE NOT EXISTS sur challenges.title (jamais utilisé).
-- Même structure que l'import JSON futur : challenges + challenge_options
--   (content / is_correct / display_order / explanation) + liens
--   categories / skills / profiles.
-- Aucune redondance :
--   - Docker V27 = build d'image, signaux, ressources (périmètre image) ;
--   - Git V26 = flux de branches, tags manuels, release procédurale ;
--   - Tests V22 = flaky, couverture, métriques de test ;
--   - SQL V18 = expand/contract de colonne (périmètre base).
-- Skills existants uniquement (V6) : Code Quality / Problem Solving.
-- ===============================================

INSERT INTO challenges (
    title, type, selection_type, difficulty, context, question,
    explanation, estimated_time_seconds, active, points,
    created_at, updated_at
)
SELECT * FROM (VALUES
('CI : ce que la CI doit bloquer avant la merge', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'JUNIOR',
 'L''équipe « a de la CI » : un job qui compile. Les régressions se découvrent en recette, parfois en prod.',
 'Quel est le contrat minimal d''une intégration continue, et pourquoi ce périmètre-là ?',
 'La CI vérifie, à CHAQUE proposition, ce qui peut casser pour de vrai : build, tests, contrôles automatiques — avant que le travail ne se mélange aux autres. Le périmètre se choisit pour être complet et rapide : ce qui n''est pas vérifié ici sera vérifié par un humain (revue) ou plus tard (prod), au coût le plus élevé des trois.',
 130, true, 10, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('CI : l''ordre des étages du pipeline', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'JUNIOR',
 'Le pipeline lance tout en parallèle : analyse lourde, packaging, tests e2e, puis compile en dernier. On attend 6 minutes pour découvrir une faute de frappe.',
 'Quel ordre d''étages sert le feedback le plus rapide ?',
 'Placer d''abord les contrôles les plus rapides et les plus susceptibles d''échouer (syntaxe/lint, compilation, tests unitaires), ensuite les lourds (intégration, packaging), enfin les plus lents. Fail fast : l''échec probable arrive en premier, le parallélisme complète sans masquer l''ordre logique. Attendre 6 minutes pour un bug de frappe gaspille le principe même de la CI.',
 130, true, 10, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('CI : push ou pull request comme déclencheur', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'JUNIOR',
 'Deux déclencheurs en lice : CI à chaque push, ou CI à l''ouverture/mise à jour de la pull request.',
 'Quel déclencheur vaut quoi, et comment les combiner ?',
 'La PR est la porte du gate : CI au push offre le feedback local rapide (itération du développeur), la CI de PR protège l''intégration (résultat exigé avant merge). Combinés : pousser donne un feedback vert sur son propre travail, la PR garantit que seul un travail vérifié entre. Tester uniquement à la merge (ou jamais) revient à vérifier après le mélange.',
 140, true, 10, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('CI : construire une fois, promouvoir partout', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'JUNIOR',
 'Chaque environnement reconstruit l''application à partir du code : le staging passe, la prod échoue sur « la même version ».',
 'Quel principe de livraison évite l''écart ?',
 'Un seul artefact construit (immutabilité par digest) puis PROMU entre environnements — dev/stage/prod exécutent exactement les mêmes octets, seule la configuration change. Reconstruire = produire un autre artefact : les dépendances flottantes, le toolchain et le moment du build introduisent des différences que personne ne contrôle.',
 140, true, 10, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('CI : configuration et secrets par environnement', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'JUNIOR',
 'Un fichier de configuration contient les URLs et clés des trois environnements ; il est commité « pour que ça marche partout ».',
 'Quelle séparation est saine ?',
 'Configuration par environnement injectée à l''exécUTION (variables du runner/orchestrateur), jamais compilée dans l''artefact ; les secrets ne vivent qu''dans le coffre de leur pipeline, avec des droits par environnement. Le fichier-commun cherche la commodité au prix du secret versionné et d''un artefact différent partout — l''inverse de la promotion propre.',
 140, true, 10, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('CI : paralléliser les tests', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'La suite de tests dure 18 minutes sur un seul runner ; l''équipe veut la découper en quatre pour tenir sous les 6.',
 'Quels écueils et réglages décident du gain réel ?',
 'Le parallélisme utile exige : découpage par temps (pas par nombre de fichiers — un test lent monopolise sa grappe), isolation des tests partagés (base, ports, fichiers : sinon la parallélisation crée du flaky), rapports fusionnés, et un coût de démarrage maîtrisé. Mesurer la répartition réelle avant de choisir le nombre de grappes : la moitié du temps se passe souvent dans trois tests.',
 150, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('CI : cache des dépendances et lockfile', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Après un changement de dépendance, le cache saute et tout se télécharge ; un autre jour, deux builds identiques produisent des versions différentes.',
 'Comment fiabiliser vitesse et reproductibilité ?',
 'La clé de cache se calcule sur le LOCKFILE (et le toolchain) — la seule source de vérité des versions ; installation en mode verrouillé (frozen/locked) pour échouer si le lockfile et le manifest divergent ; cache partagé entre runners mais jamais un lockfile modifié dans la CI. Sans clé sur le lockfile, le cache devient un non-dit : ni vitesse fiable, ni build identique.',
 150, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('CI : secrets dans le pipeline sans fuite', 'SITUATIONAL_QCM', 'MULTIPLE_CHOICE', 'INTERMEDIATE',
 'Les pipelines manipulent des jetons de publication ; l''équipe craint les journaux d''exécution et les forks.',
 'Quelles pratiques tiennent réellement la sécurité des secrets de CI ?',
 'Portée minimale (droits strictement nécessaires à ce job), injection seulement aux étapes qui en ont besoin, masquage dans les journaux + interdiction de les imprimer, remplacement par OIDC/fédération quand possible (pas de clé persistante), et éviction des secrets des forks/PR externes. Un secret longue durée dans un pipeline est un secret déjà partagé avec toute son histoire d''exécution.',
 160, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('CI : versions, tags et changelog', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'L''équipe incrémente la version à la main dans le pom, oublie des tags, et le changelog est écrit au dernier moment — parfois.',
 'Quelle chaîne automatise une version honnête ?',
 'Une source unique : les conventions de commits (ou le merge tracé) → calcul de version (semver : rupture/fonctionnalité/correctif) → bump + changelog générés → tag signé publié avec l''artefact. Le tag devient l''adresse de la release et alimente les notes ; l''humain arbitre les cas limites, pas la saisie du numéro. Sans source unique, la version raconte l''organisation, pas le logiciel.',
 150, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('CI : déploiement canari et critères de bascule', 'SITUATIONAL_QCM', 'MULTIPLE_CHOICE', 'INTERMEDIATE',
 'Le déploiement monolithique (100 % en une fois) fait peur ; l''équipe veut une mise en progressive mais personne ne sait quoi observer.',
 'Quelles affirmations décrivent un canari qui tient ses promesses ?',
 'Un pourcentage maîtrisé avec critères de bascule EXPLICITES (taux d''erreur, latence, métriques métier) comparés à la version précédente : sinon « le canari va bien » reste une opinion. Il faut un vrai trafic (le canal de feedback est la production), une bascule automatique aux critères, et l''équivalence des migrations de données entre versions. Sans critères écrits d''avance, le canari est un décor.',
 160, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('CI : schéma et application ne se déploient pas au même rythme', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Déploiement simultané : la nouvelle version lit une colonne que l''ancienne, encore active, ignore — ou l''inverse.',
 'Quel contrat de compatibilité structurer autour des migrations ?',
 'Le schéma doit être compatible avec l''application précédente ET la suivante pendant la fenêtre de bascule : migrations en deux temps (étendre, puis nettoyer après), lecture tolérante à l''absence des nouveaux champs, ordre « base d''abord » pour tout ajout. On teste le couple version précédente → nouveau schéma et version nouvelle → ancien schéma — sinon chaque déploiement est un pari sur l''ordre d''arrivée.',
 160, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('CI : file de merge et main toujours verte', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Deux PR vertes fusionnent ; leur combinaison casse la build — détectée à la troisième merge suivante, par des gens sans rapport.',
 'Quel mécanisme garantit que main reste verte ?',
 'Une file de merge (merge queue) : les PR sont testées EN COMBINAISON avec la pointe et entre elles avant fusion — ce n''est qu''alors que la vertu est prouvée. Sans file, deux approches individuellement vertes n''ont jamais été testées ensemble ; le dette revient sur la main pour tout le monde. La règle « la main est verrouillée sur CI verte » devient une propriété vérifiée, pas un vœu.',
 150, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('CI : lint et analyse statique comme garde-fous', 'SITUATIONAL_QCM', 'MULTIPLE_CHOICE', 'INTERMEDIATE',
 'L''équipe ajoute analyse statique et formatage : certains voulaient tout bloquer, d''autres ne rien bloquer du tout.',
 'Quelle politique de garde-fous est la plus sage ?',
 'Bloquer sur le fiable et le mécanique (formatage, erreurs certaines, règles de sécurité ciblées) — le signal est net et l''effort borné ; laisser informatif ce qui juge (complexité, duplication, couverture) pour alimenter la revue sans guerre de réglage. La règle qui n''est jamais honorée devient du bruit qu''on apprend à ignorer — pire : elle vous apprend à ignorer la CI.',
 160, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('CI : identité du pipeline sans clé statique (OIDC)', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'ADVANCED',
 'Un compte cloud est accessible via une clé API placée dans les secrets de la CI ; le token fait 12 mois et son historique de rotation est confus.',
 'Quel mécanisme remplace avantageusement la clé persistante ?',
 'La fédération d''identité (OIDC) : le runner présente un jeton court, signé et vérifiable (identité du dépôt, branche, workflow), le cloud échange contre un jeton de session à durée brève. Fin de clé à recopier, traçabilité fine (quelle branche a pris quel droit), et révocation par politique plutôt que par rotation. Le jeton vivant quelques minutes remplace un secret permanent dont personne ne connaît le périmètre.',
 170, true, 20, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('CI : provenance, SBOM et signatures d''images', 'SITUATIONAL_QCM', 'MULTIPLE_CHOICE', 'ADVANCED',
 'Face à une dépendance compromise, l''équipe doit répondre en une heure : « quels services tournent quelque chose de touché ? » — personne ne le sait.',
 'Quelles pratiques rendent la réponse possible ?',
 'SBOM (inventaire des composants par version, généré à la construction) pour croiser le CVE avec le périmètre ; provenance attestée (qui a construit, depuis quel commit, avec quelles entrées) pour faire le tri entre images fiables et contrefaites ; signature des images et vérification à l''admission pour que seules les images attestées tournent. Sans ces trois, la réponse dépend de la mémoire des gens — et prend des jours.',
 170, true, 20, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('CI : infrastructure as code dans le pipeline', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'ADVANCED',
 'L''infrastructure se modifie à la main dans la console cloud ; une « petite règle pare-feu » ouverte à 22 h diffère de ce que le dépôt dit.',
 'Quel régime introduire, et avec quels garde-fous ?',
 'Toute définition versionnée (plan, revue, puis application automatisée) : la console redevient l''exception tracée, le drift se détecte (plan périodique comparé à l''état réel). Garde-fous : séparation des environnements, approbation sur les environnements sensibles, plan affiché en revue avant apply. Sans détection de drift, l''IaC décrit un monde qui n''existe plus.',
 170, true, 20, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('CI : pipelines sélectifs en monorepo', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'ADVANCED',
 'Monorepo de 40 services : chaque commit lance 40 pipelines complets ; les files débordent et tout le monde attend pour une ligne changée.',
 'Quelle sélectivité structurer sans perdre la couverture ?',
 'Filtrer par chemin (seuls les services impactés se construisent) + calcul des tests impactés par graphe de dépendances, avec un job de vérification périodique du filtre lui-même. Garde-fous : les changements transversaux (toolchain, contrats partagés) doivent déclencher le large — un filtre optimiste qui rate une dépendance rend la CI rapide et fausse. La sélectivité se prouve, elle ne se postule pas.',
 170, true, 20, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('CI : config d''environnement qui fait échouer la livraison', 'PROBLEM_SOLVING', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'La mise en prod échoue alors que staging est vert : variable absente en prod, URL de service différente, un secret jamais injecté hors préproduction.',
 'Décrivez la démarche : diagnostics, structure de configuration, validation amont, prévention.',
 'Démarche : (1) comparer les configurations EFFECTIVES des deux environnements (quelles variables, quelles valeurs — pas les fichiers) pour isoler l''écart exact ; (2) mettre en place une configuration versionnée par environnement, injectée à l''exécution, avec schéma validé (config manquante = échec au DÉMARRAGE, pas en cours de requête) ; (3) valider amont : démarrage en dry-run avec la config prod simulée, contrôles de présence/type de variables dans la CI ; (4) séparer secrets et configuration non sensible ; (5) prévenir : template de déploiement, checklist automatisée, test de démarrage dans la pipeline. L''écart de config se traite comme un defect de build, pas comme une fatalité d''exploitation.',
 900, true, 30, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('CI : introduire la livraison continue sur projet à déploiement manuel', 'PROBLEM_SOLVING', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Projet livré tous les deux mois par copie manuelle sur un serveur ; l''équipe veut de la livraison continue sans risquer la production.',
 'Décrivez la trajectoire d''installation, incrémentale et vérifiable.',
 'Trajectoire : (1) poser le filet minimal — build + tests automatiques obligatoires sur chaque proposition, branche protégée ; (2) fiabiliser l''artefact — construction unique, reproductible, versionnée ; (3) automatiser d''abord la préproduction — déploiement automatique avec vérifications ; (4) ajouter le test de démarrage et les contrôles de config sur l''environnement ; (5) bascule prod automatisée mais déclenchée (release manuelle d''abord), avec rollback immédiat ; (6) puis livraison continue réelle : fréquence haussée, taille bouchée, métriques (lead time, taux de changement, MTTR). Chaque étape augmente la fréquence SANS diminuer la sûreté — l''une sans l''autre n''est qu''une accélération vers l''accident.',
 900, true, 30, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('CI : dette du pipeline hérité', 'PROBLEM_SOLVING', 'SINGLE_CHOICE', 'ADVANCED',
 'Une pipeline de 600 lignes, écrite par un ancien parti : scripts shell entremêlés, personne ne sait ce qu''elle fait vraiment, personne n''ose y toucher.',
 'Décrivez le plan de reprise : cartographie, réécriture progressive, tests du pipeline lui-même, propriété partagée.',
 'Plan : (1) cartographier — ce qui tourne réellement (étages, entrées/sorties, secrets, dépendances cachées), ce qui bloque les merges, ce que personne ne comprend ; (2) trier — indispensable / obsolète / dangereux (supprimer le mort d''abord : moins de surface à réécrire) ; (3) réécrire progressivement par étage, l''ancien et le nouveau en parallèle sur les mêmes commits, comparaison des résultats ; (4) traiter le pipeline comme du code — revue, version, et « tests du pipeline » (dry-run, exécution sur un commit de référence, règles de composition vérifiables) ; (5) propriété partagée — runbook court, alertes, rotation des responsables. On ne réécrit pas 600 lignes en bloc : on remplace un étage à la fois, sous comparaison.',
 900, true, 30, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('CI : structurer la pipeline d''un projet partagé', 'SEQUENTIAL_REASONING', 'SINGLE_CHOICE', 'ADVANCED',
 'Six équipes poussent sur le même dépôt : les files de CI débordent, tout le monde bloque tout le monde, et personne ne sait qui réparer quoi.',
 'Place ces étapes dans l''ordre de la structuration recommandée.',
 'La structuration va de la mesure à la gouvernance : voir QUI consomme et POURQUOI (attribution du coût), découper les déclencheurs par chemin pour ne payer que ce qui change, poser des limites de parallélisme et de quotas, rendre chaque pipeline propriétaire de son périmètre (statut visible, mainteneurs nommés), puis ritualiser la maintenance. Sans attribution du coût, toute règle de file reste perçue comme une contrainte arbitraire.',
 360, true, 20, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
) AS v(title, type, selection_type, difficulty, context, question, explanation, estimated_time_seconds, active, points, created_at, updated_at)
WHERE NOT EXISTS (SELECT 1 FROM challenges c WHERE c.title = v.title);

INSERT INTO challenges (
    title, type, selection_type, difficulty, context, question,
    explanation, estimated_time_seconds, active, points,
    created_at, updated_at
)
SELECT * FROM (VALUES
('CI : premier déploiement automatisé vers la prod', 'SEQUENTIAL_REASONING', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'L''équipe souhaite franchir le pas : de « release déclenchée à la main » à « la CI pousse en prod » — sans perdre le contrôle.',
 'Place ces étapes dans l''ordre de la bascule recommandée.',
 'La bascule ajoute de la fréquence en gardant la main : artefact unique promu, gate de qualité explicite, déploiement d''abord déclenché (une personne lance), filet de retour immédiat, puis surveillance du déploiement qui conditionne la suite. Automatiser le geste précède l''automatisation du déclenchement — sinon on a délégué la production à un YAML non éprouvé.',
 300, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('CI : faire entrer un nouveau contrôle dans le pipeline', 'SEQUENTIAL_REASONING', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Un nouveau contrôle (analyse de licence, scan de secret, test de performance) doit rejoindre la pipeline — sans ralentir tout le monde ni être contourné.',
 'Place ces étapes dans l''ordre de l''intégration recommandée.',
 'L''intégration d''un contrôle suit : définition du signal (que détecte-t-il, quelle preuve produit), choix de l''emplacement selon coût et pertinence (rapide bloquant en amont, lent en fond), période informative pour mesurer le ratio signal/bruit, puis bascule en bloquant avec budget de temps assumé et voie d''exception tracée. Un contrôle instauré bloquant d''emblée est contourné ; un contrôle qui n''est jamais bloquant n''existe pas.',
 300, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('CI : rétablir la chaîne de livraison après incident', 'SEQUENTIAL_REASONING', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Une livraison a mis en prod une version défaillante ; la livraison automatique est désormais perçue comme dangereuse et réclamée « à la main ».',
 'Place ces étapes dans l''ordre de la reprise recommandée.',
 'La reprise d''une chaîne de livraison va du frein aux leçons : geler les livraisons suivantes (stabiliser le système avant de chercher), remonter à la version saine, diagnostiquer la chaîne elle-même (quel gate aurait dû l''arrêter — test absent, config, artefact non conforme), corriger et PROUVER le gate par un envoi contrôlé, reprendre par paliers avec surveillance, et faire le post-mortem. Rétablir la cadence avant de savoir pourquoi ça a cassé, c''est programmer la récidive.',
 300, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
) AS v(title, type, selection_type, difficulty, context, question, explanation, estimated_time_seconds, active, points, created_at, updated_at)
WHERE NOT EXISTS (SELECT 1 FROM challenges c WHERE c.title = v.title);

-- -----------------------------------------------
-- Options des QCM (SINGLE : 1 correcte — MULTIPLE : 2-3 correctes)
-- -----------------------------------------------

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('À chaque proposition : build, tests, contrôles automatiques — vérifier avant que le travail ne se mélange', true, 1,
 'Le périmètre se choisit pour être complet et rapide : au-delà, c''est la revue humaine ou la prod qui paie.'),
('Lancer l''intégration quotidienne en fin de journée pour batcher les échecs', false, 2,
 'Le feedback différé multiplie le mélange des causes — l''inverse du principe.'),
('Laisser les tests en recette manuelle : la CI ne sert qu''à compiler', false, 3,
 'Compiler ne détecte aucune régression de comportement : c''est le cas décrit.'),
('Vérifier seulement ce qui concerne le service modifié', false, 4,
 'Les régressions transversales sont exactement celles que personne ne voit venir.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'CI : ce que la CI doit bloquer avant la merge'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Rapides et probables en premier (lint, compile, unitaires), lourds ensuite : le fail fast sert le feedback', true, 1,
 'L''échec le plus fréquent arrive en premier — et coûte le moins cher à détecter.'),
('Lancer tout en parallèle : l''ordre ne change rien', false, 2,
 'Le parallélisme ne corrige pas l''attente d''un résultat critique derrière un étage lent.'),
('Les tests e2e d''abord : ils couvrent le plus, donc ils informent le plus', false, 3,
 'Couverture large et diagnostic rapide sont deux besoins différents — un e2e ne dit pas où est la faute.'),
('Le packaging d''abord pour disposer de l''artefact le plus tôt', false, 4,
 'Empaqueter du code qui ne compile pas ne sert personne.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'CI : l''ordre des étages du pipeline'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Push = feedback rapide de son propre travail ; PR = gate exigé avant fusion — les deux se complètent', true, 1,
 'Le développeur itère vert sur son travail, l''intégration ne s''ouvre qu''à des travaux vérifiés.'),
('Seul le push compte : la PR n''a pas besoin de vérification', false, 2,
 'Deux pushes verts peuvent former un couple cassant — c''est la PR qui doit le prouver.'),
('Un seul déclencheur suffit toujours : choisir entre les deux', false, 3,
 'Les deux rôles (itération et protection) n''ont pas le même destinataire.'),
('Tester uniquement à la merge, une fois par jour', false, 4,
 'Vérifier après le mélange retourne au problème initial — et quotidiennement.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'CI : push ou pull request comme déclencheur'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Un artefact unique construit une fois, promu entre environnements par digest — seule la configuration change', true, 1,
 'Reconstruire produit un AUTRE artefact : dépendances, toolchain et moment du build divergent.'),
('Reconstruire à chaque environnement pour refléter sa configuration', false, 2,
 'La config appartient à l''exécution, pas à la construction — reconstruire mélange les deux.'),
('Comparer manuellement les versions de dépendances entre les builds pour détecter l''écart', false, 3,
 'Contrôle perpétuel et impossible : c''est le principe de construction propre qui évite l''écart.'),
('Ne promouvoir qu''en préproduction, la prod pouvant se reconstruire en urgence', false, 4,
 'L''artefact d''urgence est précisément celui qu''aucun environnement n''a jamais testé.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'CI : construire une fois, promouvoir partout'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Config par environnement injectée à l''exécution ; secrets hors artefact, dans le coffre de leur pipeline', true, 1,
 'Un seul artefact, des configurations distinctes — les secrets suivent l''environnement, pas le build.'),
('Compiler la configuration dans l''artefact : c''est plus simple à retrouver', false, 2,
 'La clé en couche = secret versionné ET artefact différent partout — deux défauts en un.'),
('Un seul fichier de config partagé, commenté pour plus de clarté', false, 3,
 'Le fichier commun réunit les secrets des trois environnements — c''est la fuite par conception.'),
('Réutiliser les secrets de préproduction en prod : mêmes services', false, 4,
 'Mêmes services, droits différents : la portée de prod ne doit jamais circuler en dev.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'CI : configuration et secrets par environnement'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Découpage par TEMPS (les tests lourds d''abord) et isolation des ressources partagées — sinon le parallélisme crée du flaky', true, 1,
 'Une grappe dominée par un test lent ne gagne rien ; des tests partagés en parallèle se contredisent.'),
('Découper par nombre de fichiers de tests : la répartition est alors égale', false, 2,
 'Le volume de fichiers dit rien du temps : quelques tests lourds monopolisent leur grappe.'),
('Augmenter le nombre de grappes jusqu''à ce que la durée diminue', false, 3,
 'Au-delà du parallélisme réel, le démarrage domine : on paie plus pour gagner moins.'),
('Paralléliser en partageant la même base de test entre les grappes', false, 4,
 'Concurrence sur l''état partagé : c''est la recette du test instable en CI.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'CI : paralléliser les tests'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Clé de cache sur le lockfile (+ toolchain) et installation en mode verrouillé pour échouer sur divergence', true, 1,
 'Le lockfile est l''unique source de vérité des versions : la clé et la vérification en découlent.'),
('Clé de cache fixe : le cache doit durer le plus longtemps possible', false, 2,
 'Un cache figé sert d''anciennes dépendances — le « plus rapide » devient le plus faux.'),
('Autoriser la CI à mettre à jour le lockfile automatiquement', false, 3,
 'Le lockfile change alors hors revue, dans la machine — reproductibilité perdue.'),
('Ignorer le lockfile : le manifeste suffit à décrire les versions', false, 4,
 'Le manifeste décrit des fourchettes, pas des versions exactes — deux builds divergent.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'CI : cache des dépendances et lockfile'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Portée minimale et injection par étape : le secret n''est exposé qu''aux jobs qui l''utilisent', true, 1,
 'Moins de périmètre exposé = moins de dégât en cas de fuite de journal ou de code exécuté.'),
('Masquage des journaux + interdiction de les imprimer (et de les mettre en arguments)', true, 2,
 'Les journaux d''exécution sont le vecteur n°1 de fuite involontaire.'),
('Fédération OIDC quand possible : jeton court, aucune clé persistante à rotationner', true, 3,
 'Le pipeline prouve son identité au lieu de porter un secret permanent.'),
('Un secret unique longue durée pour tous les environnements : plus simple à gérer', false, 4,
 'Compromission = accès partout, pour des mois — la simplicité se paie en surface.'),
('Les PR externes peuvent utiliser les secrets : elles simulent la prod', false, 5,
 'Un code externe exécuté avec vos secrets = exfiltration assurée.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'CI : secrets dans le pipeline sans fuite'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Source unique (conventions de commits) → calcul semver → bump + changelog générés → tag publié avec l''artefact', true, 1,
 'La version décrit le logiciel parce qu''elle dérive de ce qui est entré, pas de la mémoire de quelqu''un.'),
('Incrémenter la version manuellement avant chaque mise en ligne', false, 2,
 'La version raconte alors l''organisation (oublis inclus), pas le logiciel.'),
('Écrire le changelog à la main au moment du déploiement', false, 3,
 'Rédigé après coup, il dépend du dernier qui se souvient — et saute sous la pression.'),
('Se passer de tags : la branche principale suffit à identifier la version', false, 4,
 'La branche bouge : sans adresse figée, « quelle version tournait mardi ? » n''a pas de réponse.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'CI : versions, tags et changelog'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Critères de bascule explicites et mesurés (erreurs, latence, métier) comparés à la version précédente', true, 1,
 '« L''équipe juge que ça va » n''est pas un critère : sans seuils écrits, aucun canari n''est concluant.'),
('Un vrai trafic de production comme canal de feedback', true, 2,
 'Le canari sert précisément à observer là où les problèmes se produisent réellement.'),
('Bascule automatique déclenchée par les critères (pas un humain attentif)', true, 3,
 'La fenêtre de réaction est courte : la bascule doit être une propriété, pas une astreinte.'),
('Déployer 50 % du trafic d''emblée pour accélérer la validation', false, 4,
 'L''objectif du canari est un petit périmètre à risque borné — 50 % le rend improbable.'),
('Migrer les données une fois que le canari est validé', false, 5,
 'Le schéma doit précéder les deux versions : ni canari ni rollback ne fonctionnent sinon.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'CI : déploiement canari et critères de bascule'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Schéma compatible avec l''ancienne ET la nouvelle version pendant la bascule : étendre d''abord, nettoyer après', true, 1,
 'Deux versions coexistent forcément — la fenêtre de double compatibilité est le contrat.'),
('Tester le couple version précédente → nouveau schéma et version nouvelle → ancien schéma', true, 2,
 'Les deux sens d''incompatibilité se vérifient : c''est le test de bascule.'),
('Appliquer migration et code en un seul geste atomique', false, 3,
 'Rien n''est atomique entre base et processus déployés un par un : la fenêtre existe toujours.'),
('Attendre que toutes les instances soient à jour avant toute migration', false, 4,
 'Prérequis impossible : la migration doit rendre le schéma SUPPORTÉ par l''ancienne version.'),
('Les migrations sont toujours réversibles : un down suffit comme filet', false, 5,
 'Down destructeur (perte de colonnes) = rollback en perte de données — le filet n''en est pas un.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'CI : schéma et application ne se déploient pas au même rythme'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('La file de merge teste les PR en combinaison avec la pointe avant fusion : la vertu est prouvée, pas supposée', true, 1,
 'Deux approches vertes séparément ne l''ont jamais été ensemble — la file le fait avant merge.'),
('Exiger la CI verte et à jour sur la dernière pointe avant toute fusion', true, 2,
 'La condition d''entrée courante : évite de fusionner un travail testé sur un état périmé.'),
('Faire merger vite puis corriger main cassée après coup', false, 3,
 'C''est l''état actuel décrit : la dette revient sur tout le monde, chez ceux qui n''ont rien cassé.'),
('Sérialiser toutes les merges pour éviter les conflits de combinaison', false, 4,
 'Sérialiser limite le nombre de PR, pas leur combinaison — le problème n''est pas la file d''attente.'),
('Confier la vérification de combinaison à la recette manuelle hebdomadaire', false, 5,
 'La découverte hebdomadaire multiplie le nombre de culpables possibles — et la portée du correctif.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'CI : file de merge et main toujours verte'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Bloquer le mécanique et le certain (formatage, erreurs sûres, règles de sécurité ciblées)', true, 1,
 'Signal net, effort borné : le blocage ne se négocie pas parce que la règle ne se discute pas.'),
('Laisser informatif ce qui juge (complexité, duplication) pour nourrir la revue', true, 2,
 'Un jugement imposé déclenche des guerres de réglage et des contournements — l''information suffit.'),
('Bloquer aussi les règles discutables : la qualité s''impose', false, 3,
 'Une règle jamais honorée devient du bruit qu''on apprend à ignorer — pire qu''absente.'),
('Ne rien bloquer : les contrôles servent seulement de rapport', false, 4,
 'Sans blocage, le contrôle cesse d''être un garde-fou — il devient un rapport de plus.'),
('Désactiver les contrôles lents pour préserver la vitesse du pipeline', false, 5,
 'La vitesse d''un pipeline qui ne vérifie plus rien est celle de la découverte en prod.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'CI : lint et analyse statique comme garde-fous'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('OIDC : jeton court signé par l''identité du pipeline, échangé contre un droit à durée brève — traçable et révocable par politique', true, 1,
 'Le pipeline prouve QUI il est au lieu de CARRIER un secret — rotation et périmètre deviennent des politiques.'),
('La clé actuelle suffit si on la rotate chaque mois', false, 2,
 'Rotation = hygiène d''un secret persistant : périmètre grossier et historique restent.'),
('Stocker la clé dans un coffre de fichiers monté sur le runner', false, 3,
 'Déplace la clé sans changer sa nature : même durée, même périmètre, présent sur le disque du runner.'),
('Limiter la clé à un seul projet cloud suffit à remplacer la fédération', false, 4,
 'Le périmètre reste statique et la preuve d''identité inexistante — c''est le secret qui prouve, pas l''identité.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'CI : identité du pipeline sans clé statique (OIDC)'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('SBOM : inventaire composants/versions par artefact — croiser avec le CVE donne le périmètre en minutes', true, 1,
 'La question « qui tourne quelque chose de touché ? » n''a de réponse que si l''inventaire existe déjà.'),
('Provenance attestée : qui a construit, depuis quel commit, quelles entrées', true, 2,
 'Elle distingue l''image fiable de la contrefaite et documente la chaîne de fabrication.'),
('Signature des images et vérification à l''admission : seules les images attestées tournent', true, 3,
 'La signature ferme la porte aux images non provenant de la chaîne de confiance.'),
('Un antivirus sur le registre suffit à répondre à la question du périmètre', false, 4,
 'Il dit ce qu''il reconnaît, pas CE QUI TOURNE chez vous — la question reste sans réponse.'),
('Il suffit de regarder les logs de build au moment de l''incident', false, 5,
 'Journal dispersé et partiellement expiré : la mémoire des builds n''existe pas sans provenance.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'CI : provenance, SBOM et signatures d''images'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Définition versionnée : plan, revue, puis application automatisée — la console devient l''exception tracée', true, 1,
 'L''infra redevient un artefact relecturable : ce qui n''est pas dans le dépôt n''existe pas (ou se détecte).'),
('Détection de drift : plan périodique comparé à l''état réel', true, 2,
 'Sans comparaison, l''IaC décrit un monde qui n''existe plus — le drift se cache dans l''écart.'),
('Approbation et environnements séparés sur les changements sensibles', true, 3,
 'L''application automatique ne doit pas devenir une application aveugle.'),
('Uniquement de la documentation : l''appliquer reste manuel pour la sûreté', false, 4,
 'Documenter sans appliquer ne change rien au régime actuel — le drift reste certain.'),
('Appliquer automatiquement tout changement, sans plan ni revue', false, 5,
 'Automatiser l''aveugle accélère l''incident : le plan EST la relecture.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'CI : infrastructure as code dans le pipeline'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Filtrer par chemin + tests impactés par graphe de dépendances, avec vérification périodique du filtre', true, 1,
 'Seuls les services touchés construisent — à condition que le graphe de dépendances soit vrai.'),
('Faire déclencher le large sur les changements transversaux (toolchain, contrats partagés)', true, 2,
 'Un filtre optimiste qui rate une dépendance rend la CI rapide et FAUSSE.'),
('Lancer tout le dépôt à chaque commit : c''est le plus sûr', false, 3,
 'Sûr et ingérable : les files débordent, les feedbacks attendent — la sélectivité devient vitale.'),
('Ne tester que le service modifié, quoi qu''il importe', false, 4,
 'Imports d''un contrat partagé : le service modifié casse ses voisins — invisibles au filtre.'),
('Découper le monorepo en dépôts pour supprimer le problème', false, 5,
 'Déplace les contrats sans les supprimer : les intégrations deviennent manuelles entre dépôts.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'CI : pipelines sélectifs en monorepo'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- -----------------------------------------------
-- Code Review : options + snippet (INSERT classique pour contrôler les '')
-- -----------------------------------------------

INSERT INTO challenges (
    title, type, selection_type, difficulty, context, question,
    code_snippet, code_language, explanation, estimated_time_seconds, active, points,
    created_at, updated_at
)
SELECT
    'CI Review : déploiement à chaque push', 'CODE_REVIEW', 'MULTIPLE_CHOICE', 'INTERMEDIATE',
    'Ce workflow accompagne le déploiement d''une application front ; il tourne depuis sa création et personne ne l''a relu depuis.',
    'Quels problèmes identifiez-vous dans ce workflow ?',
    'on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm install
      - run: npm test
      - run: npm run deploy
        env:
          DEPLOY_TOKEN: abc123secret',
    'yaml',
    'Trois défauts : le workflow se déclenche sur TOUS les pushes (toutes les branches) et déploie en prod — une simple branche d''essai publie, avec un secret de prod exposé à du code en cours de travail ; le DEPLOY_TOKEN est écrit en clair dans le fichier (et historisé, lisible par qui clone) ; npm install sans lockfile verrouillé produit des builds non reproductibles. L''ordre test→deploy est par contre correct — c''est le déclencheur, le secret et la reproductibilité qui posent problème.',
    170, true, 20, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM challenges c WHERE c.title = 'CI Review : déploiement à chaque push');

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Déclenchement sur TOUS les pushes avec déploiement prod : toute branche publie avec un secret de production', true, 1,
 'Le gate (merge, approval) est absent : le déploiement suit la poussée, pas la validation.'),
('Le DEPLOY_TOKEN est en clair dans le workflow : historisé, lisible par quiconque clone le dépôt', true, 2,
 'Un secret committé est un secret compromis — rotation obligatoire en plus du retrait.'),
('npm install sans lockfile verrouillé : deux builds peuvent tirer des versions différentes', true, 3,
 'Installation non figée = artefact non reproductible, exactement ce que la promotion refuse.'),
('Il manque un nom de workflow : les jobs ne s''exécuteraient pas sans lui', false, 4,
 'Le nom est cosmétique — le workflow tourne très bien, c''est le problème.'),
('npm test devrait passer APRÈS le déploiement pour vérifier en conditions réelles', false, 5,
 'Inversion dangereuse : publier avant de tester fait de chaque échec de test un incident de prod.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'CI Review : déploiement à chaque push'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- -----------------------------------------------
-- Raisonnements séquentiels (4) : options (explications par rang)
-- -----------------------------------------------

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Artefact unique construit, versionné et promu — la prod exécute ce que la préproduction a testé', true, 1,
 'Sans identité d''artefact, chaque environnement exécute autre chose.'),
('Gate de qualité explicite : ce qui doit bloquer est écrit et exigé avant fusion', true, 2,
 'Un gate implicite n''est rien : seuls les critères écrits protègent la suite.'),
('Premier pas : déploiement automatique MAIS déclenché (une personne lance la release)', true, 3,
 'La main garde le geste critique pendant que la chaîne se fiabilise.'),
('Filet de retour : version précédente disponible, retour testé AVANT d''en avoir besoin', true, 4,
 'Un rollback jamais répété n''existe pas : on l''éprouve avant l''incident.'),
('Surveillance du déploiement (métriques d''erreur, latence) conditionnant la suite, puis déclenchement automatique', true, 5,
 'Automatiser le geste précède automatiser la décision — chacun à son tour.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'CI : premier déploiement automatisé vers la prod'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Définir le signal : que détecte ce contrôle et quelle preuve produit-il ?', true, 1,
 'Un contrôle dont on ne peut pas nommer le signal ne mérite pas un étage.'),
('Choisir l''emplacement selon coût et pertinence : rapide bloquant en amont, lent en fond', true, 2,
 'Le coût du contrôle fixe sa place ; sa valeur fixe s''il bloque.'),
('Période informative : mesurer le ratio signal/bruit sur commits réels', true, 3,
 'On bascule en bloquant sur des preuves, pas sur l''enthousiasme du lancement.'),
('Bascule en bloquant avec budget de temps assumé (le coût du pipeline est un contrat)', true, 4,
 'Un contrôle qui viole le budget de temps est contourné — le budget se négocie et s''affiche.'),
('Voie d''exception tracée et revue périodique de la règle', true, 5,
 'Sans échappatoire documentée, l''équipe désactive en secret — la règle meurt sans trace.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'CI : faire entrer un nouveau contrôle dans le pipeline'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Geler les livraisons suivantes : stabiliser avant de chercher', true, 1,
 'Pendant qu''on cherche, la chaîne peut répéter l''incident sur les livraisons suivantes.'),
('Remonter à la version saine (l''incident se résout en durée d''abord)', true, 2,
 'Le service d''abord : le diagnostic se fait ensuite, avec le temps qu''il faut.'),
('Diagnostiquer la chaîne elle-même : quel gate aurait dû l''arrêter ?', true, 3,
 'La question n''est pas seulement « pourquoi c''est cassé » mais « pourquoi ça a pu passer ».'),
('Corriger et PROUVER le gate par un envoi contrôlé (simulation ou préproduction)', true, 4,
 'Un gate renforcé jamais exercé reste une hypothèse sur le papier.'),
('Reprendre par paliers avec surveillance, puis post-mortem documenté', true, 5,
 'La reprise progressive et la leçon partagée transforment l''incident en capacité.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'CI : rétablir la chaîne de livraison après incident'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Mesurer QUI consomme la CI et POURQUOI (coût par équipe, par service, par type de push)', true, 1,
 'Sans attribution du coût, toute règle de file reste perçue comme arbitraire.'),
('Découper les déclencheurs par chemin : ne payer que ce qui change réellement', true, 2,
 'La sélectivité réduit la file commune — le coût diminue pour tout le monde.'),
('Poser des limites de parallélisme et des quotas par projet/équipe', true, 3,
 'Sans quota, un seul service peut monopoliser le pool commun.'),
('Rendre chaque pipeline propriétaire : statut visible, mainteneurs nommés', true, 4,
 'Qui possède répare : le canal sans propriétaire devient le canal sans maintenance.'),
('Ritualiser la maintenance (revue périodique des jobs, suppression du mort)', true, 5,
 'La pipeline se dégrade comme le code : l''entretien planifié empêche le déclin silencieux.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'CI : structurer la pipeline d''un projet partagé'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- -----------------------------------------------
-- Liens catégories / skills / profiles (idempotents)
-- -----------------------------------------------

INSERT INTO challenge_categories (challenge_id, category_id)
SELECT c.id, cat.id
FROM challenges c, categories cat
WHERE cat.name = 'CI / CD'
  AND c.title LIKE 'CI %'
  AND NOT EXISTS (SELECT 1 FROM challenge_categories cc WHERE cc.challenge_id = c.id AND cc.category_id = cat.id);

INSERT INTO challenge_skills (challenge_id, skill_id)
SELECT c.id, s.id
FROM challenges c, skills s
WHERE c.title LIKE 'CI %'
  AND (
    (c.type IN ('SITUATIONAL_QCM', 'CODE_REVIEW') AND s.name = 'Code Quality')
    OR (c.type IN ('PROBLEM_SOLVING', 'SEQUENTIAL_REASONING') AND s.name = 'Problem Solving')
  )
  AND NOT EXISTS (SELECT 1 FROM challenge_skills cs WHERE cs.challenge_id = c.id AND cs.skill_id = s.id);

INSERT INTO challenge_profiles (challenge_id, profile_id)
SELECT c.id, p.id
FROM challenges c, profiles p
WHERE p.code = 'DEVELOPER'
  AND c.title LIKE 'CI %'
  AND NOT EXISTS (SELECT 1 FROM challenge_profiles cp WHERE cp.challenge_id = c.id AND cp.profile_id = p.id);

-- Vérification rapide attendue : 25 défis CI / CD (17/3/1/4 par type).
-- SELECT c.type, count(*) FROM challenges c WHERE c.title LIKE 'CI %' GROUP BY c.type;
