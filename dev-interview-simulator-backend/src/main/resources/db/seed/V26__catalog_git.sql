-- ===============================================
-- Catalogue V1 — Profil Développeur — catégories manquantes
-- V26 : Git (28 défis — 20 QCM, 3 problem-solving, 1 code review,
--       4 raisonnement séquentiel)
-- Idempotent : WHERE NOT EXISTS sur challenges.title (jamais utilisé).
-- Même structure que l'import JSON futur : challenges + challenge_options
--   (content / is_correct / display_order / explanation) + liens
--   categories / skills / profiles.
-- Aucune redondance avec V6/V16-V25 (nouvelle catégorie, titres préfixés).
-- Skill « Git » créé ici (V6 n'en insère que 4).
-- ===============================================

INSERT INTO challenges (
    title, type, selection_type, difficulty, context, question,
    explanation, estimated_time_seconds, active, points,
    created_at, updated_at
)
SELECT * FROM (VALUES
('Git : les trois zones — arbre de travail, index, HEAD', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'JUNIOR',
 'Un stagiaire ne retrouve plus sa modification après un checkout, alors qu''il avait enregistré le fichier dans son éditeur.',
 'Que représentent les trois zones et où vit la modification avant le commit ?',
 'L''arbre de travail porte les fichiers réels ; l''index (stage) l''image CANDIDATE du prochain commit ; HEAD le dernier commit figé. Une modification vit dans l''arbre et n''existe pour Git qu''après un add (stage) puis un commit. Un checkout remplace l''arbre par la cible : sans commit ni stash, le travail non stageé part avec.',
 120, true, 10, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Git : ce que fait exactement git pull', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'JUNIOR',
 '« git pull a supprimé mon travail » : la commande s''est terminée sur un conflit, un collègue signale que lui n''a rien perdu.',
 'De quoi git pull est-il composé et où naissent les conflits ?',
 'pull = fetch (récupère les commits distants dans origin/*, sans toucher à votre travail) + merge (ou rebase avec l''option) qui intègre ces commits dans votre branche. Le fetch ne modifie jamais votre historique local : les conflits naissent à l''intégration, quand vos changements et ceux reçus se combinent. La phrase « le pull perte » cible le mauvais maillon.',
 130, true, 10, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Git : retrouver un commit perdu', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'JUNIOR',
 'Après un reset --hard, un commit de la veille n''apparaît plus dans l''historique et il n''a jamais été poussé. L''équipe parle de réécrire tout le travail.',
 'Comment le retrouver sans tout refaire ?',
 'La reflog journalise les mouvements de HEAD (reset, checkout, amend...) : git reflog retrouve la position d''avant, puis on rescapate le SHA via une branche (switch -b <nom> <sha>) ou un cherry-pick. Rien n''est effacé immédiatement : Git purge seulement après expiration — il faut juste aller le chercher avant.',
 130, true, 10, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Git : .gitignore n''efface pas le suivi', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'JUNIOR',
 'Un fichier de configuration vient d''être ajouté à .gitignore, mais il continue d''apparaître dans git status avec ses modifications.',
 'Pourquoi .gitignore ne suffit-il pas ici ?',
 '.gitignore n''agit que sur les fichiers NON suivis : un fichier déjà tracké reste suivi, ses diffs inclus. Il faut le retirer du suivi (git rm --cached) en le gardant sur le disque, puis committer la perte de suivi. Si le fichier contenait un secret, le retirer du présent ne suffit pas : rotation + réécriture de l''historique.',
 130, true, 10, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Git : protéger ses modifications locales', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'JUNIOR',
 'Après une semaine d''absence, la branche locale a avancé sur le dépôt distant et vos modifications non committées risquent d''être écrasées par la prochaine opération.',
 'Quelle séquence protège réellement votre travail ?',
 'Sauvegarder D''ABORD (commit de travail en cours ou stash), puis intégrer (pull), enfin résoudre le conflit avec votre travail préservé. Commencer par un reset/checkout « pour repartir propre » inverse la priorité : on jette ce qui n''existe que chez soi, précisément la chose qu''il faut protéger.',
 130, true, 10, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Git : merge ou rebase', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Deux écoles s''affrontent pour intégrer une feature : fusionner telle quelle ou rejouer les commits sur la pointe.',
 'Quelles différences décident réellement du choix ?',
 'Le merge conserve l''historique réel (branchements + commit de fusion), sans réécrire — sûr même après publication. Le rebase rejoue vos commits sur la pointe : historique linéaire, mais NOUVEAUX SHA — interdit sur une branche partagée sans coordination. Critères : branche partagée ? lecture de l''historique voulu ? conventions d''équipe ? Pas de « toujours l''un ».',
 150, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Git : fast-forward ou commit de merge', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Vous fusionnez une branche d''un seul commit d''avance : l''historique avance sans trace de l''intégration. L''équipe ne sait plus quand la feature est entrée.',
 'Quand Git produit-il un commit de merge, et comment l''imposer ?',
 'Sans divergence, Git fait un fast-forward : HEAD avance simplement, aucun commit de fusion — historique propre mais frontière d''intégration perdue. --no-ff force le commit de merge : on garde la trace « cette feature est entrée ici », utile pour relire, retracer ou revert une feature entière. Un projet choisit sa règle (toujours --no-ff, ou selon la taille).',
 150, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Git : cherry-pick et doublons de patchs', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Vous rapatriez deux correctifs d''une branche de maintenance abandonnée via cherry-pick. Un merge ultérieur entre les deux branches provoque des conflits incompréhensibles.',
 'Que produit un cherry-pick et quel risque porter ?',
 'Il copie le patch en NOUVEAU commit (nouveau SHA) sur la branche courante : la branche d''origine garde le sien. Deux lignées du même changement coexistent ; au merge, Git rapproche deux commits au contenu identique mais SHA différents — conflits absurdes ou doublons discrets. Le cherry-pick convient au rapatriage ponctuel ; pour une réintégration durable, merger.',
 150, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Git : résoudre un conflit de fusion', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Marqueurs de conflit dans le fichier, merge en attente : un développeur stage le fichier en l''état « pour que ça avance ».',
 'Quelle est la façon correcte de conclure ce conflit ?',
 'Éditer pour obtenir le résultat VOULU (un côté, l''autre, ou les deux fondus), retirer TOUS les marqueurs, stageer le fichier résolu, puis conclure (merge/commit). Stageer des marqueurs intacts valide le conflit tel quel — c''est la recette du <<<<<<< qui atteint la production. Un merge qui tourne mal s''annule proprement avec merge --abort.',
 140, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Git : stash, le pas-une-sauvegarde', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Un stash stocké pour un changement de sujet disparaît trois jours plus tard lors d''une purge ; personne ne l''avait poussé.',
 'Que permet le stash et quels pièges éviter ?',
 'Le stash exile temporairement des brouillons pour basculer de contexte (pull/switch propres). Pièges : ce n''est PAS une sauvegarde (pile locale, pas poussée, purgeable) et pop écrase s''il y a conflit avec le travail courant. Pour du travail à conserver ou partager, on commite (WIP) : un commit est versionné, poussé, retrouvable — la pile de stash ne l''est pas.',
 150, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Git : revert ou reset selon l''état de la branche', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Un commit défectueux doit être annulé. La branche est tantôt locale sur la machine du développeur, tantôt déjà poussée et suivie par l''équipe.',
 'Que tranche l''état de la branche sur la méthode d''annulation ?',
 'Locale → reset : réécriture propre, le commit en erreur n''a jamais existé (soft conserve son contenu stageé). Poussée → réécriture déplacerait le travail des autres (commits orphelins dans leurs clones) : on REVERT, le défaut reste dans l''histoire suivi de son annulation. L''état partagé tranche entre réécriture et annulation explicite.',
 150, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Git : supprimer une branche sans drame', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Après merge, l''équipe veut nettoyer ; certains craignent de perdre des commits en supprimant des branches.',
 'Que font -d et -D, et pourquoi cette différence ?',
 '-d vérifie AVANT de supprimer que la branche est intégrée dans HEAD : le garde-fou refuse de perdre du travail unique. -D force et saute la vérification — à réserver aux branches dont on sait que tout est poussé/intégré, sinon les commits uniques meurent avec elle (reflog local seulement). Réflexe : -d par défaut, -D en connaissance de cause.',
 140, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Git : tags légers, annotés et releases', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Pour la release 2.4, l''équipe pose un simple tag local sans message ; un an plus tard, impossible de savoir ce que contenait vraiment la version.',
 'Quels choix de tag et quelle discipline tenir ?',
 'Léger = simple nom pointant un commit, sans métadonnées. Annoté = objet Git autonome (auteur, date, message, signable) — le support naturel de release. Publier le tag (push) car il vit en plus des branches, et ne JAMAIS le déplacer une fois public : déploiements et données y font référence. Un tag annoté bien message remplace l''annale perdue.',
 150, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Git : bisect pour localiser une régression', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Une régression est apparue entre les commits 400 et 800 : quatre cents commits à parcourir manuellement d''un air résigné.',
 'Quelle méthode et quel contrat de test ?',
 'git bisect fait une dichotomie binaire : on marque good/bad, Git teste au milieu — environ 9 essais suffisent pour 512 commits (log2). Le « test » doit être reproductible et automatisable (script avec code de sortie), sinon on est réduit à juger à la main (bisect run l''automatise). Il livre le PREMIER coupable : la compréhension commence à cet endroit.',
 150, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Git : suivre une branche distante (tracking)', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Un push ne fait rien d''attendu et personne ne comprend où la branche est partie : chaque poste semble pousser « quelque part ».',
 'Comment fonctionne le suivi d''une branche distante ?',
 'Chaque branche locale n''a de distant que celui qu''on lui configure : git push -u origin <branche> fixe l''upstream, après quoi push/pull marchent sans argument. git branch -vv montre les correspondances et git remote -v les dépôts. Sans tracking explicite, Git devine mal (ou refuse) : « la même branche partout » n''existe pas en soi.',
 140, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Git : --force et --force-with-lease', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Un push est rejeté : le distant a avancé. La solution retenue est un simple git push --force, sans vérification préalable.',
 'Que signifient les deux forces et pourquoi le lease change tout ?',
 '--force écrase le distant quoi qu''il y ait : si un collègue a poussé entre-temps, ses commits disparaissent de la branche (son travail ne rejoint personne). --force-with-lease vérifie d''abord que le distant est exactement l''état qu''on avait vu : échec si un tiers a poussé. Même ainsi, la réécriture reste réservée à l''historique non partagé.',
 150, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Git : un secret poussé — procédure de rotation', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'ADVANCED',
 'Une clé API découverte dans un commit poussé il y a deux mois ; elle est toujours active et l''équipe veut « nettoyer le dépôt ».',
 'Quelle est la procédure complète, et dans quel ordre ?',
 'Priorité absolue : RÉVOQUER/REMPLACER la clé — elle est déjà en dehors du dépôt, la réécriture ne la désactive pas côté fournisseur. Ensuite nettoyer : filter-repo/BFG sur le fragment fautif, force-push coordonné, tous les clones re-clonés (leur reflog garde l''ancien commit), forks et CI audités. Prévention : secrets hors du code, scan en pre-commit.',
 160, true, 20, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Git : trunk-based ou git-flow', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'ADVANCED',
 'Équipe de 8, déploiements continus ; le modèle git-flow (develop, release, hotfix) ajoute des merges quotidiens et deux durées de vie de branche.',
 'Quel est le bon critère de choix du flux de branches ?',
 'Le flux suit la FRÉQUENCE DE LIVRAISON : déploiement continu → trunk-based (petits commits sur la branche principale, feature flags, CI rapide, releases découplées) ; versions livrées au rythme → modèle structuré avec branches de release. Ni mode ni « sérieux » : c''est le cadence de livraison qui décide, et surtout un flux court.',
 160, true, 20, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Git : .gitattributes contre les conflits d''encodage', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'ADVANCED',
 'Chaque poste reçoit ses propres conflits CRLF/LF sur les mêmes fichiers, et les merges sortent avec des retours à la ligne mélangés selon les machines.',
 'Quelle est la configuration durable du problème ?',
 '.gitattributes tranche AUTOMATIQUEMENT au dépôt : text=auto, eol=lf/crlf par type de fichier, drivers de merge (ours/theirs) pour les fichiers générés, linguist pour les gros fichiers. La politique est versionnée avec le code — chaque clone converge sur la même forme. Régler l''eol poste par poste ou nettoyer à la main ne fait que reprogrammer le conflit.',
 150, true, 20, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Git : binaires dans l''historique et LFS', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'ADVANCED',
 'Un dépôt de 40 Mo atteint 2 Go : mockups et APK versionnés à chaque release ; les clones prennent 10 minutes et le CI expire.',
 'Pourquoi ça grossit, et quelle correction tient ?',
 'L''historique conserve CHAQUE version des binaires (packs) : la taille se cumule — supprimer du dernier commit ne rend rien, seule la réécriture (filter-repo/BFG) remonte le temps. Pour l''avenir : Git LFS (des pointeurs, les octets ailleurs) ou stockage objet avec référence, plus une règle d''équipe et un contrôle des dépôts. Le problème est structurel : Git n''est pas un stockage de fichiers versionnés.',
 160, true, 20, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Git : reprendre une branche abandonnée', 'PROBLEM_SOLVING', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Une branche métier est restée inactive six mois avec 40 commits ; entre-temps, la principale a beaucoup évolué et certains correctifs ont été repris manuellement ailleurs.',
 'Décrivez la démarche complète : état des lieux, tri, réécriture, validation, intégration.',
 'Étapes : (1) inventaire — merge-base avec la principale, quels commits n''existent SUR AUCUNE autre branche (tri par contenu, pas par titre) ; (2) tri — valides, obsolètes, doublons déjà repris (à la poubelle) ; (3) réécriture — rebase sur la pointe en découpant proprement, abandon du mort, messages à l''intention ; (4) validation — suite complète, revue ciblée sur l''écart réel ; (5) intégration — PR courte avec --no-ff ou squash assumé, puis branches nettoyées. Pièges : merger 40 commits en bloc, ou rejouer ce qui existe déjà — les doublons se paient en conflits absurdes.',
 900, true, 30, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Git : découper un commit fourre-tout', 'PROBLEM_SOLVING', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Un commit unique mélange feature, correctif, renommage et formatage sur 30 fichiers ; la revue est ingérable et le revert impossible ciblé.',
 'Décrivez la démarche de découpage propre, en conservant le résultat final.',
 'Étapes : annuler proprement le commit (reset --soft pour tout remettre en index, ou reset --hard suivi d''une restauration par patch) ; morceler (add -p / add -i par intention) ; ORGANISER : formatage à part, refactor à part, correctif isolé de la feature — chaque commit doit tenir seul et passer la suite ; écrire un message d''intention par commit (fixup + rebase --autosquash pour affiner) ; relancer les tests entre chaque étape. Découper au hasard produit des morceaux non testables — l''ordre logique est le vrai travail.',
 900, true, 30, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Git : sauver une revue devenue ingérable', 'PROBLEM_SOLVING', 'SINGLE_CHOICE', 'ADVANCED',
 'Une PR de 120 fichiers cumule six mois de travail, des conflits résolus chaque semaine, des revues qui repartent à zéro et plus personne ne lit rien.',
 'Décrivez le plan de sauvetage : arrêt de l''empilement, re-découpage, stratégie de branche, revue par tranches, leçons.',
 'Plan : (1) arrêter d''empiler — geler les merges de la PR, stabiliser ; (2) cartographier — quels lots restent valides, ce qui est mort, ce qui a bougé ailleurs ; (3) re-découpage — plusieurs PR courtes enchaînées (base dédiée par PR, ou stack) avec contrats d''entrée/sortie ; (4) stratégie — rebase régulier sur la pointe plutôt que résolutions de conflits empilés, exclusions du génératif ; (5) revue tranche par tranche dans l''ordre des dépendances, avec critères d''acceptation par PR ; (6) leçon institutionnalisée : PR courte = une pratique, pas un coup de chance. La force : on peut abandonner une PR sans perdre tout le reste.',
 900, true, 30, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
) AS v(title, type, selection_type, difficulty, context, question, explanation, estimated_time_seconds, active, points, created_at, updated_at)
WHERE NOT EXISTS (SELECT 1 FROM challenges c WHERE c.title = v.title);

INSERT INTO challenges (
    title, type, selection_type, difficulty, context, question,
    explanation, estimated_time_seconds, active, points,
    created_at, updated_at
)
SELECT * FROM (VALUES
('Git : premier correctif sur branche partagée', 'SEQUENTIAL_REASONING', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Votre branche de feature longue tourne depuis trois semaines ; un correctif urgent doit partir sur la branche principale sans tout réécrire.',
 'Place ces étapes dans l''ordre de la démarche recommandée.',
 'La séparation des lignées protège les deux côtés : repérer le point commun, corriger depuis le point stable, intégrer par revue sur la principale, puis RÉINTÉGRER la correction dans votre longue durée pour qu''elle ne réapparaisse pas en conflit au prochain merge.',
 300, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Git : annuler proprement un commit poussé', 'SEQUENTIAL_REASONING', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Un commit défectueux est déjà poussé sur la branche principale ; des collègues l''ont déjà récupéré.',
 'Place ces étapes dans l''ordre de la procédure recommandée.',
 'L''annulation va de la diffusion à la vérification : savoir qui l''a reçu dicte la méthode, revert s''impose dès que l''historique est partagé, l''exécution se teste, l''information accompagne la poussée, et la vérification finale (CI, historique) clôt — jamais de réécriture silencieuse sur un travail que d''autres portent.',
 300, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Git : réintégrer une longue branche', 'SEQUENTIAL_REASONING', 'SINGLE_CHOICE', 'ADVANCED',
 'Une branche de deux mois doit entrer dans la principale ; la main a beaucoup avancé entre-temps et certains commits locaux ont été repris ailleurs.',
 'Place ces étapes dans l''ordre de l''intégration recommandée.',
 'L''intégration propre : mesurer l''écart avant de choisir, replaquer sur la pointe en découpant les conflits par lots, valider sur la cible réelle, trancher le mode d''entrée (frontière --no-ff ou squash de feature), puis nettoyer et tracer. Réintégrer sans mesurer revient à découvrir les doublons en production de merge.',
 360, true, 20, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Git : préparer une release depuis le trunk', 'SEQUENTIAL_REASONING', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Le trunk accumule les features ; l''équipe doit livrer la version 3.0 la semaine prochaine et préparer les correctifs qui suivront.',
 'Place ces étapes dans l''ordre de la préparation recommandée.',
 'La release se fige puis se documente : stabilisation et suite verte, tag annoté sur le commit exact, publication (tag = source des artefacts), déploiement depuis le TAG et non depuis « la dernière branche », enfin la ligne de maintenance naît du tag pour que les hotfix aient une origine claire — sinon la 3.0 n''a jamais d''adresse.',
 300, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
) AS v(title, type, selection_type, difficulty, context, question, explanation, estimated_time_seconds, active, points, created_at, updated_at)
WHERE NOT EXISTS (SELECT 1 FROM challenges c WHERE c.title = v.title);

-- -----------------------------------------------
-- Options des QCM (SINGLE : 1 correcte)
-- -----------------------------------------------

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Arbre de travail = fichiers réels, index = candidat du commit, HEAD = dernier commit figé', true, 1,
 'Stage (add) puis commit : la modification n''existe pour Git qu''après ces deux passages.'),
('HEAD contient toutes les modifications en cours, commitées ou non', false, 2,
 'HEAD pointe le dernier commit : le brouillon n''y figure jamais.'),
('L''index est la sauvegarde automatique des brouillons', false, 3,
 'Rien n''est automatique : sans add, la modification reste invisible pour le prochain commit.'),
('Git garde trois copies de toute modification : stage, stash et HEAD', false, 4,
 'Le stash est facultatif, HEAD ne contient que le figé — aucune triple copie.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Git : les trois zones — arbre de travail, index, HEAD'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('pull = fetch + merge (ou rebase en option) : le fetch ne touche pas votre travail, le conflit naît à l''intégration', true, 1,
 'La récupération et l''intégration sont deux étapes distinctes — c''est la seconde qui combine.'),
('fetch + suppression des commits locaux non poussés', false, 2,
 'Aucune suppression : fetch écrit seulement dans origin/*.'),
('pull réécrit toujours l''historique local en mode rebase forcé', false, 3,
 'Le merge est la valeur par défaut ; le rebase est une option explicite.'),
('Les conflits apparaissent au fetch quand deux branches ont divergé', false, 4,
 'Le fetch n''intègre rien : diverger ne peut pas confliter tant qu''on n''a pas fusionné.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Git : ce que fait exactement git pull'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('git reflog localise le déplacement de HEAD, on rescapate le SHA via une branche ou un cherry-pick', true, 1,
 'La reflog est le journal des mouvements de HEAD : reset, checkout, amend — rien n''est purgé d''emblée.'),
('C''est définitif : un commit réinitialisé quitte le dépôt immédiatement', false, 2,
 'Le purge vient beaucoup plus tard (expiration du gc) — d''abord il est simplement orphelin.'),
('Il faut demander au serveur la liste des commits manquants', false, 3,
 'Le commit n''a jamais été poussé : le serveur ne l''a jamais vu.'),
('git status liste les commits égarés', false, 4,
 'status montre l''arbre et l''index — les orphelins se cherchent par reflog.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Git : retrouver un commit perdu'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Le fichier est déjà suivi : git rm --cached puis commit pour arrêter son suivi (le fichier reste en local)', true, 1,
 '.gitignore n''agit que sur les NON suivis — le retrait du suivi est l''étape qui manque.'),
('Supprimer le fichier du disque pour que .gitignore agisse', false, 2,
 'On veut précisément le conserver localement : le retrait du suivi suffit.'),
('Le .gitignore ne s''applique qu''au premier commit du dépôt', false, 3,
 'Il s''applique en continu à tout fichier non suivi.'),
('Forcer avec git add -f pour que Git l''ignore ensuite', false, 4,
 'À l''inverse : -f AJOUTE au suivi, l''ignorance est impossible ensuite.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Git : .gitignore n''efface pas le suivi'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Commit ou stash des changements AVANT d''intégrer, puis résolution du conflit avec le travail préservé', true, 1,
 'On protège d''abord ce qui n''existe que chez soi, ensuite on combine.'),
('Reset dur pour repartir de l''état distant : le travail distant fait foi', false, 2,
 'Écraser le local = perdre l''unique copie du travail en cours.'),
('Pull avec force pour écraser le distant et conserver le local', false, 3,
 'Le travail des autres disparaît — solution symétrique du problème précédent.'),
('Attendre que le collègue annule sa partie pour ne rien résoudre', false, 4,
 'Dépendance à la main d''œuvre d''autrui, sans avantage.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Git : protéger ses modifications locales'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('rebase = réécriture des commits (nouveaux SHA, jamais sur branche partagée) ; merge = historique réel préservé', true, 1,
 'Le critère décisif est le partage : la réécriture dépossède ceux qui ont les anciens SHA.'),
('Les deux produisent exactement le même graphe, seul le message varie', false, 2,
 'Le graphe diffère radicalement : branchements contre ligne droite.'),
('Le merge réécrit les SHA, le rebase ne touche jamais l''historique', false, 3,
 'Inversion exacte des deux mécanismes.'),
('rebase est toujours supérieur : l''historique linéaire est une règle absolue', false, 4,
 'Linéarité et perte des branchements sont un choix, pas une loi.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Git : merge ou rebase'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Fast-forward sans divergence (aucun commit de fusion) ; --no-ff impose le merge commit pour tracer l''intégration', true, 1,
 'La frontière « feature entrée ici » n''existe qu''avec un commit de fusion — FF l''efface.'),
('Un commit de merge est créé à chaque fusion, sans exception', false, 2,
 'Seule la divergence (ou --no-ff) produit un commit de fusion.'),
('Le fast-forward crée un commit caché supprimé à la prochaine réécriture', false, 3,
 'Aucun commit n''est créé — c''est exactement le propos.'),
('Il faut --ff-only pour imposer un commit de merge', false, 4,
 '--ff-only INTERDIT la fusion non fast-forward : l''effet est l''opposé.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Git : fast-forward ou commit de merge'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Il copie le patch en nouveaux commits : deux lignées du même changement, conflits ou doublons probables au merge', true, 1,
 'Même contenu, SHA différents : Git ne peut plus rapprocher proprement les deux lignées.'),
('Il déplace le commit : la branche source en est privée', false, 2,
 'Le commit d''origine reste en place — rien n''est déplacé.'),
('Il rejoue le commit en conservant exactement son SHA', false, 3,
 'Conserver le SHA définirait un commit sur deux branches : Git crée un nouveau SHA.'),
('Il fusionne automatiquement les deux branches à la fin', false, 4,
 'Le cherry-pick ne touche qu''une branche, sans intégration globale.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Git : cherry-pick et doublons de patchs'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Obtenir le contenu voulu, retirer TOUS les marqueurs, stageer le fichier résolu, puis conclure le merge', true, 1,
 'La résolution est humaine : Git ne choisit pas le sens métier à votre place.'),
('Stageer tel quel : Git nettoie les marqueurs au moment du commit', false, 2,
 'Il les conserve fidèlement — c''est ainsi qu''ils arrivent en production.'),
('Relancer le merge avec --force pour que Git tranche entre les deux côtés', false, 3,
 'Aucune option de ce type ne choisit un côté : le conflit est un travail, pas un réglage.'),
('Sauvegarder et annuler : le conflit se résout de lui-même au prochain pull', false, 4,
 'Un conflit différé est le même conflit, avec en plus le risque d''écraser le résolu.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Git : résoudre un conflit de fusion'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Bref exil de brouillons pour changer de contexte — ni sauvegarde ni partage : pour du travail durable, committer (WIP)', true, 1,
 'La pile est locale et volatile : le commit est versionné, poussé, retrouvable.'),
('La pile de stash se synchronise avec le dépôt distant comme une branche', false, 2,
 'Elle vit localement ; on peut la pousser manuellement, ce n''est pas le défaut.'),
('stash pop applique toujours le contenu sans conflit possible', false, 3,
 'Un conflit avec le travail courant reste tout à fait possible.'),
('Le stash conserve indéfiniment les brouillons, même après purge locale', false, 4,
 'Une purge locale l''emporte avec le reste — c''exactement ce qui est arrivé.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Git : stash, le pas-une-sauvegarde'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Locale → reset (soft conserve le contenu stageé) ; poussée → revert pour ne pas déposséder les autres', true, 1,
 'L''état partagé de la branche décide : réécriture privée contre annulation publique.'),
('Toujours reset --hard : un historique propre prime sur le partage', false, 2,
 'Réécrire ce que d''autres ont récupéré laisse leurs clones avec des commits orphelins.'),
('Toujours revert : la réécriture est interdite même en local', false, 3,
 'En local, réécrire est propre et gratuit — inutile de polluer l''historique d''un revert.'),
('Revert puis reset dans la foulée pour couvrir les deux cas', false, 4,
 'Doubler les deux mécanismes crée de la confusion, pas de la sécurité.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Git : revert ou reset selon l''état de la branche'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('-d vérifie l''intégration dans HEAD avant de supprimer ; -D force, et exige que tout soit intégré ou poussé', true, 1,
 'Le garde-fou de -d est ce qui protège les commits uniques — D le supprime au nom de la commodité.'),
('Les deux commandes sont identiques : la suppression ne touche jamais aux commits', false, 2,
 '‑D ne vérifie rien : un commit non poussé meurt avec la branche.'),
('La suppression d''une branche déplace toujours ses commits sur la principale', false, 3,
 'Rien n''est déplacé : c''est justement ce qu''il faut vérifier AVANT.'),
('-d est le mode définitif, -D le plus sûr des deux', false, 4,
 'Inversion : -D est le forçage, -d celui qui vérifie.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Git : supprimer une branche sans drame'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Tag annoté avec message, poussé comme release, jamais déplacé une fois publié', true, 1,
 'Métadonnées + publication = la release a une adresse stable et documentée.'),
('Un tag léger suffit : tout le contexte vit dans le message du commit', false, 2,
 'Le commit raconte l''état, pas l''événement de release — et rien n''est rattaché au tag.'),
('Les tags restent locaux et se recréent à chaque déploiement', false, 3,
 'Recréer un tag mobile défait le principe : deux « 2.4 » ne disent plus la même chose.'),
('On peut déplacer un tag publié : il pointe le même commit', false, 4,
 'Déplacer un tag public change ce que déploiements et données ont retenu de « la 2.4 ».')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Git : tags légers, annotés et releases'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Bisect : dichotomie binaire (~log2(n) essais) guidée par un test reproductible automatisable', true, 1,
 'Neuf essais suffisent pour 512 commits — à condition que « bon/mauvais » se juge par un script.'),
('Parcourir l''historique commit par commit pour ne rien manquer', false, 2,
 '400 essais manuels contre 9 : la dichotomie existe précisément pour ça.'),
('Le blame d''une ligne distante repère toujours le commit fautif', false, 3,
 'Blame explique la dernière main sur une ligne, pas l''apparition d''un comportement.'),
('bisect ne fonctionne que sur les vingt commits les plus récents', false, 4,
 'Aucune telle borne : il marche sur tout l''historique local.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Git : bisect pour localiser une régression'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('git push -u origin <branche> définit l''upstream : ensuite push/pull sans argument, suivis par git branch -vv', true, 1,
 'Le tracking est une liaison explicite branche locale ↔ distante, établie à la première poussée.'),
('Git suit automatiquement toute branche de même nom sur n''importe quel dépôt', false, 2,
 'Aucune correspondance magique : sans -u, Git ne sait pas où ni quoi.'),
('L''upstream se configure une fois pour toutes au niveau du dépôt', false, 3,
 'Il se configure par branche — chaque nouvelle branche recommence.'),
('push publie toujours automatiquement sur la branche principale distante', false, 4,
 'C''est une règle de configuration, jamais une vérité de Git.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Git : suivre une branche distante (tracking)'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('--force-with-lease vérifie que le distant n''a pas bougé avant d''écraser ; --force écrase aveuglément', true, 1,
 'Le lease compare le distant à ce qu''on avait vu : un poussage tiers fait échouer — le filet manquant du force brut.'),
('Les deux sont équivalents : le nom long est simplement plus poli', false, 2,
 'Écraser sans vérifier et écraser après vérification n''ont pas le même bilan.'),
('Le force ne supprime que les commits locaux non poussés', false, 3,
 'Il réécrit le distant : c''est bien ce qui dépossède les autres.'),
('Après un force, les commits écrasés restent récupérables par l''équipe', false, 4,
 'Ils ne sont nulle part sauf dans les reflogs individuels : personne ne les récupère.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Git : --force et --force-with-lease'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Révoquer/remplacer la clé d''abord (priorité), puis réécrire l''historique, force-push coordonné, clones re-clonés', true, 1,
 'La clé est déjà dehors : seule sa révocation l''invalide — le nettoyage du dépôt vient ensuite.'),
('Réécrire l''historique suffit : l''ancien commit disparaît, la clé est sauf', false, 2,
 'Elle a déjà servi et peut être conservée ailleurs : réécrire ne la révoque pas.'),
('Supprimer juste le fichier du dernier commit', false, 3,
 'Le commit d''origine reste dans l''historique — la clé aussi.'),
('Remplacer la clé dans le code sans révoquer l''ancienne', false, 4,
 'L''ancienne reste valide : l''incident n''est pas traité, seulement masqué.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Git : un secret poussé — procédure de rotation'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Le flux suit la fréquence de livraison : continu → trunk-based avec feature flags ; cadencé → branches de release', true, 1,
 'C''est le rythme de livraison qui décide, pas la réputation du modèle.'),
('git-flow est le standard : toute équipe sérieuse l''adopte', false, 2,
 'Il fut adapté à des livraisons versionnées — il alourdit un flux continu.'),
('Le trunk-based sans feature flag est le plus sûr pour tous les projets', false, 3,
 'Sans flags, trunk exige d''avoir toujours la main verte — sinon on bloque ou on casse.'),
('Chaque équipe du projet doit choisir un modèle différent', false, 4,
 'Un dépôt, un flux : des règles divergentes multiplient les intégrations incompatibles.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Git : trunk-based ou git-flow'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('.gitattributes : eol/text par type de fichier + drivers de merge — politique versionnée avec le dépôt', true, 1,
 'La norme se transmet avec le code : chaque clone converge sur la même forme.'),
('Régler l''eol dans la config locale de chaque poste et documenter la manipulation', false, 2,
 'Politique par personne : le prochain poste clone sans l''historique des manip.'),
('Normaliser le fichier à la main après chaque merge', false, 3,
 'Corriger le symptôme en boucle : le conflit repart à chaque merge.'),
('Ajouter les fichiers problématiques au .gitignore', false, 4,
 'Ignorer ne règle ni l''EOL ni le merge — cela retire le fichier du suivi.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Git : .gitattributes contre les conflits d''encodage'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('L''historique conserve toutes les versions : réécrire (filter-repo/BFG) + Git LFS ou stockage objet pour l''avenir', true, 1,
 'Chaque version binaire reste dans les packs — corriger le présent ne rend pas les octets passés.'),
('Supprimer les fichiers du dernier commit libère tout l''espace', false, 2,
 'Le poids vit dans les commits antérieurs : le présent n''est qu''une partie de l''iceberg.'),
('git gc suffit : les versions binaires obsolètes sont purgées automatiquement', false, 3,
 'gc compacte, ne supprime pas le reachable — l''historique reste intégralement servi.'),
('Il faut un dépôt séparé par type de binaire, l''historique n''est pas en cause', false, 4,
 'Séparer change le dépôt futur seulement : l''historique cumulé reste à réécrire.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Git : binaires dans l''historique et LFS'
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
    'Git Review : commit sans intention', 'CODE_REVIEW', 'MULTIPLE_CHOICE', 'INTERMEDIATE',
    'Revue d''une série de commits : le message final est « update » et le diff cumule une correction de bug et un réordonnancement de code.',
    'Quels problèmes identifiez-vous dans ces commits ?',
    '$ git commit -m "update"
 1 file changed, 3 insertions(+), 3 deletions(-)
 (le diff contient à la fois la correction du bug #482
  et le réordonnancement de la méthode render())',
    'shell',
    '« update » ne dit rien du POURQUOI : l''histoire devient inexploitable pour bisect, revert et relecture future — un message porte l''intention et la référence de ticket, pas le geste. Deuxième défaut : correction et reformatage mêlés : ni isoler ni revenir sur la correction, ni relire le fond dans le bruit. Corriger tant que rien n''est partagé : reset/add -p en commits distincts, ou fixup + rebase autosquash.',
    170, true, 20, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM challenges c WHERE c.title = 'Git Review : commit sans intention');

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Message sans intention : l''histoire ne dit pas pourquoi — bisect, revert et relecture perdent leur valeur', true, 1,
 'Un message décrit l''intention et la référence (ticket) — « update » ne raconte rien de réutilisable.'),
('Formatage mélangé à la correction : séparer les commits tant que rien n''est partagé (add -p, fixup + rebase)', true, 2,
 'Des intents distincts = des commits distincts : chaque geste reste isolable et relisible.'),
('Il suffit d''ajouter un emoji ou un numéro de ticket pour que le message devienne exploitable', false, 3,
 'Une décoration sans phrase ne révèle ni le pourquoi ni la portée du changement.'),
('Compresser en un seul commit à la fusion efface le problème d''intention', false, 4,
 'Le squash fusionne les problèmes, il ne les répare pas : le pourquoi reste absent.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Git Review : commit sans intention'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- -----------------------------------------------
-- Raisonnements séquentiels (4) : options (explications par rang)
-- -----------------------------------------------

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Repérer le point de divergence (merge-base) entre votre branche et la principale', true, 1,
 'La base commune définit ce qui appartient déjà aux deux lignées.'),
('Créer la branche de correctif depuis le point stable (tag ou dernier merge commun)', true, 2,
 'Le correctif naît du terrain connu, pas du milieu de votre feature.'),
('Corriger avec test de non-régression et pousser la branche de correctif', true, 3,
 'La preuve de correction part avec le code — le test protège la reprise.'),
('Ouvrir la revue, merger dans la principale sans réécriture', true, 4,
 'Sur la branche partagée, l''intégration est tracée et ne dépossède personne.'),
('Réintégrer le correctif dans la longue branche (merge ou rebase) pour qu''il ne revienne pas en conflit', true, 5,
 'Sans cette étape, votre branche redécouvre le bug à son prochain merge.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Git : premier correctif sur branche partagée'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Vérifier la diffusion : poussé seul, ou déjà récupéré/forké par d''autres ?', true, 1,
 'La diffusion décide de tout : réécriture ou annulation explicite.'),
('Décider : revert (historique partagé, rien réécrit) contre réécriture (non partagée uniquement)', true, 2,
 'Le choix de mécanique découle du constat de diffusion, pas de l''habitude.'),
('Exécuter : revert testé, ou reset local avec force-with-lease le cas échéant', true, 3,
 'Chaque voie a son geste exact — exécuter sans trancher casse les clones.'),
('Pousser l''annulation et informer les personnes impactées', true, 4,
 'Une annulation publique s''explique : les autres doivent savoir ce qui a bougé.'),
('Vérifier CI et historique final (l''état voulu est bien en tête de branche)', true, 5,
 'On ne clôt pas une annulation sans regarder ce que la branche dit maintenant.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Git : annuler proprement un commit poussé'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Mettre à jour (fetch) et mesurer l''écart : commits locaux, commits repris ailleurs, intégrés ou non', true, 1,
 'Choisir merge ou rebase avant de connaître l''écart, c''est choisir au hasard.'),
('Réécrire la branche sur la pointe (rebase) en traitant les conflits par lots', true, 2,
 'Réécriture locale autorisée ici : les conflits se découpent au lieu de s''empiler.'),
('Relancer la suite complète sur la cible réelle (pointe réécrite)', true, 3,
 'Valider l''état CONVERGÉ, pas l''état d''avant le rebase.'),
('Choisir le mode d''entrée : merge --no-ff avec revue, ou squash assumé de la feature', true, 4,
 'La frontière ou la ligne droite : tranché AVANT la fusion, pas au dernier moment.'),
('Nettoyer branches locales/distantes et tracer le ticket', true, 5,
 'L''intégration se termine par la suppression des doubles et l''archive du contexte.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Git : réintégrer une longue branche'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Stabiliser : gel des features, suite verte sur le point choisi de la principale', true, 1,
 'Une release se fige sur un état vérifié, pas sur « le dernier commit qui marchait ».'),
('Créer le tag annoté sur le commit exact (version, message, signé le cas échéant)', true, 2,
 'L''adresse de la 3.0 est un objet autonome et publié, pas un pointeur mobile.'),
('Publier tag et notes de version — source unique des artefacts', true, 3,
 'Déploiements et données se réfèrent au tag : il vit avec le dépôt, pas sur un poste.'),
('Déployer depuis le tag, jamais depuis la branche courante', true, 4,
 'Déployer une branche = déployer du code qui bouge : la release perd son adresse.'),
('Ouvrir la ligne de maintenance depuis le tag (origine des prochains correctifs)', true, 5,
 'Sans origine claire, les hotfix se dispersent — la prochaine release partira de rien de stable.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Git : préparer une release depuis le trunk'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- -----------------------------------------------
-- Skill Git (créé ici : V6 n'en insère que 4) — idempotent
-- -----------------------------------------------

INSERT INTO skills (name, description)
SELECT 'Git', 'Workflow, branches, merge/rebase, historique et collaboration.'
WHERE NOT EXISTS (SELECT 1 FROM skills s WHERE s.name = 'Git');

-- -----------------------------------------------
-- Liens catégories / skills / profiles (idempotents)
-- -----------------------------------------------

INSERT INTO challenge_categories (challenge_id, category_id)
SELECT c.id, cat.id
FROM challenges c, categories cat
WHERE cat.name = 'Git'
  AND (c.title LIKE 'Git %' OR c.title LIKE 'Git Review %')
  AND NOT EXISTS (SELECT 1 FROM challenge_categories cc WHERE cc.challenge_id = c.id AND cc.category_id = cat.id);

INSERT INTO challenge_skills (challenge_id, skill_id)
SELECT c.id, s.id
FROM challenges c, skills s
WHERE (c.title LIKE 'Git %' OR c.title LIKE 'Git Review %')
  AND (
    (c.type IN ('SITUATIONAL_QCM', 'PROBLEM_SOLVING') AND s.name = 'Git')
    OR (c.type = 'CODE_REVIEW' AND s.name = 'Code Review')
    OR (c.type = 'SEQUENTIAL_REASONING' AND s.name = 'Problem Solving')
  )
  AND NOT EXISTS (SELECT 1 FROM challenge_skills cs WHERE cs.challenge_id = c.id AND cs.skill_id = s.id);

INSERT INTO challenge_profiles (challenge_id, profile_id)
SELECT c.id, p.id
FROM challenges c, profiles p
WHERE p.code = 'DEVELOPER'
  AND (c.title LIKE 'Git %' OR c.title LIKE 'Git Review %')
  AND NOT EXISTS (SELECT 1 FROM challenge_profiles cp WHERE cp.challenge_id = c.id AND cp.profile_id = p.id);

-- Vérification rapide attendue : 28 défis Git (20/3/1/4 par type).
-- SELECT c.type, count(*) FROM challenges c
-- WHERE c.title LIKE 'Git %' OR c.title LIKE 'Git Review %' GROUP BY c.type;
