-- =====================================================================
-- Catalogue V1 — Pilier JAVA (profil DEVELOPER)
-- 29 SITUATIONAL_QCM + 4 PROBLEM_SOLVING + 6 CODE_REVIEW + 6 SEQUENTIAL = 45
-- Idempotence : WHERE NOT EXISTS (title) + NOT EXISTS par option/liens.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 29 QCM
-- ---------------------------------------------------------------------
INSERT INTO challenges (title, type, selection_type, difficulty, context, question, code_snippet, code_language, explanation, estimated_time_seconds, active, points, created_at, updated_at)
SELECT v.title, v.type, v.selection_type, v.difficulty, v.context, v.question,
       NULLIF(v.snippet, ''), NULLIF(v.lang, ''), v.explanation, v.time, TRUE, v.points,
       CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM (VALUES
-- JUNIOR (9)
('ConcurrentModificationException dans une boucle', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'JUNIOR',
 'Tu parcours une List<String> pour supprimer les éléments vides d''un formulaire.',
 'Tu utilises un for-each et list.remove(s) quand s est vide, et tu obtiens une ConcurrentModificationException. Quelle est la correction correcte ?',
 '',
 '',
 'La modification pendant l''itération est interdite sur une ArrayList : il faut utiliser l''itérateur (it.remove()) ou une copie filtrée (list.removeIf(String::isEmpty)).',
 90, 10),
('Clé introuvable dans la HashMap', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'JUNIOR',
 'Tu mets un objet UserKey dans une HashMap et get() renvoie null alors que la clé y a bien été ajoutée.',
 'Quelle est la cause la plus probable ?',
 '',
 '',
 'Sans equals() et hashCode() cohérents, la HashMap utilise l''identité d''objet : la clé mise et la clé recherchée sont deux instances différentes, donc deux emplacements distincts. Les surcharger de façon cohérente (et @Override) résout le problème.',
 120, 15),
('Comparaison de jetons de session avec ==', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'JUNIOR',
 'Un test compare deux String reçues de sources différentes : if (token == expectedToken). Ça marche en dev, pas en prod.',
 'Pourquoi ce code est-il dangereux malgré des tests verts ?',
 '',
 '',
 '== compare des références, pas le contenu. La comparaison ne fonctionne que lorsque le compilateur ou la JVM intern les chaînes. En prod, les chaînes proviennent de flux différents : il faut equals().',
 90, 10),
('Fichier jamais fermé après une exception', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'JUNIOR',
 'Ton code lit un fichier avec new BufferedReader(new FileReader(f)) et le ferme dans un finally... sauf si la construction du BufferedReader échoue.',
 'Quelle forme de code garantit la fermeture dans tous les cas ?',
 '',
 '',
 'try-with-resources : la ressource déclarée dans le try est fermée automatiquement, même si le constructeur suivant lève une exception, et l''exception d''origine est préservée (addSuppressed).',
 90, 10),
('NullPointerException sur une comparaison', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'JUNIOR',
 'Dans ton service, Integer nb = map.get(cle); if (nb == 0) {...} plante quand la clé est absente.',
 'Pourquoi cette ligne plante-t-elle alors que == ne devrait pas déréférencer ?',
 '',
 '',
 'nb == 0 force le déboîtage (auto-unboxing) de Integer en int : si nb est null, Java tente d''appeler nb.intValue() et lève une NullPointerException. Il faut d''abord vérifier nb != null.',
 90, 10),
('Total tronqué dans un rapport', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'JUNIOR',
 'Un écran affiche « moyenne : 2 » alors que la moyenne réelle est 2.75. Le calcul est fait avec int total / int nombre.',
 'Que se passe-t-il et comment corriger proprement ?',
 '',
 '',
 'La division entre deux int tronque la partie décimale : 11 / 4 vaut 2, pas 2.75. Il faut caster au moins un operande en double (double moyenne = (double) total / nombre) avant la division.',
 90, 10),
('Collections final non modifiable ?', 'SITUATIONAL_QCM', 'MULTIPLE_CHOICE', 'JUNIOR',
 'Une méthode déclare private final List<String> tags = new ArrayList<>();',
 'Quelles affirmations sont exactes ?',
 '',
 '',
 'final fige la RÉFÉRENCE, pas le contenu : on peut toujours ajouter ou retirer des éléments. En revanche, la liste reste accessible à tout code recevant l''objet (fuite d''état si elle est exposée) — défensive copy recommandée à la frontière.',
 120, 15),
('UnsupportedOperationException inattendu', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'JUNIOR',
 'Tu remplaces Arrays.asList(...) par List.of(...) et ton code plante à la ligne tags.add("x").',
 'Quelle différence de comportement explique la rupture ?',
 '',
 '',
 'Arrays.asList renvoie une liste à taille fixe mais modifiable par set(), alors que List.of renvoie une immutable list : toute tentative d''ajout ou de modification lève UnsupportedOperationException. Choisis selon l''intention : vue figée ou liste de travail.',
 90, 10),
('Surcharge résolue à la compilation', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'JUNIOR',
 'Tu as deux méthodes : process(int n) et process(Integer n). Tu appelles process(null) dans un utilitaire de test.',
 'Que fait la JVM et pourquoi ?',
 '',
 '',
 'La résolution des surcharges (overload) est statique : process(null) ne correspond qu''à process(Integer) (null n''est pas un int), et l''autre méthode n''est jamais candidate. Attention aussi aux boîtes automatiques quand la valeur est 0 : process(int) gagne.',
 120, 15),
-- INTERMEDIATE (14)
('SimpleDateFormat partagé entre threads', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Un formatter statique SimpleDateFormat est utilisé parallèlement : des dates ressortent décalées ou corrompues sans exception.',
 'Quelle est la cause racine et le remède ?',
 '',
 '',
 'SimpleDateFormat est mutable et non thread-safe : deux threads modifient simultanément son état interne. Remède : DateTimeFormatter (immuable) ou un format par thread (ThreadLocal).',
 120, 15),
('Flag de coordination entre threads', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Un thread d''arrière-plan écrit running = false ; le thread principal tourne en while (running) et ne s''arrête jamais, sans exception.',
 'Quel mécanisme minimal garantit la visibilité de l''écriture ?',
 '',
 '',
 'Sans synchronisation, rien ne garantit que le thread principal voie l''écriture du flag (optimisation de cache CPU / mémoire non ordonnée). Déclarer le champ volatile impose la lecture/écriture en mémoire principale.',
 120, 15),
('Double-checked locking instable', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Un singleton utilise le pattern double-checked locking avec un champ instance non volatile.',
 'Pourquoi le pattern peut-il renvoyer un objet partiellement initialisé ?',
 '',
 '',
 'Sans volatile, la JVM peut réordonner l''affectation de l''instance et l''initialisation du constructeur : un autre thread passe le second contrôle et lit un objet dont le constructeur n''est pas terminé. volatile (ou holder idiom) interdit cette réordonnance.',
 180, 20),
('Deadlock sur deux verrous', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Deux threads verrouillent successivement compte puis ledger dans l''ordre inverse : l''application gèle par intermittence.',
 'Quelle prévention est la plus fiable ?',
 '',
 '',
 'Imposer un ordre d''acquisition unique (toujours compte puis ledger, sous une classe d''ordre) élimine le cycle d''attente circulaire. Réduire la portée des verrous aide, mais sans ordre commun le deadlock reste possible.',
 120, 15),
('wait() hors boucle de condition', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Un producteur appelle queue.wait() quand la file est pleine, puis reprend après notifyAll(). Des pertes d''éléments restent possibles.',
 'Quelle structure est correcte ?',
 '',
 '',
 'Toujours attendre dans une boucle while (!condition) : wait() peut retourner (interrupt, faux réveil, notify d''un autre état). La re-vérification de la condition dans la boucle évite de reprendre dans un état invalide.',
 120, 15),
('Optional : orElse coûteux', 'SITUATIONAL_QCM', 'MULTIPLE_CHOICE', 'INTERMEDIATE',
 'Config config = Optional.ofNullable(cache.get(cle)).orElse(chargerDepuisDisque());',
 'Quelles affirmations sont exactes ?',
 '',
 '',
 'L''argument d''orElse est évalué AVANT l''appel, même quand la valeur est présente : le chargement disque a lieu à chaque fois. orElseGet prend un fournisseur paresseux. D''ailleurs, sur une Map, getOrDefault ou computeIfAbsent exprime mieux l''intention.',
 120, 15),
('Stream jamais exécuté', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Une classe construit un stream, y ajoute des filtres... et aucun résultat n''apparaît dans le log. Aucune erreur.',
 'Expliquez le comportement et la correction.',
 '',
 '',
 'Les opérations intermédiaires sont paresseuses : sans opération terminale (collect, forEach, count...), rien ne s''exécute. Ajouter une opération terminale déclenche la chaîne ; retenir qu''un stream est jetable (une seule terminale).',
 120, 15),
('Récupérer un résultat depuis un thread', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Tu lances une tâche calcul total et tu as besoin du résultat et des exceptions dans le thread appelant.',
 'Quelle abstraction choisir ?',
 '',
 '',
 'Callable + ExecutorService.submit rend un Future : get() récupère le résultat et remet l''exception de la tâche (ExecutionException). Runnable ne renvoie ni résultat ni exception ; Thread + wait/notify serait un réinventage fragile.',
 120, 15),
('thenApply ou thenCompose', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Tu enchaînes deux appels asynchrones : CompletableFuture<User> puis un service retourne CompletableFuture<Orders>.',
 'Quelle différence de forme et de résultat entraîne le choix des deux méthodes ?',
 '',
 '',
 'thenApply sur une fonction synchrone donne un CompletableFuture<CompletableFuture<Orders>> (obligé de déplier à la main) ; thenCompose (monadique) relie directement les deux étapes asynchrones en une seule chaîne plate.',
 120, 15),
('Exception avalée par exceptionally', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Une chaîne CompletableFuture utilise exceptionally(e -> valeurParDefaut) : le fallback fonctionne, mais le ticket d''incident n''a aucune trace de l''erreur d''origine.',
 'Quelle est la bonne pratique ?',
 '',
 '',
 'Le gestionnaire de repli doit journaliser l''exception (e.printStackTrace() ne suffit pas) avant de renvoyer une valeur par défaut, ou utiliser handle() pour observer sans masquer. Un fallback silencieux transforme une panne visible en dégradation invisible.',
 120, 15),
('Exception checked : quelle politique', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Une méthode valide un montant et peut échouer. Le code déclare throws Exception partout et les appelants catch (Exception e) { }.',
 'Quelle conception Java est préférable ?',
 '',
 '',
 'Des exceptions métiers runtime typées (IllegalArgumentException / DomainException) documentées, propagées seulement là où on sait traiter. Catcher Exception en amont avale tout (y compris OOM/bugs) et noie le vrai problème.',
 120, 15),
('Cache LRU en mémoire', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Tu dois garder les 500 derniers résultats de recherche : insertion/accès fréquents, éjection de la plus ancienne non utilisée.',
 'Quelle structure Java te donne cela sans bibliothèque externe ?',
 '',
 '',
 'LinkedHashMap en mode accessOrder=true avec removeEldestEntry() : elle préserve l''ordre d''insertion OU d''accès et permet d''éjecter la plus ancienne. HashMap seul ne conserve aucun ordre, TreeMap impose un ordre de tri inutile ici.',
 120, 15),
('Identifiants > 127 comparés avec ==', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'if (orderId == 128) fonctionne pour les petits ids mais échoue pour certaines commandes en production.',
 'Quel mécanisme Java explique ce comportement ?',
 '',
 '',
 'Le cache d''Integer de la JVM ne couvre que -128 à 127 : au-delà, == compare des références différentes. C''est un bug classique « ça marche en dev ». Toujours equals() sur les types objets.',
 120, 15),
('ClassCastException malgré des génériques', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Une classe utilise des cast bruts (raw types) quelque part : la compilation passe, mais un ClassCastException tombe à l''exécution au détour d''une boucle.',
 'Pourquoi les génériques n''ont-ils pas protégé ?',
 '',
 '',
 'Les génériques sont effacés à la compilation (type erasure) : seule la vérification compile-time protège. Un cast brut court-circuite cette vérification, et la vérification réelle n''a lieu qu''au moment de la désérialisation/l''accès.',
 120, 15),
-- ADVANCED (6)
('Publication non sûre d''un objet mutable', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'ADVANCED',
 'Un service crée un état dans le constructeur et le publie via this dans un registre statique : d''autres threads voient des champs à moitié initialisés, sans exception.',
 'Quel mécanisme de la mémoire des threads est en cause ?',
 '',
 '',
 'La fuite de this hors du constructeur permet à d''autres threads de lire l''objet avant la fin de son initialisation (réordonnancement + pas de garantie de visibilité). Remèdes : publication immuable (champs finaux), initialisation lazy en statique, ou construction entière avant publication.',
 180, 20),
('ThreadLocal dans un pool de threads', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'ADVANCED',
 'Une application serveur stocke le contexte utilisateur dans un ThreadLocal. Après plusieurs heures, la mémoire monte et des données d''un utilisateur apparaissent... chez un autre.',
 'Quelle est la double cause du problème ?',
 '',
 '',
 'Les threads du pool sont réutilisés et le ThreadLocal n''est jamais vidé : d''une part fuite mémoire (données jamais relâchées), d''autre part contamination de contexte entre requêtes. remove() en finally est obligatoire dans un pool.',
 180, 20),
('Record apparemment immuable', 'SITUATIONAL_QCM', 'MULTIPLE_CHOICE', 'ADVANCED',
 'Un record Stats contient int[] values. Le constructeur fait this.values = values;',
 'Quelles affirmations sont exactes ?',
 '',
 '',
 'Un record fige les références, pas les objets pointés : le tableau reste modifiable par l''appelant (fuite d''état) et le record cesse d''être immuable. Copie défensive (values.clone()) en entrée ET en sortie, sinon equals/hashCode aussi deviennent instables.',
 180, 20),
('LinkedList plus rapide qu''ArrayList ?', 'SITUATIONAL_QCM', 'MULTIPLE_CHOICE', 'ADVANCED',
 'Après un benchmark naïf, un développeur affirme qu''il faut préférer LinkedList « car insertion en O(1) » pour un parcours intensif.',
 'Quelles affirmations corrigent ce raisonnement ?',
 '',
 '',
 'O(1) porte sur l''insertion en tête (après avoir navigué au bon endroit, sinon O(n)), et chaque nœud = allocation + pointeur : LinkedList est quasi toujours plus lent en pratique (localité de cache nulle) sauf insertions/validation au milieu fréquentes. Benchmark réaliste obligatoire.',
 180, 20),
('parallelStream en environnement serveur', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'ADVANCED',
 'Un endpoint applique parallelStream() sur une liste partagée, avec des écritures dans un accumulator non thread-safe. Quelques réponses sont corrompues sans exception.',
 'Quel est le problème le plus probable et le risque systémique ?',
 '',
 '',
 'Écriture concurrente non synchronisée = course (résultats partiels perdus) ; par ailleurs parallelStream utilise le pool commun ForkJoinPool, partagé avec le reste du serveur : la saturation d''un endpoint peut ralentir tous les autres. Limiter aux traitements purs et bornés.',
 180, 20),
('allOf et la première exception', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'ADVANCED',
 'Trois CompletableFuture sont combinés par allOf ; whenComplete réagit en échec dès qu''une tâche échoue, même si les deux autres réussissent.',
 'Quel comportement de allOf est responsable et comment obtenir un résultat partiel utile ?',
 '',
 '',
 'allOf est fail-fast : le premier échec met le combiné en exception, les autres tâches continuent mais leur résultat devient inaccessible via ce combiné. Pour un traitement partiel, chaque future doit gérer son propre exceptionally et être agrégée ensuite.',
 180, 20)
     ) AS v(title, type, selection_type, difficulty, context, question, snippet, lang, explanation, time, points)
