-- =====================================================================
-- Catalogue V1 — Pilier API / BACKEND (profil DEVELOPER)
-- 24 SITUATIONAL_QCM + 3 PROBLEM_SOLVING + 6 CODE_REVIEW + 3 SEQUENTIAL = 36
-- Exclus déjà couverts : « Mauvais code HTTP retourné » (V6),
-- « Idempotence des verbes HTTP » (V6), erreurs 200/log sensibles/JPQL (V17),
-- « Normaliser les erreurs » (V17 SEQ).
-- =====================================================================

-- ---------------------------------------------------------------------
-- 24 QCM
-- ---------------------------------------------------------------------
INSERT INTO challenges (title, type, selection_type, difficulty, context, question, code_snippet, code_language, explanation, estimated_time_seconds, active, points, created_at, updated_at)
SELECT v.title, v.type, v.selection_type, v.difficulty, v.context, v.question,
       NULLIF(v.snippet, ''), NULLIF(v.lang, ''), v.explanation, v.time, TRUE, v.points,
       CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM (VALUES
-- JUNIOR (5)
('API : PUT ou PATCH pour modifier deux champs', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'JUNIOR',
 'Le front envoie uniquement le nouvel email d''un profil, sans le reste. Un PUT écrase le profil entier avec des nulls.',
 'Quel verbe correspond à l''intention « mettre à jour partiellement » et quel contrat lui est associé ?',
 '',
 '',
 'PATCH : modification partielle, seuls les champs envoyés changent. PUT = remplacement complet de la ressource (le client doit fournir l''état entier valide). L''erreur de contrat (PUT avec un objet partiel) produit des pertes de données silencieuses.',
 90, 10),
('API : un client casse après un renommage de champ', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'JUNIOR',
 'Le backend renomme total en amountTotal. L''ancien mobile affiche « 0 » au lieu du montant : aucune erreur visible.',
 'Que faut-il avoir posé pour éviter cette rupture et pourquoi le JSON le permet-il ?',
 '',
 '',
 'Un contrat versionné/évolué : le JSON est « self-describing » mais les clients lisent les champs par leur nom — renommer est un CHANGEMENT CASSANT. Règle : ajouter est sûr, renommer/supprimer ne l''est pas ; si nécessaire, accepter les deux noms pendant une période (tolérance) ou versionner l''API.',
 120, 15),
('API : message CORS illisible dans la console', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'JUNIOR',
 'En local tout marche ; déployée sur un autre domaine, l''API répond... le navigateur affiche « blocked by CORS policy » alors que le backend tourne bien.',
 'Qui décide réellement de l''accès et quel est le levier correct ?',
 '',
 '',
 'C''est le NAVIGATEUR qui bloque (le serveur a répondu 200). Le serveur doit déclarer Access-Control-Allow-Origin pour l''origine du front (CORS_ORIGINS) — c''est une règle de sécurité navigateur, pas une erreur serveur : corriger le front ne sert à rien, ajouter l''origine côté API oui.',
 120, 15),
('API : effet de bord dans un GET', 'SITUATIONAL_QCM', 'MULTIPLE_CHOICE', 'JUNIOR',
 'Une équipe implémente la suppression d''un brouillon via GET /drafts/123/delete « pour faire simple ».',
 'Quels problèmes ce choix pose-t-il ?',
 '',
 '',
 'Un GET doit être sûr et idempotent : les préfetcheurs/crawlers/proxies (et le navigateur lui-même) peuvent le déclencher. La suppression devient non intentionnelle et non répétable-sûre. Verbe PATCH/DELETE à la bonne URI, idempotence assumée.',
 120, 15),
('API : enveloppe de liste paginée', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'JUNIOR',
 'Une liste renvoie un tableau brut : le front ne sait pas s''il reste des pages, et compte les éléments affichés.',
 'Quelle forme de réponse donne l''information de pagination ?',
 '',
 '',
 'Une enveloppe explicite : { items, page, pageSize, total / nextCursor }. L''information de navigation appartient au contrat — un tableau brut ne porte ni total ni continuité, et le front devine (mal).',
 90, 10),
-- INTERMEDIATE (13)
('API : CORS, wildcard et credentiels', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Avec cookies d''authentification, l''équipe met allowedOrigin = "*" pour « faire au plus simple » : le navigateur refuse catégoriquement.',
 'Pourquoi le wildcard est-il interdit avec les credentiels et quelle forme adopter ?',
 '',
 '',
 'Avec credentials (cookies/Authorization), le navigateur exige une origine EXPRESSE — "*" est rejeté (vol de contexte auth possible). Déclarer les origines réelles du front, une liste maîtrisée, évoluant avec les environnements.',
 180, 20),
('API : directives de cache sur données personnelles', 'SITUATIONAL_QCM', 'MULTIPLE_CHOICE', 'INTERMEDIATE',
 'Un endpoint /api/me renvoie des données personnelles avec Cache-Control: public, max-age=3600.',
 'Quels risques et quelles directives ?',
 '',
 '',
 '« public » autorise caches INTERMÉDIAIRES (proxies, CDN) à conserver des données d''un utilisateur : fuite entre personnes sur un cache partagé. Données personnelles : private (navigateur seul) ou no-store (rien de stocké) ; le public se réserve aux données anonymes/stables.',
 180, 20),
('API : 429 et Retry-After', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Un client reçoit 429 Too Many Requests et resserre immédiatement sa boucle de retry : le serveur reçoit une seconde salve et finit par le bannir plus longtemps.',
 'Que dit la spec du 429 et comment le client doit-il réagir ?',
 '',
 '',
 '429 s''accompagne d''un Retry-After (secondes) : le client attend AVANT de réessayer, avec backoff exponentiel + jitter. Réessayer à l''instant 1 transforme un throttle local en interdiction prolongée (et noie le serveur — retry storm).',
 120, 15),
('API : concurrence sur la même ressource (If-Match)', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Deux agents éditent le même dossier : le dernier PUT écrase silencieusement les modifications du premier (perdu update HTTP).',
 'Quel mécanisme HTTP natif détecte ce conflit ?',
 '',
 '',
 'L''ETag de représentation + If-Match dans la requête d''écriture : si l''état courant ne correspond plus à l''ETag du client → 412 Precondition Failed, le client recharge et arbitre. Version HTTP du contrôle optimiste, sans dépendance applicative.',
 180, 20),
('API : 502, 503, 504 — qui est en faute ?', 'SITUATIONAL_QCM', 'MULTIPLE_CHOICE', 'INTERMEDIATE',
 'Pendant un incident, les clients reçoivent tantôt 503, tantôt 504. L''équipe répond « c''est le backend » sans distinction.',
 'Quelles différences sémantiques porter ?',
 '',
 '',
 '503 Service Unavailable : le service est là mais refuse/indispo (Retry-After possible) ; 504 Gateway Timeout : l''amont n''a pas répondu à temps ; 502 Bad Gateway : réponse invalide d''un amont. La distinction guide le retry côté client et le diagnostic côté poste de garde.',
 180, 20),
('API : absent, null ou chaîne vide en PATCH', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Un PATCH reçoit {"nickname": null} : le front pensait « pas de changement », le back efface le surnom.',
 'Quelle convention de contrat faut-il figer ?',
 '',
 '',
 'Distinguer explicitement les trois états : champ ABSENT (pas de modification), null (effacer, si le champ l''autorise), valeur (remplacer). Nullable ≠ omis en PATCH : sans règle documentée, chaque client interprète différemment.',
 120, 15),
('API : traitement long et 202 Accepted', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Un import peut prendre 90 s : le maintenir en HTTP maintient le client et le proxy (timeout 60 s) en vie.',
 'Quel modèle d''API adopter et que renvoyer ?',
 '',
 '',
 'Asynchrone : 202 Accepted + en-tête Location vers une ressource d''état (ou id de job) que le client interroge (ou webhook). Le contrat devient « demandé » et non « terminé » ; le client sait où suivre sans dépendre de la tenue du connect.',
 180, 20),
('API : identifiant de chemin non numérique', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'GET /orders/abc — le service tente un parse Long, échoue, et le GlobalExceptionHandler répond 500 « erreur interne ».',
 'Quel statut décrit cette situation et pourquoi ?',
 '',
 '',
 '400 : la REQUÊTE est invalide (l''identifiant ne peut pas être décodé) — erreur du client, pas du serveur. Le mapper en 400/404 avec message propre (validation de type de paramètre) : une 500 masque une faute de format qui se reproduira toujours.',
 120, 15),
('API : corps de requête sans limite', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Un endpoint accepte des JSON sans limite : un payload de 800 Mo arrive, la mémoire serveur explose, le pod redémarre.',
 'Quel mécanisme poser en premier et quel statut attend-on ?',
 '',
 '',
 'Borner le corps (server.max-http-form-size / max-request-size / limit applicatif) et répondre 413 Payload Too Large AVANT le traitement complet. Limiter côté reverse proxy si possible (rejet plus tôt) — la taille acceptée fait partie du contrat de l''API.',
 180, 20),
('API : rate limiting derrière un proxy', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'L''API limite à 100 req/min « par IP » : en prod derrière un load balancer, TOUS les clients partagent l''IP du proxy et sont bloqués ensemble.',
 'Pourquoi la clé de limitation est-elle fausse et que faut-il faire ?',
 '',
 '',
 'Derrière un proxy, l''IP au niveau applicatif est celle du proxy (X-Forwarded-For fiable seulement si le proxy le force et est maîtrisé). Clé de limitation : identifiant d''utilisateur/tenant quand authentifié (sinon IP réelle via configuration de confiance), avec fenêtre glissante et burst.',
 180, 20),
('API : SameSite et cookies cross-site', 'SITUATIONAL_QCM', 'MULTIPLE_CHOICE', 'INTERMEDIATE',
 'Le front tourne sur app.exemple.com et l''API sur api.exemple.com : les cookies de session ne partent plus dans les requêtes.',
 'Quels mécanismes gouvernent ce comportement ?',
 '',
 '',
 'Les cookies sont dits « site for good » SameSite=Lax/Strict : cross-site (sous-domaines distincts = site distincts au sens cookie) non envoyés. Solutions : SameSite=None + Secure (HTTPS obligatoire) si cookies voulus, ou — notre cas — s''appuyer sur un token porté par en-tête, non soumis à SameSite.',
 180, 20),
('API : recherche complexe en GET ou POST', 'SITUATIONAL_QCM', 'MULTIPLE_CHOICE', 'INTERMEDIATE',
 'Une recherche multi-critères avec 15 filtres et tri complexe dépasse les limites d''URL et devient illisible.',
 'Quels arbitrages poser ?',
 '',
 '',
 'Un GET reste possible avec critères encodés (et garde bénéfices : cachable, partageable, idempotent) si l''URL reste raisonnable ; un POST de recherche est légitime pour corps volumineux — mais il perdit le cache HTTP naturel et la sémanticité « sûre ». Décider et documenter, avec borne sur le nombre de critères.',
 120, 15),
-- ADVANCED (6)
('API : 409, 412 ou 422 — quel statut pour quel refus', 'SITUATIONAL_QCM', 'MULTIPLE_CHOICE', 'INTERMEDIATE',
 'Une API renvoie un statut de refus : l''équipe met systématiquement 400 « avec le message dans le corps » pour tout type de rejet.',
 'Quelles distinctions sémantiques faut-il faire ?',
 '',
 '',
 '409 Conflict : état serveur en conflit avec la demande (doublon métier, ressource déjà consommée) ; 412 : condition préalable non remplie (If-Match obsolète) ; 422 : syntaxe correcte mais échec de validation métier sur le corps. 400 reste pour la forme invalide. Les statuts guident le client — tout renvoyer en 400 rend l''API illisible.',
 120, 15),
('API : BFF et front qui parle au micro-service interne', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'ADVANCED',
 'Le front consomme 6 services internes directement : chaque évolution d''un service casse le front, et les 6 tokens circulent partout.',
 'Quelle architecture limiterait ce couplage et quels bénéfices attendre ?',
 '',
 '',
 'Un agrégateur / BFF (Backend For Frontend) : le front ne connaît QUE l''API de son BFF, qui agrège les services, centralise l''authentification et formate au besoin de l''écran. Le coût : un composant de plus — bénéfice : le contrat front est stable face aux réorganisations internes.',
 240, 25),
('API : évolution du contrat sans casser les clients', 'SITUATIONAL_QCM', 'MULTIPLE_CHOICE', 'ADVANCED',
 'Audit de compatibilité avant de modifier un DTO consommé par des clients tiers.',
 'Quels changements sont cassants et lesquels ne le sont pas ?',
 '',
 '',
 'Cassants : renommer un champ, supprimer un champ, restreindre un type (string→int), resserrer une énumération, changer un statut. Non cassants : AJOUTER un champ (lecteurs l''ignorent), ouvrir un type (int→string si toléré), ajouter une valeur d''énum côté écriture avec tolérance côté lecture. Règle des lecteurs tolérants : toujours lire en tolérance, écrire strictement.',
 240, 25),
('API : SSE, WebSocket ou polling', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'ADVANCED',
 'Un écran de suivi temps réel de jobs doit réagir aux changements d''état. L''équipe propose un WebSocket complet, le produit veut du simple.',
 'Selon quelles dimensions arbitrer les trois ?',
 '',
 '',
 'Polling : simple, latence = cadence, coût = requêtes. SSE : flux serveur→client unidirectionnel, reprise automatique, HTTP simple (passant par nos proxys) — idéal pour du temps réel léger. WebSocket : bidirectionnel, état persistant, infrastructure dédiée — juste si le client ENVOIE en continu. Le besoin réel (volume, sens, latence) décide, pas la mode.',
 240, 25),
('API : Idempotency-Key sur les POST critiques', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'ADVANCED',
 'Un double clic (ou un retry de proxy) déclenche deux paiements pour la même intention : le POST n''est pas idempotent.',
 'Quel mécanisme serveur garantit « une seule exécution, mêmes réponses » ?',
 '',
 '',
 'L''en-tête Idempotency-Key : le serveur mémorise la clé + la réponse du premier traitement ; un rejeu avec la même clé renvoie la réponse stockée (ou 409 si en cours) sans ré-exécuter. La clé vient du client d''intention, la déduplication vit côté serveur (cache/DB avec TTL).',
 240, 25),
('API : isolation multi-tenant et IDOR', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'ADVANCED',
 'Une API trouve les commandes avec /api/orders/{id} : un utilisateur modifie l''id dans l''URL et lit le dossier d''un autre client.',
 'Quelle famille de faille est-elle ouverte et quel contrôle systématique poser ?',
 '',
 '',
 'IDOR (Insecure Direct Object Reference) : l''accès n''est vérifié que sur l''existence, pas sur l''APPARTENANCE. Contrôle systématique : chaque ressource chargée est scopée au tenant/utilisateur de la requête (filtre WHERE porteur inclus) + tests d''accès transverses automatisés. Un contrôle uniquement à l''entrée d''URL ne protège pas des objets volés.',
 240, 25),
('API : Vary et caches qui servent le mauvais contenu', 'SITUATIONAL_QCM', 'MULTIPLE_CHOICE', 'ADVANCED',
 'Après activation de gzip, certains clients XML/anciens reçoivent des octets illisibles depuis un proxy, et un variant de langue se propage entre utilisateurs.',
 'Quels mécanismes de variances maîtriser ?',
 '',
 '',
 'Vary: Accept-Encoding (variant compressé vs brut), Vary: Accept-Language / Accept selon le contenu négocié : sans lui, le premier variant mis en cache est servi à tous. À limiter : chaque Vary multiplie les entrées de cache ; au-delà de quelques dimensions, mieux vaut des URLs distinctes (URL rewriting) que multiplier les variances.',
 240, 25)
) AS v(title, type, selection_type, difficulty, context, question, snippet, lang, explanation, time, points)
WHERE NOT EXISTS (SELECT 1 FROM challenges c WHERE c.title = v.title);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.ord, v.expl
FROM (VALUES
('API : PUT ou PATCH pour modifier deux champs', 'PATCH : modification partielle, seuls les champs présents changent', TRUE, 1, 'Le verbe porte l''intention : « Mets à jour ce fragment ».'),
('API : PUT ou PATCH pour modifier deux champs', 'PUT exige l''état complet : un objet partiel écrase le reste (nulls)', TRUE, 2, 'Remplacement total — d''où la perte de données observée.'),
('API : PUT ou PATCH pour modifier deux champs', 'POST peut convenir si l''API le documente ainsi', FALSE, 3, 'POST = création d''une sous-ressource ; ce n''est pas l''intention ici.'),
('API : PUT ou PATCH pour modifier deux champs', 'Le serveur complète automatiquement les champs absents en PUT', FALSE, 4, 'Le serveur ne devine pas : il remplace ce qu''il reçoit.'),
('API : un client casse après un renommage de champ', 'Renommer/supprimer un champ est un changement CASSANT du contrat', TRUE, 1, 'Les clients lisent les noms : la rupture est silencieuse côté ancien client.'),
('API : un client casse après un renommage de champ', 'Ajouter un champ est généralement sûr (lecteurs tolérants)', TRUE, 2, 'Le principe de tolérance des lecteurs guide l''évolution.'),
('API : un client casse après un renommage de champ', 'Versionner l''API ou assurer une transition à deux noms', TRUE, 3, 'Accepter ancien + nouveau le temps de migrer les clients.'),
('API : un client casse après un renommage de champ', 'Le JSON étant non typé, aucun renommage ne peut casser un client', FALSE, 4, 'C''est précisément le nom qui est lu — le typage n''y change rien.'),
('API : message CORS illisible dans la console', 'Le navigateur bloque : le serveur doit déclarer son origine autorisée', TRUE, 1, 'Access-Control-Allow-Origin côté API pour l''origine du front.'),
('API : message CORS illisible dans la console', 'Ajouter l''origine à CORS_ORIGINS (liste maîtrisée côté backend)', TRUE, 2, 'Le levier opérationnel du projet.'),
('API : message CORS illisible dans la console', 'Corriger le code du front pour « contourner » l''erreur', FALSE, 3, 'Impossible : c''est le navigateur qui refuse, le serveur a répondu.'),
('API : message CORS illisible dans la console', 'Désactiver la sécurité CORS côté navigateur', FALSE, 4, 'Aucun tel réglage utilisateur — protection non contournable.'),
('API : effet de bord dans un GET', 'Les préfetcheurs/crawlers/proxies peuvent déclencher le GET', TRUE, 1, 'La suppression part sans intervention humaine.'),
('API : effet de bord dans un GET', 'Un GET doit être sûr (pas d''effet) et idempotent', TRUE, 2, 'Le contrat HTTP repose sur cette promesse.'),
('API : effet de bord dans un GET', 'Aucun risque : seul le front appelle l''API', FALSE, 3, 'Navigateurs, proxys et robots appellent aussi — souvent sans l''humain.'),
('API : effet de bord dans un GET', 'Il suffit d''ajouter un token dans l''URL pour sécuriser le GET de suppression', FALSE, 4, 'Le token dans l''URL fuit (logs, historique) — et le préfetch reste.'),
('API : enveloppe de liste paginée', 'Enveloppe { items, page/total ou nextCursor } : la navigation fait contrat', TRUE, 1, 'Le client sait s''il reste sans deviner.'),
('API : enveloppe de liste paginée', 'Réserver total aux cas bon marché (COUNT coûteux)', TRUE, 2, 'Sur volume, préférer un curseur sans total.'),
('API : enveloppe de liste paginée', 'Un tableau brut convient quand la pagination n''existe pas', TRUE, 3, 'La forme suit le périmètre — mais ici elle existe.'),
('API : enveloppe de liste paginée', 'Le front peut déduire la fin des pages en comptant les éléments', FALSE, 4, 'Seulement si page size fixe ET taille connue — fragile par construction.'),
('API : CORS, wildcard et credentiels', 'Avec credentials, l''origine doit être explicite : "*" est rejeté', TRUE, 1, 'Règle navigateur : empêcher le vol de contexte authentifié.'),
('API : CORS, wildcard et credentiels', 'Liste d''origines réelles par environnement (CORS_ORIGINS)', TRUE, 2, 'Origines maîtrisées = surface d''attaque maîtrisée.'),
('API : CORS, wildcard et credentiels', 'allowCredentials(true) + wildcard : double faute de configuration', TRUE, 3, 'Les deux ensemble sont explicitement interdits par la spec.'),
('API : CORS, wildcard et credentiels', 'Le wildcard est toléré si le front est en HTTPS',FALSE, 4, 'Le HTTPS n''affecte pas la règle d''origine explicite.'),
('API : directives de cache sur données personnelles', 'public autorise les caches partagés : fuite inter-utilisateurs', TRUE, 1, 'Un CDN/proxy peut servir le /api/me d''un client à un autre.'),
('API : directives de cache sur données personnelles', 'private (navigateur seul) ou no-store (aucun stockage) selon sensibilité', TRUE, 2, 'Le niveau de partage se décrit explicitement.'),
('API : directives de cache sur données personnelles', 'public se réserve aux données anonymes/stables', TRUE, 3, 'Le bon usage du partage : contenu identique pour tous.'),
('API : directives de cache sur données personnelles', 'Les données perso ne peuvent pas être mises en cache du tout, même navigateur', FALSE, 4, 'private le permet : c''est le PARTAGE qui est proscrit.'),
('API : 429 et Retry-After', '429 porte Retry-After : attendre avant de réessayer', TRUE, 1, 'Le serveur indique la durée du refroidissement.'),
('API : 429 et Retry-After', 'Backoff exponentiel + jitter côté client', TRUE, 2, 'Évite que tous les clients réalignent leur essai au même instant.'),
('API : 429 et Retry-After', 'Réessayer immédiatement aggrave le throttle', TRUE, 3, 'Le serveur voit un comportement abusif : interdiction prolongée.'),
('API : 429 et Retry-After', 'Un 429 signifie toujours une erreur serveur définitive', FALSE, 4, 'C''est transitoire et délibéré — la réponse est « attends ».'),
('API : concurrence sur la même ressource (If-Match)', 'ETag d''état + If-Match à l''écriture → 412 si obsolète', TRUE, 1, 'Détecte l''écrasement avant qu''il ne se produise.'),
('API : concurrence sur la même ressource (If-Match)', 'Le client recharge puis arbitre avec information fraîche', TRUE, 2, 'Le conflit devient visible et gérable côté utilisateur.'),
('API : concurrence sur la même ressource (If-Match)', 'Version applicative (@Version) possible si HTTP non souhaité', TRUE, 3, 'L''esprit est identique : contrôle optimiste.'),
('API : concurrence sur la même ressource (If-Match)', 'Un lock serveur sur la ressource résout tout sans contrat', FALSE, 4, 'Verrou oublié = ressource gelée ; le 412 reste explicite.'),
('API : 502, 503, 504 — qui est en faute ?', '503 : service présent mais indisponible/refusant (Retry-After possible)', TRUE, 1, 'L''émetteur sait qu''il est en cause.'),
('API : 502, 503, 504 — qui est en faute ?', '504 : un amont n''a pas répondu à temps (gateway)', TRUE, 2, 'La faute se situe au-delà du sender.'),
('API : 502, 503, 504 — qui est en faute ?', '502 : réponse invalide reçue d''un amont', TRUE, 3, 'Protocole respecté, contenu/corruption invalide.'),
('API : 502, 503, 504 — qui est en faute ?', 'Les trois sont strictement équivalents côté traitement client', FALSE, 4, 'Les politiques de retry et de diagnostic diffèrent selon le statut.'),
('API : absent, null ou chaîne vide en PATCH', 'ABSENT = pas de changement ; null = effacer (si permis) ; valeur = remplacer', TRUE, 1, 'Trois états, trois interprétations — à figer dans le contrat.'),
('API : absent, null ou chaîne vide en PATCH', 'Nullable ≠ omis : documenter la règle par champ', TRUE, 2, 'Sans règle, chaque client devine.'),
('API : absent, null ou chaîne vide en PATCH', 'Désérialiser en distinguant map (présence) vs valeur (contenu)', TRUE, 3, 'Implémentation classique : Map<String,Object> ou JsonNode.'),
('API : absent, null ou chaîne vide en PATCH', 'Traiter null et absent de la même façon « pour simplifier »', FALSE, 4, 'La simplification efface l''information : données perdues.'),
('API : traitement long et 202 Accepted', '202 Accepted + Location/état du job que le client consulte', TRUE, 1, 'Le client suit une ressource d''état dédiée.'),
('API : traitement long et 202 Accepted', 'Webhook de fin : le client n''a pas à poller', TRUE, 2, 'Quand le client peut recevoir — modèle complet.'),
('API : traitement long et 202 Accepted', 'Le connect HTTP est soumis aux timeouts de proxy : maintenir 90 s est fragile', TRUE, 3, 'C''est la cause initiale du scénario.'),
('API : traitement long et 202 Accepted', 'Augmenter le timeout serveur à 10 minutes règle le problème', FALSE, 4, 'Déplace la fragilité (proxys, batteries, réseaux mobiles).'),
('API : identifiant de chemin non numérique', '400 : la requête est mal formée (paramètre non décodable)', TRUE, 1, 'Faute du client, pas du serveur.'),
('API : identifiant de chemin non numérique', 'Mapper type invalide / corps invalide en réponse 400 propre', TRUE, 2, 'Le handler de validation doit couvrir les types de paramètres.'),
('API : identifiant de chemin non numérique', '500 masque un cas qui se reproduira systématiquement', TRUE, 3, 'Erreur reproductible = erreur de contrat, pas incident.'),
('API : identifiant de chemin non numérique', '404 convient puisque la ressource n''existe pas pour un id invalide', FALSE, 4, '404 = syntaxe valide, ressource absente — l''id illisible n''est même pas interprété.'),
('API : corps de requête sans limite', 'Borner la taille (proxy + serveur) et répondre 413', TRUE, 1, 'Rejet avant épuisement mémoire.'),
('API : corps de requête sans limite', 'Rejeter au plus tôt : limite aussi au niveau du reverse proxy', TRUE, 2, 'Moins de travail inutile, protection du process.'),
('API : corps de requête sans limite', 'La limite maximale fait partie du contrat documenté de l''API', TRUE, 3, 'Les clients l''intègrent à leurs validations.'),
('API : corps de requête sans limite', 'Augmenter la mémoire du conteneur protège contre ce scénario', FALSE, 4, 'Échelle le coût sans supprimer l''abus — masque la cause.'),
('API : rate limiting derrière un proxy', 'Derrière un proxy, l''IP applicative est celle du proxy', TRUE, 1, 'Tous les clients partagent la même clé — limitation inutile.'),
('API : rate limiting derrière un proxy', 'Clé = identifiant d''utilisateur/tenant quand authentifié', TRUE, 2, 'La vraie unité d''usage : la personne/organisation.'),
('API : rate limiting derrière un proxy', 'X-Forwarded-For fiable seulement si le proxy l''écrase et est maîtrisé', TRUE, 3, 'Sinon l''en-tête est forgeable par le client.'),
('API : rate limiting derrière un proxy', 'Placer la limitation uniquement côté application (jamais proxy)', FALSE, 4, 'Le proxy peut absorber l''avant-coût : double couche idéale.'),
('API : SameSite et cookies cross-site', 'SameSite=Lax/Strict : cookie non envoyé en cross-site (sous-domaines = sites distincts)', TRUE, 1, 'D''où la perte du cookie entre app.* et api.*.'),
('API : SameSite et cookies cross-site', 'SameSite=None + Secure (HTTPS) si cookies cross-site voulus', TRUE, 2, 'La dérogation explicite, conditionnée au HTTPS.'),
('API : SameSite et cookies cross-site', 'Token porté par en-tête : hors périmètre SameSite', TRUE, 3, 'Notre architecture Bearer n''est pas soumise à cette règle.'),
('API : SameSite et cookies cross-site', 'SameSite n''existe que pour les cookies de session', FALSE, 4, 'Tous les cookies — ce qui inclut les tokens si portés en cookie.'),
('API : recherche complexe en GET ou POST', 'GET encodé reste possible avec critères bornés (et garde cache + idempotence)', TRUE, 1, 'Uniquement si l''URL reste raisonnable.'),
('API : recherche complexe en GET ou POST', 'POST recherche : corps volumineux accepté, mais perd le cache HTTP', TRUE, 2, 'Arbitrage à documenter — le cache naturel disparaît.'),
('API : recherche complexe en GET ou POST', 'Borner le nombre de critères et documenter la limite', TRUE, 3, 'Tout contrat a besoin de gardes-fous.'),
('API : recherche complexe en GET ou POST', 'Les URLs longues cassent toujours les proxies modernes', FALSE, 4, 'Exagéré : c''est la lisibilité, le cache et les limites qui motivent la décision.'),
('API : 409, 412 ou 422 — quel statut pour quel refus', '409 Conflict : état serveur en conflit (doublon, ressource consommée)', TRUE, 1, 'Le conflit porte sur l''état courant, pas sur la forme.'),
('API : 409, 412 ou 422 — quel statut pour quel refus', '412 Precondition Failed : condition préalable (If-Match) non remplie', TRUE, 2, 'Le refus vient de l''état attendu par le client.'),
('API : 409, 412 ou 422 — quel statut pour quel refus', '422 : corps syntaxiquement valide mais échec de validation métier', TRUE, 3, 'Le JSON est bien formé ; ce sont les règles métier qui refusent.'),
('API : 409, 412 ou 422 — quel statut pour quel refus', '400 convient à tous les refus, seul le corps compte', FALSE, 4, 'Écrase l''information : le client ne peut plus automatiser sa réaction.'),
('API : BFF et front qui parle au micro-service interne', 'Un BFF agrège : le front ne connaît qu''un contrat stable', TRUE, 1, 'Réorganiser les services ne touche plus le front.'),
('API : BFF et front qui parle au micro-service interne', 'Authentification et formatage centralisés côté agrégateur', TRUE, 2, 'Un seul point d''entrée = un seul point de contrôle.'),
('API : BFF et front qui parle au micro-service interne', 'Coût assumé : un composant de plus à maintenir et monitorer', TRUE, 3, 'L''arbitrage honnête de l''architecture.'),
('API : BFF et front qui parle au micro-service interne', 'Le BFF supprime tout besoin de sécurité interne', FALSE, 4, 'Les services restent protégés — défense en profondeur.'),
('API : évolution du contrat sans casser les clients', 'Cassant : renommer, supprimer, restreindre un type, resserrer une énumération', TRUE, 1, 'Tout ce qui peut rendre un ancien client inopérant.'),
('API : évolution du contrat sans casser les clients', 'Non cassant : AJOUTER un champ (lecteurs tolérants)', TRUE, 2, 'La règle d''or de l''évolution de contrat JSON.'),
('API : évolution du contrat sans casser les clients', 'Écrire strictement, lire en tolérance (et ne jamais exploiter l''inconnu)', TRUE, 3, 'Deux moitiés du même principe de robustesse.'),
('API : évolution du contrat sans casser les clients', 'Tout changement exige une nouvelle version majeure', FALSE, 4, 'Trop violent : l''ajout de champ reste non cassant.'),
('API : SSE, WebSocket ou polling', 'Polling : simple, latence = cadence, coût en requêtes', TRUE, 1, 'Souvent suffisant pour du rafraîchissement peu pressé.'),
('API : SSE, WebSocket ou polling', 'SSE : flux unidirectionnel, reprise auto, HTTP classique', TRUE, 2, 'Idéal serveur→client sans infrastructure dédiée.'),
('API : SSE, WebSocket ou polling', 'WebSocket : bidirectionnel et persistant — seulement si le client envoie', TRUE, 3, 'Le coût d''infrastructure se justifie par le besoin réel.'),
('API : SSE, WebSocket ou polling', 'Le WebSocket est toujours supérieur pour du temps réel', FALSE, 4, 'Surcoût injustifié sans flux client→serveur.'),
('API : Idempotency-Key sur les POST critiques', 'Clé fournie par le client + réponse du 1er traitement mémorisée', TRUE, 1, 'Le rejeu renvoie la même réponse sans ré-exécuter.'),
('API : Idempotency-Key sur les POST critiques', '409 si le premier traitement est encore en cours', TRUE, 2, 'Évite le double travail concurrent.'),
('API : Idempotency-Key sur les POST critiques', 'Stockage clé→réponse avec TTL borné (cache ou table dédiée)', TRUE, 3, 'La fenêtre de déduplication est une décision.'),
('API : Idempotency-Key sur les POST critiques', 'Le mécanisme rend automatiquement tout POST sûr', FALSE, 4, 'Seulement ceux qui l''implémentent — et la clé doit venir du client.'),
('API : isolation multi-tenant et IDOR', 'IDOR : accès par id sans contrôle d''appartenance', TRUE, 1, 'La faille OWASP classique des API REST.'),
('API : isolation multi-tenant et IDOR', 'Scoper la requête au porteur (WHERE tenant/user inclus)', TRUE, 2, 'La donnée n''existe tout simplement pas pour l''autre.'),
('API : isolation multi-tenant et IDOR', 'Tests automatisés d''accès transverses (changer l''id = 403/404)', TRUE, 3, 'La régression de contrôle se détecte au CI.'),
('API : isolation multi-tenant et IDOR', 'Rendre les ids UUID opaques ne fait que décourager la devinette', FALSE, 4, 'Décourage la devinette, mais ne vérifie toujours pas l''appartenance.'),
('API : Vary et caches qui servent le mauvais contenu', 'Vary: Accept-Encoding / Accept-Language déclare les variantes du cache', TRUE, 1, 'Sans variance, le premier variant est servi à tous.'),
('API : Vary et caches qui servent le mauvais contenu', 'Chaque Vary multiplie les entrées de cache : à limiter', TRUE, 2, 'Surdimensionner Vary détruit le taux de touché.'),
('API : Vary et caches qui servent le mauvais contenu', 'URLs distinctes par variantes (langue) = variances nulles', TRUE, 3, 'Alternative standard : la variance descend dans l''URL.'),
('API : Vary et caches qui servent le mauvais contenu', 'Désactiver entièrement le cache règle tous les variants', FALSE, 4, 'Supprime le bénéfice au lieu de le dimensionner.')
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
('API : concevoir un endpoint d''export volumineux', 'PROBLEM_SOLVING', 'SINGLE_CHOICE', 'ADVANCED',
 'Un export comptable de 200 000 lignes bloque le navigateur, fait sauter le timeout du proxy, et une interruption perd tout.',
 'Conçois l''export de bout en bout.',
 '',
 '',
 'Découpler : POST /exports → 202 + job (états : en cours/terminé/échec) avec progression. Génération en streaming côté serveur (fichier écrit par lots, jamais tout en mémoire) vers stockage objet, puis GET du fichier signé (expiration courte). Bornes métier (périmètre, nombre max), notifications/webhook en fin, et reprise possible. Le client télécharge quand c''est prêt — jamais un connect de 10 minutes.',
 240, 25),
('API : contrat d''une ressource imbriquée', 'PROBLEM_SOLVING', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Les commandes portent des lignes : le front veut la liste dépliée, un autre écran veut le détail seul. L''équipe imbrique tout partout.',
 'Quelles décisions de modélisation prendre ?',
 '',
 '',
 'Choix par usage : ressource en sous-chemin (/orders/{id}/lines) pour le détail paginé si la collection est grande/vivante ; agrégation dans la réponse de liste si le rendu en dépend systématiquement et que le volume est borné. Éviter le dépliage complet illimité, définir la profondeur d''imbrication maximale du contrat, et documenter : le format suit l''écran, pas l''inverse.',
 180, 15),
('API : latence perçue — où est le temps ?', 'PROBLEM_SOLVING', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'L''écran « semble lent » : certains utilisateurs en campagne mobile se plaignent, d''autres non. Le backend affiche 120 ms.',
 'Comment découpes-tu le diagnostic ?',
 '',
 '',
 'Décomposer avant de conclure : temps serveur (métriques backend) vs transit (TTFB : DNS/TLS/réseau) vs rendu (poids de la réponse, waterfall navigateur, JS). Mesurer par segment et par population (RUM/par région), pas la moyenne globale : 120 ms de backend ne prouve rien si le reste du budget part en réseau ou en hydration. identifier le segment dominant avant toute optimisation.',
 180, 15)
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
('API Review : référence circulaire dans la réponse JSON', 'CODE_REVIEW', 'MULTIPLE_CHOICE', 'INTERMEDIATE',
 'GET /orders/{id} plante en StackOverflowError dès qu''une commande a des notes rattachées.',
 'Quels problèmes identifiez-vous dans ce code ?',
 'public OrderDto get(@PathVariable Long id) {
    Order order = repo.findById(id).orElseThrow();
    return mapper.toDto(order);   // Order -> lines -> line.order ...
}',
 'java',
 'Le mapping expose un cycle (entité ↔ collection) : le sérialiseur JSON boucle jusqu''à StackOverflow. Raisons classiques : DTO sérialisé depuis l''entité avec @JsonIgnore manquant sur le retour, ou mapping non borné. Solution : DTO dédiés sans retour vers le parent (le contrat décide de la profondeur).',
 180, 20),
