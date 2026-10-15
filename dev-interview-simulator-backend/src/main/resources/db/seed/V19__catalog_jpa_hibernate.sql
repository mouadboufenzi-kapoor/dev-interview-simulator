-- =====================================================================
-- Catalogue V1 — Pilier JPA / HIBERNATE (profil DEVELOPER)
-- 22 SITUATIONAL_QCM + 3 PROBLEM_SOLVING + 6 CODE_REVIEW + 3 SEQUENTIAL = 34
-- Exclus déjà couverts : « Problème N+1 en production » (V6),
-- « Portée du First-Level Cache » (V6), LazyInitialization (V17),
-- @Version optimiste (V17), @Query concaténée (V17), N+1 review (V7).
-- =====================================================================

-- ---------------------------------------------------------------------
-- 22 QCM
-- ---------------------------------------------------------------------
INSERT INTO challenges (title, type, selection_type, difficulty, context, question, code_snippet, code_language, explanation, estimated_time_seconds, active, points, created_at, updated_at)
SELECT v.title, v.type, v.selection_type, v.difficulty, v.context, v.question,
       NULLIF(v.snippet, ''), NULLIF(v.lang, ''), v.explanation, v.time, TRUE, v.points,
       CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM (VALUES
-- JUNIOR (6)
('JPA : l''id n''est renseigné qu''après le flush', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'JUNIOR',
 'Tu fais Order o = new Order(); repository.save(o); et tu affiches o.getId() : le logger montre null.',
 'Pourquoi l''id est-il absent alors que save a « réussi » ?',
 '',
 '',
 'Avec l''identité (GenerationType.IDENTITY), l''insertion doit avoir lieu pour récupérer l''id généré par la séquence/serial : save déclenche l''insertion immédiate dans la session, mais hors transaction le flush effectif et le retour d''id peuvent ne pas être là. Dans tous les cas, l''id se lit APRÈS le flush — l''objet sauvegardé retourné par save porte l''id.',
 90, 10),
('JPA : « No path defined » dans une requête JPQL', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'JUNIOR',
 'Une JPQL déclare SELECT o FROM Orders o WHERE o.customerName = :n — erreur : o.customerName n''existe pas.',
 'Sur quoi porte la vérification JPQL ?',
 '',
 '',
 'La JPQL parle d''ENTITÉS et de leurs attributs (Order, customer.name), pas de tables et colonnes SQL. Le nommage suit le mapping Java. Le correctif : attribut de l''entité (customer.name), et vérifier le mapping — SQL natif seulement si on manipule réellement le schéma.',
 90, 10),
('JPA : enum stocké en ORDINAL', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'JUNIOR',
 'L''enum Status reçoit une nouvelle constante en tête : en base, d''anciennes lignes « ANCIEN_STATUT » sont lues comme le mauvais état.',
 'Quel mapping évite cette corruption et pourquoi ?',
 '',
 '',
 '@Enumerated(EnumType.STRING) stocke le NOM : réordonner ou insérer des constantes ne déplace aucune donnée. L''ORDINAL (défaut de JPA !) stocke la position — réordonner l''enum réécrit silencieusement le sens des lignes existantes.',
 120, 15),
('JPA : entités dans un HashSet', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'JUNIOR',
 'Un Set<Tag> d''entités ne déduplique pas : le même tag apparaît deux fois après réunion de deux collections.',
 'Quel contrat JPA manque et comment le rétablir ?',
 '',
 '',
 'Sans equals/hashCode définis (sur la clé métier / l''id), le HashSet compare les références. Implémenter equals/hashCode sur l''entité (prudence : identité d''objet vs id — l''id seul pose problème avant persistance) ou distinguer les objets transitoires.',
 120, 15),
('JPA : entité détachée modifiée sans effet', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'JUNIOR',
 'Dans un contrôleur non transactionnel, tu modifies une entité chargée et tu ne fais aucun save : rien ne change en base. Personne ne reçoit d''erreur.',
 'Quel mécanisme explique le silence de JPA ?',
 '',
 '',
 'Hors transaction (session fermée), l''entité est détachée : plus de dirty checking, plus de flush. Les modifications en mémoire sont perdues. Le remède : persister via la méthode transactionnelle du repository (ou service @Transactional) — jamais compter sur l''« auto-save » inexistant.',
 120, 15),
('JPA : états d''entité — réattacher un objet', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'JUNIOR',
 'Une entité chargée dans un premier composant est passée (DTO/mémoire) dans un second, qui la modifie : rien n''est sauvegardé.',
 'Quel est l''état de l''objet et l''action correcte ?',
 '',
 '',
 'État détaché (chargé puis séparé de la session). Pour la réattacher : merge() / persist() selon l''intention, ou — mieux — recharger par id dans la transaction d''édition puis appliquer les changements. Savoir distinguer transient / detached / persistent est le socle du debug JPA.',
 120, 15),
-- INTERMEDIATE (12)
('JPA : suppression par retrait de collection', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Une Order contient une List<OrderLine> avec orphanRemoval = true. On fait order.getLines().remove(line) puis on sauvegarde l''ordre.',
 'Quel est le sort de la ligne retirée et à quelle condition ?',
 '',
 '',
 'orphanRemoval supprime l''enfant orphelin (DELETE) lors du flush si la collection est rattachée et parcourue par Hibernate (managed). Condition : la collection doit être chargée et l''entité parente persistée. Sans orphanRemoval, la ligne reste simplement non liée (ou reste en base) : le retrait n''est qu''un retrait mémoire.',
 180, 20),
('JPA : insertions massives sans batch', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Un import insère 50 000 entités : le log montre 50 000 INSERT individuels ; le temps explose avec la latence réseau.',
 'Quels réglages Hibernate réduisent les allers-retours ?',
 '',
 '',
 'hibernate.jdbc.batch_size (taille de lot), plus order_inserts/order_updates pour regrouper par type de statement. Attention : l''identité (IDENTITY) empêche le batching (il faut une séquence avec optimizer) — le choix d''id conditionne la capacité à batcher.',
 180, 20),
('JPA : flush automatique inopiné', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Tu modifies une entité, puis tu exécutes une requête JPQL sur la même table : la modification est poussée en base alors que tu n''avais rien « sauvé ».',
 'Quel mécanisme est à l''œuvre et quel en est le risque ?',
 '',
 '',
 'Auto-flush : avant toute requête concernant les mêmes tables, Hibernate synchronise la session (cohérence du résultat). Risque : des écritures partielles peuvent partir en base sans que tu l''aies décidé (échec ultérieur = transaction en état inattendu, effets surprenants dans les traitements longs).',
 180, 20),
('JPA : pagination avec jointures fetchées', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'setFirstResult(100).setMaxResults(10) sur une requête avec JOIN FETCH collection retourne 3 lignes au lieu de 10 éléments métier.',
 'Pourquoi la pagination est-elle faussée et quelle alternative ?',
 '',
 '',
 'La pagination s''applique aux LIGNES du résultat joint (fetch multiplie les lignes) : 10 lignes jointes ≠ 10 entités. Solutions : paginer en sous-requête sur les ids (WHERE id IN (sous-requête paginée)) puis fetcher, ou séparer la liste de la jointure d''enfants.',
 180, 20),
('JPA : clé de jointure supplémentaire en ManyToMany', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'La table d''association user_roles porte une colonne assigned_by en plus des deux clés. @ManyToMany ne l''accueille pas.',
 'Quel mapping adopter ?',
 '',
 '',
 'Promouvoir l''association en entité : UserAssociation (@ManyToOne vers chaque côté + colonnes métier), avec Index/UNIQUE. @ManyToMany (ou @ElementCollection) ne porte que les deux clés — quand l''association a sa propre donnée, elle a sa propre entité.',
 180, 20),
('JPA : Open Session in View', 'SITUATIONAL_QCM', 'MULTIPLE_CHOICE', 'INTERMEDIATE',
 'En prod, la latence des endpoints augmente et la durée des transactions serveur aussi, sans code transactionnel apparent.',
 'Quels éléments sont en cause ?',
 '',
 '',
 'spring.jpa.open-in-view (défaut true) maintient la session JPA ouverte pendant TOUT le rendu de la réponse : accès lazy « gratuits » côté UI, mais session longue (verrous, latence, effets de bord du dirty checking). Coupler à un log SQL actif en prod, c''est doublement coûteux. Idéal : DTO construits en transaction courte, OSIV off.',
 180, 20),
('JPA : requête native contre JPQL', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Un rapport a besoin d''un DISTINCT ON / fonctions PostgreSQL spécifiques que la JPQL ne connaît pas.',
 'Quelle approche est saine et quel prix paie-t-on ?',
 '',
 '',
 'Le natif est légitime quand la portabilité SQL n''est pas un enjeu et que la fonction est serveur-spécifique : le prix est le couplage au schéma (renommages cassent) et la perte des optimisations de mapping. Toujours typer le résultat (projection DTO) et garder le périmètre SQL minimal.',
 120, 15),
('JPA : cascade REMOVE sur un objet partagé', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Une Order référence un Customer avec cascade = ALL. Supprimer une commande... supprime aussi le client utilisé par 200 autres commandes.',
 'Pourquoi et quelle règle poser ?',
 '',
 '',
 'cascade REMOVE propage la suppression à l''objet référencé : appliqué à une association vers un entité PARTAGÉE, la suppression devient catastrophique. Les cascades suivent la sémantique de possession : PERSIST/REMOVE seulement vers les enfants exclusifs (composition). Jamais ALL par défaut sur un lien.',
 180, 20),
('JPA : association bidirectionnelle — quel côté porte la clé', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Tu fais category.getChallenges().add(c) sans toucher à c.category : rien n''apparaît dans la table de jointure à l''écriture.',
 'Quel concept manque et quelle est la règle ?',
 '',
 '',
 'Il faut synchroniser les DEUX côtés ET persister par le côté owning (celui qui porte le mappedBy non) : c.category = category. La base ne lit que le côté owning ; l''inverse n''est qu''une commodité de navigation. Inverser mappedBy déplace le problème sans le résoudre.',
 180, 20),
('JPA : traiter un volume sans tout charger', 'SITUATIONAL_QCM', 'MULTIPLE_CHOICE', 'INTERMEDIATE',
 'Un batch de nuit doit traiter 2 millions d''entités : findAll() en mémoire explose, la boucle de save ralentit.',
 'Quelles techniques sont appropriées ?',
 '',
 '',
 'Requête paginée/par lots (id > curseur LIMIT n), ou Stream/iterator avec scroll pour ne jamais résider le jeu complet ; le dirty checking de masse se remplace par des UPDATE JPQL ciblés ou du SQL direct. Et désactiver le cache de niveau 1 de session pour les objets de traitement (clear/detach périodiques).',
 180, 20),
('JPA : horodatages en base et en Java', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Les créations enregistrées par le back en UTC affichent des décalages d''heure côté front, parfois d''un jour.',
 'Quelle stratégie de fuseau faut-il poser ?',
 '',
 '',
 'Stocker en UTC (timestamptz ou TIMESTAMP UTC), ne jamais mettre de fuseau local en base, et ne porter le fuseau qu''à l''affichage (front) ou au périmètre métier (« minuit local »). En JPA : Instant pour l''instant absolu ; LocalDateTime seulement pour un heure locale sans instant — jamais pour des instants partagés.',
 180, 20),
-- ADVANCED (4)
('JPA : tri dynamique depuis un paramètre utilisateur', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'L''écran de liste accepte un tri passé en paramètre (?sort=...) et le concatène dans la JPQL : un tri malveillant casse la requête ou révèle des colonnes.',
 'Quelle approche est saine pour du tri dynamique ?',
 '',
 '',
 'ORDER BY ne peut pas être paramétré (les identifiants de colonnes ne sont pas des valeurs) : d''où le réflexe dangereux de concaténation. Correction : whitelist serveur des colonnes/tri autorisées, rejet du reste — et ne jamais trier côté Java sur une page déjà tronquée par la pagination.',
 120, 15),
('JPA : ordre d''insertion et clés étrangères', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'ADVANCED',
 'Une même transaction insère un parent et ses enfants référencés dans plusieurs tables ; sous contrainte FK différée à tort, l''insertion échoue.',
 'Comment Hibernate choisit-il l''ordre et que maîtriser ?',
 '',
 '',
 'Les inserts suivent l''ordre des tables (sort_inserts) et le graphe d''insertion des dépendances — en cas de cycle réel, la clé doit être générée (séquence) et non produite en fin d''insertion, ou la contrainte déclarée DEFERRABLE INITIALLY IMMEDIATE selon le besoin. L''ordre des statements est un levier de batch comme de correction FK.',
 240, 25),
('JPA : cache de second niveau et données périmées', 'SITUATIONAL_QCM', 'MULTIPLE_CHOICE', 'ADVANCED',
 'Le L2 cache est activé : un écran d''administration qui modifie un produit ne se voit pas sur l''instance voisine, parfois même sur la même.',
 'Quels mécanismes/risques maîtriser ?',
 '',
 '',
 'Le L2 est partagé/mis à jour par région : il faut invalidation (usage cross-emitter native/hibernate) ou TTL court, et garder en tête que les requêtes JPQL (hors @Cacheable(nativeQuery)) ne consultent pas le L2 : c''est l''entité verbeuse qui est servie. Cohérence = invalidation à chaque écriture, sinon le cache ment (stale).',
 240, 25),
('JPA : séquences et batch — hi-lo', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'ADVANCED',
 'Les inserts batchés restent lents : chaque nouvel enchaînement provoque un round-trip vers la séquence (nextval).',
 'Quel générateur d''identité résout ce coût sans casser l''unicité ?',
 '',
 '',
 'Hi-lo (ou pooled/pooled-lo) : Hibernate prélève un bloc de valeurs et les distribue localement — un seul appel par bloc. Les ids peuvent ne pas être continus ; unicité garantie. Une clé pré-générée côté client partage la même logique (sans attente de séquence).',
 180, 20),
('JPA : verrou pessimiste piloté par JPA', 'SITUATIONAL_QCM', 'MULTIPLE_CHOICE', 'ADVANCED',
 'Un allotissement de stock ne peut pas se résoudre en optimiste (trop de conflits) : il faut verrouiller la ligne à la lecture.',
 'Que fournit JPA et quels garde-fous poser ?',
 '',
 '',
 '@Lock(PESSIMISTIC_WRITE) (SELECT ... FOR UPDATE) sur l''entité/requête ; Options : timeout (NO_WAIT/WAIT n) pour refuser au lieu d''attendre, verrou sur une requête ciblée plutôt que globalement, et périmètre minimal (stock verrouillé = lecture-décision-écriture dans une transaction courte). Risque : deadlocks si l''ordre de verrouillage varie.',
 240, 25)
) AS v(title, type, selection_type, difficulty, context, question, snippet, lang, explanation, time, points)
WHERE NOT EXISTS (SELECT 1 FROM challenges c WHERE c.title = v.title);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.ord, v.expl
FROM (VALUES
('JPA : l''id n''est renseigné qu''après le flush', 'Avec IDENTITY, l''insertion doit avoir lieu pour obtenir l''id généré par la base', TRUE, 1, 'La valeur vient du côté base : pas de flush, pas de valeur.'),
('JPA : l''id n''est renseigné qu''après le flush', 'Lire l''objet retourné par save (et non l''instance d''origine) après exécution', TRUE, 2, 'save renvoie l''entité persistée porteuse de l''id.'),
('JPA : l''id n''est renseigné qu''après le flush', 'Le save a échoué silencieusement : il faut vérifier les logs', FALSE, 3, 'Aucun échec : c''est le cycle de génération d''id qui est en jeu.'),
('JPA : l''id n''est renseigné qu''après le flush', 'Il faut appeler flush() manuellement pour que save fonctionne', FALSE, 4, 'Le flush est automatique à la transaction — inutile en situation courante.'),
('JPA : « No path defined » dans une requête JPQL', 'La JPQL référence entités et attributs Java, pas tables et colonnes', TRUE, 1, 'SELECT o FROM Order o WHERE o.customer.name — le modèle objet prime.'),
('JPA : « No path defined » dans une requête JPQL', 'Vérifier le mapping (@Column/@JoinColumn) du champ en erreur', TRUE, 2, 'L''erreur signale souvent un attribut réellement absent de l''entité.'),
('JPA : « No path defined » dans une requête JPQL', 'Passer en SQL natif résout tous les problèmes de nommage', FALSE, 3, 'Déplace le problème vers le schéma et perd la portabilité.'),
('JPA : « No path defined » dans une requête JPQL', 'JPQL tolère les fautes de nom et les corrige au runtime', FALSE, 4, 'Elle échoue à l''exécution — aucune tolérance.'),
('JPA : enum stocké en ORDINAL', '@Enumerated(STRING) stocke le nom : réordonner l''enum ne touche rien', TRUE, 1, 'Le nom est stable ; la position ne l''est pas.'),
('JPA : enum stocké en ORDINAL', 'L''ORDINAL (défaut JPA) stocke la position : insertion en tête = corruption', TRUE, 2, 'Piège silencieux classique du défaut de spécification.'),
('JPA : enum stocké en ORDINAL', 'Il faut une table de référence pour chaque enum métier', FALSE, 3, 'Possible (overkill) : STRING suffit à l''intégrité requise.'),
('JPA : enum stocké en ORDINAL', 'Hibernate convertit automatiquement les ordinaux au démarrage', FALSE, 4, 'Aucune conversion — les données restent fausses.'),
('JPA : entités dans un HashSet', 'Sans equals/hashCode, le Set compare des références d''objets', TRUE, 1, 'Deux instances = deux entrées, même valeur métier.'),
('JPA : entités dans un HashSet', 'Implémenter equals/hashCode sur la clé métier (prudence avant persistance)', TRUE, 2, 'L''id seul pose problème pour les objets transitoires (null).'),
('JPA : entités dans un HashSet', 'Remplacer Set par List : la duplication disparaît', FALSE, 3, 'Le List n''élimine rien du tout — la duplication y est garantie.'),
('JPA : entités dans un HashSet', 'Ajouter distinct() sur la collection', FALSE, 4, 'distinct() sur Set d''entités = même défaut d''égalité.'),
('JPA : entité détachée modifiée sans effet', 'Hors transaction, l''entité est détachée : plus de dirty checking ni de flush', TRUE, 1, 'La session ne suit plus l''objet — silence complet.'),
('JPA : entité détachée modifiée sans effet', 'Persister via le service/repository transactionnel (merge/reload + save)', TRUE, 2, 'La bonne frontière : toute écriture passe par une transaction.'),
('JPA : entité détachée modifiée sans effet', 'Hibernate aurait dû prévenir à la modification du champ', FALSE, 3, 'Hors session, aucun hooks n''est attaché à l''objet.'),
('JPA : entité détachée modifiée sans effet', 'Ajouter @Transactional au contrôleur résout tous les cas', FALSE, 4, 'Ouvrir des transactions sur les contrôleurs étale la session (OSIV-like) — mauvaise frontière.'),
('JPA : états d''entité — réattacher un objet', 'État détaché : recharger par id dans la transaction d''édition, ou merge', TRUE, 1, 'Deux réponses selon l''intention : fusionner l''état ou repartir de la base.'),
('JPA : états d''entité — réattacher un objet', 'Persist vs merge selon que l''objet est neuf ou existant', TRUE, 2, 'La distinction d''état détermine l''API à appeler.'),
('JPA : états d''entité — réattacher un objet', 'L''objet reste permanent : toute modification sera un jour prise en compte', FALSE, 3, 'Invention : l''état détaché n''est jamais suivi.'),
('JPA : états d''entité — réattacher un objet', 'Il faut redémarrer la session Hibernate pour « raccrocher » l''objet', FALSE, 4, 'Le rattachement est par requête/transaction, pas global.'),
('JPA : suppression par retrait de collection', 'orphanRemoval provoque le DELETE de l''enfant retiré au flush', TRUE, 1, 'Seule la version avec orphanRemoval supprime réellement.'),
('JPA : suppression par retrait de collection', 'Conditions : collection chargée, parent persistant, cycle de flush normal', TRUE, 2, 'Un retrait sur collection non chargée ne se propage pas.'),
('JPA : suppression par retrait de collection', 'Sans orphanRemoval, le retrait ne fait que détacher en mémoire', TRUE, 3, 'La ligne reste en base avec sa clé étrangère.'),
('JPA : suppression par retrait de collection', 'remove() dans la collection équivaut toujours à un DELETE SQL', FALSE, 4, 'Seulement avec orphanRemoval — sinon rien côté base.'),
('JPA : insertions massives sans batch', 'hibernate.jdbc.batch_size + order_inserts/order_updates', TRUE, 1, 'Regroupe les statements en lots : un allers-retour au lieu de N.'),
('JPA : insertions massives sans batch', 'IDENTITY empêche le batching : préférer séquence + optimizer', TRUE, 2, 'Génération immédiate d''id = impossibilité de différer les inserts.'),
('JPA : insertions massives sans batch', 'Désactiver le dirty checking et écrire des INSERT SQL à la main', FALSE, 3, 'Lourd et hors ORM — le batch suffit au problème posé.'),
('JPA : insertions massives sans batch', 'Mettre toutes les insertions dans un seul save()', FALSE, 4, 'Aucune API de ce type : le batching est un réglage du JDBC layer.'),
('JPA : flush automatique inopiné', 'Auto-flush : Hibernate synchronise la session avant une requête sur les mêmes tables', TRUE, 1, 'Garantit la cohérence du résultat de la requête.'),
('JPA : flush automatique inopiné', 'Écritures partielles poussées sans décision explicite', TRUE, 2, 'Dans un traitement long, l''ordre réel des écritures surprend.'),
('JPA : flush automatique inopiné', 'Désactiver l''auto-flush pour reprendre la main', TRUE, 3, 'flushMode/FlushModeType — à utiliser en connaissance de cause (risque d''incohérence).'),
('JPA : flush automatique inopiné', 'L''auto-flush écrit aussi les entités jamais modifiées', FALSE, 4, 'Seules les entités dirty sont poussées.'),
('JPA : pagination avec jointures fetchées', 'Le fetch multiplie les lignes : la limite frappe les lignes jointes', TRUE, 1, '10 lignes jointes ≠ 10 entités complètes.'),
('JPA : pagination avec jointures fetchées', 'Paginer les ids en sous-requête puis fetcher (WHERE id IN ...)', TRUE, 2, 'Forme canonique de la pagination + fetch.'),
('JPA : pagination avec jointures fetchées', 'Séparer liste paginée et chargement des collections', TRUE, 3, 'Deux requêtes propres plutôt qu''un fetch explosif.'),
('JPA : pagination avec jointures fetchées', 'Augmenter maxResults compense toujours', FALSE, 4, 'Ne change pas la sémantique : le comptage reste faussé.'),
('JPA : clé de jointure supplémentaire en ManyToMany', 'Promouvoir l''association en entité propre (colonnes métier incluses)', TRUE, 1, 'L''association porte une donnée : elle devient une classe.'),
('JPA : clé de jointure supplémentaire en ManyToMany', '@JoinTable ne porte pas de colonnes de données métier', TRUE, 2, 'Seules les clés (et le nom de table) y logent.'),
('JPA : clé de jointure supplémentaire en ManyToMany', 'ElementCollection accueille les colonnes supplémentaires', FALSE, 3, 'Collection de valeurs simples seulement — pas d''entité d''association.'),
('JPA : clé de jointure supplémentaire en ManyToMany', 'Ajouter la colonne à l''une des deux tables existantes', FALSE, 4, 'Déplace la donnée sur le mauvais graphe métier.'),
('JPA : Open Session in View', 'open-in-view garde la session ouverte pendant tout le rendu de la réponse', TRUE, 1, 'Latence de session longue + accès lazy invisibles côté contrôleur.'),
('JPA : Open Session in View', 'DTO construits en transaction courte + OSIV off = session bornée', TRUE, 2, 'Le remède structurel : le lazy est décidé en service, pas au render.'),
('JPA : Open Session in View', 'Les écritures sortent en dehors de toute transaction', TRUE, 3, 'Le dirty checking peut profiter de la session de rendu — effets de bord en prod.'),
('JPA : Open Session in View', 'Désactiver la session JPA est toujours la bonne réponse', FALSE, 4, 'Trop absolu : c''est la durée et l''usage implicite qu''il faut supprimer.'),
('JPA : requête native contre JPQL', 'Le natif est légitime pour les fonctions serveur-spécifiques', TRUE, 1, 'La portabilité n''est pas un enjeu pour un rapport interne.'),
('JPA : requête native contre JPQL', 'Prix : couplage au schéma SQL (renommages = requêtes cassées)', TRUE, 2, 'Le contrat devient la base, plus l''entité.'),
('JPA : requête native contre JPQL', 'Projeter en DTO typé plutôt que d''hydrater des entités', TRUE, 3, 'Moins de mapping, contrat de résultat explicite.'),
('JPA : requête native contre JPQL', 'Le natif est toujours plus rapide que la JPQL', FALSE, 4, 'Le plan SQL est identique : la différence est sémantique.'),
('JPA : cascade REMOVE sur un objet partagé', 'cascade REMOVE propage le DELETE à la cible partagée', TRUE, 1, '200 commandes citent le même client : le client disparaît.'),
('JPA : cascade REMOVE sur un objet partagé', 'Cascader seulement vers les enfants exclusifs (composition)', TRUE, 2, 'Le cascade suit la possession réelle du graphe.'),
('JPA : cascade REMOVE sur un objet partagé', 'ALL par défaut est risqué : il propage persist + remove', TRUE, 3, 'Raccourci de confort qui finit par supprimer ce qu''on ne possède pas.'),
('JPA : cascade REMOVE sur un objet partagé', 'Ajouter orphanRemoval résout le problème de suppression', FALSE, 4, 'Agrandit encore la sémantique dangereuse.'),
('JPA : association bidirectionnelle — quel côté porte la clé', 'Le côté owning (sans mappedBy) porte la clé : sans lui, rien n''est écrit', TRUE, 1, 'La base ne voit que l''inverse-pas-de-mappedBy.'),
('JPA : association bidirectionnelle — quel côté porte la clé', 'Synchroniser systématiquement les deux côtés (méthode métier dédiée)', TRUE, 2, 'setParent+getChildren cohérents évitent les incohérences de graphe.'),
('JPA : association bidirectionnelle — quel côté porte la clé', 'Inverser mappedBy déplace la clé mais règle le problème', FALSE, 3, 'Cela change le porteur — il faut toujours persister par le bon côté.'),
('JPA : association bidirectionnelle — quel côté porte la clé', 'Flush explicite résout l''absence de clé', FALSE, 4, 'Flush écrit ce qui est mappé : si le owning est vide, rien ne part.'),
('JPA : traiter un volume sans tout charger', 'Itération par curseur d''id + LIMIT n (jamais findAll)', TRUE, 1, 'Mémoire constante, requêtes bornées.'),
('JPA : traiter un volume sans tout charger', 'UPDATE/DELETE JPQL ciblés quand la logique tient en SQL', TRUE, 2, 'Évite hydratation + dirty checking massifs.'),
('JPA : traiter un volume sans tout charger', 'clear()/detach périodiques pour ne pas retenir la session', TRUE, 3, 'Le cache de session grossit sinon à chaque lot.'),
('JPA : traiter un volume sans tout charger', 'stream() sans limite : la requête reste ouverte pendant tout le traitement', FALSE, 4, 'Pertinent sous conditions — sans borne, c''est un filet tendu en prod.'),
('JPA : horodatages en base et en Java', 'Stocker en UTC ; le fuseau ne sert qu''à l''affichage ou au périmètre métier', TRUE, 1, 'Une fois en base, la donnée ne doit plus dépendre d''un serveur.'),
('JPA : horodatages en base et en Java', 'Instant = instant absolu ; LocalDateTime = heure locale sans instant', TRUE, 2, 'Choix sémantique : partagé vs local — jamais l''inverse.'),
('JPA : horodatages en base et en Java', 'Passer la JVM en fuseau UTC règle tous les cas', FALSE, 3, 'Réduit les écarts mais ne tranche pas « minuit local » vs instant absolu.'),
('JPA : horodatages en base et en Java', 'Stocker l''offset (+02:00) dans chaque ligne', FALSE, 4, 'Rend les tris/plages temporelles difficiles sans règle stricte.'),
('JPA : tri dynamique depuis un paramètre utilisateur', 'ORDER BY ne peut pas être paramétré : identifiants de colonnes ≠ valeurs liées', TRUE, 1, 'D''où la tentation (fautive) de concaténer.'),
('JPA : tri dynamique depuis un paramètre utilisateur', 'Whitelist serveur des colonnes/tri autorisés, rejet explicite du reste', TRUE, 2, 'Correction standard du tri dynamique.'),
('JPA : tri dynamique depuis un paramètre utilisateur', 'Tri côté Java après une requête paginée : résultat partiellement trié', FALSE, 3, 'Le LIMIT frappe AVANT le tri complet — faux résultat.'),
('JPA : tri dynamique depuis un paramètre utilisateur', 'Utiliser un paramètre lié dans ORDER BY comme dans WHERE', FALSE, 4, 'Impossible : le nom de colonne appartient à la requête, pas à la donnée.'),
('JPA : ordre d''insertion et clés étrangères', 'L''ordre des statements suit les dépendances (sort_inserts) et le batching', TRUE, 1, 'Ordre correct = contraintes FK satisfaites à l''écriture.'),
('JPA : ordre d''insertion et clés étrangères', 'Cycle réel : générer la clé (séquence) plutôt qu''attendre la fin d''insertion', TRUE, 2, 'Casse le cycle parent↔enfant au moment de la clé.'),
('JPA : ordre d''insertion et clés étrangères', 'Contraintes DEFERRABLE quand le cycle est structurellement attendu', TRUE, 3, 'PostgreSQL vérifie à COMMIT — outil ciblé du cas réel.'),
('JPA : ordre d''insertion et clés étrangères', 'Désactiver toutes les FK pendant l''import (jamais)', FALSE, 4, 'Opération risquée hors périmètre contrôlé et transitoire.'),
('JPA : cache de second niveau et données périmées', 'Invalidation à chaque écriture (ou TTL court) : sinon données périmées', TRUE, 1, 'Un L2 non invalidé sert de vieilles versions.'),
('JPA : cache de second niveau et données périmées', 'Les requêtes JPQL ne consultent pas le L2 (sauf natif cachable)', TRUE, 2, 'C''est l''entité qui est cachée, pas le résultat de requête.'),
('JPA : cache de second niveau et données périmées', 'Multi-instances : la cohérence exige un support partagé/diffusé', TRUE, 3, 'Un cache local diverge instantanément entre instances.'),
('JPA : cache de second niveau et données périmées', 'Activer le L2 en production sans politique d''invalidation', FALSE, 4, 'C''est exactement le scénario de données périmées.'),
('JPA : séquences et batch — hi-lo', 'Hi-lo prélève un bloc d''ids : un seul appel de séquence par bloc', TRUE, 1, 'Le coût de round-trip devient constant.'),
('JPA : séquences et batch — hi-lo', 'Les ids peuvent avoir des trous : unicité garantie, continuité non', TRUE, 2, 'Compromis assumé — vérifier l''exigence métier.'),
('JPA : séquences et batch — hi-lo', 'Pooled/Pooled-lo : variantes adaptées aux séquences partagées', TRUE, 3, 'Choix d''optimizer selon la source d''identité.'),
('JPA : séquences et batch — hi-lo', 'Hi-lo casse l''unicité des identifiants', FALSE, 4, 'Exactement l''inverse : c''est sa garantie.'),
('JPA : verrou pessimiste piloté par JPA', '@Lock(PESSIMISTIC_WRITE) : SELECT ... FOR UPDATE côté JPA', TRUE, 1, 'Verrou de ligne à la lecture — décision d''allotissement sûre.'),
('JPA : verrou pessimiste piloté par JPA', 'Options NO_WAIT / WAIT n : refuser ou attendre avec borne', TRUE, 2, 'Évite les files d''attente bloquées sans limite.'),
('JPA : verrou pessimiste piloté par JPA', 'Périmètre minimal + ordre de verrouillage constant (anti-deadlock)', TRUE, 3, 'La discipline d''accès réduit le risque de cycle.'),
('JPA : verrou pessimiste piloté par JPA', 'Le verrou pessimiste remplace le retry sur conflit d''écriture', FALSE, 4, 'Ce sont deux stratégies distinctes selon le taux de conflit.')
) AS v(title, content, is_correct, ord, expl)
JOIN challenges c ON c.title = v.title
WHERE NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id AND o.display_order = v.ord);