WHERE NOT EXISTS (SELECT 1 FROM challenges c WHERE c.title = v.title);

-- Options des QCM (5 colonnes)
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.ord, v.expl
FROM (VALUES
          ('ConcurrentModificationException dans une boucle', 'Retirer avec list.remove(o) dans le for-each', FALSE, 1, 'C''est exactement ce qui provoque l''exception : l''itérateur détecte la modification de structure.'),
          ('ConcurrentModificationException dans une boucle', 'Parcourir avec un itérateur et appeler it.remove()', TRUE, 2, 'La suppression via l''itérateur prévient la ArrayList, l''itération reste valide.'),
          ('ConcurrentModificationException dans une boucle', 'Synchroniser la liste avec Collections.synchronizedList', FALSE, 3, 'Le verrou ne protège pas l''itération : l''exception vient de l''itérateur, pas des threads.'),
          ('ConcurrentModificationException dans une boucle', 'Copier la liste dans un nouveau ArrayList puis parcourir la copie', TRUE, 4, 'Solution simple et sûre ; removeIf(String::isEmpty) fait encore mieux en une ligne.'),
          ('Clé introuvable dans la HashMap', 'La HashMap a été instanciée avec une capacité trop faible', FALSE, 1, 'La capacité ne change que les performances, jamais la localisation sémantique d''une clé.'),
          ('Clé introuvable dans la HashMap', 'equals() et hashCode() ne sont pas surchargés ou sont incohérents', TRUE, 2, 'Sans égalité de valeur, la clé est « une autre » : le bucket visité diffère de celui de l''insertion.'),
          ('Clé introuvable dans la HashMap', 'Il faut appeler HashMap.rehash() manuellement', FALSE, 3, 'Le recalcul interne est automatique ; il ne dépend que de hashCode().'),
          ('Clé introuvable dans la HashMap', 'La clé est null, ce qui est interdit dans une HashMap', FALSE, 4, 'HashMap accepte une clé null (bucket 0) ; le symptôme décrit n''est pas celui-ci.'),
          ('Comparaison de jetons de session avec ==', '== compare le contenu des String en Java moderne', FALSE, 1, '== compare toujours les références ; le contenu se compare avec equals().'),
          ('Comparaison de jetons de session avec ==', 'Les String literals sont internés : == ne marche que sur les littéraux', TRUE, 2, 'C''est la raison du « ça marche en dev » : les chaînes constantes partagent la même référence.'),
          ('Comparaison de jetons de session avec ==', 'equals() est trop lent pour des jetons courts', FALSE, 3, 'La différence est négligeable ; la correction du résultat prime.'),
          ('Comparaison de jetons de session avec ==', 'Il faut utiliser intern() avant chaque comparaison', FALSE, 4, 'La surcharge du pool de chaînes aggraverait la mémoire sans garantir la correction.'),
          ('Fichier jamais fermé après une exception', 'Fermer dans un bloc finally après le try', FALSE, 1, 'Seulement si la ressource a été créée AVANT le try ; sinon elle ne correspond pas à la variable du finally.'),
          ('Fichier jamais fermé après une exception', 'try (BufferedReader br = new BufferedReader(new FileReader(f))) { ... }', TRUE, 2, 'try-with-resources ferme dans tous les cas, y compris si une construction ultérieure échoue.'),
          ('Fichier jamais fermé après une exception', 'Ajouter un catch (IOException e) { } pour fermer en cas d''erreur', FALSE, 3, 'Attraper l''exception ne ferme rien et détruit l''information d''erreur.'),
          ('Fichier jamais fermé après une exception', 'Attendre le GC : il ferme les flux', FALSE, 4, 'Un finalizer ne garantit ni le timing ni l''existence de la libération (et est déconseillé).'),
          ('NullPointerException sur une comparaison', 'Le déboîtage (unboxing) appelle intValue() sur un Integer null', TRUE, 1, 'nb == 0 impose une conversion en int : le null provoque la NullPointerException.'),
          ('NullPointerException sur une comparaison', '== provoque toujours une NullPointerException sur Integer', FALSE, 2, 'Comparé à un objet (nb == null) cela ne plante pas ; c''est la comparaison à un primitive qui déboîte.'),
          ('NullPointerException sur une comparaison', 'La variable nb est déclarée final', FALSE, 3, 'final n''a aucun lien avec le déboîtage ni avec le null.'),
          ('NullPointerException sur une comparaison', 'map.get() lève l''exception quand la clé est absente', FALSE, 4, 'get() renvoie null ; c''est l''utilisation en aval qui plante.'),
          ('Total tronqué dans un rapport', 'Java arrondit automatiquement les divisions entières', FALSE, 1, 'Il tronque (partie entière inférieure en valeur absolue), il n''arrondit jamais.'),
          ('Total tronqué dans un rapport', 'La division int/int supprime la partie décimale', TRUE, 2, '11 / 4 vaut 2 : le cast en double DOIT avoir lieu avant la division.'),
          ('Total tronqué dans un rapport', 'Le format d''affichage (DecimalFormat) est mal configuré', FALSE, 3, 'La valeur calculée est déjà fausse : corriger le calcul avant l''affichage.'),
          ('Total tronqué dans un rapport', 'Il faut utiliser BigDecimal pour toute division', FALSE, 4, 'BigDecimal est utile pour la monnaie, mais un simple cast en double suffit pour une moyenne.'),
          ('Collections final non modifiable ?', 'final empêche tout ajout dans la liste', FALSE, 1, 'final fige la référence de la variable, pas le contenu de l''objet.'),
          ('Collections final non modifiable ?', 'La référence ne peut être réassignée, mais le contenu reste modifiable', TRUE, 2, 'tags = new ArrayList<>() est interdit ; tags.add(...) reste parfaitement possible.'),
          ('Collections final non modifiable ?', 'La liste est automatiquement exposée en lecture seule aux appelants', FALSE, 3, 'L''encapsulation ne vient que de getTags() : exposez Collections.unmodifiableList ou une copie.'),
          ('Collections final non modifiable ?', 'final remplace synchronized pour sécuriser la liste', FALSE, 4, 'final ne dit rien de la concurrence ; il faut verrouiller ou utiliser une structure adaptée.'),
          ('UnsupportedOperationException inattendu', 'List.of refuse toute mutation, Arrays.asList accepte set()', TRUE, 1, 'Deux contrats différents : liste immuable vs liste à taille fixe.'),
          ('UnsupportedOperationException inattendu', 'Arrays.asList est déprécié depuis Java 9', FALSE, 2, 'Toujours utilisable ; c''est son contrat de taille fixe qui est souvent mal compris.'),
          ('UnsupportedOperationException inattendu', 'List.of ne supporte pas les éléments null', TRUE, 3, 'Détail important : List.of rejette null — utile pour forcer des valeurs non nulles.'),
          ('UnsupportedOperationException inattendu', 'Le problème vient du type générique String', FALSE, 4, 'Le type est sans effet sur la mutabilité de la liste.'),
          ('Surcharge résolue à la compilation', 'JVM choisit process(int) car null se convertit en 0', FALSE, 1, 'Null n''est pas convertible en int : aucune conversion ne s''applique.'),
          ('Surcharge résolue à la compilation', 'Seule process(Integer) est candidat : la résolution est statique', TRUE, 2, 'L''overloading se résout à la compilation selon les types déclarés ; null correspond à Integer.'),
          ('Surcharge résolue à la compilation', 'Les deux méthodes s''exécutent, la dernière gagne', FALSE, 3, 'Une seule overload est compilée dans le bytecode appelé.'),
          ('Surcharge résolue à la compilation', 'Java lance un error au chargement de la classe', FALSE, 4, 'Aucun conflit d''appel n''est détectable à l''exécution : le choix est fixé à la compilation.'),
          ('SimpleDateFormat partagé entre threads', 'SimpleDateFormat n''est pas thread-safe : son état interne est muté', TRUE, 1, 'Le parseur conserve un calendrier mutable ; deux threads l''écrasent mutuellement.'),
          ('SimpleDateFormat partagé entre threads', 'La zone horaire du serveur change pendant le traitement', FALSE, 2, 'Le symptôme (dates corrompues sans exception) est propre à la course sur l''état du formatter.'),
          ('SimpleDateFormat partagé entre threads', 'Il faut synchroniser chaque appel sur le formatter', FALSE, 3, 'Possible mais sérialise tout le service ; DateTimeFormatter immuable est supérieur.'),
          ('SimpleDateFormat partagé entre threads', 'Il faut créer une Date à chaque appel', FALSE, 4, 'La Date n''est pas le problème : c''est l''objet formatage partagé.'),
          ('Flag de coordination entre threads', 'volatile garantit la visibilité de l''écriture entre threads', TRUE, 1, 'volatile impose écritures en mémoire principale et interdit les réordonnances autour.'),
          ('Flag de coordination entre threads', 'Synchroniser la méthode qui lit le flag', FALSE, 2, 'Possible, mais coûteux et le bloc de lecture devrait alors aussi être verrouillé — volatile est l''outil prévu.'),
          ('Flag de coordination entre threads', 'Le compilateur optimise la boucle while : il faut Thread.sleep', FALSE, 3, 'sleep ne crée aucune garantie de mémoire ; la cause est l''absence de happens-before.'),
          ('Flag de coordination entre threads', 'Il faut déclarer le champ static', FALSE, 4, 'static ne change rien à la visibilité entre threads.'),
          ('Double-checked locking instable', 'Sans volatile, l''initialisation peut être réordonnée par rapport à l''affectation', TRUE, 1, 'Un thread peut observer une référence non null pointant vers un objet non construit.'),
          ('Double-checked locking instable', 'Le second if est inutile et provoque un deadlock', FALSE, 2, 'Il est nécessaire (coût d''acquisition du verrou) et n''est pas une source de blocage.'),
          ('Double-checked locking instable', 'Seuls les int sont concernés par le réordonnancement', FALSE, 3, 'Les références d''objets concernées autant, sinon davantage.'),
          ('Double-checked locking instable', 'Il faut appeler System.gc() après l''initialisation', FALSE, 4, 'Le GC n''a aucun rôle dans la publication d''objet entre threads.'),
          ('Deadlock sur deux verrous', 'Imposer un ordre global d''acquisition des verrous', TRUE, 1, 'Sans cycle d''attente circulaire, le deadlock est structurellement impossible.'),
          ('Deadlock sur deux verrous', 'Remplacer synchronized par un pool de threads plus grand', FALSE, 2, 'Plus de threads ne fait qu''augmenter la probabilité de collision.'),
          ('Deadlock sur deux verrous', 'Ajouter un timeout sur synchronized', FALSE, 3, 'synchronized n''accepte pas de timeout : ReentrantLock.tryLock() oui, mais l''ordre reste la vraie prévention.'),
          ('Deadlock sur deux verrous', 'Exécuter les deux verrouillages dans le thread principal', FALSE, 4, 'La sérialisation totale supprime le débit — prévention ≠ annulation de la concurrence.'),
          ('wait() hors boucle de condition', 'while (!condition) { queue.wait(); } puis notifyAll()', TRUE, 1, 'La boucle re-vérifie la condition : faux réveils et interruptions ne passent pas.'),
          ('wait() hors boucle de condition', 'if (!condition) { queue.wait(); } pour éviter les réveils inutiles', FALSE, 2, 'if ne re-vérifie pas : un retour (sans réveil légitime) reprend dans un état invalide.'),
          ('wait() hors boucle de condition', 'Appeler wait() sans synchronized', FALSE, 3, 'wait() exige le verrou de l''objet ; sinon IllegalMonitorStateException.'),
          ('wait() hors boucle de condition', 'Remplacer wait() par un sleep de 100 ms', FALSE, 4, 'Polling aveugle : gaspille du CPU et ne résout pas la condition partagée.'),
          ('Optional : orElse coûteux', 'orElse évalue son argument même si la valeur est présente', TRUE, 1, 'Argument passé avant appel : le chargement disque a lieu à chaque fois.'),
          ('Optional : orElse coûteux', 'orElseGet diffère uniquement par sa signature', FALSE, 2, 'Il diffère par la paresse : Supplier évalué seulement si vide.'),
          ('Optional : orElse coûteux', 'Sur une Map, computeIfAbsent évite même l''appel quand la clé existe', TRUE, 3, 'C''est la solution la plus directe : une seule passe, aucune évaluation inutile.'),
          ('Optional : orElse coûteux', 'Optional ne doit jamais être utilisé avec une Map', FALSE, 4, 'Rien d''interdit — c''est l''impatience d''orElse le piège, pas Optional lui-même.'),
          ('Stream jamais exécuté', 'Il manque une opération terminale : la chaîne reste paresseuse', TRUE, 1, 'filter/map ne s''exécutent qu''au déclenchement par collect, forEach, count...'),
          ('Stream jamais exécuté', 'Le stream est fermé automatiquement après 5 secondes', FALSE, 2, 'Aucun délai du genre : il attend indéfiniment une terminale.'),
          ('Stream jamais exécuté', 'filter() ignore les éléments par défaut', FALSE, 3, 'Aucun filtre ne tourne tant que rien ne déclenche la chaîne.'),
          ('Stream jamais exécuté', 'Il faut appeler stream.parallel() pour l''activer', FALSE, 4, 'Le parallélisme ne déclenche pas plus l''exécution que le séquentiel.'),
          ('Récupérer un résultat depuis un thread', 'Callable soumis à ExecutorService, résultat via Future.get()', TRUE, 1, 'get() rend le résultat et remet les exceptions sous ExecutionException.'),
          ('Récupérer un résultat depuis un thread', 'Runnable avec un champ partagé résultat', FALSE, 2, 'Possible mais réinvente Future avec toute la gestion des races et de la mémoire.'),
          ('Récupérer un résultat depuis un thread', 'Thread.start() puis lecture immédiate du champ', FALSE, 3, 'Aucune attente ni garantie de visibilité : lecture opportuniste.'),
          ('Récupérer un résultat depuis un thread', 'ForkJoinPool.commonPool().execute()', FALSE, 4, 'execute ne renvoie pas de Future de résultat ; submit si, mais la réponse attendue est Callable + get.'),
          ('thenApply ou thenCompose', 'thenApply produit un CompletableFuture imbriqué à déplier', TRUE, 1, 'Fonction synchrone sur valeur : le résultat s''emboîte — puisque la fonction renvoie déjà un future, on obtient un double niveau.'),
          ('thenApply ou thenCompose', 'thenCompose est l''équivalent monadique de l''enchaînement asynchrone', TRUE, 2, 'Il « aplatit » la composition : une chaîne plate, lisible et composable.'),
          ('thenApply ou thenCompose', 'Aucune différence : les deux sont synonymes', FALSE, 3, 'La forme du résultat change (imbriqué vs aplati).'),
          ('thenApply ou thenCompose', 'thenCompose ne fonctionne qu''avec des listes', FALSE, 4, 'Confusion avec Stream.flatMap / Optional.flatMap — le principe est le même, le support est CompletableFuture.'),
          ('Exception avalée par exceptionally', 'Journaliser l''exception (ou utiliser handle) avant le repli', TRUE, 1, 'Un fallback silencieux transforme une panne détectable en dégradation invisible.'),
          ('Exception avalée par exceptionally', 'Renvoyer null pour propager l''erreur plus tard', FALSE, 2, 'null déplace juste l''erreur, souvent sous la forme d''une NPE incompréhensible.'),
          ('Exception avalée par exceptionally', 'Supprimer exceptionally : les exceptions doivent remonter', FALSE, 3, 'Un repli assumé est légitime — à condition d''être observable (métrique, log).'),
          ('Exception avalée par exceptionally', 'Utiliser printStackTrace() comme solution complète', FALSE, 4, 'Ça trace dans stdout, ignoré en prod ; il faut le logger structurément.'),
          ('Exception checked : quelle politique', 'Des exceptions métiers runtime typées, catch là où on sait traiter', TRUE, 1, 'Propager la responsabilité : attraper au niveau qui peut réellement agir (ou remonter).'),
          ('Exception checked : quelle politique', 'catch (Exception e) {} en haut de chaîne pour ne jamais faire planter', FALSE, 2, 'Avale les vrais bugs (et parfois les OOM) sans trace exploitable.'),
          ('Exception checked : quelle politique', 'Déclarer throws Exception partout pour être transparent', FALSE, 3, 'Transfère le fardeau à tous les appelants sans les aider à décider.'),
          ('Exception checked : quelle politique', 'Retourner un code d''erreur négatif dans le domaine', FALSE, 4, 'Les codes sont ignorés silencieusement ; les exceptions sont structurées.'),
          ('Cache LRU en mémoire', 'LinkedHashMap(accessOrder=true) avec removeEldestEntry()', TRUE, 1, 'Construit pour ce cas précis : éjection de la moins récemment utilisée.'),
          ('Cache LRU en mémoire', 'HashMap avec suppression manuelle à chaque ajout', FALSE, 2, 'HashMap n''a aucun ordre : « la plus ancienne » est indéfinissable.'),
          ('Cache LRU en mémoire', 'TreeMap trié sur l''horodatage', FALSE, 3, 'Possible mais coût O(log n) pour un tri inutile ; l''accès fréquent n''est pas le plus récent.'),
          ('Cache LRU en mémoire', 'ConcurrentHashMap avec size() > 500', FALSE, 4, 'La taille ne dit pas laquelle éjecter : aucun ordre d''usage.'),
          ('Identifiants > 127 comparés avec ==', 'Le cache d''Integer ne couvre que -128..127 ; au-delà, == compare des instances', TRUE, 1, 'Bug typique « ne se reproduit qu''avec de gros ids » — equals() systématique sur les wrappers.'),
          ('Identifiants > 127 comparés avec ==', 'Les long ne sont jamais concernés', FALSE, 2, 'Long possède le même cache (-128..127) et le même piège.'),
          ('Identifiants > 127 comparés avec ==', 'Le compilateur remplace == par equals sur Integer', FALSE, 3, 'Aucune réécriture : la comparaison de références telle quelle.'),
          ('Identifiants > 127 comparés avec ==', 'C''est une erreur de la base qui renvoie des ids dupliqués', FALSE, 4, 'Le symptôme est purement JVM — les ids sont corrects.'),
          ('ClassCastException malgré des génériques', 'Type erasure : les génériques sont effacés à la compilation', TRUE, 1, 'Avec raw types, aucune vérification compile-time : le cast échoue à l''exécution.'),
          ('ClassCastException malgré des génériques', 'Les génériques ne fonctionnent pas avec les listes', FALSE, 2, 'Ils fonctionnent ; c''est le contournement (raw) qui casse la protection.'),
          ('ClassCastException malgré des génériques', 'Le compilateur a ignoré le générique à cause de @SuppressWarnings', FALSE, 3, 'SuppressWarnings ne désactive que l''avertissement, pas la vérification de type.'),
          ('ClassCastException malgré des génériques', 'La classe a été chargée par deux classloaders', FALSE, 4, 'Un double chargement donne plutôt un LinkageError ou un CCE entre « mêmes » classes, pas ce symptôme dans une boucle.'),
          ('Publication non sûre d''un objet mutable', 'Fuite de this dans le constructeur : lecture avant initialisation complète', TRUE, 1, 'Le happens-before manque : d''autres threads observent un état intermédiaire.'),
          ('Publication non sûre d''un objet mutable', 'Le constructeur devrait être déclaré synchronized', FALSE, 2, 'Un constructeur ne peut pas être synchronized, et le verrou ne protégerait de toute façon pas la publication.'),
          ('Publication non sûre d''un objet mutable', 'Il faut utiliser un HashMap synchronized', FALSE, 3, 'Le registre n''est pas en cause : c''est la visibilité de l''objet publié.'),
          ('Publication non sûre d''un objet mutable', 'Déclarer la classe abstract règle la publication', FALSE, 4, 'Aucun lien : la publication dépend des références partagées, pas de l''héritage.'),
          ('ThreadLocal dans un pool de threads', 'Les threads sont réutilisés et remove() n''est jamais appelé : fuite + contamination', TRUE, 1, 'Double effet : mémoire jamais libérée et contexte d''une requête réutilisé par la suivante.'),
          ('ThreadLocal dans un pool de threads', 'ThreadLocal est interdit dans les applications web', FALSE, 2, 'Utilisable à bon escient — avec remove() en finally dans un pool.'),
          ('ThreadLocal dans un pool de threads', 'Il faut appeler ThreadLocal.set(null) au démarrage', FALSE, 3, 'Chaque thread a son propre emplacement : le set initial ne nettoie rien pour les suivants.'),
          ('ThreadLocal dans un pool de threads', 'Le problème vient du garbage collector qui ne tourne pas', FALSE, 4, 'Le GC ignore les valeurs encore référencées par les threads vivants — c''est la référence qui manque.'),
          ('Record apparemment immuable', 'Un record fige les références : le tableau reste modifiable par l''appelant', TRUE, 1, 'Fuite d''état : l''encapsulation réelle exige une copie défensive.'),
          ('Record apparemment immuable', 'equals/hashCode des records ignorent le contenu des tableaux', TRUE, 2, 'La comparaison par défaut de tableau compare les références : deux records égaux en contenu peuvent différer.'),
          ('Record apparemment immuable', 'Les records ne peuvent contenir que des types immuables', FALSE, 3, 'Ils acceptent tout type ; c''est la responsabilité du constructeur qui joue.'),
          ('Record apparemment immuable', 'Le mot clé record rend la classe automatiquement thread-safe', FALSE, 4, 'L''immuabilité n''est que celle des références finales.'),
          ('LinkedList plus rapide qu''ArrayList ?', 'L''insertion O(1) suppose déjà d''être positionné au nœud', TRUE, 1, 'Atteindre le nœud reste O(n) : le gain n''existe qu''après navigation (add-after-iterator).'),
          ('LinkedList plus rapide qu''ArrayList ?', 'Chaque nœud coûte une allocation et casse la localité de cache', TRUE, 2, 'Parcours séquentiel : ArrayList gagne largement en pratique.'),
          ('LinkedList plus rapide qu''ArrayList ?', 'LinkedList est toujours plus lent quel que soit l''usage', FALSE, 3, 'Trop absolu : insertions/validation au milieu fréquents peuvent le favoriser.'),
          ('LinkedList plus rapide qu''ArrayList ?', 'ArrayList est en O(n) pour chaque ajout en fin', FALSE, 4, 'L''ajout en fin est amorti O(1) (redimensionnement inclus).'),
          ('parallelStream en environnement serveur', 'Écriture concurrente non thread-safe : résultat corrompu sans exception', TRUE, 1, 'Les compteurs/fusions perdent des mises à jour — silence total, données fausses.'),
          ('parallelStream en environnement serveur', 'Le pool commun ForkJoinPool peut ralentir tous les endpoints', TRUE, 2, 'Saturation partagée : un traitement lourd impacte le reste du service.'),
          ('parallelStream en environnement serveur', 'parallelStream lève toujours une exception en cas de conflit', FALSE, 3, 'Les courses sont muettes : d''où la dangerosité.'),
          ('parallelStream en environnement serveur', 'Il faut déclarer la liste en synchronizedList', FALSE, 4, 'Le verrou de la liste ne protège pas l''accumulator de la réduction.'),
          ('allOf et la première exception', 'allOf est fail-fast : la première exception met tout le combiné en échec', TRUE, 1, 'Les autres tâches continuent, mais leurs résultats sont inaccessibles par ce chemin.'),
          ('allOf et la première exception', 'allOf annule physiquement les tâches en cours', FALSE, 2, 'Aucune annulation automatique : elles tournent jusqu''au bout, résultat perdu.'),
          ('allOf et la première exception', 'Il faut une exception par future avec exceptionally avant agrégation', TRUE, 3, 'Chaque branche devient indépendante : résultats partiels et erreurs observables séparément.'),
          ('allOf et la première exception', 'Les exceptions se cumulent automatiquement dans une liste', FALSE, 4, 'Aucun cumul natif — il faut le construire (handle/exceptionally par branche).')
     ) AS v(title, content, is_correct, ord, expl)
         JOIN challenges c ON c.title = v.title
