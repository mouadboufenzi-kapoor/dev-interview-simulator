-- ===============================================
-- Catalogue V1 — Profil Développeur — catégories manquantes
-- V21 : React (37 défis — 24 QCM, 3 problem-solving, 6 code review,
--       4 raisonnement séquentiel)
-- Idempotent : WHERE NOT EXISTS sur challenges.title (jamais utilisé).
-- Même structure que l'import JSON futur : challenges + challenge_options
--   (content / is_correct / display_order / explanation) + liens
--   categories / skills / profiles.
-- Aucune redondance avec V6/V16-V20 : nouvelle catégorie, titres préfixés.
-- (le corps du fichier totalise 24 QCM — 6 JUNIOR, 13 INTERMEDIATE, 5 ADVANCED)
-- ===============================================

INSERT INTO challenges (
    title, type, selection_type, difficulty, context, question,
    explanation, estimated_time_seconds, active, points,
    created_at, updated_at
)
SELECT * FROM (VALUES
('React : clé de liste — le piège de l''index', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'JUNIOR',
 'Une liste de tâches (tâche cochable avec un état local ouvert/fermé par élément) est rendue avec list.map((t, i) => <Row key={i} ... />). Après réordonnancement ou suppression, certains éléments affichent l''état d''un autre.',
 'Pourquoi la clé index est-elle dangereuse ici ?',
 'React associe l''état local et l''identité des composants à la clé : une clé index réutilise le composant physique pour une donnée différente, transportant l''état au mauvais endroit. Des identifiants stables (id) ou, en dernier recours, une clé dérivée du contenu, restaurent le bon appariement.',
 120, true, 10, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('React : les props sont un contrat en lecture seule', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'JUNIOR',
 'Un composant ProfileCard reçoit une prop user et fait user.name = input.value dans son onChange pour répercuter la saisie du parent. Le rendu parent ne bouge pas et la donnée semble perdue à l''affichage.',
 'Pourquoi cette approche est-elle condamnable selon le modèle de React ?',
 'Les props appartiennent au parent : les muter casse le principe d''unicité de la source de vérité et rend le rendu imprévisible (React ne re-rend pas parce qu''une prop interne a changé). La bonne voie : remonter le state (état contrôlé parent/enfant) ou, pour un état dérivé d''une prop, le recalculer au rendu plutôt que de le copier dans un state local.',
 120, true, 10, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('React : quand s''exécute un useEffect ?', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'JUNIOR',
 'Un composant charge des données : useEffect(() => { charger(); }). Sans tableau de dépendances, l''écran déclenche une nouvelle requête HTTP à chaque rendu visible.',
 'Que garantit le second argument de useEffect ?',
 'Le tableau de dépendances déclenche l''effet uniquement quand l''une des valeurs listées a changé ([] = au montage et au démontage pour le nettoyage). Sans tableau, l''effet s''exécute à chaque rendu. La contrepartie : lister les vraies dépendances, sinon l''effet travaille sur des données périmées (règle exhaustive-deps).',
 130, true, 10, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('React : fermeture périmée dans un handler', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'JUNIOR',
 'Un composant affiche un décompte : useEffect(() => { const id = setInterval(() => setRemaining(remaining - 1), 1000); return () => clearInterval(id); }, []). Le compteur reste figé à sa valeur initiale.',
 'Quel mécanisme explique ce comportement ?',
 'Un closure capture la valeur de remaining au moment de sa création : l''effet, exécuté une seule fois ([]), ne voit jamais la mise à jour. La correction : utiliser la forme fonctionnelle setRemaining(v => v - 1) ou inclure remaining dans les dépendances (avec le piège de la recréation d''intervalle). Ce défaut « stale closure » touche handlers, intervalles et callbacks mémoïsés.',
 130, true, 10, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('React : champ contrôlé ou non contrôlé', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'JUNIOR',
 'Un champ de recherche met à jour un state du parent à chaque frappe, mais l''écran ré-écrit la valeur saisie par l''utilisateur avec un défaut d''une seconde.',
 'De quel mode de champ s''agit-il et comment le corriger ?',
 'C''est un champ contrôlé (value piloté par le state) : le state initial ou une remise à zéro mal placée écrase la saisie. Soit on initialise le state correctement, soit on laisse le DOM piloter (non contrôlé avec defaultValue/unRef) si aucune validation immédiate n''est nécessaire.',
 120, true, 10, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('React : éviter le double état dérivé', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'JUNIOR',
 'Un composant reçoit la prop items et initialise useState(items) puis useEffect pour resynchroniser quand items change. Des bugs apparaissent : l''écran affiche parfois l''ancienne liste.',
 'Quel problème structurel cette architecture crée-t-elle ?',
 'Deux sources de vérité pour la même donnée : la copie locale et la prop. Toute désynchronisation (effet oublié, maj manuelle, rendu pendant la transition) produit des états intermédiaires faux. Règle : dériver au rendu (calcul direct) quand c''est possible ; réserver le state local à l''état qui vit et se modifie réellement dans le composant.',
 130, true, 10, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('React : race condition de chargement', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Une vue de recherche affiche parfois les résultats d''une requête précédente quand l''utilisateur tape vite : la réponse lente d''une ancienne frappe arrive après celle de la nouvelle.',
 'Quelle défense adopter côté client ?',
 'Annuler la requête obsolète : AbortController dans le cleanup de useEffect, ou un drapeau « la requête est-elle encore la plus récente ? ». Ignorer le cleanup laisse la dernière réponse arrivée écrire l''état, quelle que soit sa pertinence — le classique bug de course (race condition) des effets asynchrones.',
 140, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('React : React.memo et props fonctionnelles', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Une liste mémoïse ses lignes avec React.memo, mais les performances ne bougent pas : le parent passe un callback onSelect={id => select(id)} et un objet de style créé au rendu.',
 'Pourquoi la mémoïsation ne protège-t-elle pas ici ?',
 'React.memo compare les props en shallow equality : fonction flèche créée à chaque rendu et objet/littéral inline sont toujours référentiellement neufs, donc l''enfant re-rend quand même. Il faut useCallback/useMemo en amont ou passer des primitives stables — sinon la mémoïsation ne fait que consommer de la mémoire pour rien.',
 150, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('React : useReducer plutôt que useState', 'SITUATIONAL_QCM', 'MULTIPLE_CHOICE', 'INTERMEDIATE',
 'Un écran de formulaire multi-étapes gère 8 states liés (étape, données, erreurs, touched, submitting, erreur serveur…), avec des transitions comme RESET, NEXT, VALIDATE_ERROR.',
 'Quand un useReducer devient-il le bon outil ?',
 'Quand plusieurs états forment une machine à états : le reducer regroupe les transitions en actions explicites, évite les mises à jour intermédiaires incohérentes et rend les cas testables sans le rendu. Ce n''est ni obligatoire ni magique : pour 1 ou 2 states indépendants, useState reste plus lisible. Lorsque le state dépasse ce que la page porte, c''est le store global (Redux, Zustand) qui entre en jeu.',
 150, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('React : clé générée à chaque rendu', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Un développeur utilise key={uuidv4()} dans le map d''une liste, les formulaires perdent leur contenu à chaque frappe parente et le scroll saute.',
 'Quelle est la cause racine et le correctif ?',
 'Une clé nouvelle à chaque rendu démonte/remonte tous les éléments, effaçant leur état local et leurs nœuds DOM. La clé doit être stable dans le temps : identifiant métier (id) ; à défaut, une valeur dérivée de la donnée. La génération de clé n''a de sens que pour des éléments réellement interchangeables et sans état.',
 140, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('React : remonter l''état (lift state up)', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Deux composants frères, le filtre et le tableau, ont chacun leur copie de la liste ; modifier le filtre ne met pas le tableau à jour (ou l''inverse, avec un délai).',
 'Quel patron de composition rétablit la cohérence ?',
 'Remonter l''état au plus proche ancêtre commun qui le possède déjà (état dérivé) : le parent détient la source, redescend filtre + liste filtrée et reçoit les callbacks de modification. L''alternative — dupliquer l''état ou le synchroniser par effet — reconstruit le bug de double vérité de déclaration.',
 130, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('React : dériver la liste filtrée plutôt que la dupliquer', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Un écran stocke results (résultats affichés) et le met à jour dans useEffect quand query change. Parfois results et query divergent (affichage d''anciens résultats).',
 'Quelle refactorisation supprime ce type de bug ?',
 'Ne pas stocker ce qui est calculable : result = useMemo(() => filtrer(query), [query]) directement au rendu. On élimine l''état dérivé, la fenêtre de désynchronisation de l''effet et les re-rendus inutiles. L''état ne doit porter que l''information irréductible (la query, l''état de chargement, le cache distant).',
 140, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('React : coût du filtrage à chaque rendu', 'SITUATIONAL_QCM', 'MULTIPLE_CHOICE', 'INTERMEDIATE',
 'Une liste de 10 000 éléments filtre et trie dans le corps du composant à chaque rendu ; le champ de saisie devient saccadé.',
 'Quelles optimisations sont pertinentes (plusieurs réponses) ?',
 'Memoïser la dérivation (useMemo sur le filtre) tant que query ne change pas ; virtueliser la liste pour ne rendre que la fenêtre visible ; découper le champ de son parent (état local + remontée ciblée) pour limiter le périmètre de re-rendu ; batcher les mises à jour. L''ordre compte : mesurer d''abord (Profiler), optimiser ensuite — sinon on ne fait qu''ajouter de la complexité.',
 160, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('React : Contexte et re-rendus', 'SITUATIONAL_QCM', 'MULTIPLE_CHOICE', 'INTERMEDIATE',
 'Une app met le thème, la session et les notifications dans un Contexte unique dont la valeur est un objet reconstruit à chaque rendu de App. Toutes les pages flickent au moindre changement.',
 'Quelles constations et parades sont correctes ?',
 'La valeur de contexte reconstruitée à chaque rendu re-rend tous les consommateurs : découper les contextes par domaine (session / thème / features) ; passer des primitives ou memoïser la valeur ; isoler les parties volatiles (notifications à haute fréquence séparées de la session) ; pour des lectures très sélectives, un store avec sélecteurs restreint le re-rendu aux seuls abonnés concernés.',
 170, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('React : mise à jour optimiste (optimistic UI)', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Un toggle "favori" affiche immédiatement l''icône active avant la réponse du serveur, mais si l''API échoue, l''icône reste active à tort et l''utilisateur croit son choix enregistré.',
 'Quelle séquence corrige le défaut sans perdre la réactivité ?',
 'Optimiste d''abord (état local à l''état souhaité), puis envoi, puis réconciliation : sur succès on garde (ou on adopte l''état confirmé par le serveur), sur échec on restaure l''état précédent et on signale l''erreur. Sans branche de rollback, l''optimisme devient un mensonge persistant ; l''état du serveur reste la vérité.',
 150, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('React : longue liste et virtualisation', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Un journal d''activité rend 50 000 lignes d''un coup : la page met plusieurs secondes à s''afficher et le scroll est saccadé sur les appareils modestes.',
 'Quelle approche traite la cause plutôt que le symptôme ?',
 'La virtualisation : ne rendre que la fenêtre visible (hauteur fixe + scroll synthétique, ou bibliothèque type react-window/tanstack-virtual). Le DOM reste petit. Corollaire : clés stables sur la fenêtre, mesure avant/après, et mise à disposition paginée côté données si le jeu excède ce qui tient en mémoire confortablement.',
 150, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('React : code splitting d''une application monolithique', 'SITUATIONAL_QCM', 'MULTIPLE_CHOICE', 'INTERMEDIATE',
 'Le bundle principal dépasse 2 Mo ; le premier écran (page d''accueil) ne sert que 20 % du code (admin, graphes, éditeur de code à peine utilisés).',
 'Quelles mesures réduisent réellement le temps au premier rendu ?',
 'Découper par route avec React.lazy + Suspense (chunks au moment de la visite) ; dynamiser les lourdes dépendances (éditeur, graphiques) au point d''usage ; vérifier le tree-shaking (exports nommés, pas de side-effects globales) ; auditer les doublons. Ce qui ne aide pas : compresser un peu plus un bundle qu''on continue de télécharger en entier.',
 160, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('React : règles des hooks', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Un composant appelle useState dans une branche if (si isAdmin) sinon un autre montage. En production, les champs se désynchronisent après un changement de rôle.',
 'Pourquoi l''ordre des hooks doit-il être inconditionnel ?',
 'React repère chaque hook par sa position dans l''ordre d''appel du rendu : une branche conditionnelle modifie cette position entre deux rendus et React associe alors les valeurs aux mauvais hooks (voire plante). Les données conditionnelles se gèrent à l''intérieur d''un seul hook (objet, reducer, dérivation), jamais en ajoutant ou retirant un appel.',
 140, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('React : useRef pour ce qui ne doit pas re-rendre', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Un composant met dans un state l''identifiant d''un minuteur et le dernier événement clavier, provoquant des re-rendus invisibles pour l''utilisateur à chaque tic.',
 'Quel outil porte ces valeurs et pourquoi ?',
 'useRef : mutable, identique d''un rendu à l''autre, sans déclencher de re-rendu. On y place les identifiants de timers/intervalles, les nœuds DOM, les valeurs techniques purement internes. Le state reste réservé à ce qui doit apparaître dans le rendu ; confondre les deux surpaie en rendus.',
 140, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('React : re-rendu en boucle', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'ADVANCED',
 'Un écran réaffiche en boucle et le CPU monte : un useEffect liste un objet créé au corps du composant sans dépendances et appelle setState quand la référence change.',
 'Diagnostic le plus probable ?',
 'L''objet littéral a une référence nouvelle à chaque rendu ; l''effet le considère comme modifié, déclenche setState, donc un nouveau rendu, donc un nouvel objet… boucle infinie. Dépendances correctes (valeurs stables, useMemo sur l''objet) ou effet piloté par des valeurs primitives cassent la boucle. Le linter exhaustive-deps signale ce piège avant la prod.',
 150, true, 20, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('React : rendu concurrent et transitions', 'SITUATIONAL_QCM', 'MULTIPLE_CHOICE', 'ADVANCED',
 'Une app React 18 doit filtrer un grand jeu de données dans l''écran au changement d''un onglet : l''interface gèle pendant le calcul et l''utilisateur ne peut plus cliquer.',
 'Quelles stratégies du mode concurrent s''appliquent ?',
 'useTransition marque la mise à jour lourde comme non urgente : React peut l''interrompre et garder l''UI réactive (l''onglet réagit immédiatement, le tableau arrive ensuite). Compléments : Suspense pour les rendus en attente (requis par startTransition), dériver plutôt que calculer en boucle, et server-side rendering/selective hydration côté SSR. Le concurrent n''annule pas la nécessité de mesurer : il améliore la perception, pas le coût total.',
 170, true, 20, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('React : arbitrage mémoïsation globale', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'ADVANCED',
 'Une équipe a décoré l''arbre de useMemo, useCallback et React.memo partout « pour les perfs ». Le code est difficile à lire et les gains mesurés sont proches de zéro.',
 'Quelle position est la plus sage en entretien ?',
 'La mémoïsation a un coût (allocation, comparaison, invalidation) et ne rapporte que si le composant re-rend cher et souvent avec des props réellement stables. D''abord mesurer (React Profiler), éliminer les re-rendus évitables à la source (structure d''état, découpage), puis cibler les quelques points chauds. Mémoïser par défaut dégrade la lisibilité pour un gain rarement démontré.',
 150, true, 20, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('React : frontière d''erreur par région', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'ADVANCED',
 'Un bug de parsing dans un panneau latéral fait tomber tout l''écran blanc, y compris la navigation qui fonctionnait pourtant.',
 'Quelle architecture de résilience retenir ?',
 'Des Error Boundaries délimités par région (panneau, route) captent l''erreur de rendu et offrent un repli local (retry, message, état précédent) sans emporter l''application. Côté données, distinguer ce qui est récupérable (erreur serveur → toast + retry) de l''erreur de code (→ boundary + journal). Une boundary unique en racine ne fait que transformer le crash global en blanc un peu plus propre.',
 150, true, 20, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('React : re-rendus invisibles — stratégie de debug', 'SITUATIONAL_QCM', 'MULTIPLE_CHOICE', 'ADVANCED',
 'Un dashboard est lent : le Profiler montre des centaines de rendus par seconde sur des composants qui « ne font rien ». Il faut retrouver la cause.',
 'Quels outils et causes types mobiliser ?',
 'Marquer les rendus (log dans le corps du composant, Highlight updates) pour localiser ; lister les déclencheurs types : props objets/fonctions recréées (mémoïsation inefficace), setState dans un effet dépendant d''une nouvelle référence, contexte global modifié à chaque frappe, listeners non nettoyés. Prioriser par coût réel : un composant « qui ne fait rien » devient grave quand il est appelé 300 fois par seconde dans une liste large.',
 160, true, 20, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('React : migrer un formulaire local vers un état partagé', 'PROBLEM_SOLVING', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Un formulaire de création de projet (12 champs, listes dépendantes, brouillon enregistré) est réparti entre trois composants qui se transmettent des props en cascade ; l''équipe doit l''exposer dans une modale et une page dédiée.',
 'Proposez la démarche de refactorisation complète : diagnostic, découpage de l''état, contrat des composants, persistance du brouillon et tests.',
 'Diagnostic : état dispersé et props drilling profond, double vérité sur le brouillon. Démarche : cartographier chaque champ et son producteur/consommateur ; regrouper l''état du formulaire dans un useReducer (champs + erreurs + touched + statut envoi) au niveau du plus petit ancêtre partagé ; rendre les champs contrôlés simples autour de la même source ; exposer des callbacks nommés (setField, validate, submit) plutôt que des setters bruts ; persister le brouillon dans un effet dédié (debounce) avec état de sauvegarde ; découper l''UI en sous-composants sans état ; tests : rendu, validation par champ, envoi, restauration du brouillon. Piège à éviter : dupliquer l''état dans la modale et la page — une seule source, montée à l''endroit où l''écran vit.',
 900, true, 30, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('React : audit et correction des performances d''une liste', 'PROBLEM_SOLVING', 'SINGLE_CHOICE', 'ADVANCED',
 'La page d''inventaire (20 000 articles, filtres combinés, tri, sélection multiple) devient inutilisable sur portable moyen : la saisie du filtre a 300 ms de retard. Aucun budget de performance n''existe.',
 'Décrivez la démarche complète : mesurer, hiérarchiser les causes, corriger dans l''ordre d''impact, puis empêcher la régression.',
 'Mesure d''abord : React Profiler (re-rendus et commits), performance.now autour du filtrage, onglet Performance du navigateur (long tasks), network. Causes types à tester dans l''ordre : filtrage/tri non mémoïsés recalculés à chaque frappe (useMemo + debounce sur query) ; DOM complet rendu au lieu d''une virtualisation ; champs filtre éloignés de leur état (re-rendu de tout le tableau par frappe) ; props recréées empêchant la mémoïsation des lignes ; setState éclaté en plusieurs commits (batching, actions). Après correction : revérifier au Profiler, poser un budget (ex. rendu < 16 ms, bundle < 250 ko gzip) et un test de non-régression. Piège classique : optimiser le tri alors que le vrai coût est le rendu de 20 000 nœuds — jamais corriger sans mesure.',
 900, true, 30, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('React : sortir un état global du contexte monolithique', 'PROBLEM_SOLVING', 'SINGLE_CHOICE', 'ADVANCED',
 'Toute l''application lit un AppContext unique (auth, thème, filtres de recherche, notifications, feature flags) dont la valeur est reconstruite à chaque mutation. L''UI re-rend en cascade à chaque notification.',
 'Comment découper progressivement cette architecture, et quelles garanties de non-régression mettre en place ?',
 'Démarche : répertorier les lectures réelles (quels composants consomment quelles tranches) ; découper par domaine de fréquence et de sensibilité (session pérenne / thème / notifications volatiles / filtres de page) en contextes séparés, ordonnés du plus volatile au plus stable ; passer des valeurs primitives ou mémoïser la valeur du provider ; là où les lectures sont fines et fréquentes, remplacer l''écriture globale par un store avec sélecteurs (abonnement ciblé). Migration progressive : ancien contexte en façade déléguant aux nouveaux, bascule composant par composant avec tests de rendu et capture des subscriptions ; supprimer l''ancien à la fin. Garanties : tests de non-régression sur les écrans critiques et mesure du nombre de rendus avant/après.',
 900, true, 30, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('React : ordonner la remontée d''état dans un écran partagé', 'SEQUENTIAL_REASONING', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Le filtre et le tableau d''une page doivent partager leur état ; l''équipe veut éviter la copie divergente vue en sprint précédent.',
 'Place ces étapes dans l''ordre de la démarche recommandée.',
 'Le cheminement : comprendre les flux (qui lit quoi), placer la vérité au plus proche du commun, ne descendre que du sens unique props + callbacks, dériver le calcul au rendu, puis verrouiller par tests. Toute autre hiérarchie reconstruit un état dupliqué ou un effet de synchronisation fragile.',
 300, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('React : protocole de debug d''un état aléatoire', 'SEQUENTIAL_REASONING', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Un panier perd parfois son contenu après plusieurs actions, sans reproduction fiable. L''équipe veut une démarche structurée.',
 'Place ces étapes dans l''ordre logique du diagnostic.',
 'Le bon ordre : figer la reproduction (journal des actions), rendre visible le flux d''état (log des transitions), localiser le point de divergence (composant / action fautive), formuler puis vérifier l''hypothèse (mutation ? clé ? double source ? effet ?), corriger à la racine, et tester la non-régression. Corriger au premier symptôme sans reproduction laisse le bug fuiter ailleurs.',
 300, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('React : introduction mesurée d''un store global', 'SEQUENTIAL_REASONING', 'SINGLE_CHOICE', 'ADVANCED',
 'Un store global (Zustand/Redux) doit remplacer un contexte monolithique sans réécriture big bang.',
 'Place ces étapes dans l''ordre d''une migration progressive sûre.',
 'La trajectoire sûre : cartographier les lectures/écritures réelles, découper les domaines, créer le store par tranche en doublon avec l''ancien, migrer composant par composant avec tests, faire de l''ancien contexte une façade déléguante, puis supprimer les chemins morts. Bascule d''un seul coup = explosion de régressions invisibles sur les écrans non testés.',
 360, true, 20, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('React : valider un formulaire de bout en bout', 'SEQUENTIAL_REASONING', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Un formulaire critique (inscription) doit éviter les erreurs réseau comme les saisies invalides, sans gêner l''utilisateur.',
 'Place ces étapes dans l''ordre de l''implémentation recommandée.',
 'L''ordre : définir le schéma des règles (côté modèle), les refléter côté client pour l''UX (validation par champ au touched, messages localisés), soumettre en état verrouillé (désactivation + feedback), rester autoritaire côté serveur (revalidation + erreurs remontées par champ), enfin tester chaque couche. La validité client est un confort, jamais une garantie : le serveur décide.',
 300, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
) AS v(title, type, selection_type, difficulty, context, question, explanation, estimated_time_seconds, active, points, created_at, updated_at)
WHERE NOT EXISTS (SELECT 1 FROM challenges c WHERE c.title = v.title);

-- -----------------------------------------------
-- Options des QCM (SINGLE : 1 correcte — MULTIPLE : 2-3 correctes)
-- -----------------------------------------------

-- React : clé de liste — le piège de l'index
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('L''index comme clé réutilise le composant physique pour une autre donnée : son état local suit la position, pas la tâche.', true, 1,
 'Les clés identifient les éléments entre les rendus : index = identité par position.'),
('C''est un simple avertissement console sans impact fonctionnel.', false, 2,
 'L''avertissement existe (chez les libs de liste), mais le bug d''état réaffecté est bien réel.'),
('La clé index est interdite par React qui refuse de rendre la liste.', false, 3,
 'React l''accepte et rend ; c''est la cohérence de l''état qui sape.'),
('Il suffit d''ajouter un setTimeout avant le réordonnancement.', false, 4,
 'Aucun délai ne corrige un appariement d''état fondé sur la position.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'React : clé de liste — le piège de l''index'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- React : les props sont un contrat en lecture seule
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('La mutation casse l''unicité de la source de vérité : React ne re-rend pas le parent et le rendu se désynchronise.', true, 1,
 'Le state du parent reste inchangé : sa copie affichée ne connaît pas la modification.'),
('Les props sont simplement lues plus lentement après mutation.', false, 2,
 'La vitesse n''y est pas : le parent ignore la mutation.'),
('React jette les props mutées au prochain montage.', false, 3,
 'Aucun mécanisme de ce type ; les objets props restent en mémoire.'),
('C''est autorisé tant que le composant est fonctionnel.', false, 4,
 'Le type de composant ne change pas la règle de lecture seule.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'React : les props sont un contrat en lecture seule'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- React : quand s'exécute un useEffect ?
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Le tableau déclenche l''effet seulement quand une dépendance change ; [] = montage/démontage.', true, 1,
 'Le second argument borne le déclenchement aux valeurs listées.'),
('Sans tableau, React optimise et n''exécute l''effet qu''une seule fois.', false, 2,
 'À l''inverse : sans tableau il part à chaque rendu.'),
('Le tableau remplace la fonction de nettoyage.', false, 3,
 'Le cleanup est la fonction retournée, distincte des dépendances.'),
('Il s''applique uniquement aux composants classe.', false, 4,
 'useEffect vaut pour les composants fonctionnels — c''''est son contrat.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'React : quand s''exécute un useEffect ?'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- React : fermeture périmée dans un handler
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Le closure capture la valeur de remaining au montage ; l''effet ne voit jamais la mise à jour.', true, 1,
 'Le closure fige le contexte du rendu où il a été créé.'),
('setInterval ne fonctionne pas dans React 18.', false, 2,
 'Le timer fonctionne ; c''''est la valeur captée qui est périmée.'),
('Les secondes dépassent la capacité du state.', false, 3,
 'Le state gère très bien les nombres ; le problème est la capture.'),
('Il faut forcer un re-rendu global toutes les secondes.', false, 4,
 'Le re-rendu existe déjà via setRemaining — reste à lire la bonne valeur.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'React : fermeture périmée dans un handler'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- React : champ contrôlé ou non contrôlé
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Champ contrôlé : value est piloté par un state qu''un reset réécrivait ; corriger l''initialisation/la remise à zéro.', true, 1,
 'Dans un champ contrôlé, c''est le state qui décide de la valeur affichée.'),
('Champ non contrôlé : il faut ajouter un value pour rétablir la saisie.', false, 2,
 'Ajouter value sans state piloté ne fait qu''aggraver le conflit.'),
('React interdit la saisie utilisateur sur plus de deux caractères.', false, 3,
 'Aucune telle limite n''existe.'),
('Il faut debounce la saisie pour conserver le texte.', false, 4,
 'Le debounce agit sur la fréquence, pas sur l''écrasement de la valeur.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'React : champ contrôlé ou non contrôlé'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- React : éviter le double état dérivé
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Deux sources de vérité pour une même donnée, resynchronisées par effet : fenêtre de désynchronisation garantie.', true, 1,
 'La copie locale et la prop divergent dès qu''une des deux bouge sans que l''effet rattrape.'),
('React interdit le useState pour une liste reçue en props.', false, 2,
 'Aucune interdiction — c''est un problème de conception, pas de syntaxe.'),
('Le problème vient du rendu en StrictMode.', false, 3,
 'StrictMode double les montages en dev, mais le double état pose problème partout.'),
('Il faut déplacer le state dans localStorage.', false, 4,
 'Persister ne supprime pas la double vérité, elle devient triple.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'React : éviter le double état dérivé'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- React : race condition de chargement
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Annuler la requête obsolète (AbortController dans le cleanup) ou ignororer toute réponse qui n''est plus la dernière en date.', true, 1,
 'Seule la réponse de la requête la plus récente a le droit d''écrire l''état.'),
('Augmenter le debounce à plusieurs secondes pour laisser le temps aux réponses.', false, 2,
 'Masque le symptôme sans garantir l''ordre : une réponse lente peut quand même arriver en dernier.'),
('Afficher toutes les réponses en superposition jusqu''à la suivante.', false, 3,
 'Surcharge l''écran sans résoudre le conflit d''écriture.'),
('Désactiver React.memo sur le champ de recherche.', false, 4,
 'La mémoïsation n''a aucun lien avec l''ordre des réponses réseau.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'React : race condition de chargement'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- React : React.memo et props fonctionnelles
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('La comparaison est référentielle : fonction flèche et objet inline sont recréés à chaque rendu, donc la mémoïsation ne bloque rien.', true, 1,
 'Shallow equality sur des références toujours neuves = re-rendu permanent.'),
('React.memo ne fonctionne qu''avec les classes.', false, 2,
 'Il s''applique aux composants fonctionnels — c''est son cas d''usage principal.'),
('Il faut remplacer React.memo par shouldComponentUpdate.', false, 3,
 'shouldComponentUpdate est l''équivalent des classes, pas une correction.'),
('Le parent doit forcer un re-rendu global pour réactiver la mémo.', false, 4,
 'Ajouter des re-rendus aggrave le problème au lieu de le réparer.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'React : React.memo et props fonctionnelles'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- React : useReducer plutôt que useState
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Quand plusieurs states dépendent de transitions communes (RESET, NEXT, SUBMIT_ERROR) : le reducer les rend atomiques et testables.', true, 1,
 'Un reducer centralise les transitions et évite les états intermédiaires incohérents.'),
('Toujours : un reducer est plus rapide que useState.', false, 2,
 'La performance n''est pas le critère : pour un booléen, useState reste mieux.'),
('Jamais : les reducers sont dépréciés en React 19.', false, 3,
 'Les reducers restent un outil standard du modèle React.'),
('Uniquement pour synchroniser deux contextes.', false, 4,
 'Le découpage de contextes est une autre préoccupation.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'React : useReducer plutôt que useState'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- React : clé générée à chaque rendu
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('La clé change à chaque rendu : React démonte et remonte les éléments, effaçant leur état local et le DOM associé.', true, 1,
 'Nouvelle clé = nouvel identité = reconstruction complète de l''élément.'),
('uuid() est incompatible avec JSX et casse le rendu au moment du typage.', false, 2,
 'Le rendu fonctionne — c''est sa stabilité qui manque.'),
('React exige des clés numériques uniquement.', false, 3,
 'Les clés string sont parfaitement valides et courantes.'),
('Le problème vient de l''absence de React.memo sur chaque ligne.', false, 4,
 'La mémoïsation ne change pas la destruction causée par la clé instable.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'React : clé générée à chaque rendu'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- React : remonter l'état (lift state up)
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Placer l''état au plus proche ancêtre commun et ne redescendre que props + callbacks.', true, 1,
 'Une source unique descend aux deux frères, qui ne font que la lire/la signaler.'),
('Dupliquer l''état dans les deux frères et les resynchroniser toutes les secondes.', false, 2,
 'Reconstruit le double état et la fenêtre de désynchronisation.'),
('Stocker l''état dans localStorage pour que les deux frères le lisent.', false, 3,
 'Persistance ≠ partage temps réel ; le re-rendu n''est pas déclenché.'),
('Convertir les deux frères en composants classe héritant du même parent.', false, 4,
 'L''héritage de classe ne crée pas de source d''état commune.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'React : remonter l''état (lift state up)'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- React : dériver la liste filtrée plutôt que la dupliquer
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Ne stocker que la query et dériver les résultats au rendu (useMemo) : plus de double vérité ni de fenêtre de désynchronisation.', true, 1,
 'Ce qui se calcule n''est pas un état : le calcul suit mécaniquement l''entrée.'),
('Ajouter un useEffect qui remet results à jour en cas de divergence détectée.', false, 2,
 'Soigner un symptôme structurel par un autre effet reconstruit le même bug.'),
('Conserver les deux states et forcer un re-rendu global à chaque frappe.', false, 3,
 'Renforce le couplage sans rétablir la cohérence.'),
('Déléguer le filtrage au serveur via un endpoint pour toute taille de liste.', false, 4,
 'Valable pour des jeux distants, mais ne supprime pas la double source quand le filtre est local.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'React : dériver la liste filtrée plutôt que la dupliquer'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- React : coût du filtrage à chaque rendu
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Memoïser le dérivé (useMemo) et ne recalculer que quand query change.', true, 1,
 'Évite le tri/filtre à chaque rendu sans rapport avec la saisie.'),
('Virtueliser la liste pour rendre uniquement la fenêtre visible.', true, 2,
 'Attaque le coût du DOM, souvent dominant sur 10 000 éléments.'),
('batcher les setState dans un requestAnimationFrame maison.', false, 3,
 'React batch déjà les mises à jour : doublon inutile.'),
('Remplacer le champ contrôlé par un champ non contrôlé sans state.', false, 4,
 'Supprime le lien query/liste et casse la fonctionnalité de filtrage.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'React : coût du filtrage à chaque rendu'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- React : Contexte et re-rendus
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('La valeur reconstruite à chaque rendu re-rend tous les consommateurs : découper par domaine et stabiliser la valeur.', true, 1,
 'Un contexte par fréquence de changement limite le périmètre des re-rendus.'),
('Isoler les notifications volatiles dans un contexte séparé de la session pérenne.', true, 2,
 'Séparer par fréquence : seuls les abonnés aux notifications bougent quand elles arrivent.'),
('Passer l''objet de contexte en prop sur chaque page pour le figer.', false, 3,
 'Une nouvelle référence à chaque rendu ne fige rien.'),
('Supprimer le Contexte et refaire un props drilling complet.', false, 4,
 'Recrée le problème initial avec plus de bruits — le découpage suffit.'),
('Le re-rendu des consommateurs est impossible : le Contexte verrouille l''arbre.', false, 5,
 'Tout consommateur re-rend quand la valeur change — c''est la règle.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'React : Contexte et re-rendus'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- React : mise à jour optimiste (optimistic UI)
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Optimiste immédiatement, puis confirmer au succès et restaurer l''état précédent + message d''erreur à l''échec.', true, 1,
 'L''optimisme s''accompagne obligatoirement d''une branche de rollback.'),
('Attendre la réponse du serveur sans jamais modifier l''écran.', false, 2,
 'Correct et sûr, mais perd la réactivité — ce n''est pas la parade à l''échec, c''est l''abandon de l''optimisme.'),
('Conserver l''état optimiste quoi qu''arrive pour ne pas frustrer l''utilisateur.', false, 3,
 'Laisse un écran qui ment : l''action n''est pas enregistrée.'),
('Réessayer indéfiniment en boucle jusqu''à succès.', false, 4,
 'Masque l''erreur sans feedback ni limite.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'React : mise à jour optimiste (optimistic UI)'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- React : longue liste et virtualisation
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Virtualiser : ne rendre que la fenêtre visible pour garder un DOM petit.', true, 1,
 'Le DOM passe de dizaines de milliers de nœuds à quelques dizaines.'),
('Augmenter la mémoire du navigateur au niveau navigateur.', false, 2,
 'Ne traite ni le coût de création du DOM ni le temps de rendu initial.'),
('Passer la liste en tableau HTML brut (innerHTML) pour aller plus vite.', false, 3,
 'Perte du modèle React, des gestionnaires d''événements et de la sécurité d''échappement.'),
('Supprimer les clés de la liste pour réduire la réconciliation.', false, 4,
 'Les clés ne coûtent pas cher ; les retirer crée des bugs d''état.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'React : longue liste et virtualisation'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- React : code splitting d'une application monolithique
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('React.lazy + Suspense par route : le code non visité n''est pas téléchargé au premier rendu.', true, 1,
 'Le chunk lourd (admin, éditeur) ne part qu''à la visite effective.'),
('Dynamiser les dépendances lourdes (éditeur, graphiques) à leur point d''usage.', true, 2,
 'Le composant de première page ne paie pas le poids des modules de fond.'),
('Remplacer les images par des composants texte pour réduire le bundle JS.', false, 3,
 'Les images ne pèsent pas dans le bundle JS — autre canal, autre budget.'),
('Compiler le projet en mode développement pour diagnostiquer le poids.', false, 4,
 'Le mode dev gonfle artificiellement les bundles : mesure trompeuse.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'React : code splitting d''une application monolithique'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- React : règles des hooks
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('React indexe les hooks par position : une branche conditionnelle décale l''ordre et associe les valeurs aux mauvais hooks.', true, 1,
 'La position est l''identité d''un hook entre deux rendus.'),
('Les hooks conditionnels sont refusés au montage initial uniquement.', false, 2,
 'Ils passent parfois au montage — c''est la désynchronisation ultérieure qui tue.'),
('React rafraîchit les hooks conditionnels au changement de props.', false, 3,
 'Aucun mécanisme de rafraîchissement : les valeurs restent décalées.'),
('C''est un avertissement de développement sans effet en production.', false, 4,
 'La désynchronisation d''état survient aussi en production.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'React : règles des hooks'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- React : useRef pour ce qui ne doit pas re-rendre
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('useRef : valeur mutable conservée entre rendus sans déclencher de re-rendu.', true, 1,
 'Identifiant de timer et dernière touche sont des métadonnées techniques invisibles du rendu.'),
('useState avec null initial pour conserver la même référence.', false, 2,
 'setState provoque un re-rendu — exactement ce qu''on veut éviter.'),
('useMemo retournant un tableau [value, setValue].', false, 3,
 'Le memo ne réduit pas les re-rendus provoqués par le state.'),
('Les placer dans le localStorage pour éviter les rendus.', false, 4,
 'Persistance hors périmètre : le composant perdrait la valeur courante en mémoire.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'React : useRef pour ce qui ne doit pas re-rendre'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- React : re-rendu en boucle
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Objet de dépendance recréé à chaque rendu → effet qui setState à chaque passage → boucle infinie.', true, 1,
 'La référence toujours nouvelle du dépendant déclenche indéfiniment l''effet.'),
('React plante car setState est interdit dans un useEffect.', false, 2,
 'setState y est parfaitement autorisé — c''est sa fréquence qui pose problème.'),
('Le composant appelle setState dans son corps de rendu.', false, 3,
 'Corps de rendu sans setState ici : l''effet est le moteur de la boucle.'),
('Le tableau de dépendances est trop long et dépasse la limite React.', false, 4,
 'Aucune limite de longueur : le souci est la stabilité des valeurs.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'React : re-rendu en boucle'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- React : rendu concurrent et transitions
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('useTransition rend la mise à jour lourde interruptible : l''UI reste réactive pendant le filtre.', true, 1,
 'La transition n''est pas urgente : React peut la relancer ou la différer.'),
('Suspense avec fallback met en cache le filtre précédent automatiquement.', true, 2,
 'Suspense orchestre l''affichage de repli pendant la résolution (requis par startTransition).'),
('Le mode concurrent supprime le besoin de diviser les composants.', false, 3,
 'Il n''annule pas le coût : découper reste nécessaire sur les arbres énormes.'),
('Il faut désactiver le batching des événements pour gagner en fluidité.', false, 4,
 'Le batching React 18 est déjà global ; le désactiver multiplie les rendus.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'React : rendu concurrent et transitions'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- React : arbitrage mémoïsation globale
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Mesurer d''abord, supprimer les re-rendus évitables à la source, puis mémoïser uniquement les points chauds.', true, 1,
 'La mémoïsation n''est rentable que sur un composant cher et fréquemment re-rendu.'),
('Mémoïser chaque composant de l''application par principe de précaution.', false, 2,
 'Coût permanent (complexité, allocations) pour un gain rarement démontré.'),
('Supprimer tous les useMemo pour simplifier, quoi qu''il arrive.', false, 3,
 'Rejeter aussi les cas réellement rentables : la mesure tranche.'),
('Attendre React Compiler pour ne plus jamais y penser.', false, 4,
 'Le compiler n''élimine pas les re-rendus structurels liés à l''architecture d''état.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'React : arbitrage mémoïsation globale'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- React : frontière d'erreur par région
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Des Error Boundaries par région capturent l''erreur de rendu et offrent un repli local sans emporter la navigation.', true, 1,
 'La frontière isole la panne à sa zone et le reste de l''app continue.'),
('Afficher un try/catch autour du JSX pour attraper l''erreur de rendu.', false, 2,
 'try/catch n''attrape pas les erreurs du rendu asynchrone React : c''est le rôle des boundaries.'),
('Reporter l''erreur vers le serveur et relancer l''application complète.', false, 3,
 'Journaliser est bien, mais ne protège pas l''utilisateur de l''écran blanc.'),
('Désactiver StrictMode pour supprimer les erreurs de composant.', false, 4,
 'StrictMode révèle des bugs ; le retirer les enterre.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'React : frontière d''erreur par région'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- React : re-rendus invisibles — stratégie de debug
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Journaliser les rendus et activer « Highlight updates » pour localiser la source des re-rendus.', true, 1,
 'Voir quel composant re-rend et à quelle fréquence oriente immédiatement l''investigation.'),
('Chercher dans le code toutes les fonctions flèches passées en prop (props recréées = mémoïsation inefficace).', true, 2,
 'C''est la cause n°1 de re-rendu évitable dans les listes mémoïsées.'),
('Désactiver React.memo partout pour uniformiser les performances.', false, 3,
 'Retire la seule défense en place sans traiter la cause.'),
('Forcer un shouldComponentUpdate global sur l''application.', false, 4,
 'N''existe pas pour les fonctionnels, et ne dit rien des déclencheurs réels.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'React : re-rendus invisibles — stratégie de debug'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- -----------------------------------------------
-- Code Review : options + snippets (code via INSERT classique pour contrôler les '' )
-- -----------------------------------------------

INSERT INTO challenges (
    title, type, selection_type, difficulty, context, question,
    code_snippet, code_language, explanation, estimated_time_seconds, active, points,
    created_at, updated_at
)
SELECT
    'React Review : effet sans annulation et état après démontage', 'CODE_REVIEW', 'MULTIPLE_CHOICE', 'INTERMEDIATE',
    'Un composant de profil doit charger les informations quand le paramètre d''URL id change. Il est monté/démonté fréquemment (navigation rapide entre profils).',
    'Quels problèmes identifiez-vous dans ce code ?',
    'useEffect(() => {
  fetch("/api/users/" + id)
    .then((r) => r.json())
    .then((data) => setProfile(data));
}, []);',
    'javascript',
    'Trois défauts : aucune annulation de la requête (la réponse la plus ancienne peut écrire l''état après la plus récente — race condition), setState potentiel sur composant démonté (fuite/avertissement), et un id passé dans la dépendance est bien mais sans cleanup les effets se chevauchent. Le pattern correct : cleanup avec AbortController (ou drapeau de fraîcheur) + dépendances complètes.',
    180, true, 20, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM challenges c WHERE c.title = 'React Review : effet sans annulation et état après démontage');

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('La requête n''est jamais annulée : la réponse la plus ancienne peut écrire l''état en dernier.', true, 1,
 'Sans AbortController, l''ordre d''arrivée des réponses ne garantit pas l''ordre des écritures.'),
('setState peut s''exécuter sur un composant démonté (fuite / avertissement).', true, 2,
 'La réponse arrive après le démontage : cleanup ou drapeau de fraîcheur requis.'),
('Le fetch devrait être appelé dans le corps du composant, pas dans un effet.', false, 3,
 'Un fetch au corps partirait à chaque rendu sans lien avec les dépendances.'),
('Il manque un React.memo autour de l''effet pour le performance.', false, 4,
 'React.memo ne s''applique pas aux effets — faux ordre d''idées.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'React Review : effet sans annulation et état après démontage'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenges (
    title, type, selection_type, difficulty, context, question,
    code_snippet, code_language, explanation, estimated_time_seconds, active, points,
    created_at, updated_at
)
SELECT
    'React Review : mutation directe du state', 'CODE_REVIEW', 'MULTIPLE_CHOICE', 'INTERMEDIATE',
    'Ce bouton ajoute un tag à un projet. Parfois le tag apparaît, parfois rien ne se passe au premier clic.',
    'Quels problèmes identifiez-vous dans ce code ?',
    'const addTag = () => {
  tags.push(newTag);      // tags = state
  setTags(tags);
  setNewTag("");
};',
    'javascript',
    'tags.push(...) mute le tableau du state (le même objet référentiel) : React compare la référence, ne détecte pas de changement et ne re-rend pas — d''où l''effet aléatoire selon que le parent re-rend par ailleurs. Le remède : nouveau tableau immuable (spread [...tags, newTag] ou méthode non mutable) ; corriger aussi la clé si elle est dérivée d''un index et la logique de doublon éventuelle.',
    160, true, 20, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM challenges c WHERE c.title = 'React Review : mutation directe du state');

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('push mute le tableau du state : la référence est identique, React ne re-rend pas.', true, 1,
 'L''état immuable est un contrat : nouvelle valeur = nouvelle référence.'),
('setTags devrait recevoir une fonction : setTags((t) => [...t, newTag]).', true, 2,
 'La forme fonctionnelle évite la référence périmée et impose l''immutabilité.'),
('newTag doit être un tableau et non une chaîne pour être accepté.', false, 3,
 'Le type de la valeur nouvelle n''est pas la cause du non-rendu.'),
('Il faut appeler addTag dans un useEffect pour déclencher le rendu.', false, 4,
 'L''effet ne corrige pas la mutation : il ajouterait un déclenchement artificiel.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'React Review : mutation directe du state'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenges (
    title, type, selection_type, difficulty, context, question,
    code_snippet, code_language, explanation, estimated_time_seconds, active, points,
    created_at, updated_at
)
SELECT
    'React Review : HTML injecté et données non fiables', 'CODE_REVIEW', 'MULTIPLE_CHOICE', 'INTERMEDIATE',
    'Un fil d''actualité affiche le contenu des messages en contournant l''échappement de JSX pour préserver le formatage d''origine.',
    'Quels problèmes identifiez-vous dans ce code ?',
    '<div dangerouslySetInnerHTML={{ __html: message.body }} />',
    'javascript',
    'dangerouslySetInnerHTML avec des données utilisateur est une porte d''entrée XSS : un message contenant du script s''exécute avec la session de la victime. Les alternatives : laisser React échapper (par défaut), sanitizer serveur/client (DOMPurify) avec liste blanche de balises si le formatage est requis, ou restreindre la saisie à la source. Le nom de l''API est un avertissement explicite.',
    160, true, 20, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM challenges c WHERE c.title = 'React Review : HTML injecté et données non fiables');

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('XSS : un corps malveillant injecté s''exécute dans la session de la victime.', true, 1,
 'Le HTML brut contourne l''échappement automatique de JSX.'),
('Sanitizer avec liste blanche de balises (DOMPurify) avant injection.', true, 2,
 'Si le formatage est requis, on filtre balises/attributs/scripts avant rendu.'),
('Échapper le HTML côté serveur puis le réinjecter tel quel.', false, 3,
 'Échapper puis réinjecter en HTML brut affiche les entités littérales, pas le format.'),
('Limiter la longueur du message à 280 caractères.', false, 4,
 'La longueur ne neutralise pas un script court.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'React Review : HTML injecté et données non fiables'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenges (
    title, type, selection_type, difficulty, context, question,
    code_snippet, code_language, explanation, estimated_time_seconds, active, points,
    created_at, updated_at
)
SELECT
    'React Review : dépendance obsolète dans un effet', 'CODE_REVIEW', 'SINGLE_CHOICE', 'INTERMEDIATE',
    'Le panneau de comments doit recharger quand la sélection change. L''équipe a verrouillé le tableau de dépendances pour éviter les requêtes répétées.',
    'Quel est le défaut principal et la bonne correction ?',
    'useEffect(() => {
  loadComments(selectionId);
  // eslint-disable-next-line react-hooks/exhaustive-deps
}, []);',
    'javascript',
    'L''effet s''exécute au montage et lit une sélection périmée : quand la sélection change, aucune requête ne repart (contenu d''un autre projet affiché). Corriger : lister [selectionId] comme vraie dépendance et annuler la requête dans le cleanup pour éviter les courses. Désactiver exhaustive-deps ne supprime pas la dépendance, il masque le bug.',
    150, true, 20, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM challenges c WHERE c.title = 'React Review : dépendance obsolète dans un effet');

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Le tableau de dépendances doit contenir selectionId ; l''effet court avec une valeur périmée.', true, 1,
 'Le commentaire désactivé ne supprime pas la dépendance, il enterre le symptôme.'),
('Il faut ajouter la fonction loadComments dans le tableau.', false, 2,
 'Faute secondaire : la vraie dépendance métier manquante est l''identifiant de sélection.'),
('Le défaut est l''absence de setTimeout autour du fetch.', false, 3,
 'Un délai ne lierait toujours pas l''effet à la sélection.'),
('loadComments doit être déplacé dans le corps du composant.', false, 4,
 'Au corps, il repartirait à chaque rendu sans rapport avec la sélection.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'React Review : dépendance obsolète dans un effet'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenges (
    title, type, selection_type, difficulty, context, question,
    code_snippet, code_language, explanation, estimated_time_seconds, active, points,
    created_at, updated_at
)
SELECT
    'React Review : effet dans le constructeur', 'CODE_REVIEW', 'MULTIPLE_CHOICE', 'INTERMEDIATE',
    'Un composant prépare ses données (abonnement aux messages et écoute clavier) dans son constructeur plutôt que dans un cycle d''effets.',
    'Quels problèmes identifiez-vous dans ce code ?',
    'constructor(props) {
  super(props);
  this.state = { messages: [] };
  socket.on("message", this.handleMsg);
  window.addEventListener("keydown", this.onKey);
}',
    'javascript',
    'Les effets secondaires n''appartiennent pas au constructeur : il s''exécute au montage non contrôlé (StrictMode → double montage), pas de lien avec les mises à jour de props, et surtout aucun mécanisme de nettoyage — l''abonnement et l''écoute survivent au démontage (fuites). Le remède : useEffect avec tableau de dépendances et fonction de cleanup (ou les hooks dédiés).',
    160, true, 20, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM challenges c WHERE c.title = 'React Review : effet dans le constructeur');

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Aucune fonction de nettoyage : abonnement et écoute clavier survivent au démontage (fuites mémoire).', true, 1,
 'useEffect(..., () => cleanup) est le seul endroit où désinscrire proprement.'),
('Les effets ne doivent pas s''exécuter dans le constructeur : montage non contrôlé + double exécution en StrictMode.', true, 2,
 'Le cycle d''effets porte le contrat monté/démonté que le constructeur ignore.'),
('Le constructeur ne peut pas recevoir props en argument.', false, 3,
 'Les props y sont bien transmises — ce n''est pas le défaut.'),
('socket.on n''existe pas en React 18.', false, 4,
 'L''API du socket est indépendante de React.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'React Review : effet dans le constructeur'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenges (
    title, type, selection_type, difficulty, context, question,
    code_snippet, code_language, explanation, estimated_time_seconds, active, points,
    created_at, updated_at
)
SELECT
    'React Review : composant monolithique', 'CODE_REVIEW', 'SINGLE_CHOICE', 'ADVANCED',
    'Ce composant de 1 200 lignes cumule la récupération des données, la logique métier du panier, la gestion des erreurs et le rendu de six sous-vues ; tout le state est dans un seul useState géant.',
    'Quel est le constat d''architecture le plus important et le découpage recommandé ?',
    'function CartPage() {
  const [cart, setCart] = useState(...);
  const [items, setItems] = useState(...);
  const [errors, setErrors] = useState(...);
  const [coupon, setCoupon] = useState(...);
  // + fetch, calculs promotion, rendu de 6 panneaux ...
}',
    'javascript',
    'La concentration de responsabilités rend le composant ingérable : chaque frappe re-rend tout et chaque changement risque six vues. Découper par responsabilité : hook de données dédié (useCart) isolant fetch/erreurs/état de chargement, logique métier en fonctions pures testables (prix, promotions), sous-composants de présentation sans état, state du domaine en reducer ou store selon le partage réel. L''objectif : rendre le changement local — modifier le rendu d''un panier sans rouvrir la logique du panier.',
    180, true, 20, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM challenges c WHERE c.title = 'React Review : composant monolithique');

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Séparer logique métier (fonctions pures), données (hook dédié) et présentation (sous-composants sans état).', true, 1,
 'Chaque couverture de changement ne touche plus qu''une responsabilité.'),
('Extraire un reducer ou un store pour le state du domaine partagé.', true, 2,
 'État multiple lié = transitions centralisées, testables hors rendu.'),
('Diviser le composant en six copies partageant le même useState géant.', false, 3,
 'Dupliquer l''état recrée la double vérité, découpage ou non.'),
('Encapsuler l''ensemble dans un React.memo pour limiter les re-rendus.', false, 4,
 'La mémoïsation masque le symptôme de perf sans réduire la complexité du fichier.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'React Review : composant monolithique'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- -----------------------------------------------
-- Raisonnement séquentiel : options (explications par rang)
-- -----------------------------------------------

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Cartographier les flux : qui lit, qui écrit chaque donnée du filtre et du tableau', true, 1,
 'On ne déplace que ce qu''on a cartographié : la carte des lectures précède le choix de l''emplacement.'),
('Placer la source de vérité au plus proche ancêtre commun (lift state up)', true, 2,
 'Le porteur de la vérité est l''élément partagé le plus bas — ni le frère, ni le store global.'),
('Ne redescendre que des props et des callbacks dans un sens unique', true, 3,
 'Descendants reçoivent, ancêtres reçoivent les signaux : un seul sens circule.'),
('Dériver la donnée calculée au rendu (filtre/tirage) sans la dupliquer', true, 4,
 'Le dérivé suit mécaniquement la source — pas d''état secondaire à synchroniser.'),
('Verrouiller par tests de rendu et tests d''interaction sur les deux frères', true, 5,
 'Les tests empêchent qu''une future modification recrée un état dupliqué.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'React : ordonner la remontée d''état dans un écran partagé'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Figer la reproduction : journaliser les actions menant au panier vidé', true, 1,
 'Sans reproduction fiable, toute correction est une hypothèse invérifiable.'),
('Rendre visible le flux : logger chaque transition d''état (avant/après)', true, 2,
 'On cherche le moment où la valeur devient fausse, pas le composant qui l''affiche.'),
('Localiser le point de divergence : composant, action ou effet fautive', true, 3,
 'La transition fausse désigne le coupable : mutation, clé, double source ou effet.'),
('Formuler puis vérifier l''hypothèse (reproduction + test échouant)', true, 4,
 'L''hypothèse devient un test qui échoue avant correction — preuve, pas intuition.'),
('Corriger à la racine puis ajouter le test de non-régression', true, 5,
 'Le test fige le diagnostic et bloque la récidive en CI.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'React : protocole de debug d''un état aléatoire'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Cartographier les lectures/écritures réelles du contexte monolithique', true, 1,
 'Ce qui n''est pas lu disparaît : la cartographie évite de migrer du mort.'),
('Découper les domaines (session, thème, notifications, filtres) par fréquence de changement', true, 2,
 'La découpe par volatilité limite le périmètre de re-rendu de chaque store.'),
('Créer le store tranche par tranche, en doublon avec l''ancien contexte', true, 3,
 'Coexistence temporaire : le nouveau se construit à l''abri de l''ancien.'),
('Migrer composant par composant avec tests de rendu', true, 4,
 'Chaque bascule est réversible et vérifiable — pas de big bang.'),
('Faire de l''ancien contexte une façade déléguant au store, puis supprimer les chemins morts', true, 5,
 'La façade découple la transition ; le nettoyage final supprime la double source.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'React : introduction mesurée d''un store global'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Définir le schéma des règles de validation (source unique côté modèle)', true, 1,
 'Les règles vivent une fois, partout répliquées — client et serveur.'),
('Valider côté client au « touched » avec messages par champ (UX)', true, 2,
 'Feedback immédiat sans harceler l''utilisateur à chaque frappe.'),
('Verrouiller la soumission (état submitting, désactivation, feedback)', true, 3,
 'Empêche les doubles envois et donne la visibilité du traitement.'),
('Revalider côté serveur et remonter les erreurs par champ', true, 4,
 'Le serveur reste l''autorité : le client n''est qu''un confort.'),
('Tester chaque couche (schéma, champs, soumission, erreur serveur)', true, 5,
 'La chaîne n''est solide que si chaque maillon est couvert.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'React : valider un formulaire de bout en bout'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- -----------------------------------------------
-- Skill React (créé ici : V6 n'en insère que 4) — idempotent
-- -----------------------------------------------

INSERT INTO skills (name, description)
SELECT 'React', 'React, hooks, état, rendu et écosystème front-end.'
WHERE NOT EXISTS (SELECT 1 FROM skills s WHERE s.name = 'React');

INSERT INTO challenge_categories (challenge_id, category_id)
SELECT c.id, cat.id
FROM challenges c, categories cat
WHERE cat.name = 'React'
  AND c.title LIKE 'React%'
  AND NOT EXISTS (SELECT 1 FROM challenge_categories cc WHERE cc.challenge_id = c.id AND cc.category_id = cat.id);

INSERT INTO challenge_skills (challenge_id, skill_id)
SELECT c.id, s.id
FROM challenges c, skills s
WHERE c.title LIKE 'React%'
  AND (
    (c.type IN ('SITUATIONAL_QCM', 'PROBLEM_SOLVING') AND s.name = 'React')
    OR (c.type = 'CODE_REVIEW' AND s.name = 'Code Review')
    OR (c.type = 'SEQUENTIAL_REASONING' AND s.name = 'Problem Solving')
  )
  AND NOT EXISTS (SELECT 1 FROM challenge_skills cs WHERE cs.challenge_id = c.id AND cs.skill_id = s.id);

INSERT INTO challenge_profiles (challenge_id, profile_id)
SELECT c.id, p.id
FROM challenges c, profiles p
WHERE p.code = 'DEVELOPER'
  AND c.title LIKE 'React%'
  AND NOT EXISTS (SELECT 1 FROM challenge_profiles cp WHERE cp.challenge_id = c.id AND cp.profile_id = p.id);

-- Vérification rapide attendue : 37 défis React (24/3/6/4 par type).
-- SELECT c.type, count(*) FROM challenges c WHERE c.title LIKE 'React%' GROUP BY c.type;
