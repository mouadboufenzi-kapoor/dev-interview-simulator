-- =====================================================================
-- Catalogue V1 — Pilier SPRING BOOT (profil DEVELOPER)
-- 26 SITUATIONAL_QCM + 4 PROBLEM_SOLVING + 6 CODE_REVIEW + 5 SEQUENTIAL = 41
-- Exclus déjà couverts (anti-redondance) : « Bean non injecté au démarrage »
-- (V6), « REQUIRES_NEW » (V6), « Optimisation Endpoint Orders » (V7),
-- « Migrer un singleton statique vers un bean Spring » (V16).
-- =====================================================================

-- ---------------------------------------------------------------------
-- 26 QCM
-- ---------------------------------------------------------------------
INSERT INTO challenges (title, type, selection_type, difficulty, context, question, code_snippet, code_language, explanation, estimated_time_seconds, active, points, created_at, updated_at)
SELECT v.title, v.type, v.selection_type, v.difficulty, v.context, v.question,
       NULLIF(v.snippet, ''), NULLIF(v.lang, ''), v.explanation, v.time, TRUE, v.points,
       CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM (VALUES
-- JUNIOR (5)
('Spring : état partagé dans un bean singleton', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'JUNIOR',
 'Un @Controller StockController contient private int counter = 0; pour « déboguer ». Les valeurs semblent bizarres en prod.',
 'Pourquoi ces compteurs sont-ils incohérents alors que le code fonctionne en local ?',
 '',
 '',
 'Par défaut, un bean Spring est un singleton partagé par TOUTES les requêtes : le champ instance vit dans une seule copie pour tout le serveur. Un état par requête doit vivre dans la requête (param/local) ou être thread-safe — jamais dans un bean singleton.',
 120, 15),
('Spring : NPE après new sur une classe annotée', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'JUNIOR',
 'Dans un utilitaire, tu écris OrderService svc = new OrderService(); et svc.repository est null à l''exécution malgré @Autowired dessus.',
 'Quelle est la cause et la bonne pratique ?',
 '',
 '',
 'Spring n''injecte que les instances du conteneur : un new() manuel reste hors de sa portée. Il faut obtenir le bean (injection, @Component, factory) ; et préférer l''injection constructeur, qui rend la dépendance obligatoire et le code testable.',
 90, 10),
('Spring : 404 sur un endpoint qui existe', 'SITUATIONAL_QCM', 'MULTIPLE_CHOICE', 'JUNIOR',
 'Une méthode @GetMapping("/orders/{id}") renvoie systématiquement 404 alors que le code est bien déployé.',
 'Quelles causes sont plausibles ?',
 '',
 '',
 'Classe sans @RestController (ou sans @Component/@Service) : la méthode n''est jamais enregistrée ; mapping erroné (chemin relatif ou doublon) ; enfin, une 404 peut aussi venir du chemin réel appelé côté client (proxy, /api omis). Le « existe dans le code » ne prouve pas l''enregistrement dans le contexte.',
 120, 15),
('Spring : quel stéréotype pour quelle intention', 'SITUATIONAL_QCM', 'MULTIPLE_CHOICE', 'JUNIOR',
 'Le code mélange @Component partout : controllers, services, repositories.',
 'Quelles affirmations sont exactes ?',
 '',
 '',
 'Les trois sont des @Component : @Service et @Repository expriment l''INTENTION (lisibilité, traitement). @Repository déclenche en plus la traduction des exceptions persistences en exceptions Spring compréhensibles. Réserver @Component aux types purement techniques (mappers, helpers).',
 120, 15),
('Spring : 400 au lieu de 500 sur entrée invalide', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'JUNIOR',
 'Un endpoint reçoit un JSON sans champ obligatoire. Le code plante et le client reçoit une 500 « erreur interne ».',
 'Quel manque Spring explique la 500 et quelle correction attend-on ?',
 '',
 '',
 'La validation n''est pas déclenchée : il faut @Valid (jakarta) sur le paramètre @RequestBody ET des contraintes sur le DTO. Sans elles, la désérialisation/le traitement échoue au runtime. Le GlobalExceptionHandler (ou Bean Validation) transforme alors en 400 avec le détail des champs.',
 120, 15),
-- INTERMEDIATE (17)
('Spring : appel interne et @Transactional', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Un service appelle this.saveOrder() (méthode de la même classe annotée @Transactional). La transaction ne se crée jamais.',
 'Quelle est la cause mécanique ?',
 '',
 '',
 '@Transactional passe par un proxy Spring : seul un appel traversant le PROXY (depuis un autre bean) ouvre la transaction. L''appel this.methode() court-circuite le proxy. Extraire la logique dans un autre bean, ou via self-injection/AopContext.',
 180, 20),
('Spring : exception métier attrapée = rollback manqué', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Dans une méthode @Transactional, un try/catch renvoie un message d''erreur au lieu de propager : la base est pourtant mise à jour partiellement.',
 'Pourquoi la transaction est-elle commitée malgré l''échec métier ?',
 '',
 '',
 'Spring rollback sur les RuntimeException non attrapées. L''exception attrapée dans la méthode fait que le proxy voit un retour normal → commit. Soit laisser remonter, soit marquer rollback (TransactionAspectSupport.currentTransactionStatus().setRollbackOnly()).',
 180, 20),
('Spring : LazyInitializationException', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'L''API serialize une entité et plante : failed to lazily initialize a collection of role... Hors d''une transaction, ça marche.',
 'Quel mécanisme et quelles solutions ?',
 '',
 '',
 'Les associations lazy ne se chargent qu''en transaction. Après fermeture de la session, l''accès est interdit. Solutions : charger dans la transaction (JOIN FETCH/@EntityGraph), ou sérialiser un DTO construit pendant la session (pas l''entité JPA).',
 180, 20),
('Spring : transaction longue qui grève le pool', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Un endpoint @Transactional readOnly charge des données puis lance un appel HTTP et un calcul de 4 secondes avant de répondre. Les connexions tombe en manque.',
 'Quel problème structurel est en cause et comment le corriger ?',
 '',
 '',
 'La transaction (et sa connexion Hikari) reste ouverte pendant tout le traitement non-DB : chaque requête lente occupe un slot du pool → épuisement. Borner la transaction à la seule donnée (méthode dédiée), sortir l''appel HTTP et le calcul du périmètre transactionnel.',
 180, 20),
('Spring : @Async par défaut', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Tu ajoutes @Async à une méthode : ça marche, mais en charge le serveur crée des threads sans fin et ralentit.',
 'Quel comportement par défaut explique cela ?',
 '',
 '',
 'Sans executor configuré, Spring utilise SimpleAsyncTaskExecutor : un NOUVEAU thread par appel, jamais réutilisé. Il faut un ThreadPoolTaskExecutor borné (et @EnableAsync) avec une politique de rejet explicite.',
 120, 15),
('Spring : exceptions perdues en @Async', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Une méthode @Async void renvoie une erreur distante : personne ne la voit, ni log ni alerte.',
 'Pourquoi l''erreur disparaît-elle et comment la traiter ?',
 '',
 '',
 'Une méthode void ne peut pas remonter d''exception au caller (il n''y en a pas), et Spring ne journalise pas par défaut. Implémenter AsyncUncaughtExceptionHandler, ou retourner CompletableFuture pour traiter l''échec côté chaîne.',
 120, 15),
('Spring : fixedRate vs fixedDelay', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Un import planifié met 10 minutes et tourne toutes les 5 minutes avec fixedRate : deux imports se chevauchent et saturent la base.',
 'Quel réglage correspond à cette intention et quel garde-fou ajouter ?',
 '',
 '',
 'fixedDelay attend la FIN de l''exécution avant de décompter : jamais de chevauchement. En complément (@ConditionalOnProperty ou verrou distribué si multi-instances), car @Scheduled sur plusieurs nœuds exécute N fois.',
 120, 15),
('Spring : la variable d''environnement est ignorée', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Tu exportes DB_URL=... mais le YAML continue d''utiliser sa valeur. Tu attends que l''env l''écrase.',
 'Quelle est la règle de priorité réelle et la vérification à faire ?',
 '',
 '',
 'En Spring Boot, les variables d''environnement priment sur application.yml (ordre : env > args > yml). Si ça « ne marche pas », c''est souvent le nom (SPRING_DATASOURCE_URL attendu, pas DB_URL) ou la coquille dans le placeholder. Vérifier via /actuator/env.',
 120, 15),
('Spring : profils d''environnement', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Le même YAML contient des if improbables et du code teste « si prod ». L''équipe veut un comportement dev/prod distinct sans recompiler.',
 'Le mécanisme Spring adapté ?',
 '',
 '',
 'Les profils : application-{profile}.yml activés par SPRING_PROFILES_ACTIVE, couplés à @Profile sur les beans variant (DataSource, log config, mock). Une seule image, des comportements activés à l''exécution — jamais de conditionnel dans le code métier.',
 120, 15),
('Spring : cache partagé sur la mauvaise clé', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 '@Cacheable sur findById(String cle, boolean admin) renvoie parfois les données d''un autre contexte d''appel.',
 'Pourquoi et quelle correction ?',
 '',
 '',
 'La clé par défaut regroupe TOUS les paramètres (simpleEqualsHashCode de l''objet avec null pour admin) : deux appels avec la même clé de cache mais des droits différents se confondent. Spécifier key = "#cle" (et keyGenerator si besoin) — ou ne pas mettre une méthode à paramètres de contexte en cache.',
 120, 15),
('Spring : échec concurrent sur version optimiste', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Sous charge, deux éditions simultanées d''une entité @Version lèvent ObjectOptimisticLockingFailureException en 409.',
 'Quelle est la sémantique correcte de cette erreur et la réponse serveur attendue ?',
 '',
 '',
 'La version a changé depuis le chargement : conflit d''édition, pas bug interne. Réponse 409 + rechargement/dernière version vers le client ; retry borné possible si l''opération est idempotente. Ajouter un index si le verrouillage porte sur un verrou DB.',
 180, 20),
('Spring : @ConfigurationProperties vs @Value', 'SITUATIONAL_QCM', 'MULTIPLE_CHOICE', 'INTERMEDIATE',
 'Un service affiche 27 champs @Value + @RefreshScope sur 4 classes de configuration.',
 'Quels avantages apporte @ConfigurationProperties ?',
 '',
 '',
 'Typage (pas de String partout), regroupement et préfixe unique, validation (@Validated, @NotNull) déclenchée au démarrage, édition/scaffold IDE auto-générée. @Value reste pertinent pour une valeur isolée ; pour un bloc cohérent, l''objet typé gagne en sûreté.',
 120, 15),
('Spring : décorateur de réponse en 500', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Un handler lève une ApiException("Commande introuvable") mais le client reçoit 500 avec une trace technique.',
 'Quel manque Spring MVC transforme l''intention en erreur serveur ?',
 '',
 '',
 'Aucun résolveur pour cette exception : par défaut, tout devient 500. Il faut un @ExceptionHandler (controller advice) ou @ResponseStatus qui mappe explicitement ApiException → 404/409 avec le message métier. Sans mapping, la sémantique se perd.',
 120, 15),
('Spring : deux hachages différents pour le même mot de passe', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Le support constate que deux comptes ayant pourtant le MÊME mot de passe stockent des password_hash totalement différents. Il conclut à un hash « cassé ».',
 'Que se passe-t-il réellement et comment vérifier un mot de passe ?',
 '',
 '',
 'BCrypt incorpore un sel aléatoire à chaque hash : deux encodages du même mot de passe donnent toujours des résultats différents (et c''est voulu — cela neutralise les tables de rainbow). La vérification se fait par passwordEncoder.matches(clair, hash), jamais par comparaison de hash.',
 120, 15),
('Spring : l''entité JPA renvoyée directement en JSON', 'SITUATIONAL_QCM', 'MULTIPLE_CHOICE', 'INTERMEDIATE',
 'Un endpoint retourne l''entité Order telle quelle : la réponse expose des champs internes et plante parfois hors transaction.',
 'Quels problèmes ce raccourci pose-t-il ?',
 '',
 '',
 'Trois défauts : exposition de TOUS les champs (fuite potentielle de données non destinées au contrat), chargement des associations lazy pendant la sérialisation (erreur hors transaction), et couplage du contrat API au schéma de la base (toute colonne devient publique). Le DTO à la frontière règle les trois.',
 120, 15),
('Spring : dépendance circulaire au démarrage', 'SITUATIONAL_QCM', 'MULTIPLE_CHOICE', 'INTERMEDIATE',
 'Le démarrage échoue avec BeanCurrentlyInCreationException après l''ajout d''une dépendance entre deux services.',
 'Quelles corrections sont légitimes ?',
 '',
 '',
 'Le cycle signale un couplage de conception : extraire la responsabilité commune dans un tiers, ou restructurer via injection constructeur (qui rend le cycle impossible à ignorer). @Lazy reste un étai ponctuel ; dupliquer en prototype ne fait que changer d''échelle du problème.',
 120, 15),
('Spring : 401 généralisé après ajout de Spring Security', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Tu ajoutes spring-boot-starter-security : sans écrire une ligne de config, toutes les API renvoient 401 et un user est affiché dans les logs au démarrage.',
 'Pourquoi ce comportement et quelle est la correction ?',
 '',
 '',
 'La configuration par défaut sécurise TOUTES les routes (et génère un utilisateur éphémère). Il faut déclarer son propre SecurityFilterChain : règles par chemin (permitAll/hasRole), état stateless si JWT, CORS — c''est exactement le rôle du SecurityConfig de l''application.',
 180, 20),
-- ADVANCED (4)
('Spring : connexions Hikari jamais rendues', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'ADVANCED',
 'Le log affiche « Connection leak detection triggered » toutes les minutes et le pool se vide, alors que les requêtes sont pourtant courtes.',
 'Quelle est la cause typique et le bon remède ?',
 '',
 '',
 'Une Connection/Statement obtenue manuellement n''est jamais fermée (DAO sans try-with-resources, exception avant close, ou ressource stockée dans un champ de bean). Activer leakDetectionThreshold pour obtenir la stacktrace fautive, corriger la fermeture — et ne jamais augmenter le pool pour « absorber » une fuite.',
 180, 20),
('Spring : migration jakarta.* après saut de version', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'ADVANCED',
 'Après passage de Spring Boot 2 à 3, le démarrage casse : ClassNotFoundException javax.servlet.Filter, dépendances obscures.',
 'Quelle est la racine de la rupture et la méthode de migration ?',
 '',
 '',
 'Boot 3 = Spring Framework 6 = bascule javax.* → jakarta.* (Servlet, Validation, Persistence) + JDK 17 min. Il faut migrer imports et dépendances tierces encore en javax, vérifier les starters, et ne pas mixer les deux espaces de noms — c''est un breaking change, pas un simple bump de version.',
 180, 20),
('Spring : prototype injecté dans un singleton', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'ADVANCED',
 'Un bean @Scope("prototype") est injecté dans un singleton : tu attends une instance par usage, tu n''en reçois qu''une seule.',
 'Pourquoi et quelles solutions ?',
 '',
 '',
 'L''injection résout la dépendance UNE fois, à la création du singleton : la référence figée est partagée. Obtenir une instance par usage : ObjectProvider<T>.getObject(), @Scope(proxyMode) sur l''interface, ou fabrique (Provider/FactoryBean).',
 180, 20),
('Spring : fermeture manquante au shutdown', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'ADVANCED',
 'Au redémarrage, des tâches planifiées meurent en plein traitement et un ThreadPool maison n''attend jamais la fin du last run.',
 'Quel mécanisme de cycle de vie Spring faut-il activer et pourquoi ?',
 '',
 '',
 'Arrêt gracieux : destroy-method / @PreDestroy qui appelle shutdown() puis awaitTermination() du pool, avec un délai de shutdown supérieur au temps de traitement max. Sans lui, les threads personnalisés ne font pas partie du cycle de vie du contexte et sont tués brutalement.',
 180, 20)
) AS v(title, type, selection_type, difficulty, context, question, snippet, lang, explanation, time, points)
WHERE NOT EXISTS (SELECT 1 FROM challenges c WHERE c.title = v.title);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.ord, v.expl
FROM (VALUES
('Spring : état partagé dans un bean singleton', 'Un bean Spring est singleton : le champ vit dans une copie partagée par toutes les requêtes', TRUE, 1, 'Le mode par défaut singleton implique que TOUT champ instance est du state serveur.'),
('Spring : état partagé dans un bean singleton', 'Le compteur devrait être static pour être correctement partagé', FALSE, 2, 'static aggraverait : même partage, toujours pas par requête.'),
('Spring : état partagé dans un bean singleton', 'Il faut ajouter @Autowired sur le compteur', FALSE, 3, 'L''injection ne s''applique pas aux valeurs primitives d''état.'),
('Spring : état partagé dans un bean singleton', 'Le problème vient du profil dev de Spring Boot', FALSE, 4, 'Aucun lien : c''est la sémantique singleton, identique partout.'),
('Spring : NPE après new sur une classe annotée', 'Spring n''injecte que les beans du conteneur, pas les new() manuels', TRUE, 1, 'L''injection est le travail du conteneur : hors conteneur, rien n''est rempli.'),
('Spring : NPE après new sur une classe annotée', 'Préférer l''injection constructeur : dépendances obligatoires + testables', TRUE, 2, 'Échec rapide au démarrage si manquant, plus aucune instance partiellement construite.'),
('Spring : NPE après new sur une classe annotée', '@Autowired sur un champ garantit la nullité détectée à la compilation', FALSE, 3, 'L''injection champ reste invisible au compilateur — justement un défaut de ce style.'),
('Spring : NPE après new sur une classe annotée', 'Il faut annoter la méthode appelée avec @Transactional', FALSE, 4, 'Hors sujet : le problème est l''instanciation, pas la transaction.'),
('Spring : 404 sur un endpoint qui existe', 'Classe sans @RestController : la méthode n''est jamais enregistrée', TRUE, 1, 'Sans stéréotype, Spring ignore totalement la classe.'),
('Spring : 404 sur un endpoint qui existe', 'Mapping incohérent côté client (chemin appelé ≠ chemin déclaré)', TRUE, 2, 'La 404 arrive souvent du consumer : /api omis, version, proxy.'),
('Spring : 404 sur un endpoint qui existe', 'Le serveur a besoin d''un @GetMapping pour chaque paramètre', FALSE, 3, 'Invention : un seul mapping couvre la méthode.'),
('Spring : 404 sur un endpoint qui existe', 'Spring interdit les identifiants dans l''URL', FALSE, 4, 'Les variables de chemin sont un mécanisme natif.'),
('Spring : quel stéréotype pour quelle intention', '@Repository ajoute la traduction des exceptions de persistance', TRUE, 1, 'Seul bénéfice technique réel au-delà de l''expressivité.'),
('Spring : quel stéréotype pour quelle intention', '@Service et @Component fonctionnent à l''identique côté container', TRUE, 2, 'Ce sont des alias sémantiques de @Component — la différence est l''intention.'),
('Spring : quel stéréotype pour quelle intention', '@Repository est obligatoire pour que Spring Data crée son proxy', FALSE, 3, 'Les interfaces @Repository de Spring Data sont elles-mêmes annotées : la règle ne s''exprime pas dans vos classes.'),
('Spring : quel stéréotype pour quelle intention', 'Les trois créent des scopes différents (request, singleton, prototype)', FALSE, 4, 'Le scope est indépendant du stéréotype.'),
('Spring : 400 au lieu de 500 sur entrée invalide', 'Ajouter @Valid sur le DTO + contraintes (jakarta.validation)', TRUE, 1, 'Déclenche Bean Validation avant le traitement — 400 avec fieldErrors.'),
('Spring : 400 au lieu de 500 sur entrée invalide', 'Définir un handler de l''exception de validation pour la traduire en 400', TRUE, 2, 'La sécurité du statut : jamais de 500 pour une entrée utilisateur.'),
('Spring : 400 au lieu de 500 sur entrée invalide', 'Passer le DTO en String puis valider manuellement partout', FALSE, 3, 'Contre-productif : Bean Validation existe pour cela.'),
('Spring : 400 au lieu de 500 sur entrée invalide', 'Désérialiser avec ObjectMapper en mode LENIENT', FALSE, 4, 'Tolérer le JSON invalide ne valide rien du métier.'),
('Spring : appel interne et @Transactional', 'La transaction passe par un proxy : l''appel this.xxx() l''évite', TRUE, 1, 'Le proxy Spring ne peut pas intercepter un appel intra-bean.'),
('Spring : appel interne et @Transactional', 'Extraire la méthode dans un autre bean pour qu''elle soit appelée via le proxy', TRUE, 2, 'Solution propre : la frontière transactionnelle suit la frontière de responsabilité.'),
('Spring : appel interne et @Transactional', 'Annoter la classe entière en @Transactional règle le cas interne', FALSE, 3, 'Même problème : la cible reste l''appel interne sans proxy.'),
('Spring : appel interne et @Transactional', 'Il faut ajouter @EnableTransactionManagement manuellement', FALSE, 4, 'Déjà actif par défaut avec Spring Boot — la cause est ailleurs.'),
('Spring : exception métier attrapée = rollback manqué', 'L''exception attrapée fait que le proxy voit un retour normal → commit', TRUE, 1, 'La règle : rollback sur RuntimeException non interceptée par le proxy.'),
('Spring : exception métier attrapée = rollback manqué', 'setRollbackOnly() marque la transaction pour annulation même en interne', TRUE, 2, 'Marqueur explicite quand on doit gérer l''erreur sans la remonter.'),
('Spring : exception métier attrapée = rollback manqué', 'Spring rollback sur TOUTES les exceptions, y compris checked', FALSE, 3, 'Faux : les checked ne déclenchent le rollback que via rollbackFor.'),
('Spring : exception métier attrapée = rollback manqué', 'Il faut écrire le rollback manuellement avec SQL ROLLBACK', FALSE, 4, 'Le proxy gère la connection : du SQL brut casserait la gestion.'),
('Spring : LazyInitializationException', 'Accès à une association lazy après fermeture de la session JPA', TRUE, 1, 'Hors transaction, Hibernate refuse de charger — comportement voulu.'),
('Spring : LazyInitializationException', 'Charger dans la transaction (JOIN FETCH / @EntityGraph) et sérialiser un DTO', TRUE, 2, 'La règle d''or : DTO construit en session, jamais l''entité exposée brute.'),
('Spring : LazyInitializationException', 'Passer toute la config en EAGER global', FALSE, 3, 'Ralentit tout le chemin (N+1 inversé, chargements inutiles) — anti-pattern.'),
('Spring : LazyInitializationException', 'Ajouter un try/catch autour de la sérialisation', FALSE, 4, 'Ça masque : la donnée reste non chargée.'),
('Spring : transaction longue qui grève le pool', 'L''appel HTTP et le calcul s''exécutent À L''INTÉRIEUR de la transaction', TRUE, 1, 'Connexion Hikari monopolisée pendant un traitement non-DB.'),
('Spring : transaction longue qui grève le pool', 'Borner la transaction à la seule opération DB (méthode dédiée)', TRUE, 2, 'La connexion est libérée dès la fin du SQL — le reste tourne sans elle.'),
('Spring : transaction longue qui grève le pool', 'Augmenter indéfiniment le pool Hikari', FALSE, 3, 'Déplace le problème : les connexions DB finissent par manquer aussi.'),
('Spring : transaction longue qui grève le pool', 'Mettre la méthode en @Async', FALSE, 4, 'Les threads restent bloqués avec leurs connexions — ça empire.'),
('Spring : @Async par défaut', 'SimpleAsyncTaskExecutor crée un thread neuf à chaque appel', TRUE, 1, 'Aucune réutilisation : en charge, création massive de threads.'),
('Spring : @Async par défaut', 'Configurer un ThreadPoolTaskExecutor borné + @EnableAsync', TRUE, 2, 'Taille, file et politique de rejet deviennent des décisions explicites.'),
('Spring : @Async par défaut', 'Spring met en file les appels dans le thread du caller', FALSE, 3, 'L''inverse : la méthode est détournée, jamais exécutée en caller.'),
('Spring : @Async par défaut', '@Async fonctionne sans aucune configuration car il est activé par défaut', FALSE, 4, 'Require @EnableAsync — sinon l''annotation est ignorée silencieusement.'),
('Spring : exceptions perdues en @Async', 'Une méthode void ne peut pas transmettre d''exception au caller', TRUE, 1, 'Personne n''écoute : ni caller, ni log par défaut.'),
('Spring : exceptions perdues en @Async', 'AsyncUncaughtExceptionHandler centralise ces échecs', TRUE, 2, 'Point d''étape unique : log + alerte métier.'),
('Spring : exceptions perdues en @Async', 'Retourner CompletableFuture pour traiter l''échec dans la chaîne', TRUE, 3, 'Alternative moderne : exceptionally/handle côté appelant.'),
('Spring : exceptions perdues en @Async', 'Spring relance automatiquement la tâche en cas d''erreur', FALSE, 4, 'Aucun retry automatique — la t''échec reste silencieux.'),
('Spring : fixedRate vs fixedDelay', 'fixedDelay attend la fin du run avant de décompter : pas de chevauchement', TRUE, 1, 'Sémantique « après exécution » = filet anti-chevauchement.'),
('Spring : fixedRate vs fixedDelay', 'Sur multi-instances, prévoir un verrou distribué / activation conditionnelle', TRUE, 2, '@Scheduled tourne sur CHAQUE nœud : N exécutions simultanées.'),
('Spring : fixedRate vs fixedDelay', 'fixedRate garantit l''exécution exacte toutes les 5 minutes', FALSE, 3, 'Il programme des départs, sans garantie de durée ni d''absence de recouvrement.'),
('Spring : fixedRate vs fixedDelay', 'Il faut un cron plutôt qu''un délai dans tous les cas', FALSE, 4, 'Le cron exprime un moment calendaire, pas une cadence « après fin ».'),
('Spring : la variable d''environnement est ignorée', 'Les variables d''environnement priment sur application.yml', TRUE, 1, 'Ordre de priorité Spring Boot : env > arguments > fichier de config.'),
('Spring : la variable d''environnement est ignorée', 'Vérifier le nom exact attendu (SPRING_DATASOURCE_URL, pas DB_URL)', TRUE, 2, 'Le mapping relaxed binding transforme SPRING_... en clé yaml — un autre nom ne matche pas.'),
('Spring : la variable d''environnement est ignorée', 'Spring ne lit les variables qu''au redémarrage', FALSE, 3, 'Sans refresh scope, oui au démarrage — mais le constat « ignorée » vient du nom.'),
('Spring : la variable d''environnement est ignorée', 'Il faut supprimer la valeur du YAML pour que l''env agisse', FALSE, 4, 'L''env écrase par priorité, la valeur YAML reste la défaut.'),
('Spring : profils d''environnement', 'application-{profile}.yml activé par SPRING_PROFILES_ACTIVE', TRUE, 1, 'Config dédiée par environnement, sans recompilation.'),
('Spring : profils d''environnement', '@Profile("prod") conditionne un bean à un environnement', TRUE, 2, 'Exemple : datasource réelle vs H2 de test.'),
('Spring : profils d''environnement', 'Les profils exigent de reconstruire le JAR pour changer d''environnement', FALSE, 3, 'Exactement l''inverse : activation à l''exécution.'),
('Spring : profils d''environnement', 'Il faut coder des if (env.equals("prod")) dans le service', FALSE, 4, 'Conditionnel dans le métier = anti-pattern que les profils évitent.'),
('Spring : cache partagé sur la mauvaise clé', 'La clé par défaut agrège TOUS les paramètres (contexte inclus)', TRUE, 1, 'admin=null écrasé : même hash pour des droits différents.'),
('Spring : cache partagé sur la mauvaise clé', 'Spécifier key = "#cle" (ou un keyGenerator dédié)', TRUE, 2, 'La clé doit correspondre exactement à l''identité métier du résultat.'),
('Spring : cache partagé sur la mauvaise clé', 'Il faut annoter la méthode en @CacheEvict systématiquement', FALSE, 3, 'L''éviction concerne la invalidation, pas la confusion de clé.'),
('Spring : cache partagé sur la mauvaise clé', 'Le cache Spring ne supporte que les clés String', FALSE, 4, 'Les clés simples/objets sont supportées (SimpleKey).'),
('Spring : échec concurrent sur version optimiste', 'La version @Version a changé : conflit d''édition, à répondre en 409', TRUE, 1, 'Sémantique exacte : deux éditions concurrentes sur la même ressource.'),
('Spring : échec concurrent sur version optimiste', 'Recharger l''état et laisser le client arbitrer (dernière version gagne ou merge)', TRUE, 2, 'Réponse client typée : la donnée fraîche + information de conflit.'),
('Spring : échec concurrent sur version optimiste', 'Transformer l''exception en 500 : c''est un bug serveur', FALSE, 3, 'Mauvaise sémantique : le serveur fonctionne, les données sont en conflit.'),
('Spring : échec concurrent sur version optimiste', 'Retenter en boucle infinie jusqu''à réussir', FALSE, 4, 'Thundering herd : retry borné uniquement et si idempotent.'),
('Spring : @ConfigurationProperties vs @Value', 'Typage fort + validation au démarrage (@NotNull, ranges)', TRUE, 1, 'Une valeur absente casse au démarrage, pas à la première requête.'),
('Spring : @ConfigurationProperties vs @Value', 'Regroupement par préfixe + métadonnées IDE auto-générées', TRUE, 2, 'Autocomplétion et doc du YAML gratuites.'),
('Spring : @ConfigurationProperties vs @Value', '@Value est déprécié et supprimé en Spring Boot 4', FALSE, 3, 'Toujours supporté — c''est une question d''adéquation, pas de suppression.'),
('Spring : @ConfigurationProperties vs @Value', '@ConfigurationProperties peut être muté à chaud sans redémarrage', FALSE, 4, 'Faux sans refresh/actuator dédié — la valeur tient à l''exécution.'),
('Spring : décorateur de réponse en 500', 'Aucun @ExceptionHandler ne mappe l''exception métier → repli 500', TRUE, 1, 'Spring MVC ne devine pas la sémantique : il faut la déclarer.'),
('Spring : décorateur de réponse en 500', '@ResponseStatus ou un ControllerAdvice normalise la réponse (statut + message)', TRUE, 2, 'Centralisé : statut juste, corps stable pour le frontend.'),
('Spring : décorateur de réponse en 500', 'Il faut loguer la stacktrace pour transformer la 500 en 404', FALSE, 3, 'Le log ne change pas le statut — confondre observabilité et contrat.'),
('Spring : décorateur de réponse en 500', 'Spring déduit automatiquement le statut du nom de l''exception', FALSE, 4, 'Seules quelques exceptions natives ont un mapping natif.'),
('Spring : migration jakarta.* après saut de version', 'Bascule javax.* → jakarta.* (Servlet, Validation, Persistence) + JDK 17', TRUE, 1, 'La cause racine du ClassNotFoundException massif.'),
('Spring : migration jakarta.* après saut de version', 'Auditer les dépendances tierces encore en javax (filters, serializers)', TRUE, 2, 'Le blocage vient souvent des libs externes pas encore migrées.'),
('Spring : migration jakarta.* après saut de version', 'Un simple bump de version dans le pom suffit sans code', FALSE, 3, 'Le breaking change est réel dans les imports et les libs.'),
('Spring : migration jakarta.* après saut de version', 'Il faut réécrire toutes les entités JPA', FALSE, 4, 'Les entités changent surtout d''import (jakarta.persistence) — le mapping reste.'),
('Spring : prototype injecté dans un singleton', 'L''injection résout la dépendance une seule fois à la création du singleton', TRUE, 1, 'Référence figée : plus jamais de nouvelle instance à chaque usage.'),
('Spring : prototype injecté dans un singleton', 'ObjectProvider<T> ou Provider<T> pour obtenir une instance par appel', TRUE, 2, 'La forme correcte de « retarder la résolution ».'),
('Spring : prototype injecté dans un singleton', 'Utiliser @Scope(proxyMode = TARGET_CLASS) pour que la référence résolve à chaque appel', TRUE, 3, 'Le proxy délègue au conteneur à chaque utilisation — pièce classique du pattern.'),
('Spring : prototype injecté dans un singleton', 'Déclarer le singleton en prototype aussi', FALSE, 4, 'Change l''échelle du problème sans garantir une instance par usage.'),
('Spring : fermeture manquante au shutdown', '@PreDestroy / destroy-method : shutdown() + awaitTermination()', TRUE, 1, 'Le pool personnalisé doit intégrer le cycle de vie du contexte.'),
('Spring : fermeture manquante au shutdown', 'Un délai de shutdown supérieur au temps de traitement maximum', TRUE, 2, 'Sans marge, Tomcat coupe avant la fin des dernières tâches.'),
('Spring : fermeture manquante au shutdown', 'Ajouter un Thread.sleep dans le shutdown hook maison', FALSE, 3, 'Attente aveugle : ni condition de fin, ni ordre garanti.'),
('Spring : fermeture manquante au shutdown', 'Les threads non gérés survivent au contexte et finissent proprement', FALSE, 4, 'Ils sont tués brutalement avec la JVM sans hook dédié.'),
('Spring : deux hachages différents pour le même mot de passe', 'BCrypt intègre un sel aléatoire généré à chaque encodage', TRUE, 1, 'Résultats toujours différents pour un même clair : c''est la sécurité, pas la panne.'),
('Spring : deux hachages différents pour le même mot de passe', 'Vérifier avec passwordEncoder.matches(clair, hash) — jamais == sur les hash', TRUE, 2, 'La seule comparaison correcte côté serveur.'),
('Spring : deux hachages différents pour le même mot de passe', 'Deux hash identiques sont exigés pour un même mot de passe', FALSE, 3, 'C''est l''inverse du fonctionnement d''un hash salé.'),
('Spring : deux hachages différents pour le même mot de passe', 'Il faut réinitialiser les deux mots de passe', FALSE, 4, 'Aucune donnée corrompue : le hash est parfaitement valide.'),
('Spring : l''entité JPA renvoyée directement en JSON', 'Exposition de tous les champs (fuite de données internes)', TRUE, 1, 'Chaque colonne devient publique sans décision explicite.'),
('Spring : l''entité JPA renvoyée directement en JSON', 'Sérialisation des associations lazy : erreur hors transaction', TRUE, 2, 'LazyInitialization pendant le mapping JSON.'),
('Spring : l''entité JPA renvoyée directement en JSON', 'Couplage contrat API / schéma DB : toute évolution SQL devient un risque API', TRUE, 3, 'Le DTO protège le contrat de ses évolutions internes.'),
('Spring : l''entité JPA renvoyée directement en JSON', 'Les entités sérialisent plus vite que les DTO', FALSE, 4, 'Faux et sans importance face aux trois défauts structurels.'),
('Spring : dépendance circulaire au démarrage', 'Extraire la responsabilité commune dans un troisième bean', TRUE, 1, 'Supprime l''arc qui boucle.'),
('Spring : dépendance circulaire au démarrage', 'Injection constructeur : le cycle devient visible et se casse structurellement', TRUE, 2, 'Forme recommandée d''injection — elle exige les dépendances d''entrée.'),
('Spring : dépendance circulaire au démarrage', 'Annoter les deux beans en @Lazy', FALSE, 3, 'Étai qui masque le couplage sans le résoudre.'),
('Spring : dépendance circulaire au démarrage', 'Passer les deux beans en scope prototype', FALSE, 4, 'Le cycle de résolution reste identique à la résolution.'),
('Spring : 401 généralisé après ajout de Spring Security', 'Par défaut, Spring Security protège TOUTES les routes et crée un user éphémère', TRUE, 1, '« Tout refuser » est volontaire : secure by default.'),
('Spring : 401 généralisé après ajout de Spring Security', 'Déclarer son SecurityFilterChain : règles par chemin, état, CORS', TRUE, 2, 'Le périmètre d''accès se décrit, il ne se devine pas.'),
('Spring : 401 généralisé après ajout de Spring Security', 'Ajouter simplement @CrossOrigin aux contrôleurs', FALSE, 3, 'Le CORS ne touche pas à l''authentification.'),
('Spring : 401 généralisé après ajout de Spring Security', 'La dépendance suffit : aucune règle à écrire', FALSE, 4, 'Sans chaîne explicite, ce sont les règles par défaut qui s''appliquent.'),
('Spring : connexions Hikari jamais rendues', 'Connection/Statement sans try-with-resources : la ressource ne revient jamais', TRUE, 1, 'Classique du DAO manuscrit avec exception en chemin.'),
('Spring : connexions Hikari jamais rendues', 'leakDetectionThreshold fournit la stacktrace de la requête fautive', TRUE, 2, 'La localisation précise avant toute hypothèse.'),
('Spring : connexions Hikari jamais rendues', 'Augmenter maximumPoolSize pour tenir la charge', FALSE, 3, 'La fuite avale le pool élargi tout aussi vite.'),
('Spring : connexions Hikari jamais rendues', 'Les connexions sont refermées par le garbage collector', FALSE, 4, 'Aucune garantie de timing : les descripteurs restent occupés.')
) AS v(title, content, is_correct, ord, expl)
JOIN challenges c ON c.title = v.title
WHERE NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id AND o.display_order = v.ord);