WHERE NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id AND o.display_order = v.ord);

-- ---------------------------------------------------------------------
-- 4 PROBLEM_SOLVING (réponse ouverte — aucune option, expliquée par l'explanation)
-- ---------------------------------------------------------------------
INSERT INTO challenges (title, type, selection_type, difficulty, context, question, code_snippet, code_language, explanation, estimated_time_seconds, active, points, created_at, updated_at)
SELECT v.title, v.type, v.selection_type, v.difficulty, v.context, v.question,
       NULLIF(v.snippet, ''), NULLIF(v.lang, ''), v.explanation, v.time, TRUE, v.points,
       CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM (VALUES
          ('Threads créés à la volée sans pool', 'PROBLEM_SOLVING', 'SINGLE_CHOICE', 'INTERMEDIATE',
           'Pour chaque fichier importé, ton service fait new Thread(...).start(). En charge, le serveur crée des milliers de threads et s''effondre.',
           'Comment repenser le traitement asynchrone de ces imports ? Quelles décisions prends-tu (pool, file, supervision, arrêt) ?',
           '',
           '',
           'Diagnostiquer le coût (thread OS = ~1 Mo de pile, création coûteuse) puis basculer sur ExecutorService : taille de pool raisonnée (CPU-bound = nb coeurs ; I/O-bound = coeurs × attente), file d''attente bornée avec politique de rejet explicite, naming des threads, et arrêt propre (shutdown + awaitTermination). Exposer la supervision (métriques de file, rejected tasks) et documenter les choix.',
           180, 15),
          ('Résultats dans un ordre aléatoire', 'PROBLEM_SOLVING', 'SINGLE_CHOICE', 'INTERMEDIATE',
           'Une liste de résultats construite dans un HashSet sort dans un ordre différent à chaque exécution : les tests d''affichage échouent par intermittence.',
           'Quelle est la cause et comment stabiliser l''ordre sans cacher un vrai problème ?',
           '',
           '',
           'HashMap/HashSet ne conserve aucun ordre (et le hash dépend du contenu). Décider de l''ordre métier attendu : tri explicite (TreeSet ou sorted sur un comparateur métier) si l''ordre est une exigence, LinkedHashSet si l''ordre d''insertion est significatif. Ne jamais stabiliser au hasard : l''ordre doit être une décision documentée, couverte par un test.',
           180, 15),
          ('Méthode aux booléens proliferants', 'PROBLEM_SOLVING', 'SINGLE_CHOICE', 'ADVANCED',
           'Une méthode export(..., boolean includeHeader, boolean includeFooter, boolean raw, boolean paginate, boolean anonymize) grandit à chaque sprint et les appels sont illisibles (true, false, true...).',
           'Comment refactoriser en préservant la compatibilité des appelants et la lisibilité ?',
           '',
           '',
           'Extraire un objet d''options immuable (ExportOptions.builder()...) : auto-documentation, validation centralisée, évolution sans signature qui casse. Maintenir temporairement l''ancienne méthode en déléguant (dépréciation), migrer les appelants par lots, couvrir par des tests de régression. Vérifier si certaines combinaisons sont illégales — c''est là que le booléen cachait une règle métier.',
           240, 25),
          ('Tests intermittents : état statique', 'PROBLEM_SOLVING', 'SINGLE_CHOICE', 'ADVANCED',
           'Une suite JUnit échoue aléatoirement quand on l''exécute en parallèle. Un cache statique Map<Request, Object> alimenté par le code de production est impliqué.',
           'Comment diagnostiques-tu et corriges-tu ce type d''instabilité ?',
           '',
           '',
           'Reproduire (boucle, parallélisation forcée), éliminer le partage : l''état statique est muté par tous les tests. Corriger la racine (supprimer ce cache statique — idéalement le faire injecter/instancié par test), ajouter @ResourceLock ou désactiver la parallélisation sur ce test en attendant, et traiter le symptôme résiduel comme un vrai bug de conception : un cache global partagé poserait le même problème en production multi-instances.',
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
          ('Review : import sans fermeture de flux', 'CODE_REVIEW', 'MULTIPLE_CHOICE', 'INTERMEDIATE',
           'Un import CSV de commandes s''exécute toutes les nuits.',
           'Quels problèmes identifiez-vous dans ce code ?',
           'public List<Order> importCsv(String path) {
              List<Order> out = new ArrayList<>();
              try {
                  BufferedReader br = new BufferedReader(new FileReader(path));
                  String line;
                  while ((line = br.readLine()) != null) {
                      out.add(parse(line));
                  }
              } catch (Exception e) {
                  return out;
              }
              return out;
          }',
           'java',
           'La ressource n''est jamais fermée (fuite de descripteurs si parse lève une exception) et catch(Exception) avale l''erreur en renvoyant une liste partielle : un import corrompu passe inaperçu. Fermer via try-with-resources et laisser l''exception remonter (ou la rethrow après log).',
           180, 20),
          ('Review : concaténation dans une boucle chaude', 'CODE_REVIEW', 'MULTIPLE_CHOICE', 'INTERMEDIATE',
           'Le build d''un rapport XML est remonté en top temps CPU par le profiler.',
           'Quels problèmes identifiez-vous dans ce code ?',
           'StringBuilder sb = new StringBuilder();
          for (Row row : rows) {
              sb.append("<row>").append(row.value).append("</row>");
              log.info("ligne traitée : " + row.value);
          }
          return sb.toString();',
           'java',
           'Deux vrais problèmes : le log concatène À CHAQUE itération (coût même quand le niveau est désactivé — parameterized logging : log.info("ligne : {}", row.value)), et la construction en mémoire d''un rapport non borné peut masquer un souci de volume. StringBuilder ici est déjà correct.',
           180, 20),
          ('Review : identifiants comparés avec ==', 'CODE_REVIEW', 'MULTIPLE_CHOICE', 'INTERMEDIATE',
           'Un rattachement client/commande échoue aléatoirement selon la taille des lots.',
           'Quels problèmes identifiez-vous dans ce code ?',
           'Integer clientId = row.getClientId();
          Integer existing = cache.get(clientId);
          if (existing == row.getClientId()) {
              return existing;
          }
          return repository.load(clientId);',
           'java',
           'Comparaison d''Integer avec == : hors du cache -128..127, deux instances de la même valeur sont différentes — d''où l''échec aléatoire (les petits ids passent). Utiliser equals(). De plus, cache.get peut renvoyer null : le code doit être null-safe.',
           180, 20),
          ('Review : état partagé non synchronisé', 'CODE_REVIEW', 'MULTIPLE_CHOICE', 'ADVANCED',
           'Un compteur de notifications est agrégé parallèlement côté serveur.',
           'Quels problèmes identifiez-vous dans ce code ?',
           'private static Map<String, Integer> counts = new HashMap<>();

          public void record(String key) {
              Integer n = counts.get(key);
              counts.put(key, n == null ? 1 : n + 1);
          }

          public Map<String, Integer> snapshot() {
              return counts;
          }',
           'java',
           'HashMap partagé sans synchronisation : pertes d''incrément silencieuses et corruption structurelle possible. Le check-then-act est de plus non atomique. Corriger avec ConcurrentHashMap.merge ; snapshot() expose la carte interne — renvoyer une copie (Map.copyOf).',
           240, 25),
          ('Review : verrou sur une mauvaise cible', 'CODE_REVIEW', 'MULTIPLE_CHOICE', 'ADVANCED',
           'Deux méthodes d''un service doivent être mutuellement exclusives.',
           'Quels problèmes identifiez-vous dans ce code ?',
           'public class OrderService {
              public void cancel(Long id) {
                  synchronized (this) { ... }
              }
              public static OrderService INSTANCE = new OrderService();
              public void retry(Long id) {
                  synchronized (OrderService.class) { ... }
              }
          }',
           'java',
           'Les deux verrous n''ont pas la même cible (instance vs classe) : aucune exclusion réelle entre cancel et retry. Le champ statique mutable public casse de plus l''encapsulation. Choisir UN verrou privé final (lock object) partagé par les deux méthodes, ou ReentrantLock avec tryLock si timeout souhaité.',
           240, 25),
          ('Review : catch silencieux en production', 'CODE_REVIEW', 'MULTIPLE_CHOICE', 'JUNIOR',
           'Gestion des paiements : en cas d''erreur, l''interface affiche « OK ».',
           'Quels problèmes identifiez-vous dans ce code ?',
           'try {
              paymentGateway.charge(order);
              order.markPaid();
          } catch (Exception e) {
              // ignore
          }
          return Response.ok();',
           'java',
           'Le catch vide supprime toute trace : le paiement échoue alors que le client reçoit OK (erreur métier grave, pas seulement du style). Un catch(Exception) attrape aussi les bugs imprévus. Remonter l''exception (ou un code d''erreur métier), journaliser avec le contexte de commande, et ne jamais retourner succès après un échec non traité.',
           120, 15)
     ) AS v(title, type, selection_type, difficulty, context, question, snippet, lang, explanation, time, points)
