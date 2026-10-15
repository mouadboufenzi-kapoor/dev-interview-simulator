-- ===============================================
-- Catalogue V1 — Profil Développeur — catégories manquantes
-- V27 : Docker (26 défis — 17 QCM, 3 problem-solving,
--       2 code review, 4 raisonnement séquentiel)
-- Idempotent : WHERE NOT EXISTS sur challenges.title (jamais utilisé).
-- Même structure que l'import JSON futur : challenges + challenge_options
--   (content / is_correct / display_order / explanation) + liens
--   categories / skills / profiles.
-- Aucune redondance avec V6/V16-V26 (nouvelle catégorie, titres préfixés).
-- Skill « Docker » créé ici (V6 n'en insère que 4).
-- ===============================================

INSERT INTO challenges (
    title, type, selection_type, difficulty, context, question,
    explanation, estimated_time_seconds, active, points,
    created_at, updated_at
)
SELECT * FROM (VALUES
('Docker : image et conteneur ne sont pas la même chose', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'JUNIOR',
 'Un développeur arrête « son conteneur » pour libérer de la place : les services tournent encore et le disque se remplit d''images.',
 'Quelle distinction l''incident illustre-t-il ?',
 'L''image est la recette pérenne (stockée, versionnée, partagée) ; le conteneur est une instance créée à partir d''elle (process, état, réseau) — l''arrêter ne touche ni l''image ni les couches, et l''espace se libère par suppression/rotation des images et conteneurs arrêtés, pas par « fermer le service ».',
 120, true, 10, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Docker : l''ordre des couches décide du cache', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'JUNIOR',
 'Chaque build repart de zéro : installer les dépendances (2 min) puis copier le code. Un simple changement d''un commentaire relance tout.',
 'Pourquoi, et quel ordre adopter ?',
 'Chaque instruction ne se re-exécute que si l''une des couches précédentes a changé : copier le code AVANT npm install invalide la couche des dépendances à chaque frappe. L''ordre sain : dépendances d''abord (copie des manifests seuls), code ensuite — l''installation ne se relance que quand les dépendances changent vraiment.',
 130, true, 10, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Docker : le contexte de build et .dockerignore', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'JUNIOR',
 'Le build copie le dépôt complet (400 Mo : .git, node_modules, logs, .env) et les couches dépassent les 2 Go sans raison.',
 'Quelle mécanique gonfle l''image et comment la contenir ?',
 'Tout ce qui est dans le contexte (le répertoire passé à docker build) est transféré et potentiellement copié : .git, artefacts locaux et surtout .env rejoignent l''image. .dockerignore réduit le contexte (build plus rapide, pas de couches mortes) et surtout empêche les secrets d''entrer — une couche contenant .env reste dans l''historique de l''image.',
 130, true, 10, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Docker : -p et EXPOSE ne font pas la même chose', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'JUNIOR',
 'Un service « exposé » dans le Dockerfile reste inaccessible depuis le navigateur ; un autre dit qu''il a publié le port « quelque part ».',
 'Que fait chacune des deux instructions ?',
 'EXPOSE ne fait que DÉCLARER dans les métadonnées (documentation, outils) le port qu''on vise — il n''ouvre rien. La publication -p host:conteneur branche réellement un port de l''hôte sur le conteneur (via le routage). Hors publication, les ports restent joignables uniquement depuis le réseau interne des conteneurs.',
 130, true, 10, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Docker : persister hors du conteneur', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'JUNIOR',
 'Après une remise à niveau, la base est vide : les données vivaient dans le conteneur remplacé. L''équipe blâme « Docker qui écrase tout ».',
 'Quelle architecture de persistance évite le scénario ?',
 'Un conteneur est jetable par conception : ses couches écrites en couches copie-on-write disparaissent avec lui. Les données vivent hors du conteneur — volume nommé (ou montage) branché sur le répertoire de données, ou stockage externe. Règle : conteneurs remplaçables, volumes durables et versionnés par politique de sauvegarde.',
 130, true, 10, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Docker : multi-stage pour une image de production', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'L''image de production contient la toolchain complète (JDK, compilateur, sources) : 1,4 Go, surface d''attaque large.',
 'Quelle construction réduit l''image et le risque ?',
 'Un build multi-étapes compile dans une première image « atelier » puis ne copie que les artefacts finaux dans une image de base minimale (JRE/binaire) — outils et sources n''existent plus dans l''image publiée. Gains : taille, transfert, surface d''attaque, lisibilité de ce qui part vraiment en prod.',
 150, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Docker : tag ou digest', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Après réparation du registre, la prod repart avec « l''ancienne » : quelqu''un a retagué latest. L''équipe ne sait plus quelle image tournait la veille.',
 'Quel référencement garantit la reproductibilité ?',
 'Un tag est un étiquette MOBILE : latest ou 1.2 peut être réécrit. Le digest (sha256:...) identifie le CONTENU de l''image de façon immuable — il ne change jamais pour un contenu donné. Règle : déployer par digest (ou tag immuable lié à un commit), latest réservé aux usages jetables — sinon « quelle image tournait hier ? » n''a pas de réponse.',
 150, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Docker : healthcheck et démarrage des dépendances', 'SITUATIONAL_QCM', 'MULTIPLE_CHOICE', 'INTERMEDIATE',
 'Au démarrage, l''application plante en boucle : elle démarre avant que la base ne réponde. depends_on seul ne semble rien garantir.',
 'Quelles mesures corrigent réellement le démarrage ordonné ?',
 'Déclarer un HEALTHCHECK sur la base et demander depends_on: condition: service_healthy : l''application attend l''état prêt, pas le lancement du process. Côté application, des retries bornés de connexion restent indispensables — l''orchestrateur ne remplace pas la robustesse du client. Seul depends_on garantit l''ORDRE de lancement, pas la READINESS du service.',
 160, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Docker : réseau et services par nom', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Une application tente d''atteindre sa base via localhost:5432 depuis SON conteneur : connection refused, alors que la base tourne.',
 'Quel modèle de résolution s''applique entre conteneurs ?',
 'Chaque conteneur a sa propre boucle : localhost = lui-même. Sur un réseau partagé, les services se joignent par NOM de service (db:5432), résolu par le DNS interne de Docker. C''est aussi l''isolation positive : hors réseau partagé, les conteneurs ne se voient pas — portez la communication sur le réseau interne, jamais par la porte de l''hôte.',
 140, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Docker : secrets et configuration dans l''image', 'SITUATIONAL_QCM', 'MULTIPLE_CHOICE', 'INTERMEDIATE',
 'Les clés d''API sont passées en build-args « juste pour la préproduction », et un fichier .env complet figure dans le contexte de build.',
 'Quelles affirmations sont exactes ?',
 'Tout ce qui entre dans l''image y reste, accessible à qui la télécharge — un secret en couche n''est plus un secret (d''où rotation si poussé). Les ARG/ENV de build sont injectées dans l''historique des couches : pareil pour les clés. La bonne voie : secrets injectés à l''EXÉCUTION (orchestrateur, variable d''env injectée, fichier monté), et le build reste reproductible sans secret.',
 160, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Docker : exécuter en non-root', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Le conteneur tourne en root « parce que ça ne donne pas de droits en plus de toute façon » — un défi RCE dans l''app donne alors un root conteneur.',
 'Pourquoi imposer un utilisateur dédié, et comment ?',
 'Root dans le conteneur = élargissement maximal d''une faille applicative (écriture partout, montage potentiel, évasion facilitée). Correction : USER non-root dans le Dockerfile (après l''installation des dépendances), fichiers appartenant à cet utilisateur, port non privilégié (>1024). L''isolement du noyau limite, mais rien n''oblige à donner la couronne à l''attaquant.',
 150, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Docker : les logs vont-ils à stdout ?', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Un conteneur de 2 Go sur disque : les logs applicatifs sont écrits dans /var/log du conteneur en rotation manuelle inexistante.',
 'Quel est le modèle de logs des conteneurs, et le remède ?',
 'Le conteneur écrit sur STDOUT/ERR : le driver de runtime (json-file par défaut) les capture sur l''hôte — c''est là que se pose la question de rotation (max-size/max-file). Écrire des fichiers dans le conteneur contourne le modèle : la donnée vit dans une couche jetable, sans rotation, à vider à la main. Réglage : rotation côté driver + centralisation (collecteur) si besoin.',
 150, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Docker : CMD ou ENTRYPOINT', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'L''équipe veut que son outil CLI puisse recevoir des arguments au lancement ; aujourd''hui le Dockerfile force la commande.',
 'Quel contrat chacun définit-il, et comment composer ?',
 'ENTRYPOINT définit l''exécutable fixe du conteneur, CMD les arguments PAR DÉFAUT — docker run <args> remplace CMD sans toucher à l''ENTRYPOINT, ce qui produit le contrat « exécutable figé, arguments variables ». CMD seul se fait remplacer entièrement ; les deux se composent (ENTRYPOINT exécutable + CMD défauts). Choisir, c''''est décider de ce que le lancement personnalisé peut changer.',
 150, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Docker : signaux et PID 1', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'docker stop met 10 secondes à chaque fois puis kill -9 ; l''application laisse des états incohérents à l''arrêt.',
 'Quel mécanisme explique le délai et comment corriger ?',
 'Par défaut, Docker envoie SIGTERM au PID 1 du conteneur : si la commande tourne via un shell (forme shell de CMD) ou ignore les signaux, le process ne s''arrête pas — Docker attend son délai puis SIGKILL. Correction : forme exec (CMD ["..."]) avec l''application comme PID 1, gestion explicite de SIGTERM côté app, tini/eval si besoin d''un récolteur de zombies. L''arrêt propre fait partie du contrat du conteneur.',
 160, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Docker : borner CPU et mémoire', 'SITUATIONAL_QCM', 'MULTIPLE_CHOICE', 'ADVANCED',
 'Sans limites, un conteneur gourmand asphyxie l''hôte entier ; avec des limites mal posées, la JVM meurt au démarrage « sans raison ».',
 'Quelles affirmations tiennent sur le dimensionnement des conteneurs ?',
 'Sans limite, le conteneur n''est PAS isolé de la ressource : il concurrence l''hôte — la limite est une garantie de voisinage. En mémoire, la cgroup ne voit pas la mémoire « cachée » de la JVM : limiter à la marge de l''heap sans marge pour le métaspace/off-heap déclenche OOM Kill. Le quota CPU (period/quota) borne réellement ; les parts (shares) ne sont qu''une pondération.',
 170, true, 20, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Docker : build multi-plateformes (buildx)', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'ADVANCED',
 'L''équipe doit publier linux/amd64 ET linux/arm64 (CI x86, machines Apple). Copier les Dockerfiles d''une plateforme à l''autre diverge en deux jours.',
 'Quel mécanisme construit les deux architectures sans dupliquer la recette ?',
 'buildx avec plateformes multiples : UNE recette, un build par plateforme (émulation QEMU ou nœud natif), manifest list dans le registre — le client tire la bonne par architecture. Pièges : la performance d''émulation en CI (préférer des runners natifs ou du cache) et les artefacts natifs (dépendances compilées par arch). L''image « manifeste » rend le multi-arch transparent à la lecture.',
 160, true, 20, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Docker : durcir le conteneur (caps, lecture seule, rootless)', 'SITUATIONAL_QCM', 'MULTIPLE_CHOICE', 'ADVANCED',
 'Audit sécurité : le conteneur tourne en root, avec toutes les capabilities du noyau et un système de fichiers inscriptible.',
 'Quels renforcements ont un effet réel ?',
 'Chaque couche compte : USER non-root ; drop ALL puis ré-add uniquement ce qui manque (ex. CAP_NET_BIND_SERVICE si port bas) ; --read-only avec tmpfs pour les zones écrites ; sysctls/caps au minimum, AppArmor/seccomp par défaut. Aucune de ces mesures ne remplace l''isolement du noyau (mode rootless/restricted, runtime sécurisé) — on durcit par couches successives, jamais en cochant une seule case.',
 170, true, 20, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Docker : ça marche en local, ça plante dans le conteneur', 'PROBLEM_SOLVING', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Une application de test fonctionne sur le poste du développeur mais échoue dans l''image (fichier introuvable, variables absentes, connexion refusée).',
 'Décrivez la démarche de mise en parité : hypothèses, isolation, correction, prévention.',
 'Démarche : (1) comparer les deux mondes — ENV réelles, contenu effectif de l''image (docker history, inspect), chemins et casse de fichiers, utilisateur ; (2) isoler — rejouer avec les mêmes flags en local, entrer dans le conteneur (exec/sh) pour constater l''état réel ; (3) vérifier le contexte — .dockerignore excluant un fichier nécessaire, étape COPY manquante, exclusion de build ; (4) réseau — noms de services, ports, dépendances démarrées ; (5) corriger à la racine et PREVENIR : build systématique dans la CI sur l''image exacte de prod. La parité vient du « même artefact partout », pas des notes manuelles du développeur.',
 900, true, 30, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Docker : migrer un service bare-metal vers les conteneurs', 'PROBLEM_SOLVING', 'SINGLE_CHOICE', 'ADVANCED',
 'Un service de traitement tourne en systemd sur une machine dédiée (scripts de démarrage, fichiers de config locaux, cron, état sur disque). Il faut le conteneuriser sans coupure.',
 'Décrivez la trajectoire : conteneurisation, état, configuration, cron, mise en prod, bascule.',
 'Trajectoire : (1) conteneuriser le process seul — image minimaliste, arrêt propre (SIGTERM), non-root ; (2) sortir l''état — volumes nommés ou stockage externe, chemins déplacés hors des couches ; (3) configuration — injection à l''exécution (env/config monté), secrets hors image ; (4) cron/tâches — hors du conteneur (scheduler dédié ou entrée pointée par l''orchestrateur), un conteneur = un process ; (5) construction d''artefact reproductible (digest) ; (6) bascule par double exécution ou fenêtre courte avec retour arrière, service sain vérifié avant. Pièges classiques : état et config laissés dans l''image, cron embarqué, arrêt brutal par kill.',
 900, true, 30, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Docker : diagnostiquer une fuite de disque', 'PROBLEM_SOLVING', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Le disque de l''hôte atteint 95 % alors que le service « consomme peu » ; docker system df montre des masses inexpliquées.',
 'Décrivez la démarche d''investigation et de correction, sans casser le service.',
 'Démarche : (1) ventiler — images (couches partagées/non taggées), conteneurs arrêtés, volumes (dont ORPHELINS), build cache (BuildKit) : docker system df -v ; (2) identifier les responsables — json-file sans rotation (poids des drivers de logs), couches d''écriture de conteneurs en write, vieux builds CI accumulés ; (3) corriger — rotation des logs (max-size/max-file), prune ciblé et planifié (jusqu''à un âge sûr), garder tags/filtres, jamais un prune aveugle ; (4) vérifier après, puis outiller : alerte disque + nettoyage automatisé documenté. Le piège : docker system prune -a pendant que le service tourne — on supprime ce qui est en cours d''usage ou le filet de rollback.',
 900, true, 30, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Docker : réduire le temps de build', 'SEQUENTIAL_REASONING', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Le build de l''image prend 12 minutes à chaque commit et constitue le goulot de la CI.',
 'Place ces étapes dans l''ordre de l''optimisation recommandée.',
 'La discipline du cache : mesurer d''abord (qui consomme le temps — transfert de contexte, couches invalidées, dépendances), ranger les instructions de l''invariant au volatile (dépendances avant code), nettoyer le contexte, sortir la production de l''atelier (multi-stage), brancher un cache persistant en CI, puis revérifier en comparant les durées. Optimiser sans chronologie revient à deviner.',
 300, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Docker : mettre une base de données en conteneur en production', 'SEQUENTIAL_REASONING', 'SINGLE_CHOICE', 'ADVANCED',
 'Direction envisage la base de données en conteneur sur le même hôte que l''application « pour simplifier l''exploitation ».',
 'Place ces étapes dans l''ordre de la mise en œuvre responsable.',
 'Une base en conteneur exige plus de rigueur, pas moins : état d''abord (volume dédié, permissions UID alignées, aucune donnée en couche), qualité du service (limite mémoire, healthcheck, logs, capacité), sauvegarde VÉRIFIÉE (et restauration TESTÉE — une sauvegarde jamais restaurée est une espérance), puis bascule maîtrisée (double instance ou fenêtre, reprise documentée) et runbook. Si l''exploitation ne peut pas tenir tout cela, la base managée reste le choix raisonnable.',
 360, true, 20, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Docker : gérer un crash-loop en production', 'SEQUENTIAL_REASONING', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Depuis le dernier déploiement, un conteneur redémarre toutes les 15 secondes ; l''API répond par intermittence.',
 'Place ces étapes dans l''ordre de la gestion d''incident recommandée.',
 'Le réflexe d''abord : arrêter la casse avec le rollback image (retour au tag connu qui tourne), ce qui rend le service disponible pendant qu''on cherche. Puis comprendre : logs et événements du conteneur (code de sortie, healthcheck, OOM), inspection des limites et de l''état. Corriger à la racine avec test, redéployer par image nouvelle, vérifier — et seulement ensuite retirer le rollback d''urgence du chemin. Diagnostiquer pendant que le service tombe, c''est allonger l''incident.',
 300, true, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('Docker : monter en charge un service conteneurisé', 'SEQUENTIAL_REASONING', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Le service conteneurisé passe de 2 à 20 instances ; latences dégradées et quelques OOM Kill apparaissent aux heures pleines.',
 'Place ces étapes dans l''ordre de la montée en charge recommandée.',
 'Le passage à l''échelle va de la mesure aux garanties : profil réel (CPU/mémoire par instance), limites calibrées (ni sur-limité, ni sans borne — la JVM a sa marge), orchestration (réplicas, healthcheck, répartition, autoscaling sur métrique de travail), puis validation sous charge représentative — avec budget de performance et alarmes pour que le gain tienne aux prochains lots.',
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
('L''image est la recette pérenne ; le conteneur est l''instance jetable — arrêter l''un ne supprime ni l''autre', true, 1,
 'L''espace se libère par suppression/rotation explicite (images, conteneurs arrêtés, cache).'),
('Arrêter le conteneur supprime ses couches et l''espace est rendu immédiatement', false, 2,
 'Les couches vivent dans l''image — c''est pour ça que rien ne « se ferme ».'),
('Image et conteneur sont la même chose : l''un est le nom de l''autre', false, 3,
 'Recette et instance : le même décalage que source et process.'),
('Les images se suppriment automatiquement à l''arrêt du conteneur', false, 4,
 'Rien n''est automatique : la rotation est une opération d''exploitation.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Docker : image et conteneur ne sont pas la même chose'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Chaque couche se re-calcule si une couche précédente change : mettre les dépendances AVANT le code', true, 1,
 'La copie des manifests puis install se rejoue seulement quand les dépendances changent.'),
('Copier le code d''abord pour que les dépendances soient à jour', false, 2,
 'C''est précisément ce qui invalide npm install à chaque commit.'),
('Le cache Docker est désactivé par défaut et nécessite --no-cache pour être actif', false, 3,
 'Inversion : le cache est actif par défaut, --no-cache le force à calculer tout.'),
('Ajouter --force-rm à chaque build pour activer le cache', false, 4,
 'force-rm concerne les conteneurs temporaires, pas le cache de couches.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Docker : l''ordre des couches décide du cache'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Tout le répertoire courant forme le contexte : .dockerignore le réduit et empêche secrets et artefacts d''entrer en couche', true, 1,
 'Un .env copié reste dans l''historique de l''image — le vrai risque est là.'),
('La commande build n''envoie que les fichiers explicitement COPY', false, 2,
 'Le contexte est transféré en entier en amont — COPY ne protège pas des fichiers présents.'),
('Il faut supprimer les fichiers indésirables de leur disque d''origine pour les exclure du build', false, 3,
 'Le .dockerignore exclut sans rien détruire — les deux usages sont compatibles.'),
('Les fichiers exclus par .dockerignore peuvent toujours être récupérés via docker history', false, 4,
 'Exclu du contexte = jamais dans l''image — il n''y a rien à récupérer.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Docker : le contexte de build et .dockerignore'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('EXPOSE ne fait que déclarer (métadonnées) ; -p host:conteneur publie réellement le port sur l''hôte', true, 1,
 'Sans publication, le port reste joignable seulement sur le réseau interne des conteneurs.'),
('EXPOSE ouvre le port automatiquement sur toutes les interfaces de l''hôte', false, 2,
 'Rien n''est ouvert : la déclaration ne touche pas au routage.'),
('-p publie dans les métadonnées, il faut EXPOSE pour la connexion', false, 3,
 'Inversion complète : seule -p branche le port.'),
('Les deux sont obligatoires ensemble pour qu''un port fonctionne', false, 4,
 'EXPOSE est facultatif même avec -p — il documente.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Docker : -p et EXPOSE ne font pas la même chose'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Conteneurs jetables, données dans des volumes nommés (ou stockage externe) branchés sur le répertoire de données', true, 1,
 'La remise à niveau remplace le conteneur, le volume — et les données — survivent.'),
('Les données restent dans le conteneur : il suffit de ne jamais le redémarrer', false, 2,
 'Définir la fiabilité du service sur la non-redémarrance : chaque incident devient une perte.'),
('Sauvegarder le conteneur en image avant chaque remise à niveau', false, 3,
 'Packager l''état dans une image = gaspillage de couches, pas une persistance maîtrisée.'),
('Monter le répertoire du conteneur en lecture seule pour le protéger', false, 4,
 'Protège l''écriture mais ne rend pas la donnée persistante à la suppression du conteneur.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Docker : persister hors du conteneur'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Deux étapes : compilation dans l''atelier, copie des seuls artefacts dans une image de base minimale', true, 1,
 'Outils et sources restent dans l''atelier : l''image publiée ne contient que ce qui tourne.'),
('Compresser l''image avec --squash après build (option standard recommandée)', false, 2,
 '--squash est expérimental et ne distingue pas outils et artefacts : le multi-stage fait le tri.'),
('Supprimer les sources à la fin du Dockerfile avec rm -rf', false, 3,
 'La couche contient malgré tout les octets : supprimer crée une couche supplémentaire, rien de plus.'),
('Utiliser une image de base plus petite sans changer la construction', false, 4,
 'Utile mais insuffisant : la toolchain copiée reste dans les couches d''installation.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Docker : multi-stage pour une image de production'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Le digest (sha256) identifie le contenu de façon immuable : déployer par digest, latest réservé au jetable', true, 1,
 'Un tag est réassignable ; le digest décrit les octets — seule référence reproductible.'),
('Figer le tag 1.2.3 suffit : les tags ne bougent jamais', false, 2,
 'Un tag de version se retague aussi — rien ne l''interdit côté registre.'),
('Garder latest pour être sûr d''avoir la version corrigée', false, 3,
 'Latest est exactement le tag mobile : on ne saura jamais ce qui a tourné.'),
('Lier le tag à un SHA de commit de l''application : le lien ne dit rien du conteneur construit', false, 4,
 'Le commit code l''application, pas le conteneur construit — le lien n''est pas vérifiable au démarrage.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Docker : tag ou digest'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('HEALTHCHECK sur la base + depends_on condition service_healthy : l''app attend l''état PRÊT', true, 1,
 'Le lancement du process ne garantit pas l''acceptation des connexions — le healthcheck si.'),
('Des retries bornés de connexion côté application (le client reste robuste)', true, 2,
 'L''orchestrateur aide, ne remplace pas : les reprises protègent aussi des redémarrages.'),
('Ajouter un sleep de 30 secondes au démarrage de l''application', false, 3,
 'Pari sur la durée : machine lente = encore trop tôt, machine rapide = 30 secondes perdues.'),
('depends_on seul garantit que la base est prête avant l''app', false, 4,
 'Il garantit l''ORDRE de lancement, pas la readiness — c''est exactement le bug constaté.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Docker : healthcheck et démarrage des dépendances'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Chaque conteneur a sa boucle : localhost = lui-même ; entre services, résolution par NOM sur le réseau partagé', true, 1,
 'Le DNS interne de Docker relie les services — et l''isolation isole les autres réseaux.'),
('localhost fonctionne entre conteneurs du même hôte', false, 2,
 'C''est le piège : localhost = le conteneur lui-même, jamais son voisin.'),
('Il faut publier le port de la base sur l''hôte pour y accéder', false, 3,
 'Expose la base au réseau de l''hôte pour rien : le réseau interne suffit.'),
('Les conteneurs partagent la pile réseau de l''hôte par défaut', false, 4,
 'Chaque conteneur a sa propre pile — d''où les noms de service.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Docker : réseau et services par nom'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Tout ce qui entre dans l''image y reste dans l''historique des couches, lisible par qui la télécharge', true, 1,
 'Couche = octets persistants : un secret copié reste un secret public.'),
('Les ARG/ENV de build sont inscrits dans l''historique des couches : pas de clé en build', true, 2,
 'docker history affiche les ENV/ARG — la « préproduction » n''excuse rien.'),
('Injecter les secrets à l''exécution (env de l''orchestrateur ou fichier monté)', true, 3,
 'Le build reste reproductible et vide de secret ; l''exécution les fournit à la volée.'),
('Une image purge automatiquement les build-args à la fin du build', false, 4,
 'Rien n''est effacé : chaque ARG/ENV persiste dans les métadonnées de couche.'),
('Les secrets compilés dans le binaire sont sûrs car illisibles', false, 5,
 'Extraire la configuration d''un binaire est banal — ça déplace le secret, pas le protège.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Docker : secrets et configuration dans l''image'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('USER non-root après installation, fichiers appartenant à cet utilisateur, port non privilégié', true, 1,
 'Une RCE applicative ne doit pas hériter de root conteneur — chaque degré compte.'),
('Root est acceptable : le conteneur est déjà isolé du noyau', false, 2,
 'L''isolement limite, root maximise ce qu''une faille peut faire à l''intérieur.'),
('Il faut --privileged pour donner les droits sans root', false, 3,
 'privileged OUVRE tout le noyau : solution inverse du renforcement.'),
('Seul l''administrateur hôte peut décider de l''utilisateur du conteneur', false, 4,
 'C''est une décision de construction (USER du Dockerfile), pas d''hôte.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Docker : exécuter en non-root'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Le modèle : STDOUT/ERR capturés par le driver (json-file) — rotation à régler côté driver, collecte à part', true, 1,
 'La rotation et l''expédition sont des préoccupations d''hôte/collecteur, pas du conteneur.'),
('Écrire en fichiers dans le conteneur : plus simple à retrouver sur place', false, 2,
 'Couche jetable, pas de rotation, purgée à la remise à niveau — le modèle dit le contraire.'),
('Les logs conteneurs sont ignorés par docker logs sans agent dédié', false, 3,
 'docker logs lit précisément la sortie standard — c''est son cas d''usage.'),
('Il faut un volume pour que les logs survivent à l''arrêt', false, 4,
 'Persister en volume perpétue les fichiers mort-nés : la sortie standard est le contrat.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Docker : les logs vont-ils à stdout ?'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('ENTRYPOINT = exécutable fixe, CMD = arguments par défaut : run <args> remplace CMD, l''exécutable reste', true, 1,
 'Le contrat « outil figé, arguments variables » vient de cette composition.'),
('CMD remplace complètement ENTRYPOINT à chaque lancement', false, 2,
 'C''est run qui remplace CMD ; ENTRYPOINT reste — l''ordre des mécanismes compte.'),
('Les deux sont synonymes : l''un remplace l''autre au choix', false, 3,
 'Deux rôles distincts : fixe et défaut — d''où la composition possible.'),
('Il faut un script de démarrage pour accepter des arguments', false, 4,
 'La composition ENTRYPOINT+CMD le fait sans script — le wrapper est souvent la cause du problème de signaux.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Docker : CMD ou ENTRYPOINT'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('SIGTERM part au PID 1 : shell ou gestionnaire de signaux absent = arrêt ignoré, délai puis SIGKILL', true, 1,
 'La forme exec et une gestion explicite de SIGTERM donnent l''arrêt propre — le contrat de démarrage/arrêt du conteneur.'),
('Docker ne peut pas arrêter un conteneur : kill -9 est la seule voie', false, 2,
 'SIGTERM est envoyé dès l''arrêt — c''est son traitement qui manque.'),
('docker stop force immédiatement SIGKILL, sans préavis', false, 3,
 'L''ordre est SIGTERM, attente du délai, SIGKILL — le préavis existe.'),
('Ajouter un script d''arrêt dans le répertoire /etc/init.d du conteneur', false, 4,
 'Aucun service d''init ne tourne : c''est l''application, PID 1, qui doit traiter le signal.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Docker : signaux et PID 1'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Sans limite, le conteneur concurrence réellement l''hôte : la limite est une garantie de voisinage', true, 1,
 'L''isolement des processus n''est pas l''isolement des ressources — la cgroup tranche.'),
('La cgroup mémoire ne voit pas la mémoire cachée de la JVM : limiter l''heap sans marge hors-heap déclenche OOM Kill', true, 2,
 'Métaspace, code, tampons hors-heap comptent aussi : la marge doit être dimensionnée avec.'),
('Les parts CPU (shares) bornent réellement la consommation maximale', false, 3,
 'Les parts ne pondèrent qu''en cas de concurrence — le quota CPU borne seul.'),
('Limiter la mémoire est toujours sûr : le runtime s''adapte de lui-même', false, 4,
 'Les runtimes ignorent souvent la cgroup : c''est la recette de l''OOM Kill à 60 % d''utilisé.'),
('Des limites n''ont de sens qu''en orchestration, jamais en simple docker run', false, 5,
 'docker run accepte mem/cpu dès le début : le voisinage compte partout.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Docker : borner CPU et mémoire'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('buildx avec plateformes multiples : une recette, un build par arch, manifest list — le client tire la bonne', true, 1,
 'Une seule source pour amd64/arm64 : la divergence de Dockerfile disparaît.'),
('Maintenir deux Dockerfiles, un par architecture', false, 2,
 'Deux recettes = deux vérités : elles divergent dès la première modification.'),
('Construire amd64 sur la CI et porter l''image en binaire sur arm64', false, 3,
 'Des binaires natifs ne se « portent » pas : dépendances et runtime doivent être rebuildés.'),
('Le multi-arch n''existe pas : chaque cible a son registre', false, 4,
 'La liste de manifeste est le mécanisme standard des registres modernes.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Docker : build multi-plateformes (buildx)'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('USER non-root, drop ALL puis ré-additions minimales, --read-only avec tmpfs', true, 1,
 'Chaque couche réduit la surface : user, capabilities, système de fichiers.'),
('Compléter par les profils AppArmor/seccomp et un runtime restreint (rootless)', true, 2,
 'Le renforcement est cumulatif : l''isolement du noyau reste la dernière ligne.'),
('Passer en --privileged : le confinement devient alors maximal', false, 3,
 'Privileged supprime les garde-fous — c''est la capitulation du durcissement.'),
('Seules les capabilities sont utiles : sans elles, rien ne change', false, 4,
 'Toutes les couches comptent : capabilities SEULES laissent root inscriptible et rootless hors jeu.'),
('Chiffrer l''image suffit à empêcher l''exploitation d''une faille applicative', false, 5,
 'Chiffrer protège la distribution, pas l''exécution : la faille reste exploitable.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Docker : durcir le conteneur (caps, lecture seule, rootless)'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- -----------------------------------------------
-- Code Review : options + snippets (INSERT classique pour contrôler les '')
-- -----------------------------------------------

INSERT INTO challenges (
    title, type, selection_type, difficulty, context, question,
    code_snippet, code_language, explanation, estimated_time_seconds, active, points,
    created_at, updated_at
)
SELECT
    'Docker Review : Dockerfile tout-en-un', 'CODE_REVIEW', 'MULTIPLE_CHOICE', 'INTERMEDIATE',
    'Ce Dockerfile construit l''application Node ; il tourne mais l''image fait 1,2 Go et le build repart de zéro à chaque commit.',
    'Quels problèmes identifiez-vous dans ce Dockerfile ?',
    'FROM node:20
WORKDIR /app
COPY . .
RUN npm ci
EXPOSE 3000
CMD ["node", "server.js"]',
    'dockerfile',
    'Trois défauts structurants : COPY . . avant npm ci invalide la couche des dépendances à CHAQUE changement de code (build complet) ; aucun USER non-root — l''app tourne en root ; aucun .dockerignore — .git, node_modules et .env rejoignent le contexte (couches mortes et secret en couche). L''EXPOSE absent ne poserait aucun problème (il est documentaire), et séparer les dépendances en couche propre est ce qui rétablit le cache.',
    170, true, 20, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM challenges c WHERE c.title = 'Docker Review : Dockerfile tout-en-un');

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('COPY . . avant npm ci : chaque changement de code invalide la couche des dépendances (build complet à chaque commit)', true, 1,
 'Copier les manifests d''abord, npm ci, puis le code : la couche de dépendances ne bouge que si les dépendances changent.'),
('Aucun USER non-root : l''application s''exécute avec les droits root du conteneur', true, 2,
 'Une faille applicative devient un root conteneur — facultatif au confort, obligatoire en sûreté.'),
('Aucun .dockerignore : .git, node_modules et .env entrent dans le contexte (poids, cache, secret en couche)', true, 3,
 'Le contexte part en entier : .env en couche reste extractible — pas un détail.'),
('Il manque EXPOSE : le port 3000 serait inaccessible sans lui', false, 4,
 'EXPOSE est documentaire ; la publication -p (ou le réseau interne) ouvre réellement.'),
('npm ci dans une couche séparée n''a aucun intérêt avec le cache Docker activé', false, 5,
 'Le cache n''est utile QUE si la couche survit : c''est l''ordre des COPY qui le décide.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Docker Review : Dockerfile tout-en-un'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenges (
    title, type, selection_type, difficulty, context, question,
    code_snippet, code_language, explanation, estimated_time_seconds, active, points,
    created_at, updated_at
)
SELECT
    'Docker Review : compose non reproductible', 'CODE_REVIEW', 'MULTIPLE_CHOICE', 'INTERMEDIATE',
    'Ce compose orchestre app et base ; il démarre en réunion mais « plante parfois au premier lancement ».',
    'Quels problèmes identifiez-vous dans ce fichier ?',
    'services:
  db:
    image: postgres:latest
    environment:
      POSTGRES_PASSWORD: monsecret123
    ports:
      - "5432:5432"
  api:
    image: myapi:latest
    depends_on:
      - db
    ports:
      - "8080:8080"',
    'yaml',
    'Trois défauts : latest sur les deux images — rien n''est reproductible ni révertible (impossible de savoir ce qui tourne) ; le mot de passe en dur dans le fichier versionné — secret committé, à faire tourner et à sortir vers un secret d''exécution ; depends_on sans healthcheck — l''API démarre avant que la base accepte les connexions, d''où le plantage au premier lancement. Exposer la base sur l''hôte n''est pas obligatoire (le réseau interne suffit) et ne devrait servir qu''à des outils locaux explicitement.',
    170, true, 20, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM challenges c WHERE c.title = 'Docker Review : compose non reproductible');

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('images en latest : rien n''est reproductible ni révertible — impossible de savoir ce qui tourne réellement', true, 1,
 'Sans référence immuable, ni rollback ni « quelle version hier ? » — le déploiement perd son adresse.'),
('Mot de passe en dur dans un fichier versionné : secret committé, à faire tourner et injecter à l''exécution', true, 2,
 'Le dépôt est le mauvais endroit pour un secret : il reste dans l''historique.'),
('depends_on sans healthcheck : l''API démarre avant que la base accepte les connexions', true, 3,
 'Ordre de lancement ≠ readiness — c''est exactement le plantage « parfois au premier lancement ».'),
('Exposer la base sur l''hôte est obligatoire pour que les migrations tournent', false, 4,
 'Le réseau interne du compose suffit : les migrations viennent de l''API, pas de l''hôte.'),
('Il manque restart: always, qui résoudrait tous les démarrages échoués', false, 5,
 'Redémarrer en boucle contre une base pas prête ne prépare rien — ça masque le symptôme.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Docker Review : compose non reproductible'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- -----------------------------------------------
-- Raisonnements séquentiels (4) : options (explications par rang)
-- -----------------------------------------------

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Mesurer le build actuel : chronologie par instruction, transfert de contexte, couches invalidées', true, 1,
 'Sans chronologie, l''optimisation vise l''intuition et pas le goulot réel.'),
('Ordonner les couches de l''invariant au volatile : dépendants d''abord, code ensuite', true, 2,
 'Le cache ne se rejoue qu''à partir de la première instruction changée — l''ordre est tout.'),
('Réduire le contexte (.dockerignore) et sortir l''atelier (multi-stage)', true, 3,
 'Deux leviers indépendants : moins transféré, moins copié dans l''image finale.'),
('Brancher un cache de build persistant en CI (registre/buildx cache)', true, 4,
 'Les runners jetables n''ont aucun mémoire : sans cache partagé, chaque build repart de rien.'),
('Revérifier : comparer durées avant/après sur le même type de commit', true, 5,
 'Le gain se mesure — sinon l''optimisation reste une opinion sur la durée.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Docker : réduire le temps de build'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Sécuriser l''état d''abord : volume dédié, permissions UID alignées, aucune donnée en couche', true, 1,
 'La couche est jetable : toute donnée écrite dedans part avec le conteneur.'),
('Dimensionner le service : limites mémoire, healthcheck, logs, capacité d''I/O', true, 2,
 'Une base mal bornée asphyxie son hôte — la cgroup est autant son affaire que celle de l''app.'),
('Sauvegarde VÉRIFIÉE avec restauration TESTÉE', true, 3,
 'Une sauvegarde jamais restaurée est une espérance : le test est la seule preuve.'),
('Bascule maîtrisée : double instance ou fenêtre courte, reprise documentée', true, 4,
 'Le retour arrière doit exister avant d''en avoir besoin.'),
('Runbook d''exploitation — et droit de refuser si l''exploitation ne peut pas le tenir', true, 5,
 'Si le runbook ne sera jamais tenu, la base managée est le choix raisonnable.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Docker : mettre une base de données en conteneur en production'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Stabiliser d''abord : rollback vers l''image connue qui fonctionne (service rétabli pendant l''analyse)', true, 1,
 'L''incident se gagne d''abord en durée : le rollback est le geste le plus rapide.'),
('Diagnostiquer : logs et événements du conteneur, code de sortie, healthcheck, OOM, limites', true, 2,
 'La cause se lit dans l''arrêt réel du process, pas dans les suppositions.'),
('Corriger à la racine avec un test qui échouerait sans le correctif', true, 3,
 'Sans test, le correctif reste une hypothèse rejouable au prochain déploiement.'),
('Redéployer avec une image NOUVELLE (jamais retaguer l''ancienne)', true, 4,
 'Les tags immuables rendent le retour possible et l''historique lisible.'),
('Vérifier la stabilité, puis sortir le rollback d''urgence du chemin', true, 5,
 'Le filet d''incident ne doit pas se transformer en architecture définitive.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Docker : gérer un crash-loop en production'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.display_order, v.explanation
FROM challenges c,
(VALUES
('Profil réel : CPU/mémoire par instance aux heures pleines (mesurer avant de dimensionner)', true, 1,
 'Les limites naissent du profil mesuré — ni la valeur par défaut, ni la peur.'),
('Limites calibrées : ni sur-limité (OOM Kill), ni sans borne (voisin asphyxié)', true, 2,
 'Le juste milieu a un nom : le headroom dimensionné avec les besoins du runtime.'),
('Orchestration : réplicas, healthcheck, répartition, autoscaling sur métrique de travail', true, 3,
 'Le nombre d''instances suit la charge mesurée, pas un fixe deviné.'),
('Validation sous charge représentative avec budget et alarmes', true, 4,
 'La montée en charge se prouve avant le pic réel — sinon on teste en production.'),
('Répéter le cycle à chaque palier de croissance', true, 5,
 'Le profil change avec l''échelle : le dimensionnement est un revenant, pas un réglage unique.')
) AS v(content, is_correct, display_order, explanation)
WHERE c.title = 'Docker : monter en charge un service conteneurisé'
  AND NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id);

-- -----------------------------------------------
-- Skill Docker (créé ici : V6 n'en insère que 4) — idempotent
-- -----------------------------------------------

INSERT INTO skills (name, description)
SELECT 'Docker', 'Images, conteneurs, Dockerfile, volumes, réseaux et bonnes pratiques.'
WHERE NOT EXISTS (SELECT 1 FROM skills s WHERE s.name = 'Docker');

-- -----------------------------------------------
-- Liens catégories / skills / profiles (idempotents)
-- -----------------------------------------------

INSERT INTO challenge_categories (challenge_id, category_id)
SELECT c.id, cat.id
FROM challenges c, categories cat
WHERE cat.name = 'Docker'
  AND (c.title LIKE 'Docker %' OR c.title LIKE 'Docker Review %')
  AND NOT EXISTS (SELECT 1 FROM challenge_categories cc WHERE cc.challenge_id = c.id AND cc.category_id = cat.id);

INSERT INTO challenge_skills (challenge_id, skill_id)
SELECT c.id, s.id
FROM challenges c, skills s
WHERE (c.title LIKE 'Docker %' OR c.title LIKE 'Docker Review %')
  AND (
    (c.type IN ('SITUATIONAL_QCM', 'PROBLEM_SOLVING') AND s.name = 'Docker')
    OR (c.type = 'CODE_REVIEW' AND s.name = 'Code Review')
    OR (c.type = 'SEQUENTIAL_REASONING' AND s.name = 'Problem Solving')
  )
  AND NOT EXISTS (SELECT 1 FROM challenge_skills cs WHERE cs.challenge_id = c.id AND cs.skill_id = s.id);

INSERT INTO challenge_profiles (challenge_id, profile_id)
SELECT c.id, p.id
FROM challenges c, profiles p
WHERE p.code = 'DEVELOPER'
  AND (c.title LIKE 'Docker %' OR c.title LIKE 'Docker Review %')
  AND NOT EXISTS (SELECT 1 FROM challenge_profiles cp WHERE cp.challenge_id = c.id AND cp.profile_id = p.id);

-- Vérification rapide attendue : 26 défis Docker (17/3/2/4 par type).
-- SELECT c.type, count(*) FROM challenges c
-- WHERE c.title LIKE 'Docker %' OR c.title LIKE 'Docker Review %' GROUP BY c.type;