-- ---------------------------------------------------------------------
-- 4 PROBLEM_SOLVING
-- ---------------------------------------------------------------------
INSERT INTO challenges (title, type, selection_type, difficulty, context, question, code_snippet, code_language, explanation, estimated_time_seconds, active, points, created_at, updated_at)
SELECT v.title, v.type, v.selection_type, v.difficulty, v.context, v.question,
       NULLIF(v.snippet, ''), NULLIF(v.lang, ''), v.explanation, v.time, TRUE, v.points,
       CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM (VALUES
('Service Spring devenu un état partagé', 'PROBLEM_SOLVING', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Un OrderService singleton accumule private Map<Long, Order> pending = new HashMap<>() et des flags. Des commandes disparaissent sous charge en dev.',
 'Explique le problème et propose la refonte du service.',
 '',
 '',
 'Un singleton contenant de l''état mutable = données partagées entre toutes les requêtes (races, pertes, fuite mémoire). Refonte : rendre le service stateless (paramètres + retour), déplacer l''état d''attente en base / file avec verrouillage adéquat, ou à défaut structure concurrente née à la requête. Vérifier ensuite le cycle de vie (bean scope) et ajouter des tests de concurrence.',
 180, 15),
('Trente @Value sans filet', 'PROBLEM_SOLVING', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'La configuration compte 33 champs @Value éparpillés dans 6 classes, sans validation : une valeur manquante est détectée à la première requête, en prod.',
 'Comment structurer la configuration pour supprimer cette classe d''erreurs ?',
 '',
 '',
 'Regrouper par domaine en @ConfigurationProperties typés (prefix dédié), avec validation Bean Validation (@NotNull, @Min, patterns) déclenchée AU DÉMARRAGE, métadonnées IDE générées, et un profil d''environnement par cible. Résultat : échec rapide au démarrage, config relisible, documentée automatiquement.',
 180, 15),
('Appel distant qui fait tomber le service', 'PROBLEM_SOLVING', 'SINGLE_CHOICE', 'ADVANCED',
 'Sous incident du service de paiement, les threads HTTP se bloquent sur l''appel sortant : tout le service devient injoignable (pas de timeout).',
 'Quelle stratégie de résilience mets-tu en place, et dans quel ordre ?',
 '',
 '',
 'D''abord le minimum vital : timeouts bornés (connect/read) sur le client HTTP — sans lui, aucun autre garde-fou ne joue. Ensuite circuit breaker (suspension des appels pendant l''incident + half-open), retries bornés avec backoff JITTER seulement sur les opérations idempotentes, fallback métier (file, dégradation), et enfin supervision (métriques de taux d''erreur, alertes). La règle : dégrader explicitement plutôt que bloquer.',
 240, 25),
('Suite de tests d''intégration devenue interminable', 'PROBLEM_SOLVING', 'SINGLE_CHOICE', 'ADVANCED',
 'Chaque @SpringBootTest recharge tout le contexte : la suite passe de 40 s à 25 minutes et personne ne la lance plus avant commit.',
 'Quelles leviers Spring Spring Test actives-tu, dans quel ordre ?',
 '',
 '',
 '1) Context caching : configurations identiques = un seul contexte partagé (harmoniser les configs de test, éviter de re-déclarer le même @SpringBootTest avec des variantes). 2) Réduire le périmètre : @DataJpaTest/@WebMvcTest plutôt que plein contexte. 3) Composants lourds mockés (@MockBean/MockitoBean). 4) Base H2/testcontainers partagée. 5) Parallélisation maîtrisée en dernier. Objectif : le contexte le plus petit, chargé le moins de fois.',
 240, 25)
) AS v(title, type, selection_type, difficulty, context, question, snippet, lang, explanation, time, points)
WHERE NOT EXISTS (SELECT 1 FROM challenges c WHERE c.title = v.title);