WHERE NOT EXISTS (SELECT 1 FROM challenges c WHERE c.title = v.title);

-- Options CODE_REVIEW (6 colonnes : severity, NULL pour les fausses alertes)
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation, severity)
SELECT c.id, v.content, v.is_correct, v.ord, v.expl, v.sev
FROM (VALUES
          ('Review : import sans fermeture de flux', 'La ressource n''est jamais fermée : fuite de descripteurs', TRUE, 1, 'Aucun close ni try-with-resources : FileReader reste ouvert en cas d''exception de parse.', 'BUG'),
          ('Review : import sans fermeture de flux', 'catch(Exception) retourne une liste partielle comme si c''était un succès', TRUE, 2, 'Perte silencieuse de données : l''import échoue à moitié sans erreur remontée.', 'CODE_QUALITY'),
          ('Review : import sans fermeture de flux', 'BufferedReader est inadapté pour lire un CSV volumineux', FALSE, 3, 'BufferedReader est le choix standard ; le flux n''est pas le problème ici.', NULL),
          ('Review : import sans fermeture de flux', 'Le champ out devrait être un Set pour éviter les doublons', FALSE, 4, 'Rien ne dit que les lignes dupliquées existent : fausse alerte de review.', NULL),
          ('Review : concaténation dans une boucle chaude', 'log.info("..." + row.value) concatène même si le niveau est désactivé', TRUE, 1, 'L''argument est évalué avant l''appel : utiliser log.info("ligne : {}", row.value).', 'PERFORMANCE'),
          ('Review : concaténation dans une boucle chaude', 'Aucun problème : StringBuilder est déjà utilisé pour le corps', FALSE, 2, 'La construction par StringBuilder est correcte : fausse alerte fréquente en revue.', NULL),
          ('Review : concaténation dans une boucle chaude', 'Le volume de rows n''est pas borné avant la construction en mémoire', TRUE, 3, 'Un rapport de millions de lignes explose la mémoire : pagination ou écriture en flux.', 'PERFORMANCE'),
          ('Review : concaténation dans une boucle chaude', 'Il faut remplacer la boucle par parallelStream()', FALSE, 4, 'Ajouter de la concurrence sur de l''I/O de log aggraverait le coût : mauvais réflexe.', NULL),
          ('Review : identifiants comparés avec ==', '== sur Integer échoue hors du cache -128..127', TRUE, 1, 'Cause exacte de l''échec aléatoire selon la taille des lots.', 'BUG'),
          ('Review : identifiants comparés avec ==', 'cache.get(clientId) peut renvoyer null sans être géré', TRUE, 2, 'Le null n''est pas géré : un null-check est requis.', 'BUG'),
          ('Review : identifiants comparés avec ==', 'repository.load doit être appelé avant le cache', FALSE, 3, 'L''ordre cache-puis-DB est normal (lazy loading) : fausse alerte.', NULL),
          ('Review : identifiants comparés avec ==', 'Le type Integer devrait être remplacé par int partout', FALSE, 4, 'Impossible pour un champ nullable ; equals est le correctif ciblé.', NULL),
          ('Review : état partagé non synchronisé', 'HashMap non thread-safe : incréments perdus, structure potentiellement corrompue', TRUE, 1, 'Concurrence silencieusement incorrecte : ConcurrentHashMap est l''outil adapté.', 'BUG'),
          ('Review : état partagé non synchronisé', 'Le check-then-act (get puis put) n''est pas atomique', TRUE, 2, 'Même avec une map sûre, deux threads peuvent lire la même valeur initiale.', 'BUG'),
          ('Review : état partagé non synchronisé', 'snapshot() expose la map interne : fuite d''état', TRUE, 3, 'L''appelant peut modifier la carte du service : renvoyer Map.copyOf(...).', 'ARCHITECTURE'),
          ('Review : état partagé non synchronisé', 'Il faut déclarer la méthode en synchronized', FALSE, 4, 'Seul le bon type de structure atomique (merge) résout la course : synchronized statique serait une sérialisation globale.', NULL),
          ('Review : verrou sur une mauvaise cible', 'Deux verrous différents (instance vs classe) : l''exclusion ne joue pas', TRUE, 1, 'cancel et retry ne s''excluent jamais mutuellement.', 'BUG'),
          ('Review : verrou sur une mauvaise cible', 'Un verrou privé final partagé par les méthodes corrigerait la sémantique', TRUE, 2, 'Pattern lock object : cible identique, invisible de l''extérieur.', 'ARCHITECTURE'),
          ('Review : verrou sur une mauvaise cible', 'Le champ public static mutable casse l''encapsulation', TRUE, 3, 'INSTANCE exposé = état partageable à volonté par n''importe quel code.', 'MAINTAINABILITY'),
          ('Review : verrou sur une mauvaise cible', 'synchronized est déprécié en Java 21', FALSE, 4, 'Toujours pleinement supporté : fausse information.', NULL),
          ('Review : catch silencieux en production', 'catch(Exception) {} avale toute erreur sans aucune trace', TRUE, 1, 'Aucun log, aucun contexte : impossible de diagnostiquer le problème.', 'CODE_QUALITY'),
          ('Review : catch silencieux en production', 'Retourner OK après un échec de paiement : erreur métier grave', TRUE, 2, 'L''utilisateur croit avoir payé ; le système peut croire le contraire.', 'BUG'),
          ('Review : catch silencieux en production', 'Le pattern try/catch est en lui-même incorrect partout', FALSE, 3, 'Protéger est normal : c''est le NON-traitement qui est fautif.', NULL),
          ('Review : catch silencieux en production', 'Il faut logger en System.out pour conserver la performance', FALSE, 4, 'Le niveau n''est pas le souci principal ; un vrai logger avec contexte s''impose.', NULL)
     ) AS v(title, content, is_correct, ord, expl, sev)
         JOIN challenges c ON c.title = v.title