-- ---------------------------------------------------------------------
-- 3 PROBLEM_SOLVING
-- ---------------------------------------------------------------------
INSERT INTO challenges (title, type, selection_type, difficulty, context, question, code_snippet, code_language, explanation, estimated_time_seconds, active, points, created_at, updated_at)
SELECT v.title, v.type, v.selection_type, v.difficulty, v.context, v.question,
       NULLIF(v.snippet, ''), NULLIF(v.lang, ''), v.explanation, v.time, TRUE, v.points,
       CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM (VALUES
('JPA : sortir d''un mapping « tout en EAGER »', 'PROBLEM_SOLVING', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Une entité Document porte 6 relations EAGER + un @Lob : chaque liste d''administration charge des Mo en mémoire, les endpoints ralentissent.',
 'Comment assainis le mapping sans casser les écrans existants ?',
 '',
 '',
 '1) Cartographier les usages réels (log SQL par endpoint : qui accède à quelle relation ?). 2) Basculer en LAZY (défaut sain) relation par relation. 3) Corriger les accès qui casseront : projections/DTO dédiés ou fetch ciblé (@EntityGraph) sur les requêtes qui en ont besoin. 4) Couper OSIV pour rendre les besoins explicites. 5) Mesurer (temps endpoint, poids des réponses) avant/après.',
 240, 25),
('JPA : modèle dupliqué entre deux contextes', 'PROBLEM_SOLVING', 'SINGLE_CHOICE', 'ADVANCED',
 'Le même Customer est référencé par la facturation et par la relation client ; chaque côté veut des champs différents et des cycles de release distincts.',
 'Quelle stratégie de modèle proposes-tu et pourquoi ?',
 '',
 '',
 'Ne pas partager l''entité entre contextes : chaque contexte possède SA copie/sa vue (projection dédiée) échangée par identifiant/événement, la source faisant autorité chez le propriétaire. Le partage d''une entité JPA unique couplera les schémas, les contraintes et les déploiements — le « grand entité partagée » est la dette technique la plus classique.',
 240, 25),
('JPA : graphe bidirectionnel qui double les écritures', 'PROBLEM_SOLVING', 'SINGLE_CHOICE', 'ADVANCED',
 'Un formulaire enregistre Parent + enfants via les deux côtés de la relation : le log montre des inserts dupliqués et des enfants orphelins après éditions successives.',
 'Comment diagnostiques-tu et corriges-tu ce motif ?',
 '',
 '',
 'Diagnostiquer : reproduire en logant les collections (état avant/après, ids des enfants), vérifier qui est le owning side et si une synchronisation manuelle crée des doublons. Corriger : une SEULE voie d''écriture (méthode métier qui positionne les deux côtés), état de collection remplacé (clear+addAll) ou mutation ciblée, orphanRemoval seulement si suppression réelle voulue, et couvrir d''un test d''intégration édition→relecture.',
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
('JPA Review : filtre métier en Java sur findAll', 'CODE_REVIEW', 'MULTIPLE_CHOICE', 'INTERMEDIATE',
 'Liste « filtrée » des commandes d''un client sur la semaine.',
 'Quels problèmes identifiez-vous dans ce code ?',
 'List<Order> all = orderRepository.findAll();
return all.stream()
    .filter(o -> o.getCustomerId().equals(customerId))
    .filter(o -> o.getCreatedAt().isAfter(since))
    .sorted(Comparator.comparing(Order::getCreatedAt).reversed())
    .limit(50)
    .toList();',
 'java',
 'Le filtrage et le tri se font EN MÉMOIRE sur toute la table (mémoire, CPU, latence croissante avec la base) alors que WHERE/ORDER BY/LIMIT délégués à PostgreSQL ne chargent que les 50 lignes utiles. findAll() sur une table en croissance est une bombe à retardement : requête dédiée (JPQL/critère).',
 180, 20),
('JPA Review : IN de dix mille identifiants', 'CODE_REVIEW', 'MULTIPLE_CHOICE', 'INTERMEDIATE',
 'Chargement groupé d''entités à partir d''une liste d''ids collectée en amont.',
 'Quels problèmes identifiez-vous dans ce code ?',
 'List<Long> ids = collectIds();          // jusqu''à 10 000 ids
List<Product> products =
    productRepository.findAllById(ids);

Map<Long, Product> byId = products.stream()
        .collect(toMap(Product::getId, p -> p));',
 'java',
 'Un IN de plusieurs milliers de valeurs : requête énorme, limite de paramètres JDBC/parsing lourd, et plan dégradé — sans parler de la mémoire du résultat non borné. Découper en lots raisonnables (chunks de 500-1000) avec mapping incrémental, ou déléguer au besoin réel (requête serveur si possible).',
 180, 20),
('JPA Review : @Lob en EAGER sur une entité listée', 'CODE_REVIEW', 'MULTIPLE_CHOICE', 'INTERMEDIATE',
 'Le tableau de bord des documents est devenu très lent au fil de l''ajout de pièces jointes.',
 'Quels problèmes identifiez-vous dans ce code ?',
 '@Entity
public class Document {
    @Lob
    @Basic(fetch = FetchType.EAGER)
    private byte[] content;

    @Column(nullable = false)
    private String name;
}',
 'java',
 'Le contenu binaire (potentiellement des Mo) est chargé À CHAQUE lecture de Document, y compris pour une simple liste de noms : poids mémoire × nombre de lignes, temps réseau explosé. Le contenu doit être lazy (ou hors entité : stockage fichier/BLOB référencé) et chargé seulement à la consultation ciblée.',
 120, 15),
('JPA Review : collection ré-ajoutée à chaque save', 'CODE_REVIEW', 'MULTIPLE_CHOICE', 'ADVANCED',
 'Après plusieurs éditions, la table de jointure contient des doublons persistants malgré un Set en mémoire.',
 'Quels problèmes identifiez-vous dans ce code ?',
 'order.getLines().addAll(newLines);
orderRepository.save(order);
// nouvelle édition plus tard :
order.getLines().addAll(moreLines);
orderRepository.save(order);',
 'java',
 'La collection du graphe est accumulée sans reprise en compte de l''état persistant : selon la forme (List sans Set + clear), les rééditions ré-insèrent/dupliquent et les entités retirées ne sont jamais supprimées. Remplacer l''état (clear + addAll) ou muter précisément, en gardant la collection gérée — et distinguer l''ajout d''enfants neufs des existants.',
 240, 25),
('JPA Review : toString récursif sur graphe d''entités', 'CODE_REVIEW', 'MULTIPLE_CHOICE', 'INTERMEDIATE',
 'Le serveur plante en StackOverflowError dès qu''une entité est loggée en erreur, et les logs affichent des dossiers entiers.',
 'Quels problèmes identifiez-vous dans ce code ?',
 '@ToString  // généré : inclut la collection + l''entité parente
@Entity
public class OrderLine {
    @ManyToOne private Order order;      // inverse de la collection
    @OneToMany(mappedBy = "line") private List<Note> notes;
}',
 'java',
 'toString() sur un graphe cyclique (ligne → commande → lignes → ...) explore en profondeur : StackOverflowError, et surtout loggé = fuite de données métier + coût de sérialisation massif. Préférer un toString court (id + clé métier) ou logger des identifiants — jamais le graphe complet.',
 120, 15),
('JPA Review : TransientObjectException au save', 'CODE_REVIEW', 'MULTIPLE_CHOICE', 'ADVANCED',
 'L''enregistrement échoue par intermittence selon que le sous-objet vient du formulaire ou de la base.',
 'Quels problèmes identifiez-vous dans ce code ?',
 'Tax tax = taxRepository.findById(taxId).orElse(null);
order.setTax(tax);           // peut être null/transitoire
orderRepository.save(order); // TransientObjectException ?',
 'java',
 'Cascade absent : persister un parent référençant un objet TRANSITOIRE (ou null selon le cas) lève TransientObjectException — Hibernate refuse d''imaginer la clé. Clarifier : obligatoire (validation 400 si absent), cascade PERSIST si création liée, ou rechargement systématique par id. Le null silencieux, lui, produit une violation de contrainte plus tard.',
 240, 25)
) AS v(title, type, selection_type, difficulty, context, question, snippet, lang, explanation, time, points)
WHERE NOT EXISTS (SELECT 1 FROM challenges c WHERE c.title = v.title);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation, severity)
SELECT c.id, v.content, v.is_correct, v.ord, v.expl, v.sev
FROM (VALUES
          ('JPA Review : filtre métier en Java sur findAll', 'Filtrage/tri/limit EN MÉMOIRE sur toute la table', TRUE, 1, 'PostgreSQL le fait en index, sans transporter les lignes inutiles.', 'PERFORMANCE'),
          ('JPA Review : filtre métier en Java sur findAll', 'findAll() sans borne : coût croissant avec la croissance de la table', TRUE, 2, 'Latence et mémoire linéaires en taille de table.', 'PERFORMANCE'),
          ('JPA Review : filtre métier en Java sur findAll', 'Requête dédiée : WHERE customerId + createdAt, ORDER BY, LIMIT 50', TRUE, 3, 'Une seule requête indexée ne retourne que le résultat affiché.', 'ARCHITECTURE'),
          ('JPA Review : filtre métier en Java sur findAll', 'Il faut paginer le stream Java au lieu de la base', FALSE, 4, 'La pagination n''a de sens qu''au plus près des données.', NULL),
          ('JPA Review : IN de dix mille identifiants', 'IN géant : parsing, limites JDBC, plan dégradé', TRUE, 1, 'Les valeurs volumineuses dépassent les tailles de lot raisonnables.', 'PERFORMANCE'),
          ('JPA Review : IN de dix mille identifiants', 'Découper en lots raisonnables (500-1000) avec fusion des résultats', TRUE, 2, 'Bornage courant des chargements groupés.', 'CODE_QUALITY'),
          ('JPA Review : IN de dix mille identifiants', 'La mémoire du résultat n''est pas bornée non plus', TRUE, 3, 'Liste complète hydratée d''un coup.', 'PERFORMANCE'),
          ('JPA Review : IN de dix mille identifiants', 'findAllById est une API lente par nature : éviter tout IN', FALSE, 4, 'Le souci est la TAILLE du IN, pas l''API.', NULL),
          ('JPA Review : @Lob en EAGER sur une entité listée', 'byte[] en EAGER : le contenu binaire est chargé à chaque liste', TRUE, 1, 'Des Mo × lignes à chaque affichage de noms.', 'PERFORMANCE'),
          ('JPA Review : @Lob en EAGER sur une entité listée', 'Contenu à rendre lazy (ou déplacé hors entité : fichier/BLOB référencé)', TRUE, 2, 'On ne télécharge que lors de la consultation réelle.', 'ARCHITECTURE'),
          ('JPA Review : @Lob en EAGER sur une entité listée', 'La colonne nullable=false ne concerne pas le chargement', TRUE, 3, 'La contrainte porte sur l''existence, pas le fetch — fausse alerte de revue.', 'CODE_QUALITY'),
          ('JPA Review : @Lob en EAGER sur une entité listée', 'Remplacer @Lob par String (text) règle la performance', FALSE, 4, 'Le poids reste : c''est le fetch qui coûte.', NULL),
          ('JPA Review : collection ré-ajoutée à chaque save', 'Accumulation sans reprise de l''état persistant : doublons/inserts redondants', TRUE, 1, 'addAll répété sur une collection non resynchronisée.', 'BUG'),
          ('JPA Review : collection ré-ajoutée à chaque save', 'Remplacer l''état (clear + addAll) ou muter précisément', TRUE, 2, 'La collection reflète alors l''état voulu, pas la somme des éditions.', 'CODE_QUALITY'),
          ('JPA Review : collection ré-ajoutée à chaque save', 'Retraits jamais propagés : sans orphanRemoval/clear, les enfants restent en base', TRUE, 3, 'Édition qui supprime une ligne : la ligne survit en base.', 'BUG'),
          ('JPA Review : collection ré-ajoutée à chaque save', 'Les Set garantissent l''unicité côté Java seulement', TRUE, 4, 'Le Set mémoire empêche le doublon en mémoire — pas les cycles d''édition successifs sur List.', 'CODE_QUALITY'),
          ('JPA Review : toString récursif sur graphe d''entités', 'Graphe cyclique : StackOverflowError au log', TRUE, 1, 'Ligne → commande → lignes → ... sans borne de profondeur.', 'BUG'),
          ('JPA Review : toString récursif sur graphe d''entités', 'Logguer le graphe = fuite de données métier + coût massif', TRUE, 2, 'RGPD et volume : le log devient un miroir de la base.', 'SECURITY'),
          ('JPA Review : toString récursif sur graphe d''entités', 'ToString court (id + clé métier) ou identifiants dans le log', TRUE, 3, 'Diagnostic suffisant sans exploration du graphe.', 'CODE_QUALITY'),
          ('JPA Review : toString récursif sur graphe d''entités', 'Ajouter transient sur la collection résout tout', FALSE, 4, 'Les @Transient servent à l''exclusion JPA — pas au toString généré.', NULL),
          ('JPA Review : TransientObjectException au save', 'Persister un objet transitoire sans cascade = TransientObjectException', TRUE, 1, 'Hibernate ne peut pas deviner sa clé étrangère.', 'BUG'),
          ('JPA Review : TransientObjectException au save', 'Clarifier : champ obligatoire (validation) vs cascade PERSIST si création liée', TRUE, 2, 'Chaque cas a sa sémantique — le null silencieux est le pire.', 'ARCHITECTURE'),
          ('JPA Review : TransientObjectException au save', 'Le null peut passer puis violer une contrainte FK plus tard', TRUE, 3, 'Erreur délocalisée dans le temps — diagnostic lointain.', 'DATABASE'),
          ('JPA Review : TransientObjectException au save', 'Ajouter une annotation @Nullable pour autoriser le null', FALSE, 4, 'Autoriser le vide ne résout pas la persistance du graphe.', NULL)
     ) AS v(title, content, is_correct, ord, expl, sev)
         JOIN challenges c ON c.title = v.title