-- ---------------------------------------------------------------------
-- 6 CODE_REVIEW
-- ---------------------------------------------------------------------
INSERT INTO challenges (title, type, selection_type, difficulty, context, question, code_snippet, code_language, explanation, estimated_time_seconds, active, points, created_at, updated_at)
SELECT v.title, v.type, v.selection_type, v.difficulty, v.context, v.question,
       v.snippet, v.lang, v.explanation, v.time, TRUE, v.points,
       CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM (VALUES
('Review Spring : @Transactional sur méthode privée', 'CODE_REVIEW', 'MULTIPLE_CHOICE', 'INTERMEDIATE',
 'Un service regroupe l''écriture commande + stock.',
 'Quels problèmes identifiez-vous dans ce code ?',
 '@Service
public class OrderWriteService {
    @Transactional
    private void reserveStock(Order o) { ... }

    public Order place(Order o) {
        reserveStock(o);
        save(o);
        return o;
    }
}',
 'java',
 'La transaction privée n''est jamais interceptée (proxy Spring n''expose pas les méthodes privées) : le stock est réservé hors transaction, échec partiel possible. Et place() non annotée n''en ouvre aucune. Rendre la méthode publique en bean séparé (ou annoter la méthode publique d''entrée en gardant l''appel via proxy).',
 180, 20),
('Review Spring : client HTTP sans timeout', 'CODE_REVIEW', 'MULTIPLE_CHOICE', 'INTERMEDIATE',
 'Sous incident du service tiers, la file de requêtes grossit jusqu''à vider le pool de threads.',
 'Quels problèmes identifiez-vous dans ce code ?',
 'public Invoice fetchInvoice(long id) {
    try {
        return restTemplate.getForObject("/invoices/" + id, Invoice.class);
    } catch (Exception e) {
        return null;
    }
}',
 'java',
 'Aucun timeout (connect/read) : le thread attend indéfiniment, exactement ce qui vide le pool sous incident. catch(Exception) → null : échec invisible, null propagé bien plus loin (NPE ou cache « vide »). Poser des timeouts, journaliser, et remonter une exception d''adaptation explicite avec fallback assumé.',
 180, 20),