WHERE NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id AND o.display_order = v.ord);

-- ---------------------------------------------------------------------
-- 6 SEQUENTIAL_REASONING (display_order = ordre attendu)
-- ---------------------------------------------------------------------
INSERT INTO challenges (title, type, selection_type, difficulty, context, question, code_snippet, code_language, explanation, estimated_time_seconds, active, points, created_at, updated_at)
SELECT v.title, v.type, v.selection_type, v.difficulty, v.context, v.question,
       NULLIF(v.snippet, ''), NULLIF(v.lang, ''), v.explanation, v.time, TRUE, v.points,
       CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM (VALUES
          ('OutOfMemoryError : procédure d''investigation', 'SEQUENTIAL_REASONING', 'SINGLE_CHOICE', 'INTERMEDIATE',
           'L''application jette un OutOfMemoryError en production, une fois par jour environ, puis se relance.',
           'Remets dans l''ordre les étapes d''investigation que suit un ingénieur expérimenté.',
           '',
           '',
           'On observe d''abord (dump + contexte), on analyse pour localiser, on distingue les hypothèses (fuite vs volume légitime), on corrige la cause racine, puis on institutionnalise la surveillance. Jamais l''inverse : corriger au hasard sans dump ne fait que déplacer le problème.',
           180, 15),
          ('Service CPU-bound : ordre d''optimisation', 'SEQUENTIAL_REASONING', 'SINGLE_CHOICE', 'INTERMEDIATE',
           'Un endpoint consomme 90 % de CPU sur une machine de production. L''équipe propose déjà trois «optimisations» au tableau.',
           'Quel est l''ordre correct des étapes ?',
           '',
           '',
           'Mesurer avant de deviner : profilage → hotspot identifié → correction ciblée → mesure comparative → intégration de la mesure (benchmark/CI). Inverser les étapes produit des micro-optimisations invisibles voire régressantes.',
           120, 15),
          ('Cycle de vie d''une instance Java', 'SEQUENTIAL_REASONING', 'SINGLE_CHOICE', 'JUNIOR',
           'Formation junior : comprendre ce qu''il advient d''un objet créé en méthode.',
           'Place ces étapes dans l''ordre chronologique.',
           '',
           '',
           'Allocation en eden → survie des minor GC (espaces Survivor) → promotion en old génération selon l''âge → major/full GC libère si plus référencé. C''est la mécanique qui rend les fuites (objets inutilement retenus) visibles en old.',
           90, 10),
          ('Migrer un singleton statique vers un bean Spring', 'SEQUENTIAL_REASONING', 'SINGLE_CHOICE', 'ADVANCED',
           'Un utilitaire CacheManager statique est utilisé partout ; il pose problème pour les tests et l''injection.',
           'Quel est l''ordre de migration le plus sûr ?',
           '',
           '',
           'Inventorier les usages → extraire l''interface derrière un bean → créer la configuration @Configuration/service → injecter progressivement (un appelant à la fois) → supprimer l''état statique → verrouiller par tests. Supprimer le static avant d''avoir la cible revient à tout casser en même temps.',
           240, 25),
          ('Deadlock récurrent : procédure', 'SEQUENTIAL_REASONING', 'SINGLE_CHOICE', 'ADVANCED',
           'Une file de traitement gèle 2 à 3 fois par semaine. Les redémarrages masquent le symptôme.',
           'Remets dans l''ordre la procédure d''éradication.',
           '',
           '',
           'Reproduire (stress ciblé) → capturer l''état réel (jstack au moment du gel) → cartographier les verrous et leur ordre → corriger structurellement (ordre global/timeout) → ajouter le test de non-régression. Sans reproduction ni capture, toute correction est une hypothèse.',
           240, 25),
          ('Migrer Date vers java.time', 'SEQUENTIAL_REASONING', 'SINGLE_CHOICE', 'INTERMEDIATE',
           'Le code mélange java.util.Date, Calendar et SimpleDateFormat, avec des bugs de fuseau en prod.',
           'Quel est l''ordre de migration recommandé ?',
           '',
           '',
           'Inventorier les usages et les règles de fuseau → remplacer les déclarations (LocalDateTime/Instant/ZonedDateTime selon le sens métier) → convertir aux frontières (base, JSON, front) → supprimer les formatters partagés → corriger tests et comparaisons (equals → isAfter/compareTo). Migrer les conversions avant les déclarations crée un brouillard de types hybrides.',
           180, 15)
     ) AS v(title, type, selection_type, difficulty, context, question, snippet, lang, explanation, time, points)