('API Review : liste sans pagination', 'CODE_REVIEW', 'MULTIPLE_CHOICE', 'INTERMEDIATE',
 'L''endpoint /api/products renvoie le catalogue complet : 45 Mo de JSON au premier chargement.',
 'Quels problèmes identifiez-vous dans ce code ?',
 '@GetMapping("/products")
public List<ProductDto> all() {
    return service.findAll()
        .stream().map(mapper::toDto).toList();
}',
 'java',
 'Réponse non bornée : mémoire de sérialisation × taille catalogue, temps de transfert, et côté client rendu complet impossible. Pagination (ou filtres + bornes) dès que la taille peut croître — la règle vaut pour toute liste, le « pour l''instant c''est petit » retombe toujours.',
 120, 15),
('API Review : identifiant JavaScript au-delà de 2^53', 'CODE_REVIEW', 'MULTIPLE_CHOICE', 'ADVANCED',
 'Un client web compare deux ids de commande : ils « se ressemblent tous », des conflits apparaissent en production uniquement côté front.',
 'Quels problèmes identifiez-vous dans ce code ?',
 'GET /orders
[ { "id": 1234567890123456789, "ref": "A-1" }, ... ]

// côté JS :
if (order.id === 1234567890123456788) { ... } // jamais vrai ?',
 'json',
 'Les nombres JS sont des flottants 64 bits : au-delà de 2^53 (Number.MAX_SAFE_INTEGER), la précision d''entier est perdue — deux ids distincts peuvent devenir identiques à l''affichage/comparaison. Remèdes : ids dans la limite, ids en STRING dans le contrat, ou BigInt côté client. La règle vaut pour tout entier sérialisé (money en cents inclus).',
 240, 25),