('Review Spring : log de données sensibles', 'CODE_REVIEW', 'MULTIPLE_CHOICE', 'INTERMEDIATE',
 'Le service de compte journalise les requêtes « pour le debugging ».',
 'Quels problèmes identifiez-vous dans ce code ?',
 'log.info("Login attempt: {}", request);
log.debug("Payload complet: {}", user);   // user contient passwordHash + email
if (!ok) {
    log.error("Echec: {}", request);
}',
 'java',
 'Données personnelles et secrets journalisés (passwordHash, éventuel mot de passe en clair si le DTO le contient) : violation RGPD + fuite dans les agrégateurs de logs. Masquer au niveau du DTO (@JsonIgnore sur le secret, redaction), ne logger que des identifiants pseudonymisés, et régler le niveau pour ne pas exposer les payloads.',
 120, 15),
('Review Spring : requête JPQL concaténée', 'CODE_REVIEW', 'MULTIPLE_CHOICE', 'ADVANCED',
 'Recherche d''utilisateurs par ville saisie dans un formulaire.',
 'Quels problèmes identifiez-vous dans ce code ?',
 '@Query("SELECT u FROM User u WHERE u.city = ''" + city + "''")
List<User> byCity(String city);',
 'java',
 'Concaténation dans une @Query = injection JPQL : une valeur avec une quote casse la requête, et une manipulation plus fine peut altérer la clause (extraction de données). Les paramètres existent précisément pour cela : WHERE u.city = :city avec un paramètre lié — le conteneur gère l''échappement.',
 180, 20),