WHERE NOT EXISTS (SELECT 1 FROM challenges c WHERE c.title = v.title);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.ord, v.expl
FROM (VALUES
          ('OutOfMemoryError : procédure d''investigation', 'Capturer un heap dump et noter le contexte exact (heure, charge, dernière mise en production)', TRUE, 1, 'Sans capture au moment du fait, toute analyse est de la spéculation.'),
          ('OutOfMemoryError : procédure d''investigation', 'Analyser le dump (MAT/jmap) pour identifier ce qui retient la mémoire', TRUE, 2, 'Les dominator trees/chemins de rétention désignent le coupable, pas les intuitions.'),
          ('OutOfMemoryError : procédure d''investigation', 'Distinguer une fuite (objets retenus indéfiniment) d''un pic de volume légitime', TRUE, 3, 'Les remèdes diffèrent : suppression de référence vs borne/aval.'),
          ('OutOfMemoryError : procédure d''investigation', 'Corriger la cause racine identifiée et ajouter un test de non-régression', TRUE, 4, 'Le correctif doit être prouvable et durable.'),
          ('OutOfMemoryError : procédure d''investigation', 'Augmenter -Xmx le temps de trouver la vraie cause', TRUE, 5, 'Mesure d''urgence acceptable (time-buying) — mais jamais la résolution.'),
          ('OutOfMemoryError : procédure d''investigation', 'Redémarrer en boucle et attendre que cela disparaisse', FALSE, 6, 'Le masquage : le problème revient et l''historique des causes est perdu.'),
          ('Service CPU-bound : ordre d''optimisation', 'Profilage en conditions réelles (flame graph, hot methods)', TRUE, 1, 'Seul le profilage désigne le vrai hotspot — les intuitions trompent.'),
          ('Service CPU-bound : ordre d''optimisation', 'Correction ciblée du hotspot identifié', TRUE, 2, 'On ne touche qu''à ce qui consomme réellement.'),
          ('Service CPU-bound : ordre d''optimisation', 'Mesure comparative avant/après sur le même jeu de charge', TRUE, 3, 'Sans A/B de performance, on ne peut pas affirmer avoir gagné.'),
          ('Service CPU-bound : ordre d''optimisation', 'Automatisation de la mesure (benchmark/régression dans la CI)', TRUE, 4, 'Empêche la ré-introduction silencieuse de la lenteur.'),
          ('Service CPU-bound : ordre d''optimisation', 'Changer de framework pour des performances globales meilleures', FALSE, 5, 'Réponse hors proportion : le hotspot mérite d''être traité d''abord.'),
          ('Service CPU-bound : ordre d''optimisation', 'Réécrire en bas niveau toutes les méthodes « potentiellement lentes »', FALSE, 6, 'Réécriture aveugle = coût énorme, gains non mesurés.'),
          ('Cycle de vie d''une instance Java', 'L''objet est alloué dans l''espace eden', TRUE, 1, 'Première allocation d''un objet neuf.'),
          ('Cycle de vie d''une instance Java', 'Un minor GC fait survivre les objets encore vivants (espaces Survivor)', TRUE, 2, 'Les survivants sont copiés, avec un compteur d''âge.'),
          ('Cycle de vie d''une instance Java', 'Après plusieurs survies, l''objet est promu en old génération', TRUE, 3, 'Seuil d''âge atteint (TenuringThreshold).'),
          ('Cycle de vie d''une instance Java', 'Un full/major GC libère l''espace si plus aucune référence ne pointe l''objet', TRUE, 4, 'Réclamation effectuée seulement si l''objet est inatteignable.'),
          ('Cycle de vie d''une instance Java', 'L''objet reçoit un identifiant permanent immuable', FALSE, 5, 'Aucun id permanent : les objets sont déplacés et compactés.'),
          ('Cycle de vie d''une instance Java', 'Le constructeur s''exécute après l''ajout à l''old génération', FALSE, 6, 'Le constructeur tourne juste après l''allocation, en eden.'),
          ('Migrer un singleton statique vers un bean Spring', 'Inventorier tous les accès statiques et l''état qu''ils partagent', TRUE, 1, 'Sans cartographie, on découvre les usages en cassant la prod.'),
          ('Migrer un singleton statique vers un bean Spring', 'Extraire une interface et créer le bean Spring (service injectable)', TRUE, 2, 'La cible existe avant la migration des appelants.'),
          ('Migrer un singleton statique vers un bean Spring', 'Injecter le bean et migrer les appelants un par un', TRUE, 3, 'Migration incrémentale : chaque pas reste vérifiable.'),
          ('Migrer un singleton statique vers un bean Spring', 'Supprimer l''état statique quand plus aucun appelant ne l''utilise', TRUE, 4, 'La suppression est la DERNIÈRE étape, jamais la première.'),
          ('Migrer un singleton statique vers un bean Spring', 'Ajouter des tests qui échoueraient si le statique revient', TRUE, 5, 'Verrou anti-régression.'),
          ('Migrer un singleton statique vers un bean Spring', 'Renommer la classe pour marquer la migration', FALSE, 6, 'Cosmétique : aucun effet sur le partage d''état.'),
          ('Deadlock récurrent : procédure', 'Reproduire le gel avec un stress ciblé', TRUE, 1, 'Un gel non reproductible ne peut être ni compris ni testé.'),
          ('Deadlock récurrent : procédure', 'Capturer jstack (thread dump) pendant le gel', TRUE, 2, 'Le dump montre les verrous et le cycle d''attente réel.'),
          ('Deadlock récurrent : procédure', 'Cartographier les verrous et l''ordre d''acquisition problématique', TRUE, 3, 'Le cycle circulaire se lit dans la cartographie.'),
          ('Deadlock récurrent : procédure', 'Corriger structurellement : ordre global ou timeout de tentative', TRUE, 4, 'La correction porte sur le schéma, pas sur le symptôme.'),
          ('Deadlock récurrent : procédure', 'Ajouter un test de non-régression (concurrence contrôlée)', TRUE, 5, 'Verrouille la propriété corrigée dans le temps.'),
          ('Deadlock récurrent : procédure', 'Redémarrer plus fréquemment en attendant la prochaine version', FALSE, 6, 'Masquage : le gel persiste et les données en cours peuvent être perdues.'),
          ('Migrer Date vers java.time', 'Inventorier les usages et figer le sens métier de chaque date (heure locale, instant, fuseau)', TRUE, 1, 'Sans sémantique claire, on migre des LocalDateTime partout — erreur classique.'),
          ('Migrer Date vers java.time', 'Remplacer les déclarations par les types java.time appropriés', TRUE, 2, 'Le nouveau modèle de données s''installe.'),
          ('Migrer Date vers java.time', 'Adapter les frontières : lecture base, JSON, échanges front', TRUE, 3, 'Les conversions se placent aux frontières, pas au cœur du domaine.'),
          ('Migrer Date vers java.time', 'Supprimer SimpleDateFormat partagés au profit de DateTimeFormatter', TRUE, 4, 'Immuable et thread-safe — le bug de concurrence disparaît.'),
          ('Migrer Date vers java.time', 'Migrer enfin les comparaisons (equals sur Date → compareTo/isAfter)', TRUE, 5, 'Étape de fiabilisation post-changement de type.'),
          ('Migrer Date vers java.time', 'Ajouter un cache d''objets Date pour compenser le coût d''allocation', FALSE, 6, 'Contresens : java.time est immuable et peu coûteux — optimisation inutile.')
     ) AS v(title, content, is_correct, ord, expl)
         JOIN challenges c ON c.title = v.title