WHERE NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id AND o.display_order = v.ord);

-- ---------------------------------------------------------------------
-- 3 SEQUENTIAL_REASONING
-- ---------------------------------------------------------------------
INSERT INTO challenges (title, type, selection_type, difficulty, context, question, code_snippet, code_language, explanation, estimated_time_seconds, active, points, created_at, updated_at)
SELECT v.title, v.type, v.selection_type, v.difficulty, v.context, v.question,
       NULLIF(v.snippet, ''), NULLIF(v.lang, ''), v.explanation, v.time, TRUE, v.points,
       CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM (VALUES
('JPA : démarrage refusé par un mapping erroné', 'SEQUENTIAL_REASONING', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Le service ne démarre plus : « Unable to determine appropriate id mapping strategy » / « No path defined » depuis une modification d''entité.',
 'Remets dans l''ordre la procédure de résolution.',
 '',
 '',
 'Lire l''erreur complète (classe + attribut incriminés) → vérifier le mapping déclaré contre le code réel → corriger l''entité (ou le schéma s''il a changé) → redémarrer avec ddl-auto=validate pour confronter le mapping au réel → couvrir par un test qui charge le contexte. L''ordre reverse (changer au hasard) fait perdre le fil.',
 180, 15),
('JPA : livrer entité et schéma sans interruption', 'SEQUENTIAL_REASONING', 'SINGLE_CHOICE', 'ADVANCED',
 'Une nouvelle colonne + champ obligatoire arrive : les instances tournent en ancienne version pendant le déploiement.',
 'Quel ordre de déploiement évite toute coupure ?',
 '',
 '',
 '1) Migration rétrocompatible (colonne nullable ou DEFAULT) applicable AVANT le code. 2) Déployer le code qui lit les DEUX formes (tolérance temporaire) ou remplit la nouvelle colonne. 3) Backfill des données existantes. 4) Durcir (NOT NULL) en migration ultérieure, une fois tout le parc migré. L''ordre inverse (code d''abord, puis migration) provoque des erreurs chez les anciennes instances.',
 240, 25),
('JPA : écran qui charge douze relations', 'SEQUENTIAL_REASONING', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Un écran de suivi met 4 secondes : le log SQL montre autant de requêtes que de lignes affichées (écart sur plusieurs relations lazy).',
 'Quelle est la démarche d''amélioration dans le bon ordre ?',
 '',
 '',
 'Mesurer (log SQL + plan des requêtes réelles) → cartographier les relations réellement affichées sur l''écran → choix : fetch groupé dédié (@EntityGraph/requête) OU projections/DTO ciblant les colonnes affichées → ne plus rien charger « par réflexe » (OSIV off pour rendre les besoins visibles) → mesurer et verrouiller par test de performance. Choisir la technique avant de cartographier produit du fetch global.',
 240, 25)
) AS v(title, type, selection_type, difficulty, context, question, snippet, lang, explanation, time, points)
WHERE NOT EXISTS (SELECT 1 FROM challenges c WHERE c.title = v.title);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.ord, v.expl
FROM (VALUES
('JPA : démarrage refusé par un mapping erroné', 'Lire l''exception complète : elle nomme la classe et l''attribut fautifs', TRUE, 1, 'Le message Hibernate désigne presque toujours la cause exacte.'),
('JPA : démarrage refusé par un mapping erroné', 'Confronter le mapping déclaré au code réel de l''entité', TRUE, 2, 'Attribut renommé/supprimé sans ajuster la JPQL ou le schéma.'),
('JPA : démarrage refusé par un mapping erroné', 'Corriger puis redémarrer avec ddl-auto = validate (contrôle schéma/objet)', TRUE, 3, 'Le contrôle de cohérence réel, pas la génération silencieuse.'),
('JPA : démarrage refusé par un mapping erroné', 'Couvrir d''un test qui charge le contexte Spring', TRUE, 4, 'La régression de mapping se détecte au démarrage du contexte.'),
('JPA : démarrage refusé par un mapping erroné', 'Passer ddl-auto en create pour régénérer le schéma', FALSE, 5, 'Détruit les données de dev/prod : solution hors de propos.'),
('JPA : démarrage refusé par un mapping erroné', 'Ajouter catch(Exception) autour du démarrage', FALSE, 6, 'Absurde : le contexte doit échouer proprement.'),
('JPA : livrer entité et schéma sans interruption', 'Migration rétrocompatible AVANT le déploiement du code', TRUE, 1, 'Les anciennes instances continuent de fonctionner sur la nouvelle base.'),
('JPA : livrer entité et schéma sans interruption', 'Code tolérant aux deux formes pendant la transition', TRUE, 2, 'Lecture possible ancien+nouveau : zéro coupure.'),
('JPA : livrer entité et schéma sans interruption', 'Backfill des données existantes par lots', TRUE, 3, 'La colonne est remplie sans verrou long.'),
('JPA : livrer entité et schéma sans interruption', 'Durcir (NOT NULL) en dernier, une fois le parc migré', TRUE, 4, 'La contrainte ferme le chantier, elle ne l''ouvre pas.'),
('JPA : livrer entité et schéma sans interruption', 'Déployer le code d''abord pour « voir plus vite »', FALSE, 5, 'Anciennes instances = requêtes cassées contre un schéma absent.'),
('JPA : livrer entité et schéma sans interruption', 'Rejeter/transvaser la table en une opération bloquante', FALSE, 6, 'Indisponibilité garantie — hors critère du scénario.'),
('JPA : écran qui charge douze relations', 'Mesurer d''abord : log SQL + temps réels de l''écran', TRUE, 1, 'Identifier quelles requêtes coûtent réellement.'),
('JPA : écran qui charge douze relations', 'Cartographier les relations VRAIMENT affichées par l''écran', TRUE, 2, 'Le périmètre d''affichage décide du fetch — pas l''inverse.'),
('JPA : écran qui charge douze relations', 'Choisir : fetch groupé dédié ou projection DTO des colonnes affichées', TRUE, 3, 'Deux techniques saines selon la forme du rendu.'),
('JPA : écran qui charge douze relations', 'OSIV off pour rendre les besoins de chargement explicites', TRUE, 4, 'Sans session de rendu, les accès lazy impossibles se révèlent.'),
('JPA : écran qui charge douze relations', 'Ajouter EAGER sur toutes les relations pour « sécuriser »', FALSE, 5, 'Agrandit le problème : chaque liste chargera tout le graphe.'),
('JPA : écran qui charge douze relations', 'Cacher la réponse HTTP de l''écran (le coût reste)', FALSE, 6, 'La requête lourde continue d''être payée au premier appel.')
) AS v(title, content, is_correct, ord, expl)
JOIN challenges c ON c.title = v.title
WHERE NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id AND o.display_order = v.ord);

