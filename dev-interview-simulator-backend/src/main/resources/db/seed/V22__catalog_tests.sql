-- ===============================================
-- Catalogue V1 — Profil Développeur — catégories manquantes
-- V22 : Tests & Qualité (32 défis — 22 QCM, 3 problem-solving,
--       3 code review, 4 raisonnement séquentiel)
-- Idempotent : WHERE NOT EXISTS sur challenges.title (jamais utilisé).
-- Même structure que l'import JSON futur : challenges + challenge_options
--   (content / is_correct / display_order / explanation) + liens
--   categories / skills / profiles.
-- Aucune redondance avec V6/V16-V21 : nouvelle catégorie, titres préfixés
--   « Tests : » / « Test Review : ».
-- ===============================================

INSERT INTO challenges (
    title, type, selection_type, difficulty, context, question,
    explanation, estimated_time_seconds, active, points,
    created_at, updated_at
)
SELECT * FROM (VALUES
('Tests : échec d''assertion ou erreur d''exécution', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'JUNIOR',
 'En CI, un rapport de tests mêle « expected: 42 but was: 41 » et des NullPointerException dans le code de test. L''équipe traite tout avec la même urgence.',
 'Quelle distinction faut-il faire ?',
 'L''échec d''assertion exprime un écart de comportement : le test a joué son rôle. L''erreur (exception non contrôlée) signale un défaut d''exécution — du code de test cassé ou un scénario non couvert — qu''il faut trier séparément, car elle peut masquer d''autres résultats.',
 120, true, 10, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Tests : un test casse au refactor sans changement de comportement', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'JUNIOR',
 'Un refactor interne (renommage, réorganisation des appels) fait échouer des tests alors que le comportement observable est inchangé.',
 'Quelle est la leçon principale ?',
 'Le test était couplé à l''implémentation (détails internes, ordre précis des appels) plutôt qu''au comportement visible : il teste le « comment » au lieu du « quoi ». Un bon test survit aux refactorings internes ; sinon, on l''assagit au comportement observable (résultat, état visible, contrat public).',
 130, true, 10, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Tests : cycle de vie JUnit 5 et isolation', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'JUNIOR',
 'Deux tests de la même classe passent séparément mais échouent ensemble, sans message clair. Le développeur soupçonne un bug de JUnit.',
 'Quelle affirmation sur le cycle de vie JUnit 5 est exacte ?',
 '@BeforeEach s''exécute avant chaque test (état frais par test) et l''ordre d''exécution des tests n''est PAS garanti : écrire un test qui dépend de l''ordre ou d''un état persistant entre les tests produit exactement ce comportement. L''isolation est la responsabilité du testeur, pas du moteur.',
 130, true, 10, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Tests : quand l''infrastructure réseau rend le résultat aléatoire', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'JUNIOR',
 'Un test unitaire appelle une API externe réelle ; il échoue en période de forte charge réseau, réussit ailleurs. L''équipe pense que le test est juste « un peu instable ».',
 'Quelle est la bonne réaction ?',
 'Un test qui dépend du réseau réel n''est pas unitaire : sa valeur est un produit du hasard. On externalise l''I/O (stub, fake, serveur contrôlé) pour rendre le test déterministe ; le vrai réseau appartient aux tests d''intégration dédiés, avec leur propre tolérance. La stabilité d''un test fait partie de sa correction.',
 140, true, 10, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Tests : la boucle TDD rouge-vert-refactor', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'JUNIOR',
 'Un développeur découvre le TDD et écrit d''abord tous les tests du module, puis toute la code, en espérant « faire du vert » à la fin.',
 'Quelle est la séquence correcte de la boucle ?',
 'Rouge : un test exprimant un comportement absent, qui échoue pour la bonne raison (comportement non implémenté). Vert : le plus petit changement qui le fait passer. Refactor : améliorer le design sous tests verts. L''ordre crée le feedback court : chaque pas est vérifié isolément.',
 130, true, 10, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Tests : verts en local, rouges en suite complète', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Chaque test passe quand on l''exécute seul ; en lancer toute la classe ou toute la suite provoque des échecs aléatoires selon l''ordre.',
 'Cause la plus probable et bon remède ?',
 'Un état partagé non réinitialisé (champ statique, fichier, cache, base) : les tests se contaminent mutuellement. Remède : rendre chaque test autonome — fixtures propres, nettoyage, isolation des ressources partagées — plutôt que d''ajouter des retries ou de sérialiser sans comprendre.',
 140, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Tests : structurer un test Given-When-Then', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Une équipe impose Given-When-Then ; un test contient 8 assertions sur 3 entités différentes, le Given d''un test réutilise le state modifié par le test précédent.',
 'Quelle affirmation décrit correctement ce style ?',
 'Given = mise en situation, When = une action, Then = vérifications d''une intention unique. Chaque test raconte une histoire isolée : assertions multiples sur le même résultat sont normales, mais un Given partagé et muté casse l''isolation (@BeforeEach crée l''état propre ; @BeforeAll le partagerait). GWT est une discipline de lisibilité, pas un framework.',
 140, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Tests : ce que la couverture mesure vraiment', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Un rapport affiche 95 % de lignes couvertes et l''équipe envisage de publier sur ce seul critère.',
 'Que mesure réellement la couverture ?',
 'Les lignes (ou branches) exécutées au moins une fois — rien de plus. Elle ne dit pas si un comportement est vérifié, si les cas limites sont explorés, ni si le test échouerait quand le code change. 100 % couvert ne signifie pas testé : un test peut traverser une ligne sans jamais vérifier son résultat.',
 140, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Tests : stub ou mock selon l''objectif', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Pour tester le calcul d''un prix, on hésite : renvoyer des réponses figées ou vérifier que le collaborateur est bien appelé.',
 'Quelle affirmation sur les doubles est exacte ?',
 'Un stub pilote le test avec des données prédéfinies (on teste le résultat produit à partir de ces entrées) ; un mock vérifie que des collaborations attendues ont eu lieu (appelé, avec quels arguments). Choisir mal produit des tests qui vérifient autre chose que ce qu''on croit : le résultat se teste avec des entrées, les interactions avec des mocks.',
 140, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Tests : le paradoxe des mocks partout', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Une suite où tout est mocké passe toujours — puis casse en production sur des comportements que personne n''a jamais exécutés. L''équipe constate que les tests résistent aux refactorings buggés.',
 'Quel mécanisme explique cela ?',
 'Un excès de mocks teste la forme (appels, ordre, fréquence) plus que le résultat : le test devient un moulage de l''implémentation. Il survit à un refactor faux (le même scénario mocké passe) et meurt à un refactor juste. Réserver les mocks aux collaborations dont on vérifie l''interaction, et laisser les fakes/vrais objets pour la logique.',
 150, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Tests : fixtures lisibles avec builders', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Un test construit un objet de 14 champs obligatoires, copié-collé dans 30 tests ; modifier le modèle casse la moitié de la suite, et on ne voit plus ce que le test cherche à prouver.',
 'Quelle pratique améliore durablement cette situation ?',
 'Un builder ou des fixtures nommés (avec valeurs par défaut raisonnables) concentrent la construction : le test n''exprime que les champs pertinents au scénario. On gagne en lisibilité (l''intention saute aux yeux) et en maintenance (un changement de modèle se répare en un endroit — pas par copier-coller global ni par fixture mutante partagée).',
 140, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Tests : isoler la base de données entre tests', 'SITUATIONAL_QCM', 'MULTIPLE_CHOICE', 'INTERMEDIATE',
 'Des tests d''intégration JPA partagent la même base ; des contraintes d''unicité et des comptes de lignes varient selon l''ordre d''exécution en CI.',
 'Quelles pratiques garantissent un état initial connu ?',
 'Réinitialiser par test : rollback de transaction (ou troncature) pour repartir d''un état connu à chaque cas. Distinguer aussi les données : un schéma exclusif aux tests, jamais partagé avec la préproduction — des purges aveugles ou un tri alphabétique des classes ne traitent pas la racine (le partage d''état).',
 150, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Tests : contrat d''API et compatibilité', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Une API retire un champ d''une réponse JSON sans changer les codes HTTP : les clients mobiles tombent en erreur plusieurs jours après la mise en ligne, la documentation avait pourtant été mise à jour.',
 'Quel filet de sécurité aurait détecté la rupture immédiatement ?',
 'Des tests de contrat : schéma de réponse, codes de statut, erreurs attendues, versioning. Ils vérifient que ce que le serveur expose reste compatible avec ce que les consommateurs attendent — le détecteur le plus tôt possible, avant la régression cliente. La doc seule ne vérifie rien ; un E2E navigateur complet est disproportionné pour ce contrôle.',
 150, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Tests : diagnostiquer un test flaky', 'SITUATIONAL_QCM', 'MULTIPLE_CHOICE', 'INTERMEDIATE',
 'Un test d''intégration échoue ~1 fois sur 20 en CI et passe toujours en local. On propose d''ajouter un retry automatique jusqu''à ce qu''il passe.',
 'Quelles actions sont correctes ?',
 'D''abord reproduire en boucle pour réduire l''espace des causes (course, état partagé, horloge, port, dépendance externe), puis traiter la racine — déterminisme, attente active, isolation. Le retry aveugle transforme une alerte en bruit de fond ; supprimer le test perd la couverture sans résoudre la cause.',
 150, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Tests : placer le test dans la bonne couche', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Une équipe veut tester une règle métier pure via un E2E navigateur complet, et mocking-er toute la base pour tester un repository « en unitaire ».',
 'Quelle stratégie de placement est saine ?',
 'La pyramide : des tests unitaires nombreux et immédiats pour la logique, quelques intégrations pour les assemblages réels (DB, HTTP, mapping), peu d''E2E sur les parcours critiques — le coût et la latence dictent la couche. Tester une règle en E2E la rend lente et bruitée ; mocker la base d''un repository ne teste plus le repository.',
 150, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Tests : tranches Spring et coût du contexte', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Une suite Spring de 400 tests met 8 minutes à démarrer : chaque test charge le contexte applicatif complet (Web, JPA, sécurité, messaging).',
 'Quelle technique réduit le temps sans perdre la fidélité ?',
 'Les tranches (@WebMvcTest, @DataJpaTest, @JsonTest) ne chargent que les beans de la couche testée ; Spring met aussi en cache les contextes identiques entre tests. Garder très peu de @SpringBootTest de bout en bout. L''idée que « tous les tests réutilisent le même contexte » est fausse : chaque configuration de tranche crée son propre contexte.',
 150, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Tests : tests à propriétés', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Un serializeur/deserializeur passe 60 cas unitaires écrits à la main, puis plante sur une entrée exotique trouvée en production.',
 'Qu''apporte le testing par propriétés dans ce cas ?',
 'On énonce un invariant (round-trip : serialize(deserialize(x)) = x) et le générateur explore des centaines de cas aux frontières, en minimisant la contre-preuve trouvée. Il complète les tests unitaires sans les remplacer : il explore l''espace au lieu des cas imaginés — et ne se limite ni aux erreurs de typage ni à une base de production.',
 150, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Tests : tester du code asynchrone sans sleep', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Un test lance un traitement asynchrone puis Thread.sleep(2000) avant l''assertion. Il échoue parfois sur machine lente ; la suite est devenue très lente.',
 'Quelle technique est correcte ?',
 'Attendre un état observable avec une limite explicite : awaitility, latch, CompletableFuture.get(timeout) — le test attend ce dont il a besoin, échoue vite et clairement au dépassement. Le sleep fixe est un pari (trop court = flaky, trop long = lent) ; une assertion sans attente sur de l''asynchrone est un hasard déguisé.',
 140, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Tests : choisir le bon test double', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'ADVANCED',
 'La règle métier de facturation dépend d''un port vers un client de paiement. On discute du double de test à employer pour vérifier les cas limites du calcul.',
 'Quelle affirmation est la plus juste ?',
 'Un fake — implémentation réelle simplifiée, en mémoire — exécute le vrai chemin du code avec des réponses déterministes et variées : on teste le comportement, pas les appels. Un stub à réponse unique ne couvre pas les cas limites, un spy observe sans remplacer, et « plus de mocks » n''équivaut pas à plus de robustesse.',
 150, true, 20, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Tests : mutation testing', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'ADVANCED',
 'L''équipe atteint 90 % de couverture mais cherche un indicateur de la force réelle des tests : l''outil introduit des fautes et observe la suite.',
 'Que mesure le mutation testing ?',
 'Il altère le code (mutants : négations, bordures, remplacements) et compte les mutants que la suite ne détecte pas — les survivants. C''est une mesure de la puissance des assertions, pas de l''étendue exécutée. 100 % exigeable est irréaliste en continu (coût) : on cible les zones à fort enjeu. Il complète la revue, il ne la remplace pas.',
 150, true, 20, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Tests : performance et charge', 'SITUATIONAL_QCM', 'MULTIPLE_CHOICE', 'ADVANCED',
 'Avant une montée en charge, l''équipe veut ajouter des tests de performance à la suite, à chaque commit, aux côtés des tests unitaires.',
 'Quelles affirmations sont correctes ?',
 'Les tests de performance mesurent latence, débit, tenue sous charge : ce sont des objectifs de performance, pas de justesse métier — et ils ne se substituent pas aux tests de régression pour valider une livraison. Leur rythme diffère : moins fréquents, sur des environnements dédiés. Un résultat sans seuil ni budget n''est pas exploitable : le chiffre seul ne dit rien.',
 160, true, 20, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Tests : dette de test', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'ADVANCED',
 'La suite met 25 minutes, certains tests sont commentés « désactivé temporairement » depuis six mois, d''autres sont désactivés à la discrétion des développeurs.',
 'Quel est le constat et la réponse saine ?',
 'C''est de la dette de test : elle ralentit le feedback, dégrade la confiance et enterrer les couvertures mortes. Symptômes : lenteur, commentaires, désactivations ad hoc, instabilité. Réponse : une politique explicite — réparer, cibler ou supprimer avec traçabilité — et l''intégrer au travail courant. La dette de test touche aussi le code de test ; la courbe de couverture ne l''efface pas.',
 150, true, 20, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Tests : fakes maison pour le mapper', 'PROBLEM_SOLVING', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Le mapper de facturation dépend d''un client HTTP externe ; les tests unitaires actuels sautent dès que le réseau bouge. L''équipe veut tester les règles de calcul en local, déterministe.',
 'Comment structurer cette substitution pour que le test vérifie le comportement métier ? (port, fake, cas de test, frontière à ne pas franchir)',
 'Nommer une interface (port) derrière laquelle se cache le client HTTP, avec l''implémentation réelle côté production. Implémenter un fake en mémoire, branchable en test, alimenté par des cas variés (succès, limites, erreurs, réponses partielles) — un fake exécute le vrai chemin, il ne simule pas les interactions. Conserver quelques tests d''intégration sur l''implémentation réelle (contrat HTTP). Réserver le mock aux collaborations dont on vérifie l''appel. Frontière : ne jamais mocker le cœur du calcul — c''est ce qu''on veut éprouver.',
 900, true, 30, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Tests : rendre testable un importateur legacy', 'PROBLEM_SOLVING', 'SINGLE_CHOICE', 'ADVANCED',
 'Un importateur CSV de 900 lignes lit un fichier, transforme, écrit en base et journalise — en dur, sans injection, impossible à tester unitairement. On doit le fiabiliser sans le réécrire entièrement.',
 'Décrivez la démarche par étapes : ce qui devient unitaire, ce qui reste d''intégration, et le rôle de la caractérisation avant toute modification.',
 'Étapes : (1) écrire les tests de caractérisation du comportement actuel sur un petit fichier réel — figer ce qui doit survivre ; (2) découper le flux en choke points : parse (fichier → lignes), règles métier (pures), mapping (ligne → entité), persistance (liste → base) ; (3) injecter les dépendances (lecteur, écrivain, horloge, journal) par paramètres ou constructeur pour les substituer ; (4) unitaires sur parse/règles/mapping avec échantillons (valides, malformés, limites) — sans fichier, sans base ; (5) garder un test d''intégration fin de bout sur un mini CSV + base de test. Critère de réussite : le cœur se teste sans I/O, et la couverture des cas limites explose sans ralentir la suite.',
 900, true, 30, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Tests : attribuer un test flaky à sa cause', 'PROBLEM_SOLVING', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Un test d''intégration échoue ~1 fois sur 20 en CI et passe en local. L''équipe hésite entre l''ignorer, le relancer ou le réécrire.',
 'Décrivez la démarche complète : identification, validation de l''attribution, puis décision sur l''avenir du test.',
 'Démarche : (1) capturer le contexte de l''échec (journaux, données, horodatage, environnement) ; (2) rejouer en boucle en local et en CI pour réduire l''espace des causes — course, état partagé, port, horloge, dépendance externe, ordre ; (3) isoler par bisect : désactiver une hypothèse à la fois jusqu''à reproduction stable ; (4) corriger la racine (détérminisme, attente active, isolation des fixtures) ; (5) valider par une longue série de passages verts ; (6) décider — corrigé, ou supprimé avec trace et remplacement. Jamais gardé tel quel avec des retries aveugles : un flaky silencieux coûte plus cher qu''un trou de couverture annoncé.',
 900, true, 30, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Tests : première fonctionnalité en TDD', 'SEQUENTIAL_REASONING', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Une équipe adopt le TDD pour une nouvelle règle métier simple ; il faut suivre la boucle sans la tronquer.',
 'Place ces étapes dans l''ordre de la boucle recommandée.',
 'La boucle : exprimer le comportement par un test qui échoue (rouge — preuve que le test teste quelque chose), écrire le minimum qui le fait passer (vert), refactorer sous protection, puis répéter par petits pas avec la suite qui relance à chaque incrément. Le feedback court est l''objet même de la méthode.',
 300, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Tests : encadrer un correctif de production', 'SEQUENTIAL_REASONING', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Un bug critique est confirmé en production sur une fonction de calcul. Il faut corriger sans introduire de régression.',
 'Place ces étapes dans l''ordre logique du protocole.',
 'Le protocole : reproduire et figer le scénario exact, qualifier l''impact et le périmètre, écrire le test de non-régression qui échoue sur l''ancien code (preuve que le test détecte bien ce bug), appliquer la correction minimale, puis relancer toute la suite et soumettre le couple test + correctif à revue. Corriger avant de reproduire, c''est deviner ; corriger sans test, c''est laisser la porte ouverte à la récidive.',
 300, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Tests : refactoriser sous couverture', 'SEQUENTIAL_REASONING', 'SINGLE_CHOICE', 'ADVANCED',
 'Un module legacy non testé doit être restructuré ; l''équipe refuse de le faire à l''aveugle mais n''a aucun filet.',
 'Place ces étapes dans l''ordre de la démarche sûre.',
 'La démarche : caractériser d''abord le comportement actuel (tests qui figent l''existant, même moche), découper le refactor en étapes indépendantes et réversibles, exécuter la suite fréquemment entre chaque pas, compléter les cas limites découverts en chemin, puis supprimer le code mort et relire sous verts. C''est le seul ordre qui garantit « même comportement, meilleure structure ».',
 360, true, 20, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Tests : campagne avant release', 'SEQUENTIAL_REASONING', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Une version majeure part dans deux jours : la campagne de recette doit maximiser la détection de régression avec un temps limité.',
 'Place ces étapes dans l''ordre de la stratégie recommandée.',
 'La stratégie : cartographier les changements et risques de la version, prioriser parcours critiques et composants touchés, exécuter la régression ciblée + les scénarios bout en bout des flux vitaux, vérifier performances/sécurité/compatibilité de données, puis arbitrer go/no-go avec la liste explicite des anomalies résiduelles. Tester « tout également » dilue le temps sur le bruit.',
 300, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
) AS v(title, type, selection_type, difficulty, context, question, explanation, estimated_time_seconds, active, points, created_at, updated_at)
WHERE NOT EXISTS (SELECT 1 FROM challenges c WHERE c.title = v.title);

-- -----------------------------------------------
-- Options des QCM (SINGLE : 1 correcte — MULTIPLE : 2-3 correctes)
-- -----------------------------------------------

-- Tests : échec d'assertion ou erreur d'exécution
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('L''échec d''assertion exprime un écart de comportement ; l''erreur signale un défaut d''exécution à trier séparément.', true, 1,
 'Deux signaux différents : le test qui vérifie vs le test (ou le code) qui plante.'),
('Erreurs et échecs sont interchangeables : même diagnostic, même remède.', false, 2,
 'Un écart est un constat ; une exception est un incident — traitements distincts.'),
('Il faut transformer les erreurs en assertions pour que le rapport reste lisible.', false, 3,
 'C''est masquer le symptôme : la cause de l''exception reste non traitée.'),
('Un test qui ne déclenche aucune exception est forcément vert.', false, 4,
 'Il peut échouer sur une assertion — ou pire, vérifier rien du tout.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Tests : échec d''assertion ou erreur d''exécution'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- Tests : un test casse au refactor sans changement de comportement
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Le test était couplé à l''implémentation : il faut le reposer sur le comportement observable.', true, 1,
 'Un test qui survit aux refactorings internes teste le contrat, pas la mécanique.'),
('Tout refactor légitime doit casser quelques tests : c''est le prix de la sécurité.', false, 2,
 'Un refactor ne change pas le comportement : les bons tests restent verts.'),
('Il faut figer l''implémentation actuelle dans le test pour empêcher toute réécriture.', false, 3,
 'Figer la forme interdit exactement l''amélioration que le test devrait protéger.'),
('Supprimer le test cassé puis le réécrire après le refactor.', false, 4,
 'Supprimer le filet avant la manœuvre retire toute protection à l''opération.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Tests : un test casse au refactor sans changement de comportement'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- Tests : cycle de vie JUnit 5 et isolation
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('@BeforeEach réinitialise avant chaque test et l''ordre d''exécution des tests n''est pas garanti.', true, 1,
 'L''isolation incombe au test : état frais, aucun ordre supposé.'),
('JUnit trie les tests par nom : l''ordre alphabétique suffit à isoler.', false, 2,
 'Aucun tri de ce genre n''est garanti — le support varie et n''est pas un contrat.'),
('Une seule instance de la classe sert à tous les tests, avec son état conservé.', false, 3,
 'JUnit 5 crée l''instance nécessaire par test ; l''état statique persiste — d''où le bug.'),
('@BeforeAll convient pour l''état courant car il s''exécute avant chaque test.', false, 4,
 '@BeforeAll tourne une fois par classe : partager l''état y est un piège classique.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Tests : cycle de vie JUnit 5 et isolation'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- Tests : quand l'infrastructure réseau rend le résultat aléatoire
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Externaliser l''I/O : stub ou serveur contrôlé en unitaire ; le vrai réseau appartient à la couche intégration.', true, 1,
 'Un test déterministe est un test fiable : le réseau réel introduit le hasard.'),
('Ajouter des appels d''attente avant le fetch pour laisser le réseau répondre.', false, 2,
 'Retarde le hasard sans le supprimer — flaky par décalage.'),
('Rejeter le test jusqu''à ce qu''il passe : la moyenne finit par être verte.', false, 3,
 'Du bruit auto-validé : on perd le signal exactement quand il compte.'),
('Ne rien changer : les environnements CI ont un réseau suffisamment stable.', false, 4,
 'Stable la plupart du temps ne l''est pas toujours — l''échec rare reste un échec.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Tests : quand l''infrastructure réseau rend le résultat aléatoire'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- Tests : la boucle TDD rouge-vert-refactor
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Test qui échoue pour le comportement absent (rouge) → plus petit code pour le vert → refactor sous vert.', true, 1,
 'Chaque phase a un rôle : prouver le test, satisfaire le besoin, améliorer le design — dans cet ordre.'),
('Rédiger toute la couverture du module avant d''écrire la moindre ligne de production.', false, 2,
 'Feedback différé : on valide la suite à la fin, pas le comportement à chaque pas.'),
('Obtenir le vert en ajustant ou retirant l''assertion qui bloque.', false, 3,
 'Tricher sur l''attente détruit la signification du test — faux vert.'),
('Le refactor ne commence qu''après la livraison de la recette complète.', false, 4,
 'Refactorer sous vert en continu est le troisième temps de chaque boucle.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Tests : la boucle TDD rouge-vert-refactor'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- Tests : verts en local, rouges en suite complète
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Un état partagé non réinitialisé (static, fichier, base) : rendre chaque test autonome.', true, 1,
 'La contamination mutuelle est la cause n°1 des échecs liés à l''ordre.'),
('JUnit exécute les tests en parallèle par défaut : il faut sérialiser l''exécution.', false, 2,
 'Le parallélisme n''est pas activé par défaut — sérialiser masquerait sans réparer.'),
('Ce sont les agents CI partagés : il suffit d''ajouter des retries.', false, 3,
 'Les retries transforment une alerte en bruit de fond sans traiter la cause.'),
('Le nom des méthodes détermine l''ordre : renommer les tests résout le problème.', false, 4,
 'Jouer au sort avec les noms ne crée jamais l''isolation — ça déplace la loterie.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Tests : verts en local, rouges en suite complète'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- Tests : structurer un test Given-When-Then
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Chaque test raconte une intention : Given (mise en situation), When (une action), Then (vérifications).', true, 1,
 'Structure de lisibilité : assertions multiples sur le même résultat restent normales.'),
('Given-When-Then impose un framework de tests dédié.', false, 2,
 'C''est une discipline de rédaction : on l''applique avec n''importe quel outil.'),
('Chaque test ne doit contenir qu''une seule assertion, sans exception.', false, 3,
 'Mythe répandu : plusieurs assertions sur une même intention clarifient le contrat.'),
('Le Given peut être placé dans @BeforeAll partagé entre tous les tests.', false, 4,
 'État partagé muté entre tests = dépendance à l''ordre, le défaut exact à éviter.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Tests : structurer un test Given-When-Then'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- Tests : ce que la couverture mesure vraiment
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('La couverture mesure les lignes exécutées, pas les comportements vérifiés ni les cas limites explorés.', true, 1,
 'Exécuter ≠ vérifier : un test peut traverser une ligne sans jamais juger son résultat.'),
('100 % de couverture garantit l''absence de bug résiduel.', false, 2,
 'Les bugs se logent dans les cas jamais imaginés, pas dans les lignes jamais exécutées.'),
('Exclure les fichiers difficiles est la parade standard aux revues de couverture.', false, 3,
 'Exclure pour atteindre le chiffre retourne la métrique en décor.'),
('La couverture doit servir de seul seuil de publication bloquant.', false, 4,
 'Seuil unique : publie du code traversé mais non éprouvé — faux signal de confiance.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Tests : ce que la couverture mesure vraiment'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- Tests : stub ou mock selon l'objectif
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Un stub fournit des réponses prédéfinies ; un mock vérifie des interactions attendues — deux objectifs.', true, 1,
 'Entrées prédéfinies pour le résultat, appels attendus pour la collaboration.'),
('Stub et mock sont strictement équivalents sous Mockito.', false, 2,
 'Les mêmes API les portent, mais les assertions n''expriment pas la même chose.'),
('Un stub remplace avantageusement une assertion sur le résultat.', false, 3,
 'Alimenter n''est pas vérifier : sans assertion, rien n''est jugé.'),
('Un mock prouve la justesse du calcul métier indépendamment du code.', false, 4,
 'Un mock vérifie des appels, pas la justesse d''un calcul — c''est le fake qui l''éprouve.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Tests : stub ou mock selon l''objectif'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- Tests : le paradoxe des mocks partout
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Trop de mocks testent la forme (appels, ordre) : le test survit à un refactor faux et meurt à un juste.', true, 1,
 'Le test devient le moulage de l''implémentation, plus du comportement.'),
('Chaque collaborateur doit être mocké pour garantir l''unitarité.', false, 2,
 'L''unitarité se joue sur le périmètre, pas sur le remplacement de chaque voisin.'),
('Les mocks sont toujours plus rapides que les fakes en mémoire.', false, 3,
 'La vitesse n''est pas le critère décisif : la fidélité du comportement l''est.'),
('Un test sans mock n''est pas un test unitaire.', false, 4,
 'Un test unitaire sur objets purs et fakes est parfaitement unitaire.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Tests : le paradoxe des mocks partout'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- Tests : fixtures lisibles avec builders
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Un builder/fixtures nommés concentrent la construction : le test exprime ce qui change au lieu de 14 paramètres.', true, 1,
 'Lisibilité de l''intention + réparation en un point au changement du modèle.'),
('Les builders servent principalement à augmenter la couverture de code.', false, 2,
 'Ils n''ajoutent aucune exécution : c''est un outil de lisibilité et maintenance.'),
('Copier-coller le même objet de test dans chaque classe évite la duplication.', false, 3,
 'C''est la duplication maximale : chaque évolution se répare N fois.'),
('Une fixture globale mutable enrichie test après test garantit la cohérence.', false, 4,
 'Fixture mutante partagée = état qui dépend de l''ordre — le bug de la suite.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Tests : fixtures lisibles avec builders'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- Tests : isoler la base de données entre tests
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Rollback de transaction par test (ou troncature) : la base repart d''un état connu à chaque cas.', true, 1,
 'L''état initial est garanti par construction, pas par l''ordre d''exécution.'),
('Un schéma de données exclusif aux tests d''intégration, jamais partagé avec la préproduction.', true, 2,
 'L''exclusivité supprime la contamination croisée entre environnements.'),
('Une purge en @AfterAll avec d''une seconde d''attente pour laisser la base se resynchroniser.', false, 3,
 'Délai arbitraire + point de purge unique : les tests restent couplés.'),
('Exécuter les tests dans l''ordre alphabétique des classes pour stabiliser les inserts.', false, 4,
 'Une dépendance à l''ordre ne devient jamais fiable — elle change au prochain ajout.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Tests : isoler la base de données entre tests'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- Tests : contrat d'API et compatibilité
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Des tests de contrat (schéma, codes de statut, erreurs) détectent la rupture avant les consommateurs.', true, 1,
 'Le contrat est vérifié à chaque build : la rupture est interceptée avant la prod.'),
('La doc OpenAPI suffit : les clients la relisent à chaque version.', false, 2,
 'La doc décrit l''intention ; seule une vérification automatique prouve la réalité.'),
('Il faut couvrir chaque endpoint par un scénario navigateur complet.', false, 3,
 'Disproportionné : le contrat se vérifie au niveau HTTP, sans navigateur.'),
('Un changement du corps de réponse sans code d''erreur n''est jamais cassant.', false, 4,
 'Retirer ou renommer un champ casse les clients — le statut 200 ne protège rien.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Tests : contrat d''API et compatibilité'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- Tests : diagnostiquer un test flaky
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Reproduire en boucle (dizaines de fois) en local et en CI pour isoler la cause exacte.', true, 1,
 'Réduire l''espace des hypothèses avant toute correction — mesurer, puis réparer.'),
('Traiter la racine (détérminisme, attente active, isolation) avant toute désactivation.', true, 2,
 'Seul le traitement de la cause rend le signal à nouveau fiable.'),
('Rejeter jusqu''à cinq fois en CI : la moyenne finit par être verte.', false, 3,
 'Auto-validation du bruit : l''échec réel disparaît du rapport.'),
('Supprimer le test et le remettre dans la vague de couverture suivante.', false, 4,
 'On perd la détection sans rien apprendre sur la cause.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Tests : diagnostiquer un test flaky'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- Tests : placer le test dans la bonne couche
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Unitaires nombreux pour la logique, intégrations pour les assemblages, E2E rares sur les parcours critiques : le coût dicte la couche.', true, 1,
 'Rapide et ciblé en bas, précieux et rare en haut — le coût gouverne la pyramide.'),
('Tout en E2E pour tester exactement comme l''utilisateur.', false, 2,
 'Lent, fragile, bruité : les régressions de logique y sont mal localisées.'),
('Tout en unitaire quitte à mocker la base et le réseau.', false, 3,
 'On teste alors des moulages : plus rien ne vérifie l''assemblage réel.'),
('La pyramide impose un ratio chiffré sous menace d''échec CI.', false, 4,
 'C''est une heuristique de coût/débit, pas un quota à faire respecter.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Tests : placer le test dans la bonne couche'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- Tests : tranches Spring et coût du contexte
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('@SpringBootTest charge tout le contexte ; les tranches (@WebMvcTest, @DataJpaTest) réduisent périmètre et démarrage.', true, 1,
 'Charger seulement les beans de la couche testée — et Spring met en cache les contextes identiques.'),
('Tous les tests réutilisent forcément le même contexte Spring, tranches comprises.', false, 2,
 'Chaque configuration de tranche crée son propre contexte, mis en cache séparément.'),
('Tout test de repository exige un conteneur Docker démarré.', false, 3,
 'Une base H2/mémoureuse ou un schéma dédié suffit souvent ; Docker reste ciblé.'),
('Les tranches désactivent les beans métier : inutilisables en CI.', false, 4,
 'Elles chargent juste ce qu''il faut pour la couche — parfaitement utilisables en CI.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Tests : tranches Spring et coût du contexte'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- Tests : tests à propriétés
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Le générateur explore des centaines de cas autour d''un invariant et minimise la contre-preuve trouvée.', true, 1,
 'On prouve une propriété sur un espace, au lieu des cas que l''on a su imaginer.'),
('Il remplace les tests unitaires existants dès son introduction.', false, 2,
 'Il les complète : les cas métier précis restent écrits à la main.'),
('Il exige une base de données de production réaliste.', false, 3,
 'Il génère des entrées en mémoire — aucune donnée réelle n''est requise.'),
('Il ne détecte que les erreurs de typage et de compilation.', false, 4,
 'Il éprouve la logique : c''est souvent là qu''il trouve ses contre-exemples.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Tests : tests à propriétés'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- Tests : tester du code asynchrone sans sleep
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Attendre un état observable avec une limite explicite (awaitility, latch, future.get) et échouer vite au dépassement.', true, 1,
 'Le test attend exactement ce dont il a besoin — rapide quand c''est prêt, clair quand ça ne l''est pas.'),
('Thread.sleep(2000) avant l''assertion pour laisser le temps de finir.', false, 2,
 'Pari sur la durée : trop court = flaky, trop long = suite lente — jamais fiable.'),
('Aucune attente : l''asynchrone se termine toujours avant la fin du test.', false, 3,
 'Course garantie avec l''exécution — le hasard décide du vert.'),
('Désactiver le test en CI et ne l''exécuter qu''en local.', false, 4,
 'On retire la détection exactement là où l''échec compte (enregistrement).')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Tests : tester du code asynchrone sans sleep'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- Tests : choisir le bon test double
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Un fake en mémoire exécute le vrai chemin avec des réponses déterministes et variées : on teste le comportement.', true, 1,
 'Le fake éprouve les règles sans réseau — c''est le choix pour la logique derrière un port.'),
('Un stub à réponse unique éprouve suffisamment les cas limites de la règle.', false, 2,
 'Une réponse figée ne couvre pas la diversité des entrées — les frontières restent dans le noir.'),
('Un spy remplace le composant réel en production pour plus de fiabilité.', false, 3,
 'Un spy observe un objet réel en test ; il n''est pas un substitut de production.'),
('Plus le test mocke, plus il est robuste.', false, 4,
 'Le mock protège les appels, pas la justesse — trop en mettre affaiblit le signal.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Tests : choisir le bon test double'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- Tests : mutation testing
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Il injecte des fautes et compte les tests qui ne les détectent pas (mutants survivants) : force, pas étendue.', true, 1,
 'Un mutant survivant signale une assertion trop faible ou un cas absent.'),
('Il compte simplement les lignes exécutées, comme la couverture classique.', false, 2,
 'C''est justement ce que la couverture fait — la mutation mesure la réaction des tests.'),
('Un taux de mutants à 100 % est exigible en continu sur un projet réel.', false, 3,
 'Coût de calcul prohibitif : on cible les zones critiques, on n''exige pas la perfection.'),
('Il remplace les revues de code sur la logique métier.', false, 4,
 'Il évalue la détection des fautes ; il ne juge ni la conception ni la lisibilité.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Tests : mutation testing'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- Tests : performance et charge
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Elles mesurent latence, débit et tenue sous charge : des objectifs de performance, pas la justesse métier.', true, 1,
 'On y cherche des seuils (p95, RPS), pas des égalités de résultats.'),
('Un résultat sans seuil ni budget de performance n''est pas un test exploitable.', true, 2,
 'Sans référence, un chiffre ne dit ni vert ni rouge — la mesure ne juge rien.'),
('Elles se substituent aux tests de régression pour valider une livraison.', false, 3,
 'Vitesse ≠ correction : une livraison rapide et fausse passe quand même.'),
('Elles se déclenchent à chaque commit, avec les tests unitaires, pour la même cadence.', false, 4,
 'Environnement dédié + coût élevé : cadence adaptée, pas celle du commit.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Tests : performance et charge'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- Tests : dette de test
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Symptômes : tests lents, commentés, désactivés, instables — nécessite une politique explicite de réparation/ciblage/suppression.', true, 1,
 'La dette de test dégrade le feedback et la confiance ; elle se traite comme de la dette technique.'),
('La dette disparaît dès que la courbe de couverture monte.', false, 2,
 'Couvrir davantage n''enlève ni la lenteur ni les tests morts.'),
('Un test obsolète doit être conservé « au cas où » jusqu''à la fin du projet.', false, 3,
 'Un test qui ne vérifie plus rien coûte et ment — on le répare ou on le supprime, tracé.'),
('Seul le code de production entre dans le périmètre de dette.', false, 4,
 'Le code de test est du code : il se dette aussi, et se paie à chaque exécution.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Tests : dette de test'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- -----------------------------------------------
-- Code Review : options + snippets (code via INSERT classique)
-- -----------------------------------------------

INSERT INTO challenges (
    title, type, selection_type, difficulty, context, question,
    code_snippet, code_language, explanation, estimated_time_seconds, active, points,
    created_at, updated_at
)
SELECT
    'Test Review : test sans assertion', 'CODE_REVIEW', 'MULTIPLE_CHOICE', 'JUNIOR',
    'Ce test accompagne le calcul d''un total. Il s''exécute en 0,01 s et apparaît en vert dans le rapport.',
    'Quels problèmes identifiez-vous dans ce code ?',
    '@Test
void calculatesTotal() {
    Order order = new Order();
    orderService.calculateTotal(order);
}',
    'java',
    'Le test ne peut pas échouer sur le comportement : aucune assertion, donc une couverture factice qui rassure sans vérifier. La correction : poser l''assertion sur le résultat attendu (ou un verify sur la collaboration si c''est bien l''appel qu''on veut prouver). Un affichage console ne juge rien, et « acceptable en TDD » est faux — même en TDD, le test vert exige son assertion.',
    150, true, 20, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM challenges c WHERE c.title = 'Test Review : test sans assertion');

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Aucune assertion : le test ne peut pas échouer sur le comportement — couverture factice.', true, 1,
 'Un test vert qui ne juge rien ne détecte rien : faux signal de confiance.'),
('Ajouter des assertions sur le résultat attendu (ou un verify sur la collaboration).', true, 2,
 'L''assertion est le contrat : sans elle, le test n''exprime aucune attente.'),
('Ajouter un affichage console du résultat pour lecture humaine.', false, 3,
 'Imprimer n''est pas vérifier : le rapport reste vert même en cas d''écart.'),
('C''est acceptable en TDD : le test peut rester sans assertion.', false, 4,
 'Même en TDD, le vert suppose une assertion — sinon rien n''est prouvé.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Test Review : test sans assertion'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenges (
    title, type, selection_type, difficulty, context, question,
    code_snippet, code_language, explanation, estimated_time_seconds, active, points,
    created_at, updated_at
)
SELECT
    'Test Review : exceptions avalées dans le test', 'CODE_REVIEW', 'MULTIPLE_CHOICE', 'INTERMEDIATE',
    'Ce test vérifie qu''un utilisateur s''enregistre. Il passe alors que le service lève systématiquement une exception en production.',
    'Quels problèmes identifiez-vous dans ce code ?',
    '@Test
void savesUser() {
    try {
        userRepository.save(user);
        assertTrue(user.getId() != null);
    } catch (Exception e) {
        // on ignore, le test passe
    }
}',
    'java',
    'Les assertions du try sont mortes : l''exception les contourne, le catch avale tout et transforme l''échec en vert — le test passe précisément quand le code casse. Il faut laisser l''exception propager (JUnit échouera avec la trace) ou échouer explicitement avec le contexte. Logger puis passer ne fait que consigner l''aveu.',
    160, true, 20, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM challenges c WHERE c.title = 'Test Review : exceptions avalées dans le test');

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Les assertions du catch sont mortes : l''exception les contourne et transforme l''échec en vert.', true, 1,
 'Le test réussit exactement quand le code échoue — inversion complète du signal.'),
('Le catch silencieux masque la cause : laisser propager ou échouer avec contexte.', true, 2,
 'JUnit attrape l''exception et affiche la trace : c''est le mécanisme voulu.'),
('C''est la façon propre de tester un service qui peut échouer.', false, 3,
 'Si l''échec est attendu, on l''asserte (assertThrows) — on ne l''avale pas.'),
('Il suffit de logger l''exception avant de terminer le test.', false, 4,
 'Un log ignoré ne fait pas échouer le test : le rapport reste vert à tort.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Test Review : exceptions avalées dans le test'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenges (
    title, type, selection_type, difficulty, context, question,
    code_snippet, code_language, explanation, estimated_time_seconds, active, points,
    created_at, updated_at
)
SELECT
    'Test Review : état partagé non réinitialisé', 'CODE_REVIEW', 'MULTIPLE_CHOICE', 'INTERMEDIATE',
    'Ce test de repository passe en local et échoue en suite en CI. Les deux méthodes vérifient le même compte de lignes.',
    'Quels problèmes identifiez-vous dans ce code ?',
    'class OrderRepositoryTest {
    static List<Order> orders = new ArrayList<>();

    @BeforeEach
    void setup() {
        orders.add(new Order("A-1"));
    }

    @Test void first()  { assertEquals(1, orders.size()); }
    @Test void second() { assertEquals(1, orders.size()); }
}',
    'java',
    'La liste statique s''accumule d''un test à l''autre : @BeforeEach n''a rien réinitialisé (il ne fait qu''ajouter), donc le test « second » dépend du passage de « first » — dépendance à l''ordre, donc échec selon l''ordre réel d''exécution. Corriger : réinitialiser une structure neuve par test (ou fixture dédiée) pour que chaque test soit autonome. Ni le fonctionnement normal de JUnit ni un sleep ne corrigent un état partagé.',
    170, true, 20, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM challenges c WHERE c.title = 'Test Review : état partagé non réinitialisé');

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('La liste statique s''accumule : @BeforeEach n''a rien réinitialisé — les tests dépendent de l''ordre d''exécution.', true, 1,
 'État partagé persistant = couplage invisible entre tests.'),