('API Review : dates sans fuseau dans le contrat', 'CODE_REVIEW', 'MULTIPLE_CHOICE', 'INTERMEDIATE',
 'Le front affiche des « dates d''expiration » décalées d''une heure selon les postes.',
 'Quels problèmes identifiez-vous dans ce code ?',
 '{ "expiresAt": "2026-03-14 09:00:00", "createdAt": "2026-03-14T08:59:59" }',
 'json',
 'Sans offset de fuseau, chaque côté interprète l''heure selon SON fuseau : le contrat est ambigu (et le format n''est même pas ISO 8601). Règle : ISO 8601 AVEC offset (ou Z) pour les instants, et si l''heure locale est voulue (« ouvre à 9h »), le champ doit le dire (champ + fuseau/zone explicités).',
 120, 15),
('API Review : 201 sans en-tête Location', 'CODE_REVIEW', 'MULTIPLE_CHOICE', 'JUNIOR',
 'Une ressource créée est renvoyée avec son identifiant, mais la convention de l''API est « suivre l''URI de la nouvelle ressource ».',
 'Quels problèmes identifiez-vous dans ce code ?',
 '@PostMapping("/orders")
public ResponseEntity<OrderDto> create(@RequestBody CreateOrder cmd) {
    OrderDto dto = service.create(cmd);
    return ResponseEntity.status(HttpStatus.CREATED)
            .body(dto);            // pas d''en-tête Location
}',
 'java',
 'La convention HTTP de la 201 exige un Location pointant vers l''URI de la ressource créée : sans lui, le client doit reconstruire l''URL (couplage à la forme des routes). Réponse.created(URI) — petit geste, contrat robuste.',
 90, 10),