WHERE NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id AND o.display_order = v.ord);

-- ---------------------------------------------------------------------
-- Liens (categories / skills / profile DEVELOPER)
-- ---------------------------------------------------------------------
INSERT INTO challenge_categories (challenge_id, category_id)
SELECT c.id, cat.id
FROM (VALUES
          ('ConcurrentModificationException dans une boucle','Java'),('Clé introuvable dans la HashMap','Java'),
          ('Comparaison de jetons de session avec ==','Java'),('Fichier jamais fermé après une exception','Java'),
          ('NullPointerException sur une comparaison','Java'),('Total tronqué dans un rapport','Java'),
          ('Collections final non modifiable ?','Java'),('UnsupportedOperationException inattendu','Java'),
          ('Surcharge résolue à la compilation','Java'),('SimpleDateFormat partagé entre threads','Java'),
          ('Flag de coordination entre threads','Java'),('Double-checked locking instable','Java'),
          ('Deadlock sur deux verrous','Java'),('wait() hors boucle de condition','Java'),
          ('Optional : orElse coûteux','Java'),('Stream jamais exécuté','Java'),
          ('Récupérer un résultat depuis un thread','Java'),('thenApply ou thenCompose','Java'),
          ('Exception avalée par exceptionally','Java'),('Exception checked : quelle politique','Java'),
          ('Cache LRU en mémoire','Java'),('Identifiants > 127 comparés avec ==','Java'),
          ('ClassCastException malgré des génériques','Java'),('Publication non sûre d''un objet mutable','Java'),
          ('ThreadLocal dans un pool de threads','Java'),('Record apparemment immuable','Java'),
          ('LinkedList plus rapide qu''ArrayList ?','Java'),('parallelStream en environnement serveur','Java'),
          ('allOf et la première exception','Java'),
          ('Threads créés à la volée sans pool','Java'),('Résultats dans un ordre aléatoire','Java'),
          ('Méthode aux booléens proliferants','Architecture'),('Tests intermittents : état statique','Testing'),
          ('Review : import sans fermeture de flux','Java'),('Review : concaténation dans une boucle chaude','Java'),
          ('Review : identifiants comparés avec ==','Java'),('Review : état partagé non synchronisé','Java'),
          ('Review : verrou sur une mauvaise cible','Java'),('Review : catch silencieux en production','Java'),
          ('OutOfMemoryError : procédure d''investigation','Java'),('Service CPU-bound : ordre d''optimisation','Testing'),
          ('Cycle de vie d''une instance Java','Java'),('Migrer un singleton statique vers un bean Spring','Spring Boot'),
          ('Deadlock récurrent : procédure','Java'),('Migrer Date vers java.time','Java')
     ) AS v(title, cat)
         JOIN challenges c ON c.title = v.title
         JOIN categories cat ON cat.name = v.cat