('Corriger en réinitialisant (structure neuve par test) pour rendre chaque test autonome.', true, 2,
 'L''isolation se rétablit en garantissant l''état initial, pas en espérant un ordre.'),
('JUnit conserve volontairement l''état entre tests : c''est le fonctionnement normal.', false, 3,
 'L''état statique persiste par la mémoire de classe, pas par un service de JUnit.'),
('Ajouter un sleep avant les assertions pour laisser la liste se stabiliser.', false, 4,
 'Rien ne s''asynchrone ici : le sleep ne ferait que ralentir un couplage durable.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Test Review : état partagé non réinitialisé'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- -----------------------------------------------
-- Raisonnement séquentiel : options (explications par rang)
-- -----------------------------------------------

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Écrire le test exprimant le comportement attendu et le faire échouer (rouge)', true, 1,
 'Prouver que le test vise un comportement absent : sans rouge, le test ne prouve rien.'),
('Écrire le minimum de code pour passer au vert', true, 2,
 'Le vert valide la résolution du besoin précis — pas un design anticipé.'),
('Refactorer sous tests verts (nommage, duplication, structure)', true, 3,
 'La structure s''améliore en sécurité, à chaque tour, jamais reportée.'),
('Répéter par petits incréments, un comportement à la fois', true, 4,
 'Petits pas = feedback court = erreur localisée immédiatement.'),