('API Review : webhook non signé', 'CODE_REVIEW', 'MULTIPLE_CHOICE', 'ADVANCED',
 'Notre API appelle un callback partenaire à chaque événement de commande. Un faux appel déclenche des facturations de test en prod.',
 'Quels problèmes identifiez-vous dans ce code ?',
 'POST https://partner.example/hooks/orders
{ "event": "order.paid", "orderId": 812, "amount": 2490 }

// côté partenaire : 200 systématique',
 'java',
 'Aucune signature ni preuve d''origine : n''importe qui peut fabriquer l''appel (spoofing) ; et sans vérification du statut côté émetteur, un 200 même d''erreur compte comme réussi. Signer (HMAC de la charge utile + timestamp, en-tête dédié, fenêtre horaire anti-rejeu), valider la signature avant traitement, et traiter le code de retour avec retries bornés.',
 240, 25)
) AS v(title, type, selection_type, difficulty, context, question, snippet, lang, explanation, time, points)
WHERE NOT EXISTS (SELECT 1 FROM challenges c WHERE c.title = v.title);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation, severity)
SELECT c.id, v.content, v.is_correct, v.ord, v.expl, v.sev
FROM (VALUES
('API Review : référence circulaire dans la réponse JSON', 'Cycle entité ↔ collection : le sérialiseur boucle jusqu''à StackOverflow', TRUE, 1, 'Réponse attendue : explosion de récursion.', 'BUG'),
('API Review : référence circulaire dans la réponse JSON', 'DTO dédié sans référence retour vers le parent', TRUE, 2, 'Le contrat de réponse décide de la profondeur, jamais le graphe JPA.', 'ARCHITECTURE'),
('API Review : référence circulaire dans la réponse JSON', '@JsonIgnore sur la navigation inverse si le cycle doit être exposé', TRUE, 3, 'Casser un arc du cycle suffit à dérouler le JSON.', 'CODE_QUALITY'),
('API Review : référence circulaire dans la réponse JSON', 'Désactiver la validation récursive du sérialiseur', FALSE, 4, 'Ne résout pas l''infini du JSON — la boucle reste.', NULL),
('API Review : liste sans pagination', 'Réponse non bornée : mémoire × temps de transfert croissant avec la table', TRUE, 1, '45 Mo de JSON : le catalogue décide du coût.', 'PERFORMANCE'),
('API Review : liste sans pagination', 'Pagination/filtres avec bornes dès que la taille peut croître', TRUE, 2, '« Petit aujourd''hui » n''est pas un contrat durable.', 'ARCHITECTURE'),
('API Review : liste sans pagination', 'Côté client : rendre 45 000 éléments reste impossible même si le réseau va vite', TRUE, 3, 'Le problème est double : réseau et rendu.', 'PERFORMANCE'),
('API Review : liste sans pagination', 'Compression gzip règle le problème en totalité', FALSE, 4, 'Réduit le poids, pas le dépliage ni le coût de traitement.', NULL),
('API Review : identifiant JavaScript au-delà de 2^53', 'Les nombres JS perdent la précision d''entier au-delà de 2^53', TRUE, 1, 'Collisions silencieuses de comparaison côté client.', 'BUG'),
('API Review : identifiant JavaScript au-delà de 2^53', 'Ids (et montants en cents) en STRING dans le contrat JSON', TRUE, 2, 'Convention standard des API modernes pour les grands entiers.', 'CODE_QUALITY'),
('API Review : identifiant JavaScript au-delà de 2^53', 'Number.MAX_SAFE_INTEGER comme garde côté client', TRUE, 3, 'Détection au point d''usage — la borne est connue.', 'CODE_QUALITY'),
('API Review : identifiant JavaScript au-delà de 2^53', 'Cast en BigInt côté JS résout sans changer le contrat', FALSE, 4, 'Seulement si le client est maîtrisé — les tiers restent cassés.', NULL),
('API Review : dates sans fuseau dans le contrat', 'Sans offset, chaque côté interprète selon SON fuseau : contrat ambigu', TRUE, 1, 'La cause exacte du décalage d''une heure.', 'BUG'),
('API Review : dates sans fuseau dans le contrat', 'ISO 8601 avec offset (Z) pour les instants', TRUE, 2, 'Représentation non ambiguë d''un moment absolu.', 'CODE_QUALITY'),
('API Review : dates sans fuseau dans le contrat', 'Si l''heure locale est voulue, exposer zone + fuseau explicitement', TRUE, 3, '« 9h » n''a de sens qu''avec sa zone.', 'ARCHITECTURE'),
('API Review : dates sans fuseau dans le contrat', 'Le format "AAAA-MM-JJ HH:MM:SS" suffit partout', FALSE, 4, 'Il omet précisément l''information qui pose problème.', NULL),
('API Review : 201 sans en-tête Location', 'La 201 doit porter Location vers la ressource créée', TRUE, 1, 'Convention HTTP : le client découvre l''URI sans la reconstruire.', 'CODE_QUALITY'),
('API Review : 201 sans en-tête Location', 'ResponseEntity.created(URI) + corps = réponse conforme', TRUE, 2, 'Implémentation standard Spring MVC.', 'CODE_QUALITY'),
('API Review : 201 sans en-tête Location', 'Sans Location, chaque client couplage à la forme exacte des routes', TRUE, 3, 'Le couplage refait surface à chaque restructuration.', 'MAINTAINABILITY'),
('API Review : 201 sans en-tête Location', 'Retourner 200 à la place règle la convention', FALSE, 4, 'Une création au statut 200 fausse davantage le contrat.', NULL),
('API Review : webhook non signé', 'Aucune signature : n''importe qui peut fabriquer l''appel (spoofing)', TRUE, 1, 'Attaque typique de callback non authentifié.', 'SECURITY'),
('API Review : webhook non signé', 'HMAC sur la charge utile + timestamp (fenêtre anti-rejeu) en en-tête', TRUE, 2, 'Preuve d''intégrité ET d''origine.', 'SECURITY'),
('API Review : webhook non signé', 'Statut de réponse du partenaire traité (retries bornés, pas de faux succès)', TRUE, 3, 'L''émission n''est fiable qu''avec retour traité.', 'CODE_QUALITY'),
('API Review : webhook non signé', 'Appeler en HTTP simple car le payload ne contient pas de secret', FALSE, 4, 'L''enjeu est l''authenticité de l''événement, pas la confidentialité.', NULL)
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
('API : ouverture d''une API à des tiers', 'SEQUENTIAL_REASONING', 'SINGLE_CHOICE', 'ADVANCED',
 'L''équipe veut exposer sa plateforme à des partenaires techniques dès le trimestre prochain.',
 'Quelles étapes, dans quel ordre, pour une API prête pour des tiers ?',
 '',
 '',
 'Spécifier le contrat et les cas d''erreur → décider auth (clés/OAuth scopes) + limites de débit → versioning et politique d''évolution → documenter (OpenAPI + exemples) → observabilité (métriques par consumer, journaux corrélés) → environnement sandbox + tests de charge → lancement progressif. Sécuriser avant de documenter, documenter avant d''ouvrir : l''ordre inverse expose un chantier.',
 240, 25),
('API : incident en cascade sur un service tiers', 'SEQUENTIAL_REASONING', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Un fournisseur de paiement répond 500 en rafale : nos files grossissent, nos clients reçoivent des erreurs.',
 'Quelle séquence de réaction recommandes-tu ?',
 '',
 '',
 'Constat chiffré (taux d''erreur, périmètre exact) → confirmer côté tiers (status page) → limiter la casse immédiate (circuit breaker/arrêt temporaire de l''appelant, file de rejeu) → dégrader proprement (message client assumé) → post-mortem + filet durable (retry borné, second fournisseur ?). Optimiser le retry AVANT d''avoir confirmé la cause noie le tiers sous une charge de retry.',
 180, 15),
('API : sécuriser un endpoint existant', 'SEQUENTIAL_REASONING', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Un nouvel endpoint de données personnelles part en prod la semaine prochaine : il est actuellement ouvert à tous.',
 'Dans quel ordre verrouilles-tu l''accès ?',
 '',
 '',
 'Spécifier qui doit accéder (rôles/propriétaire) → implémenter l''authentification/autorisation sur la route (401/403 distincts) → tester les deux refus + l''accès légitime → corriger les messages d''erreur (aucune fuite) → vérifier la couverture (aucune route oubliée, revue du périmètre) → documenter pour les consommateurs. Tester AVANT déploiement : une règle d''accès non testée n''existe pas.',
 180, 15)
) AS v(title, type, selection_type, difficulty, context, question, snippet, lang, explanation, time, points)
WHERE NOT EXISTS (SELECT 1 FROM challenges c WHERE c.title = v.title);

INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.ord, v.expl
FROM (VALUES
('API : ouverture d''une API à des tiers', 'Spécifier contrat + erreurs (le périmètre des cas d''usage)', TRUE, 1, 'Ce qu''on promet doit être écrit avant d''être consommé.'),
('API : ouverture d''une API à des tiers', 'Authentification (scopes) + limites de débit par consumer', TRUE, 2, 'La sécurité d''usage : qui peut quoi, combien de fois.'),
('API : ouverture d''une API à des tiers', 'Versioning + politique d''évolution documentés', TRUE, 3, 'Les tiers planifient sur votre cadence de rupture.'),
('API : ouverture d''une API à des tiers', 'Documentation (OpenAPI + exemples) puis sandbox de test', TRUE, 4, 'Autonomie du partenaire = moins de support.'),
('API : ouverture d''une API à des tiers', 'Observabilité par consumer (métriques, logs corrélés)', TRUE, 5, 'Voir l''usage avant qu''il n''explose.'),
('API : ouverture d''une API à des tiers', 'Ouvrir en bêta publique immédiate pour recueillir le feedback', FALSE, 6, 'Feedback sans garde-fous = incidents chez les premiers tiers.'),
('API : incident en cascade sur un service tiers', 'Constat chiffré : taux d''erreur et périmètre exact', TRUE, 1, 'Dimensionner avant de réagir.'),
('API : incident en cascade sur un service tiers', 'Confirmer côté fournisseur (statut/réseau) : notre faute ou la leur ?', TRUE, 2, 'Le diagnostic oriente toute la suite.'),
('API : incident en cascade sur un service tiers', 'Limiter la casse : circuit breaker, arrêt temporaire, file de rejeu', TRUE, 3, 'On coupe le flux avant l''épuisement de nos ressources.'),
('API : incident en cascade sur un service tiers', 'Dégradation assumée côté client (message, parcours alternatif)', TRUE, 4, 'L''utilisateur est informé plutôt que « 500 » au hasard.'),
('API : incident en cascade sur un service tiers', 'Post-mortem + filets durables (retries bornés, diversification)', TRUE, 5, 'L''incident devient une protection.'),
('API : incident en cascade sur un service tiers', 'Multiplier les retries immédiats pour « rattraper »', FALSE, 6, 'Retry storm : le tiers déjà en souffrance reçoit plus de charge.'),
('API : sécuriser un endpoint existant', 'Spécifier l''accès (rôles, appartenance de la donnée)', TRUE, 1, 'On ne protège pas ce qu''on n''a pas défini.'),
('API : sécuriser un endpoint existant', 'Implémenter 401 (non authentifié) et 403 (non autorisé) distincts', TRUE, 2, 'La sémantique correcte guide le client.'),
('API : sécuriser un endpoint existant', 'Tester les refus ET l''accès légitime', TRUE, 3, 'Une règle testée existe vraiment.'),
('API : sécuriser un endpoint existant', 'Revue du périmètre : aucune route voisine oubliée', TRUE, 4, 'Les failles naissent des oublis de périmètre.'),
('API : sécuriser un endpoint existant', 'Documenter le contrat d''accès pour les consommateurs', TRUE, 5, 'Sans doc, chaque client devine (ou contourne).'),
('API : sécuriser un endpoint existant', 'Compter sur le filter chain global pour tout couvrir', FALSE, 6, 'Les règles globales oublient les cas particuliers — vérifier chaque route.')
) AS v(title, content, is_correct, ord, expl)
JOIN challenges c ON c.title = v.title
WHERE NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id AND o.display_order = v.ord);