WHERE NOT EXISTS (SELECT 1 FROM challenge_categories cc WHERE cc.challenge_id = c.id AND cc.category_id = cat.id);

INSERT INTO challenge_skills (challenge_id, skill_id)
SELECT c.id, s.id
FROM (VALUES
          ('ConcurrentModificationException dans une boucle','Debugging'),
          ('Clé introuvable dans la HashMap','Debugging'),
          ('Comparaison de jetons de session avec ==','Debugging'),
          ('Fichier jamais fermé après une exception','Code Quality'),
          ('NullPointerException sur une comparaison','Debugging'),
          ('Total tronqué dans un rapport','Debugging'),
          ('Collections final non modifiable ?','Code Quality'),
          ('UnsupportedOperationException inattendu','Code Quality'),
          ('Surcharge résolue à la compilation','Problem Solving'),
          ('SimpleDateFormat partagé entre threads','Debugging'),
          ('Flag de coordination entre threads','Problem Solving'),
          ('Double-checked locking instable','Problem Solving'),
          ('Deadlock sur deux verrous','Problem Solving'),
          ('wait() hors boucle de condition','Problem Solving'),
          ('Optional : orElse coûteux','Performance Analysis'),
          ('Stream jamais exécuté','Code Quality'),
          ('Récupérer un résultat depuis un thread','Code Quality'),
          ('thenApply ou thenCompose','Code Quality'),
          ('Exception avalée par exceptionally','Code Quality'),
          ('Exception checked : quelle politique','Code Quality'),
          ('Cache LRU en mémoire','Performance Analysis'),
          ('Identifiants > 127 comparés avec ==','Debugging'),
          ('ClassCastException malgré des génériques','Debugging'),
          ('Publication non sûre d''un objet mutable','Problem Solving'),
          ('ThreadLocal dans un pool de threads','Debugging'),
          ('Record apparemment immuable','Code Quality'),
          ('LinkedList plus rapide qu''ArrayList ?','Performance Analysis'),
          ('parallelStream en environnement serveur','Performance Analysis'),
          ('allOf et la première exception','Problem Solving'),
          ('Threads créés à la volée sans pool','Performance Analysis'),
          ('Résultats dans un ordre aléatoire','Debugging'),
          ('Méthode aux booléens proliferants','Code Quality'),
          ('Tests intermittents : état statique','Debugging'),
          ('Review : import sans fermeture de flux','Code Quality'),
          ('Review : concaténation dans une boucle chaude','Performance Analysis'),
          ('Review : identifiants comparés avec ==','Debugging'),
          ('Review : état partagé non synchronisé','Debugging'),
          ('Review : verrou sur une mauvaise cible','Code Quality'),
          ('Review : catch silencieux en production','Code Quality'),
          ('OutOfMemoryError : procédure d''investigation','Performance Analysis'),
          ('Service CPU-bound : ordre d''optimisation','Performance Analysis'),
          ('Cycle de vie d''une instance Java','Problem Solving'),
          ('Migrer un singleton statique vers un bean Spring','Code Quality'),
          ('Deadlock récurrent : procédure','Debugging'),
          ('Migrer Date vers java.time','Code Quality')
     ) AS v(title, skill)
         JOIN challenges c ON c.title = v.title
         JOIN skills s ON s.name = v.skill
WHERE NOT EXISTS (SELECT 1 FROM challenge_skills cs WHERE cs.challenge_id = c.id AND cs.skill_id = s.id);

INSERT INTO challenge_profiles (challenge_id, profile_id)
SELECT c.id, p.id
FROM (VALUES
          ('ConcurrentModificationException dans une boucle'),('Clé introuvable dans la HashMap'),
          ('Comparaison de jetons de session avec =='),('Fichier jamais fermé après une exception'),
          ('NullPointerException sur une comparaison'),('Total tronqué dans un rapport'),
          ('Collections final non modifiable ?'),('UnsupportedOperationException inattendu'),
          ('Surcharge résolue à la compilation'),('SimpleDateFormat partagé entre threads'),
          ('Flag de coordination entre threads'),('Double-checked locking instable'),
          ('Deadlock sur deux verrous'),('wait() hors boucle de condition'),
          ('Optional : orElse coûteux'),('Stream jamais exécuté'),
          ('Récupérer un résultat depuis un thread'),('thenApply ou thenCompose'),
          ('Exception avalée par exceptionally'),('Exception checked : quelle politique'),
          ('Cache LRU en mémoire'),('Identifiants > 127 comparés avec =='),
          ('ClassCastException malgré des génériques'),('Publication non sûre d''un objet mutable'),
          ('ThreadLocal dans un pool de threads'),('Record apparemment immuable'),
          ('LinkedList plus rapide qu''ArrayList ?'),('parallelStream en environnement serveur'),
          ('allOf et la première exception'),('Threads créés à la volée sans pool'),
          ('Résultats dans un ordre aléatoire'),('Méthode aux booléens proliferants'),
          ('Tests intermittents : état statique'),('Review : import sans fermeture de flux'),
          ('Review : concaténation dans une boucle chaude'),('Review : identifiants comparés avec =='),
          ('Review : état partagé non synchronisé'),('Review : verrou sur une mauvaise cible'),
          ('Review : catch silencieux en production'),('OutOfMemoryError : procédure d''investigation'),
          ('Service CPU-bound : ordre d''optimisation'),('Cycle de vie d''une instance Java'),
          ('Migrer un singleton statique vers un bean Spring'),('Deadlock récurrent : procédure'),
          ('Migrer Date vers java.time')
     ) AS v(title)
         JOIN challenges c ON c.title = v.title
         JOIN profiles p ON p.code = 'DEVELOPER'
WHERE NOT EXISTS (SELECT 1 FROM challenge_profiles cp WHERE cp.challenge_id = c.id AND cp.profile_id = p.id);