-- ---------------------------------------------------------------------
-- Liens
-- ---------------------------------------------------------------------
INSERT INTO challenge_categories (challenge_id, category_id)
SELECT c.id, cat.id
FROM (VALUES
('JPA : l''id n''est renseigné qu''après le flush','JPA / Hibernate'),
('JPA : « No path defined » dans une requête JPQL','JPA / Hibernate'),
('JPA : enum stocké en ORDINAL','JPA / Hibernate'),
('JPA : entités dans un HashSet','JPA / Hibernate'),
('JPA : entité détachée modifiée sans effet','JPA / Hibernate'),
('JPA : états d''entité — réattacher un objet','JPA / Hibernate'),
('JPA : suppression par retrait de collection','JPA / Hibernate'),
('JPA : insertions massives sans batch','JPA / Hibernate'),
('JPA : flush automatique inopiné','JPA / Hibernate'),
('JPA : pagination avec jointures fetchées','JPA / Hibernate'),
('JPA : clé de jointure supplémentaire en ManyToMany','JPA / Hibernate'),
('JPA : Open Session in View','JPA / Hibernate'),
('JPA : requête native contre JPQL','JPA / Hibernate'),
('JPA : cascade REMOVE sur un objet partagé','JPA / Hibernate'),
('JPA : association bidirectionnelle — quel côté porte la clé','JPA / Hibernate'),
('JPA : traiter un volume sans tout charger','JPA / Hibernate'),
('JPA : horodatages en base et en Java','JPA / Hibernate'),
('JPA : ordre d''insertion et clés étrangères','JPA / Hibernate'),
('JPA : cache de second niveau et données périmées','JPA / Hibernate'),
('JPA : séquences et batch — hi-lo','JPA / Hibernate'),
('JPA : verrou pessimiste piloté par JPA','JPA / Hibernate'),
('JPA : sortir d''un mapping « tout en EAGER »','JPA / Hibernate'),
('JPA : modèle dupliqué entre deux contextes','Architecture'),
('JPA : graphe bidirectionnel qui double les écritures','JPA / Hibernate'),
('JPA Review : filtre métier en Java sur findAll','JPA / Hibernate'),
('JPA Review : IN de dix mille identifiants','JPA / Hibernate'),
('JPA Review : @Lob en EAGER sur une entité listée','JPA / Hibernate'),
('JPA Review : collection ré-ajoutée à chaque save','JPA / Hibernate'),
('JPA Review : toString récursif sur graphe d''entités','JPA / Hibernate'),
('JPA Review : TransientObjectException au save','JPA / Hibernate'),
('JPA : démarrage refusé par un mapping erroné','JPA / Hibernate'),
('JPA : livrer entité et schéma sans interruption','JPA / Hibernate'),
('JPA : écran qui charge douze relations','JPA / Hibernate'),
('JPA : tri dynamique depuis un paramètre utilisateur','JPA / Hibernate')
) AS v(title, cat)
JOIN challenges c ON c.title = v.title
JOIN categories cat ON cat.name = v.cat
WHERE NOT EXISTS (SELECT 1 FROM challenge_categories cc WHERE cc.challenge_id = c.id AND cc.category_id = cat.id);