-- ---------------------------------------------------------------------
-- Liens
-- ---------------------------------------------------------------------
INSERT INTO challenge_categories (challenge_id, category_id)
SELECT c.id, cat.id
FROM (VALUES
('API : PUT ou PATCH pour modifier deux champs','API / Backend'),
('API : un client casse après un renommage de champ','API / Backend'),
('API : message CORS illisible dans la console','API / Backend'),
('API : effet de bord dans un GET','API / Backend'),
('API : enveloppe de liste paginée','API / Backend'),
('API : CORS, wildcard et credentiels','API / Backend'),
('API : directives de cache sur données personnelles','API / Backend'),
('API : 429 et Retry-After','API / Backend'),
('API : concurrence sur la même ressource (If-Match)','API / Backend'),
('API : 502, 503, 504 — qui est en faute ?','API / Backend'),
('API : absent, null ou chaîne vide en PATCH','API / Backend'),
('API : traitement long et 202 Accepted','API / Backend'),
('API : identifiant de chemin non numérique','API / Backend'),
('API : corps de requête sans limite','API / Backend'),
('API : rate limiting derrière un proxy','API / Backend'),
('API : SameSite et cookies cross-site','API / Backend'),
('API : recherche complexe en GET ou POST','API / Backend'),
('API : BFF et front qui parle au micro-service interne','Architecture'),
('API : évolution du contrat sans casser les clients','API / Backend'),
('API : SSE, WebSocket ou polling','Architecture'),
('API : Idempotency-Key sur les POST critiques','API / Backend'),
('API : isolation multi-tenant et IDOR','API / Backend'),
('API : Vary et caches qui servent le mauvais contenu','API / Backend'),
('API : concevoir un endpoint d''export volumineux','API / Backend'),
('API : contrat d''une ressource imbriquée','API / Backend'),
('API : latence perçue — où est le temps ?','API / Backend'),
('API Review : référence circulaire dans la réponse JSON','API / Backend'),
('API Review : liste sans pagination','API / Backend'),
('API Review : identifiant JavaScript au-delà de 2^53','API / Backend'),
('API Review : dates sans fuseau dans le contrat','API / Backend'),
('API Review : 201 sans en-tête Location','API / Backend'),
('API Review : webhook non signé','API / Backend'),
('API : ouverture d''une API à des tiers','API / Backend'),
('API : incident en cascade sur un service tiers','Distributed Systems'),
('API : sécuriser un endpoint existant','API / Backend'),
('API : 409, 412 ou 422 — quel statut pour quel refus','API / Backend')
) AS v(title, cat)
JOIN challenges c ON c.title = v.title
JOIN categories cat ON cat.name = v.cat
WHERE NOT EXISTS (SELECT 1 FROM challenge_categories cc WHERE cc.challenge_id = c.id AND cc.category_id = cat.id);