('Review Spring : erreur renvoyée en 200', 'CODE_REVIEW', 'MULTIPLE_CHOICE', 'INTERMEDIATE',
 'Le frontend « réussit » des opérations qui échouent côté serveur.',
 'Quels problèmes identifiez-vous dans ce code ?',
 'try {
    service.delete(id);
    return ResponseEntity.ok().build();
} catch (Exception e) {
    return ResponseEntity.ok(
        Map.of("error", e.getMessage(), "ok", "false")
    );
}',
 'java',
 'Statut 200 sur échec : les intercepteurs (retry, cache, code client) ne détectent rien — contrat API faussé. e.getMessage() expose parfois des détails internes (SQL, chemins). Répondre avec le statut réel (404/409/500) et un corps d''erreur normalisé, sans fuite technique.',
 120, 15),
('Review Spring : filtre qui bloque la chaîne', 'CODE_REVIEW', 'MULTIPLE_CHOICE', 'JUNIOR',
 'Toutes les requêtes passant par le filtre restent en attente jusqu''au timeout du client.',
 'Quels problèmes identifiez-vous dans ce code ?',
 'public class LoggingFilter extends OncePerRequestFilter {
    protected void doFilterInternal(HttpServletRequest req,
            HttpServletResponse res, FilterChain chain) {
        long t0 = System.currentTimeMillis();
        log.info("-> {}", req.getRequestURI());
        // fin du traitement
        log.info("<- {} {} ms", req.getRequestURI(),
                 System.currentTimeMillis() - t0);
    }
}',
 'java',
 'chain.doFilter(...) n''est jamais appelé : la chaîne s''interrompt, aucun contrôleur ne s''exécute et la réponse ne repart jamais (le client attend). Le timing de fin ne mesurera jamais rien. Ajouter l''appel (idéalement en finally) pour laisser la requête continuer.',
 90, 10)
) AS v(title, type, selection_type, difficulty, context, question, snippet, lang, explanation, time, points)
WHERE NOT EXISTS (SELECT 1 FROM challenges c WHERE c.title = v.title);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation, severity)
SELECT c.id, v.content, v.is_correct, v.ord, v.expl, v.sev
FROM (VALUES
          ('Review Spring : @Transactional sur méthode privée', 'La méthode privée n''est jamais interceptée : aucune transaction ne s''ouvre', TRUE, 1, 'Proxy Spring : les méthodes privées échappent à l''interception.', 'BUG'),
          ('Review Spring : @Transactional sur méthode privée', 'place() elle-même n''est pas transactionnelle : écritures non atomiques', TRUE, 2, 'Si save échoue, le stock réservé peut rester isolé : incohérence.', 'BUG'),
          ('Review Spring : @Transactional sur méthode privée', 'Extraire la logique dans un bean séparé pour retrouver le proxy', TRUE, 3, 'La correction propre conserve la sémantique transactionnelle.', 'ARCHITECTURE'),
          ('Review Spring : @Transactional sur méthode privée', 'Il faut remplacer @Transactional par @Async', FALSE, 4, 'Contresens total : ça éloignerait l''exécution du contrôle transactionnel.', NULL),
          ('Review Spring : client HTTP sans timeout', 'Aucun timeout : le thread attend indéfiniment sous incident distant', TRUE, 1, 'Cause directe de la vidange du pool de threads.', 'PERFORMANCE'),
          ('Review Spring : client HTTP sans timeout', 'catch(Exception) → null : échec silencieux propagé en aval', TRUE, 2, 'Le null voyage jusqu''à une NPE lointaine, sans contexte.', 'CODE_QUALITY'),
          ('Review Spring : client HTTP sans timeout', 'Journaliser l''erreur avec l''identifiant de la ressource', TRUE, 3, 'Le diagnostic est impossible sans trace : minimum d''observabilité.', 'CODE_QUALITY'),
          ('Review Spring : client HTTP sans timeout', 'La concaténation de l''URL est incompatible avec RestTemplate', FALSE, 4, 'Faux : c''est usuel, le problème est la gestion des timeouts.', NULL),
          ('Review Spring : log de données sensibles', 'passwordHash (et données personnelles) journalisé en clair', TRUE, 1, 'RGPD + surface d''attaque : les logs deviennent une source d''extraction.', 'SECURITY'),
          ('Review Spring : log de données sensibles', 'Le payload complet en debug reste dangereux en environnement partagé', TRUE, 2, 'Un changement de niveau expose tout, sans relecture.', 'SECURITY'),
          ('Review Spring : log de données sensibles', 'Il faut logger l''exception complète en error pour le diagnostic', TRUE, 3, 'La stack trace ne contient pas les secrets : c''est la bonne forme.', 'CODE_QUALITY'),
          ('Review Spring : log de données sensibles', 'Les logs doivent être désactivés en production pour la performance', FALSE, 4, 'Trop absolu : c''est le contenu qui doit être maîtrisé, pas l''existence du log.', NULL),
          ('Review Spring : requête JPQL concaténée', 'Concaténation dans @Query : injection JPQL possible', TRUE, 1, 'La valeur utilisateur modifie la structure de la requête.', 'SECURITY'),
          ('Review Spring : requête JPQL concaténée', 'Utiliser un paramètre lié (:city) : échappement assuré par le conteneur', TRUE, 2, 'La correction standard de Hibernate/Spring Data.', 'CODE_QUALITY'),
          ('Review Spring : requête JPQL concaténée', 'Une simple quote dans la valeur casse la requête (erreur runtime)', TRUE, 3, 'Cas minimal d''exploitation : refus ou erreur 500 selon le contenu.', 'BUG'),
          ('Review Spring : requête JPQL concaténée', 'JPQL est toujours sûr car il ne parle pas SQL brut', FALSE, 4, 'Illusion dangereuse : la structure de la clause reste injectable.', NULL),
          ('Review Spring : erreur renvoyée en 200', 'Statut 200 sur échec : le contrat HTTP est faussé', TRUE, 1, 'Retry/cache/clients ne voient pas l''erreur.', 'BUG'),
          ('Review Spring : erreur renvoyée en 200', 'e.getMessage() peut exposer des détails internes (SQL, chemins)', TRUE, 2, 'Fuite d''information dans la réponse.', 'SECURITY'),
          ('Review Spring : erreur renvoyée en 200', 'Le catch(Exception) avale aussi les erreurs de programmation', TRUE, 3, 'Tout devient 200 : le vrai statut est perdu.', 'CODE_QUALITY'),
          ('Review Spring : erreur renvoyée en 200', 'Il faut utiliser ResponseEntity.ok() pour TOUTES les réponses', FALSE, 4, 'Précisément l''anti-pattern qui a produit ce code.', NULL),
          ('Review Spring : filtre qui bloque la chaîne', 'chain.doFilter n''est jamais appelé : la requête ne va jamais au contrôleur', TRUE, 1, 'Blocage systématique jusqu''au timeout client.', 'BUG'),
          ('Review Spring : filtre qui bloque la chaîne', 'Le temps mesuré en fin de méthode ne mesurera rien (jamais atteint)', TRUE, 2, 'Symptôme direct : aucun log de sortie.', 'CODE_QUALITY'),
          ('Review Spring : filtre qui bloque la chaîne', 'Le filtre devrait être enregistré avec @Order explicite', TRUE, 3, 'Même corrigé, l''ordre des filtres détermine le périmètre observé.', 'MAINTAINABILITY'),
          ('Review Spring : filtre qui bloque la chaîne', 'Il faut supprimer le filtre : le logging des requêtes est inutile', FALSE, 4, 'Le besoin est légitime : c''est l''implémentation qui est cassée.', NULL)
     ) AS v(title, content, is_correct, ord, expl, sev)
         JOIN challenges c ON c.title = v.title