INSERT INTO challenge_skills (challenge_id, skill_id)
SELECT c.id, s.id
FROM (VALUES
('JPA : l''id n''est renseigné qu''après le flush','Debugging'),
('JPA : « No path defined » dans une requête JPQL','Debugging'),
('JPA : enum stocké en ORDINAL','Code Quality'),
('JPA : entités dans un HashSet','Debugging'),
('JPA : entité détachée modifiée sans effet','Debugging'),
('JPA : états d''entité — réattacher un objet','Problem Solving'),
('JPA : suppression par retrait de collection','Problem Solving'),
('JPA : insertions massives sans batch','Performance Analysis'),
('JPA : flush automatique inopiné','Problem Solving'),
('JPA : pagination avec jointures fetchées','Performance Analysis'),
('JPA : clé de jointure supplémentaire en ManyToMany','Code Quality'),
('JPA : Open Session in View','Performance Analysis'),
('JPA : requête native contre JPQL','Code Quality'),
('JPA : cascade REMOVE sur un objet partagé','Code Quality'),
('JPA : association bidirectionnelle — quel côté porte la clé','Debugging'),
('JPA : traiter un volume sans tout charger','Performance Analysis'),
('JPA : horodatages en base et en Java','Code Quality'),
('JPA : ordre d''insertion et clés étrangères','Problem Solving'),
('JPA : cache de second niveau et données périmées','Problem Solving'),
('JPA : séquences et batch — hi-lo','Performance Analysis'),
('JPA : verrou pessimiste piloté par JPA','Problem Solving'),
('JPA : sortir d''un mapping « tout en EAGER »','Performance Analysis'),
('JPA : modèle dupliqué entre deux contextes','Problem Solving'),
('JPA : graphe bidirectionnel qui double les écritures','Code Quality'),
('JPA Review : filtre métier en Java sur findAll','Performance Analysis'),
('JPA Review : IN de dix mille identifiants','Performance Analysis'),
('JPA Review : @Lob en EAGER sur une entité listée','Performance Analysis'),
('JPA Review : collection ré-ajoutée à chaque save','Debugging'),
('JPA Review : toString récursif sur graphe d''entités','Code Quality'),
('JPA Review : TransientObjectException au save','Debugging'),
('JPA : démarrage refusé par un mapping erroné','Debugging'),
('JPA : livrer entité et schéma sans interruption','Problem Solving'),
('JPA : écran qui charge douze relations','Performance Analysis'),
('JPA : tri dynamique depuis un paramètre utilisateur','Code Quality')
) AS v(title, skill)
JOIN challenges c ON c.title = v.title
JOIN skills s ON s.name = v.skill
WHERE NOT EXISTS (SELECT 1 FROM challenge_skills cs WHERE cs.challenge_id = c.id AND cs.skill_id = s.id);