INSERT INTO challenge_skills (challenge_id, skill_id)
SELECT c.id, s.id
FROM (VALUES
('API : PUT ou PATCH pour modifier deux champs','Code Quality'),
('API : un client casse après un renommage de champ','Code Quality'),
('API : message CORS illisible dans la console','Debugging'),
('API : effet de bord dans un GET','Code Quality'),
('API : enveloppe de liste paginée','Code Quality'),
('API : CORS, wildcard et credentiels','Code Quality'),
('API : directives de cache sur données personnelles','Code Quality'),
('API : 429 et Retry-After','Problem Solving'),
('API : concurrence sur la même ressource (If-Match)','Problem Solving'),
('API : 502, 503, 504 — qui est en faute ?','Debugging'),
('API : absent, null ou chaîne vide en PATCH','Code Quality'),
('API : traitement long et 202 Accepted','Problem Solving'),
('API : identifiant de chemin non numérique','Debugging'),
('API : corps de requête sans limite','Code Quality'),
('API : rate limiting derrière un proxy','Code Quality'),
('API : SameSite et cookies cross-site','Code Quality'),
('API : recherche complexe en GET ou POST','Code Quality'),
('API : BFF et front qui parle au micro-service interne','Architecture'),
('API : évolution du contrat sans casser les clients','Code Quality'),
('API : SSE, WebSocket ou polling','Architecture'),
('API : Idempotency-Key sur les POST critiques','Problem Solving'),
('API : isolation multi-tenant et IDOR','Code Quality'),
('API : Vary et caches qui servent le mauvais contenu','Problem Solving'),
('API : concevoir un endpoint d''export volumineux','Problem Solving'),
('API : contrat d''une ressource imbriquée','Code Quality'),
('API : latence perçue — où est le temps ?','Performance Analysis'),
('API Review : référence circulaire dans la réponse JSON','Debugging'),
('API Review : liste sans pagination','Performance Analysis'),
('API Review : identifiant JavaScript au-delà de 2^53','Debugging'),
('API Review : dates sans fuseau dans le contrat','Code Quality'),
('API Review : 201 sans en-tête Location','Code Quality'),
('API Review : webhook non signé','Code Quality'),
('API : ouverture d''une API à des tiers','Problem Solving'),
('API : incident en cascade sur un service tiers','Debugging'),
('API : sécuriser un endpoint existant','Problem Solving'),
('API : 409, 412 ou 422 — quel statut pour quel refus','Code Quality')
) AS v(title, skill)
JOIN challenges c ON c.title = v.title
JOIN skills s ON s.name = v.skill
WHERE NOT EXISTS (SELECT 1 FROM challenge_skills cs WHERE cs.challenge_id = c.id AND cs.skill_id = s.id);