WHERE NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id AND o.display_order = v.ord);

-- ---------------------------------------------------------------------
-- 5 SEQUENTIAL_REASONING
-- ---------------------------------------------------------------------
INSERT INTO challenges (title, type, selection_type, difficulty, context, question, code_snippet, code_language, explanation, estimated_time_seconds, active, points, created_at, updated_at)
SELECT v.title, v.type, v.selection_type, v.difficulty, v.context, v.question,
       NULLIF(v.snippet, ''), NULLIF(v.lang, ''), v.explanation, v.time, TRUE, v.points,
       CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM (VALUES
('Diagnostic BeanCreationException circulaire', 'SEQUENTIAL_REASONING', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'L''application ne démarre plus après l''ajout d''une dépendance : BeanCurrentlyInCreationException.',
 'Remets dans l''ordre la procédure de résolution.',
 '',
 '',
 'Comprendre (trace → cycle exact) avant d''agir, casser le cycle structurellement (constructeur/extraction/désignement), puis vérifier et institutionnaliser. Le lazy de confort sans compréhension masque un couplage de conception.',
 180, 15),
('Mettre en place un cache @Cacheable', 'SEQUENTIAL_REASONING', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Un endpoint de catalogue consomme 60 % du temps DB. L''équipe veut « mettre un cache Spring ».',
 'Quel est l''ordre de mise en œuvre rationnel ?',
 '',
 '',
 'On mesure et on choisit d''abord ce qui mérite d''être caché (donnée lise-écriture, coût), on choisit le support (simple en mémoire vs Redis partagé), on implémente avec clé et TTL explicites, on traite l''INVALIDATION (le vrai sujet), puis on mesure le gain. Cacher avant d''avoir identifié la cible produit des caches inutiles et périmés.',
 180, 15),
('Migration Spring Boot 2 vers 3', 'SEQUENTIAL_REASONING', 'SINGLE_CHOICE', 'ADVANCED',
 'Le projet est sur Boot 2.7 et la maintenance s''arrête. Migration planifiée.',
 'Quelles étapes dans quel ordre ?',
 '',
 '',
 'Lire les notes de version (breaking changes) → monter JDK (17) et dépendances → migrer javax.* vers jakarta.* → corriger configurations/props dépréciées → tests par lot → préproduction. Sauter l''étude des breaking changes revient à découvrir les ruptures en production.',
 240, 25),
('Rollback transactionnel qui ne se produit jamais', 'SEQUENTIAL_REASONING', 'SINGLE_CHOICE', 'ADVANCED',
 'Des écritures partielles subsistent après des échecs métier malgré @Transactional. Personne ne sait si la transaction s''ouvre.',
 'Remets dans l''ordre l''investigation.',
 '',
 '',
 'Établir les faits (logs SQL/transaction, preuve du commit) → vérifier le point d''entrée réel (proxy : appel externe ? méthodes privées ?) → corriger la structure (frontière transactionnelle dans le bon bean) → prouver par un test d''intégration qui échoue avant/réussit après → codifier la règle dans les revues.',
 240, 25),
('Normaliser les erreurs d''une API Spring', 'SEQUENTIAL_REASONING', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Les endpoints renvoient un mélange de 500, de chaînes vides et de messages texte. Le frontend parse tout à la main.',
 'Quel ordre de travail pour normaliser ?',
 '',
 '',
 'Cartographier les erreurs réelles (statuts + cas) → définir le contrat (corps d''erreur stable : statut, code, message, trace id) → centraliser dans un ControllerAdvice → brancher chaque endpoint → tester les codes → documenter (OpenAPI) pour le frontend.',
 180, 15)
) AS v(title, type, selection_type, difficulty, context, question, snippet, lang, explanation, time, points)
WHERE NOT EXISTS (SELECT 1 FROM challenges c WHERE c.title = v.title);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.ord, v.expl
FROM (VALUES
('Diagnostic BeanCreationException circulaire', 'Lire la trace complète pour identifier le cycle exact des dépendances', TRUE, 1, 'Le message liste les deux beans du cycle — la base de toute correction.'),
('Diagnostic BeanCreationException circulaire', 'Cartographier pourquoi chaque dépendance est nécessaire', TRUE, 2, 'Comprendre le couplage avant de le casser évite un lazy de dépannage.'),
('Diagnostic BeanCreationException circulaire', 'Casser le cycle : constructeur sur l''interface, extraction du tiers, ou injection différée ciblée', TRUE, 3, 'Plusieurs leviers — le choix se fait selon l''intention réelle du couplage.'),
('Diagnostic BeanCreationException circulaire', 'Relancer le démarrage et vérifier les tests', TRUE, 4, 'La preuve que la correction ne casse rien d''autre.'),
('Diagnostic BeanCreationException circulaire', 'Ajouter @Lazy partout en attendant', FALSE, 5, 'Diffère le problème sans le résoudre et masque les cycles suivants.'),
('Diagnostic BeanCreationException circulaire', 'Passer tous les scopes en prototype', FALSE, 6, 'Multiplie les instances sans casser l''ambiguïté du cycle.'),
('Mettre en place un cache @Cacheable', 'Mesurer et identifier ce qui mérite réellement d''être caché', TRUE, 1, 'Taux de lecture, coût, volatilité : le tri décide de la pertinence.'),
('Mettre en place un cache @Cacheable', 'Choisir le support selon le déploiement (mémoire locale vs Redis partagé)', TRUE, 2, 'Multi-instances : un cache local diverge ; partagé = coût d''infra.'),
('Mettre en place un cache @Cacheable', 'Implémenter avec clé métier explicite + TTL', TRUE, 3, 'Clé et durée de vie sont des décisions, jamais des défauts implicites.'),
('Mettre en place un cache @Cacheable', 'Définir l''invalidation à l''écriture (evict/put)', TRUE, 4, 'Le point le plus difficile : un cache sans invalidation finit par mentir.'),
('Mettre en place un cache @Cacheable', 'Ajouter le cache avant d''avoir mesuré le point chaud', FALSE, 5, 'Optimisation au hasard : coût sans gain mesuré.'),
('Mettre en place un cache @Cacheable', 'Cacher la réponse côté navigateur uniquement', FALSE, 6, 'Ne traite pas le coût serveur identifié.'),
('Migration Spring Boot 2 vers 3', 'Lire les notes de version et repérer les breaking changes', TRUE, 1, 'Le périmètre réel de la migration s''y trouve.'),
('Migration Spring Boot 2 vers 3', 'Monter JDK 17+ et les dépendances de base', TRUE, 2, 'Prérequis matériel de Framework 6.'),
('Migration Spring Boot 2 vers 3', 'Migrer javax.* → jakarta.* (code + libs tierces)', TRUE, 3, 'La rupture la plus généralisée du saut.'),
('Migration Spring Boot 2 vers 3', 'Corriger les propriétés/constructeurs dépréciés puis tests complets', TRUE, 4, 'La longue traîne des dépréciations se traite après la rupture majeure.'),
('Migration Spring Boot 2 vers 3', 'Déployer directement en production pour « voir plus vite »', FALSE, 5, 'Risque maximal sur une migration comportant des breaking changes.'),
('Migration Spring Boot 2 vers 3', 'Réécrire le projet en microservices pendant la migration', FALSE, 6, 'Changer deux variables à la fois : cause n°1 des échecs de migration.'),
('Rollback transactionnel qui ne se produit jamais', 'Établir les faits : logs SQL et preuve du commit malgré l''erreur', TRUE, 1, 'Constater avant d''expliquer : la transaction est-elle vraiment ouverte ?'),
('Rollback transactionnel qui ne se produit jamais', 'Vérifier le point d''entrée : appel externe au bean ou méthode privée (proxy)', TRUE, 2, 'Les deux causes classiques d''absence d''interception.'),
('Rollback transactionnel qui ne se produit jamais', 'Repositionner la frontière transactionnelle dans le bon bean', TRUE, 3, 'La correction structurelle, pas un bricolage de try/catch.'),
('Rollback transactionnel qui ne se produit jamais', 'Prouver avec un test d''intégration (échec → absence d''écriture)', TRUE, 4, 'Seul un test DB réel vérifie le rollback.'),
('Rollback transactionnel qui ne se produit jamais', 'Ajouter setRollbackOnly en attendant d''avoir le temps de corriger', FALSE, 5, 'Étai acceptable UNIQUEMENT temporairement et tracé.'),
('Rollback transactionnel qui ne se produit jamais', 'Supprimer @Transactional pour ne plus avoir de surprise', FALSE, 6, 'Renonce à l''atomicité — le problème de données reste, en pire.'),
('Normaliser les erreurs d''une API Spring', 'Cartographier les erreurs réellement renvoyées aujourd''hui', TRUE, 1, 'On ne standardise pas ce qu''on n''a pas recensé.'),
('Normaliser les erreurs d''une API Spring', 'Définir le contrat (statut + code + message + traceId)', TRUE, 2, 'Le schéma commun que le frontend pourra enfin traiter.'),
('Normaliser les erreurs d''une API Spring', 'Centraliser dans un ControllerAdvice unique', TRUE, 3, 'Une seule traduction exception → réponse, réutilisable.'),
('Normaliser les erreurs d''une API Spring', 'Brancher et tester chaque endpoint (400/404/409/500)', TRUE, 4, 'Vérification que la sémantique est bien portée partout.'),
('Normaliser les erreurs d''une API Spring', 'Documenter le contrat pour le frontend', TRUE, 5, 'Le but final : des clients qui gèrent les cas d''erreur.'),
('Normaliser les erreurs d''une API Spring', 'Remplacer toutes les exceptions par des codes retour dans les corps', FALSE, 6, 'Régression : annule la sémantique HTTP rétablie.')
) AS v(title, content, is_correct, ord, expl)
JOIN challenges c ON c.title = v.title
WHERE NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id AND o.display_order = v.ord);