INSERT INTO challenge_profiles (challenge_id, profile_id)
SELECT c.id, p.id
FROM (VALUES
('JPA : l''id n''est renseigné qu''après le flush'),('JPA : « No path defined » dans une requête JPQL'),
('JPA : enum stocké en ORDINAL'),('JPA : entités dans un HashSet'),
('JPA : entité détachée modifiée sans effet'),('JPA : états d''entité — réattacher un objet'),
('JPA : suppression par retrait de collection'),('JPA : insertions massives sans batch'),
('JPA : flush automatique inopiné'),('JPA : pagination avec jointures fetchées'),
('JPA : clé de jointure supplémentaire en ManyToMany'),('JPA : Open Session in View'),
('JPA : requête native contre JPQL'),('JPA : cascade REMOVE sur un objet partagé'),
('JPA : association bidirectionnelle — quel côté porte la clé'),('JPA : traiter un volume sans tout charger'),
('JPA : horodatages en base et en Java'),('JPA : ordre d''insertion et clés étrangères'),
('JPA : cache de second niveau et données périmées'),('JPA : séquences et batch — hi-lo'),
('JPA : verrou pessimiste piloté par JPA'),('JPA : sortir d''un mapping « tout en EAGER »'),
('JPA : modèle dupliqué entre deux contextes'),('JPA : graphe bidirectionnel qui double les écritures'),
('JPA Review : filtre métier en Java sur findAll'),('JPA Review : IN de dix mille identifiants'),
('JPA Review : @Lob en EAGER sur une entité listée'),('JPA Review : collection ré-ajoutée à chaque save'),
('JPA Review : toString récursif sur graphe d''entités'),('JPA Review : TransientObjectException au save'),
('JPA : démarrage refusé par un mapping erroné'),('JPA : livrer entité et schéma sans interruption'),
('JPA : écran qui charge douze relations'),
('JPA : tri dynamique depuis un paramètre utilisateur')
) AS v(title)
JOIN challenges c ON c.title = v.title
JOIN profiles p ON p.code = 'DEVELOPER'
WHERE NOT EXISTS (SELECT 1 FROM challenge_profiles cp WHERE cp.challenge_id = c.id AND cp.profile_id = p.id);