INSERT INTO challenge_profiles (challenge_id, profile_id)
SELECT c.id, p.id
FROM (VALUES
('API : PUT ou PATCH pour modifier deux champs'),('API : un client casse après un renommage de champ'),
('API : message CORS illisible dans la console'),('API : effet de bord dans un GET'),
('API : enveloppe de liste paginée'),('API : CORS, wildcard et credentiels'),
('API : directives de cache sur données personnelles'),('API : 429 et Retry-After'),
('API : concurrence sur la même ressource (If-Match)'),('API : 502, 503, 504 — qui est en faute ?'),
('API : absent, null ou chaîne vide en PATCH'),('API : traitement long et 202 Accepted'),
('API : identifiant de chemin non numérique'),('API : corps de requête sans limite'),
('API : rate limiting derrière un proxy'),('API : SameSite et cookies cross-site'),
('API : recherche complexe en GET ou POST'),('API : BFF et front qui parle au micro-service interne'),
('API : évolution du contrat sans casser les clients'),('API : SSE, WebSocket ou polling'),
('API : Idempotency-Key sur les POST critiques'),('API : isolation multi-tenant et IDOR'),
('API : Vary et caches qui servent le mauvais contenu'),('API : concevoir un endpoint d''export volumineux'),
('API : contrat d''une ressource imbriquée'),('API : latence perçue — où est le temps ?'),
('API Review : référence circulaire dans la réponse JSON'),('API Review : liste sans pagination'),
('API Review : identifiant JavaScript au-delà de 2^53'),('API Review : dates sans fuseau dans le contrat'),
('API Review : 201 sans en-tête Location'),('API Review : webhook non signé'),
('API : ouverture d''une API à des tiers'),('API : incident en cascade sur un service tiers'),
('API : sécuriser un endpoint existant'),
('API : 409, 412 ou 422 — quel statut pour quel refus')
) AS v(title)
JOIN challenges c ON c.title = v.title
JOIN profiles p ON p.code = 'DEVELOPER'
WHERE NOT EXISTS (SELECT 1 FROM challenge_profiles cp WHERE cp.challenge_id = c.id AND cp.profile_id = p.id);