('Laisser la suite complète relancer à chaque pas pour garder le feedback rapide', true, 5,
 'Le signal continu de la boucle ne fonctionne que s''il est vérifié en continu.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Tests : première fonctionnalité en TDD'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Reproduire le bug et figer le scénario exact', true, 1,
 'Pas de correction fiable sans reproduction : on corrige sur un fait, pas sur une rumeur.'),
('Qualifier l''impact et le périmètre du correctif', true, 2,
 'Savoir ce qui touche (et ce qui ne doit pas bouger) guide la minimalité du correctif.'),
('Écrire le test de non-régression qui échoue sur l''ancien code', true, 3,
 'Le test qui échoue avant prouve qu''il détecte bien ce bug.'),
('Appliquer la correction minimale', true, 4,
 'Le plus petit changement qui rend le test vert réduit le risque de régression.'),
('Relancer toute la suite et soumettre le couple test + correctif à revue', true, 5,
 'Le filet complet protège le reste ; la relecture traite les angles morts du pair.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Tests : encadrer un correctif de production'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Écrire les tests de caractérisation du comportement actuel', true, 1,
 'Figurer l''existant — même moche — donne le périmètre de « même comportement ».'),
('Découper le refactor en étapes indépendantes et réversibles', true, 2,
 'Petits pas réversibles : chaque échec s''isole et se démonte.'),