-- ---------------------------------------------------------------------
-- Liens
-- ---------------------------------------------------------------------
INSERT INTO challenge_categories (challenge_id, category_id)
SELECT c.id, cat.id
FROM (VALUES
('Spring : état partagé dans un bean singleton','Spring Boot'),('Spring : NPE après new sur une classe annotée','Spring Boot'),
('Spring : 404 sur un endpoint qui existe','Spring Boot'),('Spring : quel stéréotype pour quelle intention','Spring Boot'),
('Spring : 400 au lieu de 500 sur entrée invalide','API / Backend'),
('Spring : appel interne et @Transactional','Spring Boot'),('Spring : exception métier attrapée = rollback manqué','Spring Boot'),
('Spring : LazyInitializationException','JPA / Hibernate'),('Spring : transaction longue qui grève le pool','Spring Boot'),
('Spring : @Async par défaut','Spring Boot'),('Spring : exceptions perdues en @Async','Spring Boot'),
('Spring : fixedRate vs fixedDelay','Spring Boot'),('Spring : la variable d''environnement est ignorée','Spring Boot'),
('Spring : profils d''environnement','Spring Boot'),('Spring : cache partagé sur la mauvaise clé','Spring Boot'),
('Spring : échec concurrent sur version optimiste','JPA / Hibernate'),('Spring : @ConfigurationProperties vs @Value','Spring Boot'),
('Spring : décorateur de réponse en 500','API / Backend'),('Spring : migration jakarta.* après saut de version','Spring Boot'),
('Spring : prototype injecté dans un singleton','Spring Boot'),('Spring : fermeture manquante au shutdown','Spring Boot'),
('Service Spring devenu un état partagé','Spring Boot'),('Trente @Value sans filet','Spring Boot'),
('Appel distant qui fait tomber le service','Architecture'),('Suite de tests d''intégration devenue interminable','Testing'),
('Review Spring : @Transactional sur méthode privée','Spring Boot'),('Review Spring : client HTTP sans timeout','Spring Boot'),
('Review Spring : log de données sensibles','API / Backend'),('Review Spring : requête JPQL concaténée','JPA / Hibernate'),
('Review Spring : erreur renvoyée en 200','API / Backend'),('Review Spring : filtre qui bloque la chaîne','Spring Boot'),
('Diagnostic BeanCreationException circulaire','Spring Boot'),('Mettre en place un cache @Cacheable','Spring Boot'),
('Migration Spring Boot 2 vers 3','Spring Boot'),('Rollback transactionnel qui ne se produit jamais','Spring Boot'),
('Normaliser les erreurs d''une API Spring','API / Backend'),
('Spring : deux hachages différents pour le même mot de passe','Spring Boot'),
('Spring : l''entité JPA renvoyée directement en JSON','API / Backend'),
('Spring : dépendance circulaire au démarrage','Spring Boot'),
('Spring : 401 généralisé après ajout de Spring Security','Spring Boot'),
('Spring : connexions Hikari jamais rendues','Spring Boot')
) AS v(title, cat)
JOIN challenges c ON c.title = v.title
JOIN categories cat ON cat.name = v.cat
WHERE NOT EXISTS (SELECT 1 FROM challenge_categories cc WHERE cc.challenge_id = c.id AND cc.category_id = cat.id);