('Exécuter la suite fréquemment entre chaque étape', true, 3,
 'La vérification rapprochée attribue toute régression à l''étape qui l''a produite.'),
('Compléter les cas limites découverts en chemin', true, 4,
 'Le refactor révèle des angles morts : la couverture grandit avec la structure.'),
('Supprimer le code mort et relire le résultat final sous tests verts', true, 5,
 'Dernier temps : propreté et relecture humaine quand tout est vérifié.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Tests : refactoriser sous couverture'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Cartographier les changements et les risques de la version', true, 1,
 'On ne peut pas tout tester : le périmètre du risque définit l''effort.'),
('Prioriser les parcours critiques et les composants touchés', true, 2,
 'Le temps de recette investi là où la casse coûte le plus.'),
('Exécuter les tests de régression ciblés et les scénarios bout en bout', true, 3,
 'Régression sur le modifié + confiance sur les flux vitaux.'),
('Vérifier performances, sécurité et compatibilité de données', true, 4,
 'Les ruptures non fonctionnelles ne ressortent pas des tests fonctionnels.'),
('Arbitrer go/no-go avec la liste des anomalies résiduelles', true, 5,
 'Décision consciente et documentée, pas un feu vert par défaut.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Tests : campagne avant release'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- -----------------------------------------------
-- Skills Testing / Code Review (créés ici : V6 n'en insère que 4) — idempotents
-- -----------------------------------------------

INSERT INTO skills (name, description)
SELECT 'Testing', 'Tests unitaires et d''intégration, mocking, TDD, couverture.'
WHERE NOT EXISTS (SELECT 1 FROM skills s WHERE s.name = 'Testing');

INSERT INTO skills (name, description)
SELECT 'Code Review', 'Lecture critique de code : défauts, risques et propositions.'
WHERE NOT EXISTS (SELECT 1 FROM skills s WHERE s.name = 'Code Review');

INSERT INTO challenge_categories (challenge_id, category_id)
SELECT c.id, cat.id
FROM challenges c, categories cat
WHERE cat.name = 'Testing'
  AND (c.title LIKE 'Tests %' OR c.title LIKE 'Test Review %')
  AND NOT EXISTS (SELECT 1 FROM challenge_categories cc WHERE cc.challenge_id = c.id AND cc.category_id = cat.id);

INSERT INTO challenge_skills (challenge_id, skill_id)
SELECT c.id, s.id
FROM challenges c, skills s
WHERE (c.title LIKE 'Tests %' OR c.title LIKE 'Test Review %')
  AND (
    (c.type IN ('SITUATIONAL_QCM', 'PROBLEM_SOLVING') AND s.name = 'Testing')
    OR (c.type = 'CODE_REVIEW' AND s.name = 'Code Review')
    OR (c.type = 'SEQUENTIAL_REASONING' AND s.name = 'Problem Solving')
  )
  AND NOT EXISTS (SELECT 1 FROM challenge_skills cs WHERE cs.challenge_id = c.id AND cs.skill_id = s.id);

INSERT INTO challenge_profiles (challenge_id, profile_id)
SELECT c.id, p.id
FROM challenges c, profiles p
WHERE p.code = 'DEVELOPER'
  AND (c.title LIKE 'Tests %' OR c.title LIKE 'Test Review %')
  AND NOT EXISTS (SELECT 1 FROM challenge_profiles cp WHERE cp.challenge_id = c.id AND cp.profile_id = p.id);

-- Vérification rapide attendue : 32 défis Tests & Qualité (22/3/3/4 par type).
-- SELECT c.type, count(*) FROM challenges c
-- WHERE c.title LIKE 'Tests %' OR c.title LIKE 'Test Review %' GROUP BY c.type;