INSERT INTO challenge_skills (challenge_id, skill_id)
SELECT c.id, s.id
FROM (VALUES
('Spring : état partagé dans un bean singleton','Problem Solving'),
('Spring : NPE après new sur une classe annotée','Debugging'),
('Spring : 404 sur un endpoint qui existe','Debugging'),
('Spring : quel stéréotype pour quelle intention','Code Quality'),
('Spring : 400 au lieu de 500 sur entrée invalide','Code Quality'),
('Spring : appel interne et @Transactional','Debugging'),
('Spring : exception métier attrapée = rollback manqué','Debugging'),
('Spring : LazyInitializationException','Debugging'),
('Spring : transaction longue qui grève le pool','Performance Analysis'),
('Spring : @Async par défaut','Performance Analysis'),
('Spring : exceptions perdues en @Async','Code Quality'),
('Spring : fixedRate vs fixedDelay','Code Quality'),
('Spring : la variable d''environnement est ignorée','Debugging'),
('Spring : profils d''environnement','Code Quality'),
('Spring : cache partagé sur la mauvaise clé','Debugging'),
('Spring : échec concurrent sur version optimiste','Problem Solving'),
('Spring : @ConfigurationProperties vs @Value','Code Quality'),
('Spring : décorateur de réponse en 500','Code Quality'),
('Spring : migration jakarta.* après saut de version','Problem Solving'),
('Spring : prototype injecté dans un singleton','Problem Solving'),
('Spring : fermeture manquante au shutdown','Debugging'),
('Service Spring devenu un état partagé','Problem Solving'),
('Trente @Value sans filet','Code Quality'),
('Appel distant qui fait tomber le service','Problem Solving'),
('Suite de tests d''intégration devenue interminable','Performance Analysis'),
('Review Spring : @Transactional sur méthode privée','Debugging'),
('Review Spring : client HTTP sans timeout','Debugging'),
('Review Spring : log de données sensibles','Code Quality'),
('Review Spring : requête JPQL concaténée','Code Quality'),
('Review Spring : erreur renvoyée en 200','Code Quality'),
('Review Spring : filtre qui bloque la chaîne','Debugging'),
('Diagnostic BeanCreationException circulaire','Debugging'),
('Mettre en place un cache @Cacheable','Performance Analysis'),
('Migration Spring Boot 2 vers 3','Problem Solving'),
('Rollback transactionnel qui ne se produit jamais','Debugging'),
('Normaliser les erreurs d''une API Spring','Code Quality'),
('Spring : deux hachages différents pour le même mot de passe','Code Quality'),
('Spring : l''entité JPA renvoyée directement en JSON','Code Quality'),
('Spring : dépendance circulaire au démarrage','Problem Solving'),
('Spring : 401 généralisé après ajout de Spring Security','Problem Solving'),
('Spring : connexions Hikari jamais rendues','Performance Analysis')
) AS v(title, skill)
JOIN challenges c ON c.title = v.title
JOIN skills s ON s.name = v.skill
WHERE NOT EXISTS (SELECT 1 FROM challenge_skills cs WHERE cs.challenge_id = c.id AND cs.skill_id = s.id);

INSERT INTO challenge_profiles (challenge_id, profile_id)
SELECT c.id, p.id
FROM (VALUES
('Spring : état partagé dans un bean singleton'),('Spring : NPE après new sur une classe annotée'),
('Spring : 404 sur un endpoint qui existe'),('Spring : quel stéréotype pour quelle intention'),
('Spring : 400 au lieu de 500 sur entrée invalide'),('Spring : appel interne et @Transactional'),
('Spring : exception métier attrapée = rollback manqué'),('Spring : LazyInitializationException'),
('Spring : transaction longue qui grève le pool'),('Spring : @Async par défaut'),
('Spring : exceptions perdues en @Async'),('Spring : fixedRate vs fixedDelay'),
('Spring : la variable d''environnement est ignorée'),('Spring : profils d''environnement'),
('Spring : cache partagé sur la mauvaise clé'),('Spring : échec concurrent sur version optimiste'),
('Spring : @ConfigurationProperties vs @Value'),('Spring : décorateur de réponse en 500'),
('Spring : migration jakarta.* après saut de version'),('Spring : prototype injecté dans un singleton'),
('Spring : fermeture manquante au shutdown'),('Service Spring devenu un état partagé'),
('Trente @Value sans filet'),('Appel distant qui fait tomber le service'),
('Suite de tests d''intégration devenue interminable'),('Review Spring : @Transactional sur méthode privée'),
('Review Spring : client HTTP sans timeout'),('Review Spring : log de données sensibles'),
('Review Spring : requête JPQL concaténée'),('Review Spring : erreur renvoyée en 200'),
('Review Spring : filtre qui bloque la chaîne'),('Diagnostic BeanCreationException circulaire'),
('Mettre en place un cache @Cacheable'),('Migration Spring Boot 2 vers 3'),
('Rollback transactionnel qui ne se produit jamais'),('Normaliser les erreurs d''une API Spring'),
('Spring : deux hachages différents pour le même mot de passe'),
('Spring : l''entité JPA renvoyée directement en JSON'),
('Spring : dépendance circulaire au démarrage'),
('Spring : 401 généralisé après ajout de Spring Security'),
('Spring : connexions Hikari jamais rendues')
) AS v(title)
JOIN challenges c ON c.title = v.title
JOIN profiles p ON p.code = 'DEVELOPER'
WHERE NOT EXISTS (SELECT 1 FROM challenge_profiles cp WHERE cp.challenge_id = c.id AND cp.profile_id = p.id);
