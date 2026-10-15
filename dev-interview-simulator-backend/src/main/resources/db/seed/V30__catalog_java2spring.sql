-- =====================================================================
-- Catalogue Java 2 — Fondamentaux Java / Conception / Spring Boot (profil DEVELOPER)
-- 18 SITUATIONAL_QCM + 4 PROBLEM_SOLVING + 5 CODE_REVIEW + 4 SEQUENTIAL_REASONING = 31
-- Niveaux : 21 JUNIOR + 10 INTERMEDIATE
-- Idempotence : WHERE NOT EXISTS (title) + NOT EXISTS par option / lien.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 18 QCM
-- ---------------------------------------------------------------------
INSERT INTO challenges (title, type, selection_type, difficulty, context, question, code_snippet, code_language, explanation, estimated_time_seconds, active, points, created_at, updated_at)
SELECT v.title, v.type, v.selection_type, v.difficulty, v.context, v.question,
       NULLIF(v.snippet, ''), NULLIF(v.lang, ''), v.explanation, v.time, TRUE, v.points,
       CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM (VALUES
-- JUNIOR (13)
('Bases Java : HashSet ou HashMap ?', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'JUNIOR',
 'Tu dois mémoriser les adresses e-mail déjà inscrites pour refuser les doublons. Tu as seulement besoin de savoir si une adresse est déjà présente.',
 'Quelle structure est la plus adaptée ?',
 '',
 '',
 'Un HashSet stocke des éléments uniques et répond vite à la question « est-ce déjà présent ? » grâce à contains(). Une HashMap stocke des paires clé/valeur : elle sert quand on veut retrouver une valeur à partir d''une clé, ce qui n''est pas le besoin ici.',
 90, 10),
('Bases Java : HashMap ou TreeMap ?', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'JUNIOR',
 'Tu affiches un annuaire : chaque nom est associé à un numéro de téléphone, et l''écran doit lister les noms par ordre alphabétique.',
 'Quelle différence principale entre HashMap et TreeMap justifie le choix ?',
 '',
 '',
 'HashMap ne garantit aucun ordre de parcours. TreeMap garde ses clés triées (ordre naturel ou Comparator), ce qui convient à un affichage alphabétique. En contrepartie, TreeMap est un peu moins rapide et ses clés doivent être comparables.',
 90, 10),
('Bases Java : classe abstraite ou interface ?', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'JUNIOR',
 'Tu modélises des moyens de paiement (CarteBancaire, PayPal). Tous doivent exposer une méthode payer(montant), mais chacun la réalise différemment.',
 'Quel outil exprime le mieux « voici ce qu''un moyen de paiement sait faire », sans imposer de code commun ?',
 '',
 '',
 'Une interface décrit un contrat (ce qu''on peut faire) et une classe peut en implémenter plusieurs. Une classe abstraite sert plutôt à partager du code et de l''état entre des classes liées par une vraie relation « est un », mais une classe ne peut en étendre qu''une seule.',
 120, 10),
('Bases Java : surcharge ou redéfinition ?', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'JUNIOR',
 'Une classe Animal définit crier(). La classe Chien étend Animal et écrit sa propre version de crier() avec le même nom et les mêmes paramètres.',
 'Comment appelle-t-on ce mécanisme ?',
 'class Animal {
    void crier() { System.out.println("..."); }
}
class Chien extends Animal {
    @Override
    void crier() { System.out.println("Wouf"); }
}',
 'java',
 'Redéfinir (override) une méthode, c''est fournir dans une sous-classe une nouvelle version avec la même signature : c''est la base du polymorphisme. La surcharge (overload) consiste à avoir plusieurs méthodes de même nom mais de paramètres différents.',
 90, 10),
('Bases Java : exception checked ou unchecked ?', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'JUNIOR',
 'Tu lis un fichier avec FileReader : le compilateur refuse ton code tant que tu n''as pas ajouté un try/catch ou un throws. En revanche, une division entière par zéro (ArithmeticException) ne t''oblige à rien.',
 'Quelle est la différence entre ces deux familles d''exceptions ?',
 '',
 '',
 'Les exceptions checked (par exemple IOException) sont vérifiées par le compilateur : on doit les gérer avec try/catch ou les déclarer avec throws. Les unchecked (RuntimeException et ses sous-classes comme NullPointerException ou IllegalArgumentException) ne sont pas imposées et signalent souvent une erreur de programmation.',
 120, 10),
('Bases Java : throw ou throws ?', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'JUNIOR',
 'Dans une méthode, tu veux refuser un âge négatif en signalant l''erreur à l''appelant.',
 'Quelle écriture à la place du commentaire est correcte ?',
 'public void setAge(int age) {
    if (age < 0) {
        // ?
    }
    this.age = age;
}',
 'java',
 'throw (sans s) est une instruction qui lance une exception à cet endroit du code. throws se place dans la signature d''une méthode pour déclarer qu''elle peut laisser passer une exception checked. IllegalArgumentException est unchecked : aucun throws n''est nécessaire.',
 90, 10),
('Bases Java : String ou StringBuilder ?', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'JUNIOR',
 'Tu construis un long texte en ajoutant des milliers de morceaux dans une boucle.',
 'Quelle approche est la plus adaptée ?',
 'String resultat = "";
for (String morceau : morceaux) {
    resultat += morceau;
}',
 'java',
 'Une String est immuable : chaque += crée un nouvel objet et recopie le texte déjà construit. Pour assembler beaucoup de morceaux dans une boucle, StringBuilder modifie un même tampon avec append() et évite ces copies. Pour deux ou trois concaténations simples, une String suffit très bien.',
 120, 10),
('Bases Java : lire une chaîne de Stream', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'JUNIOR',
 'Une liste de prénoms contient : Anna, Bob, Alice, Eve.',
 'Que contient la liste résultat ?',
 'List<String> resultat = prenoms.stream()
        .filter(p -> p.startsWith("A"))
        .map(String::toUpperCase)
        .collect(Collectors.toList());',
 'java',
 'filter garde seulement les éléments qui respectent la condition (ceux qui commencent par A), map transforme chaque élément restant (ici en majuscules) et collect rassemble le tout dans une liste. Le résultat est [ANNA, ALICE]. La liste d''origine n''est pas modifiée.',
 120, 10),
('Bases Java : à quoi sert Optional ?', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'JUNIOR',
 'Une méthode trouverParEmail(String email) peut ne trouver aucun utilisateur.',
 'Pourquoi retourner Optional<User> plutôt que User (ou null) ?',
 '',
 '',
 'Optional rend explicite, dans la signature, que le résultat peut être absent et pousse l''appelant à traiter ce cas (orElse, orElseThrow, ifPresent). Il évite d''oublier un test de null. Il s''utilise surtout comme type de retour, pas comme champ d''entité ni comme paramètre.',
 90, 10),
('Bases Spring : PathVariable ou RequestParam ?', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'JUNIOR',
 'Tu exposes deux appels : GET /users/42 pour lire l''utilisateur 42, et GET /users?role=ADMIN pour filtrer la liste par rôle.',
 'Quelle affirmation est exacte sur ces deux annotations ?',
 '@GetMapping("/users/{id}")
public User one(@PathVariable Long id) { ... }

@GetMapping("/users")
public List<User> list(@RequestParam String role) { ... }',
 'java',
 '@PathVariable lit une valeur placée dans le chemin de l''URL (/users/42) : elle identifie une ressource. @RequestParam lit un paramètre de requête placé après le ? (?role=ADMIN) : c''est typique d''un filtre, d''un tri ou d''une pagination.',
 90, 10),
('Bases Spring : DTO ou Entity pour créer un compte ?', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'JUNIOR',
 'Un endpoint POST /users reçoit le JSON d''inscription. L''entité User possède id, email, password, role et enabled.',
 'Pourquoi recevoir un UserCreateRequest (DTO) plutôt que directement l''entité User ?',
 '',
 '',
 'Un DTO décrit exactement ce que l''API accepte ou renvoie. Avec l''entité, un client pourrait envoyer des champs qu''il ne doit pas maîtriser (role, enabled, id) et le contrat de l''API dépendrait de la structure de la base. Le DTO permet aussi de valider uniquement les champs attendus.',
 120, 15),
('Bases Spring : rôle de @RestController', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'JUNIOR',
 'Deux classes : l''une annotée @Controller, l''autre @RestController. Chacune a une méthode qui retourne un objet User.',
 'Quelle différence pratique entre les deux ?',
 '',
 '',
 '@RestController équivaut à @Controller + @ResponseBody : la valeur retournée est écrite directement dans le corps de la réponse HTTP (en JSON par défaut). Avec un simple @Controller, la valeur retournée est interprétée comme un nom de vue (page HTML), sauf si on ajoute @ResponseBody.',
 90, 10),
('Bases Spring : Spring ou Spring Boot ?', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'JUNIOR',
 'Un collègue affirme : « Avec Spring Boot, on n''a plus besoin de Spring. »',
 'Quelle réponse est correcte ?',
 '',
 '',
 'Spring Boot s''appuie sur Spring Framework (conteneur IoC, injection de dépendances, MVC, accès aux données). Il ajoute l''autoconfiguration, des starters de dépendances et un serveur embarqué (Tomcat) pour démarrer une application avec très peu de configuration. Il ne remplace pas Spring : il simplifie son utilisation.',
 90, 10),
-- INTERMEDIATE (5)
('Conception : quand utiliser le pattern Strategy ?', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Un service de commande calcule la remise avec un grand if/else (client premium, soldes, code promo...). À chaque nouvelle règle, on rouvre ce même service.',
 'Quelle approche réduit ce problème ?',
 'public double remise(String type, double prix) {
    if (type.equals("PREMIUM")) return prix * 0.10;
    else if (type.equals("SOLDES")) return prix * 0.30;
    else if (type.equals("PROMO")) return prix * 0.05;
    return 0;
}',
 'java',
 'Le pattern Strategy isole chaque règle dans sa propre classe, qui implémente une interface commune (par exemple RemiseStrategy). Le service choisit la stratégie sans connaître les détails : ajouter une règle revient à ajouter une classe, sans modifier le code existant (principe ouvert/fermé). Dans Spring, on injecte souvent les stratégies sous forme de beans.',
 150, 15),
('Conception : pourquoi un Builder ?', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Une classe Utilisateur a un constructeur à 8 paramètres dont plusieurs optionnels. Les appels sont illisibles : new Utilisateur("Anna", null, null, 30, true, null, "FR", false).',
 'Quel pattern améliore la lisibilité de la création ?',
 '',
 '',
 'Le pattern Builder construit l''objet pas à pas avec des méthodes nommées (nom("Anna").age(30).pays("FR").build()). On voit ce que représente chaque valeur, les paramètres optionnels sont simplement omis et l''objet final peut rester immuable. Lombok propose @Builder pour éviter d''écrire ce code à la main.',
 120, 15),
('Conception : Singleton et ses limites', 'SITUATIONAL_QCM', 'MULTIPLE_CHOICE', 'INTERMEDIATE',
 'Une équipe écrit une classe ConfigManager avec un constructeur privé et un getInstance() statique pour garantir une seule instance.',
 'Quelles affirmations sont exactes ?',
 '',
 '',
 'Un Singleton garantit une seule instance, mais crée un état global difficile à remplacer dans les tests et qui cache les dépendances. Dans Spring, les beans sont déjà des singletons par défaut dans le conteneur : on obtient une seule instance par injection, sans getInstance() statique, ce qui reste testable.',
 150, 15),
('Conception : inversion de dépendance (DIP)', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Un service de commande crée lui-même son accès aux données avec new MySqlOrderRepository(). Pour tester, on voudrait un faux repository en mémoire.',
 'Quelle modification applique le principe d''inversion de dépendance ?',
 'public class OrderService {
    private final MySqlOrderRepository repository = new MySqlOrderRepository();

    public void place(Order order) {
        repository.save(order);
    }
}',
 'java',
 'Le DIP veut que le code métier dépende d''une abstraction (une interface OrderRepository) et non d''une implémentation concrète, qui lui est fournie de l''extérieur (injection par constructeur). On peut alors remplacer l''implémentation (MySQL, mémoire, mock de test) sans toucher à OrderService.',
 150, 15),
('JPA : relation un-à-plusieurs simple', 'SITUATIONAL_QCM', 'SINGLE_CHOICE', 'INTERMEDIATE',
 'Un Auteur écrit plusieurs Livres. En base, la table livre contient une colonne auteur_id.',
 'Que signifie mappedBy = "auteur" dans la classe Auteur ?',
 '@Entity
public class Auteur {
    @Id @GeneratedValue
    private Long id;

    @OneToMany(mappedBy = "auteur")
    private List<Livre> livres = new ArrayList<>();
}

@Entity
public class Livre {
    @Id @GeneratedValue
    private Long id;

    @ManyToOne
    @JoinColumn(name = "auteur_id")
    private Auteur auteur;
}',
 'java',
 'Dans une relation bidirectionnelle, un seul côté possède la clé étrangère : ici Livre (colonne auteur_id). mappedBy indique, côté Auteur, que la relation est déjà décrite par le champ auteur de Livre : Hibernate ne crée ni seconde colonne ni table de jointure. Pour que la base soit à jour, il faut renseigner livre.setAuteur(auteur).',
 180, 20)
     ) AS v(title, type, selection_type, difficulty, context, question, snippet, lang, explanation, time, points)
WHERE NOT EXISTS (SELECT 1 FROM challenges c WHERE c.title = v.title);

-- ---------------------------------------------------------------------
-- 4 PROBLEM_SOLVING (réponse à choisir, une seule bonne option)
-- ---------------------------------------------------------------------
INSERT INTO challenges (title, type, selection_type, difficulty, context, question, code_snippet, code_language, explanation, estimated_time_seconds, active, points, created_at, updated_at)
SELECT v.title, v.type, v.selection_type, v.difficulty, v.context, v.question,
       NULLIF(v.snippet, ''), NULLIF(v.lang, ''), v.explanation, v.time, TRUE, v.points,
       CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM (VALUES
          ('Situation : utilisateurs sans doublons', 'PROBLEM_SOLVING', 'SINGLE_CHOICE', 'JUNIOR',
           'Tu dois stocker une liste d''utilisateurs sans jamais avoir deux fois le même (même identifiant).',
           'Quelle structure choisis-tu ?',
           '',
           '',
           'Un Set empêche les doublons. Avec un HashSet de classes personnalisées, il faut que equals() et hashCode() soient redéfinis (par exemple sur l''identifiant), sinon deux objets « identiques » sont considérés comme différents. Si l''ordre d''affichage compte, LinkedHashSet garde l''ordre d''insertion et TreeSet trie les éléments.',
           120, 10),
          ('Situation : retrouver un utilisateur par son identifiant', 'PROBLEM_SOLVING', 'SINGLE_CHOICE', 'JUNIOR',
           'Ton application doit retrouver très souvent un utilisateur à partir de son identifiant, parmi plusieurs milliers.',
           'Quelle structure est la plus adaptée ?',
           '',
           '',
           'Une Map associe une clé (l''identifiant) à une valeur (l''utilisateur) et permet un accès direct : HashMap<Long, User>. Parcourir une liste à chaque recherche devient coûteux quand les données grossissent.',
           120, 10),
          ('Situation : un Controller qui fait tout', 'PROBLEM_SOLVING', 'SINGLE_CHOICE', 'INTERMEDIATE',
           'Ton @RestController valide les données, calcule le prix avec des remises, appelle le repository et envoie un e-mail, le tout dans une seule méthode de 80 lignes.',
           'Que peux-tu améliorer en priorité ?',
           '',
           '',
           'Le Controller doit rester fin : il reçoit la requête HTTP, délègue et renvoie la réponse. La logique métier (calculs, règles, enchaînement des opérations) va dans un @Service, l''accès aux données dans un @Repository. On obtient des classes plus courtes, réutilisables et testables sans lancer de serveur web.',
           150, 15),
          ('Situation : deux classes avec beaucoup de code commun', 'PROBLEM_SOLVING', 'SINGLE_CHOICE', 'INTERMEDIATE',
           'FactureClient et FactureFournisseur contiennent chacune la même logique de calcul de TVA et d''arrondi, copiée-collée.',
           'Quelle approche envisages-tu ?',
           '',
           '',
           'La duplication oblige à corriger chaque copie à chaque évolution. On extrait le code commun : soit dans une classe parente (abstraite) si les deux classes sont réellement « une sorte de » facture, soit dans un composant séparé (par exemple CalculateurTva) utilisé par composition. En cas de doute, la composition est en général plus souple que l''héritage.',
           150, 15)
     ) AS v(title, type, selection_type, difficulty, context, question, snippet, lang, explanation, time, points)
WHERE NOT EXISTS (SELECT 1 FROM challenges c WHERE c.title = v.title);

-- ---------------------------------------------------------------------
-- 5 CODE_REVIEW
-- ---------------------------------------------------------------------
INSERT INTO challenges (title, type, selection_type, difficulty, context, question, code_snippet, code_language, explanation, estimated_time_seconds, active, points, created_at, updated_at)
SELECT v.title, v.type, v.selection_type, v.difficulty, v.context, v.question,
       v.snippet, v.lang, v.explanation, v.time, TRUE, v.points,
       CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM (VALUES
          ('Review Bases : attributs publics', 'CODE_REVIEW', 'MULTIPLE_CHOICE', 'JUNIOR',
           'Une classe CompteBancaire est utilisée dans toute l''application.',
           'Quels problèmes identifiez-vous dans ce code ?',
           'public class CompteBancaire {
              public double solde;
              public String titulaire;

              public void retirer(double montant) {
                  solde = solde - montant;
              }
          }',
           'java',
           'Les champs publics cassent l''encapsulation : n''importe quel code peut modifier le solde sans passer par la logique de la classe. De plus, retirer() ne vérifie ni le montant ni le solde disponible. Il faut des champs private, un accès contrôlé (getters) et des méthodes qui appliquent les règles (montant positif, solde suffisant).',
           150, 15),
          ('Review Bases : equals sans hashCode', 'CODE_REVIEW', 'MULTIPLE_CHOICE', 'JUNIOR',
           'Une classe Produit est stockée dans un HashSet pour éviter les doublons.',
           'Quels problèmes identifiez-vous dans ce code ?',
           'public class Produit {
              private final String reference;

              public Produit(String reference) {
                  this.reference = reference;
              }

              @Override
              public boolean equals(Object o) {
                  if (this == o) return true;
                  if (!(o instanceof Produit)) return false;
                  return reference.equals(((Produit) o).reference);
              }
          }',
           'java',
           'equals() et hashCode() doivent toujours être redéfinis ensemble : deux objets égaux doivent avoir le même hashCode. Sans hashCode(), deux Produit de même référence tombent souvent dans des cases différentes du HashSet et le doublon n''est pas détecté. Il faut ajouter un hashCode() basé sur reference (par exemple Objects.hash(reference)).',
           150, 15),
          ('Review Bases : noms et méthode illisibles', 'CODE_REVIEW', 'MULTIPLE_CHOICE', 'JUNIOR',
           'Un développeur junior a écrit cette méthode et l''équipe a du mal à la relire.',
           'Quels problèmes identifiez-vous dans ce code ?',
           'public double calc(List<Double> l, int t) {
              double r = 0;
              for (double x : l) {
                  r = r + x;
              }
              if (t == 1) {
                  r = r - r * 0.1;
              }
              return r;
          }',
           'java',
           'Les noms (calc, l, t, r, x) n''expliquent rien, et les valeurs 1 et 0.1 sont des « valeurs magiques ». Des noms explicites (calculerTotal, prix, estClientPremium, total) et une constante nommée (TAUX_REMISE_PREMIUM) rendent la méthode lisible sans commentaire. Le code fonctionne : le problème est la lisibilité et la maintenance.',
           150, 15),
          ('Review Bases : une classe, trop de responsabilités', 'CODE_REVIEW', 'MULTIPLE_CHOICE', 'INTERMEDIATE',
           'Une classe OrderService est devenue le point central de l''application.',
           'Quels problèmes identifiez-vous dans ce code ?',
           '@Service
          public class OrderService {

              public void placeOrder(OrderRequest request) {
                  if (request.getEmail() == null || !request.getEmail().contains("@")) {
                      throw new IllegalArgumentException("Email invalide");
                  }
                  double total = 0;
                  for (Item item : request.getItems()) {
                      total += item.getPrice() * item.getQuantity();
                  }
                  jdbcTemplate.update("INSERT INTO orders ...", total);
                  String body = "Merci pour votre commande de " + total + " EUR";
                  mailSender.send(request.getEmail(), "Commande", body);
              }
          }',
           'java',
           'La classe cumule validation, calcul du prix, accès à la base et envoi d''e-mail : elle change pour quatre raisons différentes, ce qui viole le principe de responsabilité unique (SRP). On la découpe (validateur, calcul de prix, repository, service de notification) et OrderService ne fait plus qu''orchestrer. Chaque morceau devient plus simple à tester.',
           180, 20),
          ('Review Bases : Controller qui parle directement au Repository', 'CODE_REVIEW', 'MULTIPLE_CHOICE', 'INTERMEDIATE',
           'Un endpoint renvoie la liste des utilisateurs.',
           'Quels problèmes identifiez-vous dans ce code ?',
           '@RestController
          @RequestMapping("/users")
          public class UserController {

              @Autowired
              private UserRepository userRepository;

              @GetMapping
              public List<User> all() {
                  return userRepository.findAll();
              }
          }',
           'java',
           'Le Controller appelle directement le Repository : il n''y a pas de couche Service pour porter les règles métier ni les transactions, et la logique finira dans le Controller le jour où il faudra filtrer ou transformer les données. L''entité User est renvoyée telle quelle : un champ interne (comme password) peut être exposé. On préfère Controller, Service, Repository, un DTO en sortie et l''injection par constructeur.',
           180, 20)
     ) AS v(title, type, selection_type, difficulty, context, question, snippet, lang, explanation, time, points)
WHERE NOT EXISTS (SELECT 1 FROM challenges c WHERE c.title = v.title);

-- ---------------------------------------------------------------------
-- 4 SEQUENTIAL_REASONING (display_order = ordre attendu)
-- ---------------------------------------------------------------------
INSERT INTO challenges (title, type, selection_type, difficulty, context, question, code_snippet, code_language, explanation, estimated_time_seconds, active, points, created_at, updated_at)
SELECT v.title, v.type, v.selection_type, v.difficulty, v.context, v.question,
       NULLIF(v.snippet, ''), NULLIF(v.lang, ''), v.explanation, v.time, TRUE, v.points,
       CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM (VALUES
          ('Ordre : parcours d''une requête dans Spring Boot', 'SEQUENTIAL_REASONING', 'SINGLE_CHOICE', 'JUNIOR',
           'Un client appelle GET /users/42 sur une application Spring Boot classique en trois couches.',
           'Remets dans l''ordre le parcours de la requête jusqu''à la réponse.',
           '',
           '',
           'La requête HTTP arrive au Controller, qui délègue au Service (logique métier). Le Service s''appuie sur le Repository pour interroger la base de données. Le résultat remonte ensuite dans l''ordre inverse jusqu''au client, converti en JSON.',
           120, 10),
          ('Ordre : créer un endpoint REST', 'SEQUENTIAL_REASONING', 'SINGLE_CHOICE', 'JUNIOR',
           'Tu dois ajouter GET /products/{id} à une application Spring Boot.',
           'Dans quel ordre logique construis-tu les éléments ?',
           '',
           '',
           'On part des données vers l''extérieur : l''entité et le repository d''abord, puis le DTO et le service (logique), puis le controller (point d''entrée HTTP), et enfin le test de l''appel. Construire le controller en premier oblige à appeler des classes qui n''existent pas encore.',
           120, 10),
          ('Ordre : try, catch et finally', 'SEQUENTIAL_REASONING', 'SINGLE_CHOICE', 'JUNIOR',
           'Tu lis un fichier dans un try/catch/finally et une erreur se produit pendant la lecture.',
           'Dans quel ordre le code s''exécute-t-il ?',
           '',
           '',
           'Le bloc try s''exécute jusqu''à l''instruction qui échoue ; le reste du try est ignoré. Java cherche alors un catch correspondant et l''exécute. Le bloc finally s''exécute ensuite, qu''il y ait eu une erreur ou non, puis le programme continue normalement si l''exception a été attrapée.',
           90, 10),
          ('Ordre : authentification JWT simple', 'SEQUENTIAL_REASONING', 'SINGLE_CHOICE', 'INTERMEDIATE',
           'Une application Spring Boot protège ses routes avec un token JWT. Un utilisateur se connecte, puis appelle une route protégée.',
           'Remets dans l''ordre le déroulement.',
           '',
           '',
           'Le client envoie ses identifiants une seule fois. Le serveur les vérifie (le mot de passe est comparé au hash enregistré) et renvoie un token signé. Pour les appels suivants, le client envoie le token dans l''en-tête Authorization ; un filtre le vérifie avant que la requête atteigne le Controller.',
           150, 15)
     ) AS v(title, type, selection_type, difficulty, context, question, snippet, lang, explanation, time, points)
WHERE NOT EXISTS (SELECT 1 FROM challenges c WHERE c.title = v.title);

-- ---------------------------------------------------------------------
-- Options QCM + PROBLEM_SOLVING + SEQUENTIAL (5 colonnes, sans sévérité)
-- ---------------------------------------------------------------------
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation)
SELECT c.id, v.content, v.is_correct, v.ord, v.expl
FROM (VALUES
-- QCM 1
('Bases Java : HashSet ou HashMap ?', 'Un HashSet<String>', TRUE, 1, 'Il garantit l''unicité et offre un contains() rapide : exactement le besoin.'),
('Bases Java : HashSet ou HashMap ?', 'Une HashMap<String, String> avec la même valeur partout', FALSE, 2, 'Ça fonctionne, mais on crée une valeur inutile : un Set exprime mieux l''intention.'),
('Bases Java : HashSet ou HashMap ?', 'Une ArrayList<String>', FALSE, 3, 'Une liste accepte les doublons et contains() parcourt tous les éléments.'),
('Bases Java : HashSet ou HashMap ?', 'Un tableau String[]', FALSE, 4, 'Taille fixe et aucune unicité automatique : peu adapté.'),
-- QCM 2
('Bases Java : HashMap ou TreeMap ?', 'TreeMap garde les clés triées, HashMap ne garantit aucun ordre', TRUE, 1, 'C''est la différence principale qui justifie le choix ici.'),
('Bases Java : HashMap ou TreeMap ?', 'HashMap accepte les doublons de clés, pas TreeMap', FALSE, 2, 'Aucune des deux n''accepte deux fois la même clé : la nouvelle valeur remplace l''ancienne.'),
('Bases Java : HashMap ou TreeMap ?', 'TreeMap ne peut pas stocker de String', FALSE, 3, 'Les String sont comparables et fonctionnent très bien comme clés.'),
('Bases Java : HashMap ou TreeMap ?', 'HashMap trie automatiquement les clés par ordre alphabétique', FALSE, 4, 'L''ordre d''une HashMap peut sembler aléatoire et ne doit jamais être utilisé.'),
-- QCM 3
('Bases Java : classe abstraite ou interface ?', 'Une interface MoyenDePaiement avec la méthode payer', TRUE, 1, 'L''interface exprime le contrat sans imposer de code ni d''état.'),
('Bases Java : classe abstraite ou interface ?', 'Une classe concrète MoyenDePaiement dont payer() ne fait rien', FALSE, 2, 'Rien n''oblige les sous-classes à redéfinir payer() : le contrat n''est pas garanti.'),
('Bases Java : classe abstraite ou interface ?', 'Une enum MoyenDePaiement', FALSE, 3, 'Une enum liste des valeurs fixes, elle ne décrit pas un comportement variable par classe.'),
('Bases Java : classe abstraite ou interface ?', 'Une variable static payer', FALSE, 4, 'Une variable ne décrit pas un comportement.'),
-- QCM 4
('Bases Java : surcharge ou redéfinition ?', 'Redéfinition (override)', TRUE, 1, 'Même signature dans une sous-classe : la version de Chien remplace celle d''Animal.'),
('Bases Java : surcharge ou redéfinition ?', 'Surcharge (overload)', FALSE, 2, 'La surcharge change les paramètres, au sein d''une même classe.'),
('Bases Java : surcharge ou redéfinition ?', 'Encapsulation', FALSE, 3, 'L''encapsulation protège l''état interne d''une classe : sans rapport ici.'),
('Bases Java : surcharge ou redéfinition ?', 'Composition', FALSE, 4, 'La composition consiste à utiliser un objet à l''intérieur d''un autre, pas à redéfinir une méthode.'),
-- QCM 5
('Bases Java : exception checked ou unchecked ?', 'Le compilateur impose de gérer les checked, pas les unchecked', TRUE, 1, 'C''est le critère de distinction entre les deux familles.'),
('Bases Java : exception checked ou unchecked ?', 'Les unchecked arrêtent toujours le programme', FALSE, 2, 'Une unchecked peut être attrapée avec try/catch comme les autres.'),
('Bases Java : exception checked ou unchecked ?', 'Les checked ne peuvent pas être attrapées avec try/catch', FALSE, 3, 'Elles s''attrapent normalement, c''est même l''une des deux façons de les gérer.'),
('Bases Java : exception checked ou unchecked ?', 'Les checked n''existent qu''avec les fichiers', FALSE, 4, 'Réseau, base de données et bien d''autres cas en produisent aussi.'),
-- QCM 6
('Bases Java : throw ou throws ?', 'throw new IllegalArgumentException("Age négatif interdit");', TRUE, 1, 'throw lance l''exception à cet endroit ; l''exception est unchecked, aucun throws n''est requis.'),
('Bases Java : throw ou throws ?', 'throws new IllegalArgumentException("Age négatif interdit");', FALSE, 2, 'throws ne lance rien : il se place dans la signature d''une méthode.'),
('Bases Java : throw ou throws ?', 'return new IllegalArgumentException("Age négatif interdit");', FALSE, 3, 'Retourner une exception ne la lance pas : le code continue normalement.'),
('Bases Java : throw ou throws ?', 'catch (IllegalArgumentException e)', FALSE, 4, 'catch sert à attraper une exception, pas à en lancer une.'),
-- QCM 7
('Bases Java : String ou StringBuilder ?', 'Utiliser un StringBuilder et appeler append() dans la boucle', TRUE, 1, 'Un seul tampon modifiable : pas de copie du texte à chaque tour.'),
('Bases Java : String ou StringBuilder ?', 'Garder la String : la concaténation dans une boucle est toujours optimale', FALSE, 2, 'Chaque tour crée en général un nouvel objet et recopie le texte déjà construit.'),
('Bases Java : String ou StringBuilder ?', 'Utiliser un tableau de char de taille fixe', FALSE, 3, 'Peu pratique : la taille finale n''est pas connue à l''avance.'),
('Bases Java : String ou StringBuilder ?', 'Convertir chaque morceau en int', FALSE, 4, 'Sans rapport avec le besoin.'),
-- QCM 8
('Bases Java : lire une chaîne de Stream', '[ANNA, ALICE]', TRUE, 1, 'filter garde Anna et Alice, map les met en majuscules.'),
('Bases Java : lire une chaîne de Stream', '[Anna, Alice]', FALSE, 2, 'map(String::toUpperCase) transforme les valeurs en majuscules.'),
('Bases Java : lire une chaîne de Stream', '[ANNA, BOB, ALICE, EVE]', FALSE, 3, 'filter retire Bob et Eve, qui ne commencent pas par A.'),
('Bases Java : lire une chaîne de Stream', 'La liste prenoms elle-même est modifiée en [ANNA, ALICE]', FALSE, 4, 'Un stream ne modifie pas sa source : il produit un nouveau résultat.'),
-- QCM 9
('Bases Java : à quoi sert Optional ?', 'Il indique clairement que l''absence de résultat est possible', TRUE, 1, 'La signature documente le cas « rien trouvé » et oblige à le traiter.'),
('Bases Java : à quoi sert Optional ?', 'Il rend la méthode plus rapide', FALSE, 2, 'Aucun gain de vitesse : le gain est en lisibilité et en sûreté.'),
('Bases Java : à quoi sert Optional ?', 'Il empêche le résultat d''être vide', FALSE, 3, 'Au contraire : il représente justement le cas « vide ».'),
('Bases Java : à quoi sert Optional ?', 'Il remplace try/catch', FALSE, 4, 'Sans rapport avec la gestion des exceptions.'),
-- QCM 10
('Bases Spring : PathVariable ou RequestParam ?', '@PathVariable lit l''id dans le chemin ; @RequestParam lit role après le ?', TRUE, 1, 'Chemin pour identifier une ressource, paramètre de requête pour filtrer.'),
('Bases Spring : PathVariable ou RequestParam ?', '@PathVariable lit le corps JSON de la requête', FALSE, 2, 'Le corps JSON se lit avec @RequestBody.'),
('Bases Spring : PathVariable ou RequestParam ?', '@RequestParam est réservé aux requêtes POST', FALSE, 3, 'Il s''utilise très souvent en GET pour des filtres.'),
('Bases Spring : PathVariable ou RequestParam ?', 'Les deux sont identiques et interchangeables', FALSE, 4, 'Elles lisent des endroits différents de l''URL.'),
-- QCM 11
('Bases Spring : DTO ou Entity pour créer un compte ?', 'Pour que le client ne puisse fournir que les champs prévus (pas role, enabled ni id)', TRUE, 1, 'Le DTO limite le contrat de l''API à ce qui est volontairement exposé.'),
('Bases Spring : DTO ou Entity pour créer un compte ?', 'Parce que Spring refuse de désérialiser une entité', FALSE, 2, 'Techniquement possible : le problème est de conception, pas de faisabilité.'),
('Bases Spring : DTO ou Entity pour créer un compte ?', 'Parce qu''un DTO est plus rapide à écrire', FALSE, 3, 'C''est une classe de plus : on gagne en sécurité et en clarté, pas en rapidité d''écriture.'),
('Bases Spring : DTO ou Entity pour créer un compte ?', 'Parce que les entités ne peuvent pas avoir de getters', FALSE, 4, 'Les entités ont des getters comme n''importe quelle classe.'),
-- QCM 12
('Bases Spring : rôle de @RestController', '@RestController écrit le retour dans le corps de la réponse (JSON), @Controller cherche une vue', TRUE, 1, '@RestController = @Controller + @ResponseBody.'),
('Bases Spring : rôle de @RestController', '@RestController ne fonctionne qu''avec JPA', FALSE, 2, 'Aucun lien avec la persistance.'),
('Bases Spring : rôle de @RestController', '@Controller est réservé aux tests', FALSE, 3, 'Il sert aux applications web qui renvoient des pages.'),
('Bases Spring : rôle de @RestController', 'Les deux sont strictement identiques', FALSE, 4, 'Leur traitement de la valeur retournée est différent.'),
-- QCM 13
('Bases Spring : Spring ou Spring Boot ?', 'Spring Boot est construit sur Spring et simplifie sa configuration (starters, autoconfiguration, serveur embarqué)', TRUE, 1, 'Boot s''appuie sur Spring Framework, il ne le remplace pas.'),
('Bases Spring : Spring ou Spring Boot ?', 'Spring Boot est un langage différent de Java', FALSE, 2, 'C''est un framework écrit en Java.'),
('Bases Spring : Spring ou Spring Boot ?', 'Spring Boot remplace complètement Spring Framework', FALSE, 3, 'Il l''utilise en interne : IoC, MVC, accès aux données.'),
('Bases Spring : Spring ou Spring Boot ?', 'Spring Boot ne sert qu''à créer des applications de bureau', FALSE, 4, 'Il sert surtout aux applications web et aux services.'),
-- QCM 14
('Conception : quand utiliser le pattern Strategy ?', 'Une interface RemiseStrategy avec une classe par règle, choisie par le service', TRUE, 1, 'Chaque règle est isolée : on ajoute une classe sans modifier le code existant.'),
('Conception : quand utiliser le pattern Strategy ?', 'Ajouter encore des else if dans la même méthode', FALSE, 2, 'La méthode grossit et doit être modifiée à chaque nouvelle règle.'),
('Conception : quand utiliser le pattern Strategy ?', 'Rendre la méthode static', FALSE, 3, 'Ça ne change rien au problème de structure.'),
('Conception : quand utiliser le pattern Strategy ?', 'Copier la méthode dans chaque classe appelante', FALSE, 4, 'Duplication : plusieurs endroits à maintenir.'),
-- QCM 15
('Conception : pourquoi un Builder ?', 'Builder', TRUE, 1, 'Il construit l''objet pas à pas avec des méthodes nommées.'),
('Conception : pourquoi un Builder ?', 'Singleton', FALSE, 2, 'Il limite à une seule instance, ce qui n''aide pas la création lisible d''objets.'),
('Conception : pourquoi un Builder ?', 'Observer', FALSE, 3, 'Il sert à notifier des abonnés lors d''un changement.'),
('Conception : pourquoi un Builder ?', 'Ajouter un neuvième paramètre pour plus de flexibilité', FALSE, 4, 'Ça aggrave le problème de lisibilité.'),
-- QCM 16 (MULTIPLE_CHOICE)
('Conception : Singleton et ses limites', 'Il garantit une seule instance de la classe', TRUE, 1, 'C''est son but.'),
('Conception : Singleton et ses limites', 'Il rend les tests plus difficiles : l''instance globale est dure à remplacer par un faux', TRUE, 2, 'L''état global et les dépendances cachées compliquent les tests.'),
('Conception : Singleton et ses limites', 'Dans Spring, un bean est déjà singleton par défaut : pas besoin d''écrire getInstance()', TRUE, 3, 'Le conteneur gère l''unicité et l''injection garde le code testable.'),
('Conception : Singleton et ses limites', 'Il est obligatoire pour toute classe de service', FALSE, 4, 'Rien ne l''impose.'),
-- QCM 17
('Conception : inversion de dépendance (DIP)', 'Dépendre d''une interface OrderRepository injectée par le constructeur', TRUE, 1, 'Le service ne connaît plus l''implémentation : on peut la remplacer en test.'),
('Conception : inversion de dépendance (DIP)', 'Rendre MySqlOrderRepository static', FALSE, 2, 'On reste attaché à l''implémentation concrète.'),
('Conception : inversion de dépendance (DIP)', 'Remplacer le champ final par une variable globale', FALSE, 3, 'Un état global aggrave le couplage.'),
('Conception : inversion de dépendance (DIP)', 'Créer le repository dans chaque méthode qui en a besoin', FALSE, 4, 'Le couplage est le même, en plus répété.'),
-- QCM 18
('JPA : relation un-à-plusieurs simple', 'La clé étrangère est gérée par le champ auteur de Livre ; Auteur ne fait que refléter la relation', TRUE, 1, 'Livre est le côté propriétaire de la relation (colonne auteur_id).'),
('JPA : relation un-à-plusieurs simple', 'Auteur supprime automatiquement ses livres', FALSE, 2, 'La suppression en cascade se configure avec cascade ou orphanRemoval, pas avec mappedBy.'),
('JPA : relation un-à-plusieurs simple', 'La relation est chargée en EAGER', FALSE, 3, 'Le mode de chargement dépend de fetch ; un OneToMany est LAZY par défaut.'),
('JPA : relation un-à-plusieurs simple', 'Il faut une table de jointure auteur_livre', FALSE, 4, 'Ici la clé étrangère se trouve dans la table livre.'),
-- PROBLEM_SOLVING 1
('Situation : utilisateurs sans doublons', 'Un Set (par exemple HashSet) avec equals() et hashCode() basés sur l''identifiant', TRUE, 1, 'Le Set garantit l''unicité ; equals/hashCode définissent ce que « même utilisateur » veut dire.'),
('Situation : utilisateurs sans doublons', 'Une ArrayList et une vérification manuelle avant chaque ajout', FALSE, 2, 'Possible mais lourd et lent : un Set fait ce travail nativement.'),
('Situation : utilisateurs sans doublons', 'Une LinkedList triée', FALSE, 3, 'Le tri n''empêche pas les doublons.'),
('Situation : utilisateurs sans doublons', 'Un tableau de taille fixe', FALSE, 4, 'Aucune unicité et taille non extensible.'),
-- PROBLEM_SOLVING 2
('Situation : retrouver un utilisateur par son identifiant', 'Une HashMap<Long, User> avec l''identifiant comme clé', TRUE, 1, 'Accès direct à la valeur à partir de la clé.'),
('Situation : retrouver un utilisateur par son identifiant', 'Une ArrayList<User> parcourue à chaque recherche', FALSE, 2, 'Correct sur peu de données, mais le coût croît avec la taille.'),
('Situation : retrouver un utilisateur par son identifiant', 'Un HashSet<User>', FALSE, 3, 'Un Set vérifie la présence d''un élément, il ne permet pas de le retrouver par une clé.'),
('Situation : retrouver un utilisateur par son identifiant', 'Un tableau de String', FALSE, 4, 'Ne représente ni l''utilisateur ni l''association à son identifiant.'),
-- PROBLEM_SOLVING 3
('Situation : un Controller qui fait tout', 'Déplacer la logique métier dans un @Service et ne garder dans le Controller que la gestion HTTP', TRUE, 1, 'Chaque couche retrouve sa responsabilité et devient testable séparément.'),
('Situation : un Controller qui fait tout', 'Mettre la méthode en private pour la cacher', FALSE, 2, 'Un endpoint doit rester accessible : le problème est la répartition des responsabilités.'),
('Situation : un Controller qui fait tout', 'Ajouter un commentaire sur chaque ligne', FALSE, 3, 'Ça documente le problème sans le résoudre.'),
('Situation : un Controller qui fait tout', 'Déplacer tout le code dans le Repository', FALSE, 4, 'Le Repository doit se limiter à l''accès aux données.'),
-- PROBLEM_SOLVING 4
('Situation : deux classes avec beaucoup de code commun', 'Extraire la logique commune dans un composant partagé (ou une classe parente si la relation « est un » existe)', TRUE, 1, 'On supprime la duplication tout en gardant des responsabilités claires.'),
('Situation : deux classes avec beaucoup de code commun', 'Continuer à copier le code, c''est plus rapide', FALSE, 2, 'Chaque correction devra être répétée et un oubli créera un bug.'),
('Situation : deux classes avec beaucoup de code commun', 'Fusionner les deux classes en une seule très grosse classe', FALSE, 3, 'On perd la clarté et on mélange les responsabilités.'),
('Situation : deux classes avec beaucoup de code commun', 'Mettre toutes les méthodes en static dans une classe Utils fourre-tout', FALSE, 4, 'Risque de créer une classe fourre-tout difficile à tester et à maintenir.'),
-- SEQUENTIAL 1
('Ordre : parcours d''une requête dans Spring Boot', 'Le client envoie la requête HTTP GET /users/42', TRUE, 1, 'Point de départ du parcours.'),
('Ordre : parcours d''une requête dans Spring Boot', 'Le Controller reçoit la requête et appelle le Service', TRUE, 2, 'Le Controller gère le HTTP et délègue.'),
('Ordre : parcours d''une requête dans Spring Boot', 'Le Service applique la logique métier et appelle le Repository', TRUE, 3, 'La logique métier vit dans le Service.'),
('Ordre : parcours d''une requête dans Spring Boot', 'Le Repository interroge la base de données et renvoie les données', TRUE, 4, 'Seule couche qui parle à la base.'),
('Ordre : parcours d''une requête dans Spring Boot', 'La réponse remonte jusqu''au client, convertie en JSON', TRUE, 5, 'Le résultat suit le chemin inverse.'),
('Ordre : parcours d''une requête dans Spring Boot', 'Le Repository répond directement au client', FALSE, 6, 'Le Repository ne connaît pas le client HTTP.'),
-- SEQUENTIAL 2
('Ordre : créer un endpoint REST', 'Créer l''entité Product et le ProductRepository', TRUE, 1, 'On commence par les données.'),
('Ordre : créer un endpoint REST', 'Créer le DTO ProductResponse et le ProductService (avec la gestion du cas introuvable)', TRUE, 2, 'La logique s''appuie sur le repository.'),
('Ordre : créer un endpoint REST', 'Créer le ProductController avec @GetMapping("/products/{id}") qui appelle le service', TRUE, 3, 'Le point d''entrée HTTP arrive quand le reste existe.'),
('Ordre : créer un endpoint REST', 'Tester l''endpoint (appel HTTP ou test MockMvc)', TRUE, 4, 'On vérifie le comportement avant d''aller plus loin.'),
('Ordre : créer un endpoint REST', 'Mettre la logique métier directement dans le Controller pour aller plus vite', FALSE, 5, 'Ça mélange les responsabilités et complique les tests.'),
('Ordre : créer un endpoint REST', 'Mettre en production avant d''avoir testé', FALSE, 6, 'Le test précède la mise en production.'),
-- SEQUENTIAL 3
('Ordre : try, catch et finally', 'Le bloc try s''exécute jusqu''à l''instruction qui échoue', TRUE, 1, 'Le code du try s''exécute tant qu''aucune erreur ne se produit.'),
('Ordre : try, catch et finally', 'L''exception est lancée : le reste du try est ignoré', TRUE, 2, 'Les instructions suivantes du try ne sont pas exécutées.'),
('Ordre : try, catch et finally', 'Le bloc catch correspondant à l''exception s''exécute', TRUE, 3, 'Java cherche le catch adapté au type de l''exception.'),
('Ordre : try, catch et finally', 'Le bloc finally s''exécute', TRUE, 4, 'Il s''exécute dans tous les cas : idéal pour libérer des ressources.'),
('Ordre : try, catch et finally', 'Le programme continue après le bloc try/catch/finally', TRUE, 5, 'L''exception ayant été attrapée, l''exécution reprend normalement.'),
('Ordre : try, catch et finally', 'Le bloc finally s''exécute avant le bloc try', FALSE, 6, 'Il s''exécute après le try et le catch.'),
-- SEQUENTIAL 4
('Ordre : authentification JWT simple', 'Le client envoie son identifiant et son mot de passe à /auth/login', TRUE, 1, 'Le mot de passe n''est envoyé qu''à cette étape.'),
('Ordre : authentification JWT simple', 'Le serveur vérifie le mot de passe (comparaison avec le hash) et génère un token signé', TRUE, 2, 'Le token prouve ensuite l''identité de l''utilisateur.'),
('Ordre : authentification JWT simple', 'Le client conserve le token et l''envoie dans l''en-tête Authorization: Bearer', TRUE, 3, 'Chaque appel suivant porte le token.'),
('Ordre : authentification JWT simple', 'Un filtre vérifie la signature et l''expiration du token avant le Controller', TRUE, 4, 'La requête n''atteint le Controller que si le token est valide.'),
('Ordre : authentification JWT simple', 'Le Controller traite la requête pour l''utilisateur authentifié', TRUE, 5, 'Dernière étape, une fois l''identité établie.'),
('Ordre : authentification JWT simple', 'Le client renvoie son mot de passe à chaque requête', FALSE, 6, 'Le token existe justement pour éviter de renvoyer le mot de passe.')
     ) AS v(title, content, is_correct, ord, expl)
         JOIN challenges c ON c.title = v.title
WHERE NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id AND o.display_order = v.ord);

-- ---------------------------------------------------------------------
-- Options CODE_REVIEW (6 colonnes : severity, NULL pour les fausses alertes)
-- ---------------------------------------------------------------------
INSERT INTO challenge_options (challenge_id, content, is_correct, display_order, explanation, severity)
SELECT c.id, v.content, v.is_correct, v.ord, v.expl, v.sev
FROM (VALUES
          ('Review Bases : attributs publics', 'Le champ solde est public : il peut être modifié depuis n''importe où sans contrôle', TRUE, 1, 'Les règles de la classe peuvent être contournées par n''importe quel appelant.', 'CODE_QUALITY'),
          ('Review Bases : attributs publics', 'retirer() ne vérifie ni le montant ni le solde disponible', TRUE, 2, 'Le solde peut devenir négatif ou augmenter avec un montant négatif.', 'BUG'),
          ('Review Bases : attributs publics', 'La classe devrait être déclarée abstract', FALSE, 3, 'Rien n''indique un besoin d''abstraction : fausse alerte.', NULL),
          ('Review Bases : attributs publics', 'La méthode retirer() devrait être static', FALSE, 4, 'Elle modifie l''état d''une instance : static n''aurait pas de sens.', NULL),
          ('Review Bases : equals sans hashCode', 'hashCode() n''est pas redéfini : le HashSet peut accepter deux produits égaux', TRUE, 1, 'Le contrat entre equals() et hashCode() n''est pas respecté.', 'BUG'),
          ('Review Bases : equals sans hashCode', 'Utiliser Objects.hash(reference) dans hashCode() corrigerait le problème', TRUE, 2, 'Le hashCode dépend alors des mêmes champs que equals().', 'CODE_QUALITY'),
          ('Review Bases : equals sans hashCode', 'Il faudrait comparer les références avec == plutôt qu''avec equals()', FALSE, 3, 'Pour des String, == compare les références : equals() est le bon choix.', NULL),
          ('Review Bases : equals sans hashCode', 'Le champ reference devrait être public pour pouvoir être comparé', FALSE, 4, 'Une classe peut lire les champs privés d''une autre instance de la même classe.', NULL),
          ('Review Bases : noms et méthode illisibles', 'Les noms de la méthode et des variables n''expriment pas l''intention', TRUE, 1, 'Un nom doit dire ce que fait ou représente l''élément.', 'MAINTAINABILITY'),
          ('Review Bases : noms et méthode illisibles', 'Les valeurs 1 et 0.1 sont des valeurs magiques sans signification explicite', TRUE, 2, 'Une constante nommée explique la règle métier.', 'MAINTAINABILITY'),
          ('Review Bases : noms et méthode illisibles', 'La boucle for est interdite avec une List', FALSE, 3, 'Elle est parfaitement valide (on pourrait aussi utiliser un stream).', NULL),
          ('Review Bases : noms et méthode illisibles', 'Il faut ajouter un commentaire sur chaque ligne', FALSE, 4, 'Un code explicite vaut mieux que beaucoup de commentaires.', NULL),
          ('Review Bases : une classe, trop de responsabilités', 'Violation du SRP : validation, calcul, base de données et e-mail dans la même classe', TRUE, 1, 'La classe a plusieurs raisons de changer.', 'ARCHITECTURE'),
          ('Review Bases : une classe, trop de responsabilités', 'L''accès SQL devrait être dans un Repository, pas dans le service', TRUE, 2, 'On sépare la logique métier de l''accès aux données.', 'ARCHITECTURE'),
          ('Review Bases : une classe, trop de responsabilités', 'La classe est trop petite et devrait contenir encore plus de code', FALSE, 3, 'C''est l''inverse : il faut répartir les responsabilités.', NULL),
          ('Review Bases : une classe, trop de responsabilités', 'L''annotation @Service est incorrecte', FALSE, 4, 'Elle est adaptée : c''est le contenu de la classe qui pose problème.', NULL),
          ('Review Bases : Controller qui parle directement au Repository', 'Il n''y a pas de couche Service entre le Controller et le Repository', TRUE, 1, 'Les règles métier et les transactions n''ont pas de place claire.', 'ARCHITECTURE'),
          ('Review Bases : Controller qui parle directement au Repository', 'L''entité User est renvoyée telle quelle : risque d''exposer des champs internes', TRUE, 2, 'Un DTO limite la réponse aux champs prévus.', 'CODE_QUALITY'),
          ('Review Bases : Controller qui parle directement au Repository', 'L''injection par champ (@Autowired) est moins testable que l''injection par constructeur', TRUE, 3, 'Le constructeur rend les dépendances explicites et obligatoires.', 'MAINTAINABILITY'),
          ('Review Bases : Controller qui parle directement au Repository', 'Appeler findAll() est interdit dans un Controller', FALSE, 4, 'La méthode existe : c''est la couche qui l''appelle qui pose question.', NULL)
     ) AS v(title, content, is_correct, ord, expl, sev)
         JOIN challenges c ON c.title = v.title
WHERE NOT EXISTS (SELECT 1 FROM challenge_options o WHERE o.challenge_id = c.id AND o.display_order = v.ord);

-- ---------------------------------------------------------------------
-- Liens (categories / skills / profil DEVELOPER)
-- ---------------------------------------------------------------------
INSERT INTO challenge_categories (challenge_id, category_id)
SELECT c.id, cat.id
FROM (VALUES
          ('Bases Java : HashSet ou HashMap ?','Java'),
          ('Bases Java : HashMap ou TreeMap ?','Java'),
          ('Bases Java : classe abstraite ou interface ?','Java'),
          ('Bases Java : surcharge ou redéfinition ?','Java'),
          ('Bases Java : exception checked ou unchecked ?','Java'),
          ('Bases Java : throw ou throws ?','Java'),
          ('Bases Java : String ou StringBuilder ?','Java'),
          ('Bases Java : lire une chaîne de Stream','Java'),
          ('Bases Java : à quoi sert Optional ?','Java'),
          ('Bases Spring : PathVariable ou RequestParam ?','API / Backend'),
          ('Bases Spring : DTO ou Entity pour créer un compte ?','API / Backend'),
          ('Bases Spring : rôle de @RestController','Spring Boot'),
          ('Bases Spring : Spring ou Spring Boot ?','Spring Boot'),
          ('Conception : quand utiliser le pattern Strategy ?','Architecture'),
          ('Conception : pourquoi un Builder ?','Architecture'),
          ('Conception : Singleton et ses limites','Architecture'),
          ('Conception : inversion de dépendance (DIP)','Architecture'),
          ('JPA : relation un-à-plusieurs simple','JPA / Hibernate'),
          ('Situation : utilisateurs sans doublons','Java'),
          ('Situation : retrouver un utilisateur par son identifiant','Java'),
          ('Situation : un Controller qui fait tout','Spring Boot'),
          ('Situation : deux classes avec beaucoup de code commun','Architecture'),
          ('Review Bases : attributs publics','Java'),
          ('Review Bases : equals sans hashCode','Java'),
          ('Review Bases : noms et méthode illisibles','Java'),
          ('Review Bases : une classe, trop de responsabilités','Architecture'),
          ('Review Bases : Controller qui parle directement au Repository','Spring Boot'),
          ('Ordre : parcours d''une requête dans Spring Boot','Spring Boot'),
          ('Ordre : créer un endpoint REST','API / Backend'),
          ('Ordre : try, catch et finally','Java'),
          ('Ordre : authentification JWT simple','Spring Boot')
     ) AS v(title, cat)
         JOIN challenges c ON c.title = v.title
         JOIN categories cat ON cat.name = v.cat
WHERE NOT EXISTS (SELECT 1 FROM challenge_categories cc WHERE cc.challenge_id = c.id AND cc.category_id = cat.id);

INSERT INTO challenge_skills (challenge_id, skill_id)
SELECT c.id, s.id
FROM (VALUES
          ('Bases Java : HashSet ou HashMap ?','Problem Solving'),
          ('Bases Java : HashMap ou TreeMap ?','Problem Solving'),
          ('Bases Java : classe abstraite ou interface ?','Code Quality'),
          ('Bases Java : surcharge ou redéfinition ?','Code Quality'),
          ('Bases Java : exception checked ou unchecked ?','Code Quality'),
          ('Bases Java : throw ou throws ?','Code Quality'),
          ('Bases Java : String ou StringBuilder ?','Performance Analysis'),
          ('Bases Java : lire une chaîne de Stream','Code Quality'),
          ('Bases Java : à quoi sert Optional ?','Code Quality'),
          ('Bases Spring : PathVariable ou RequestParam ?','Code Quality'),
          ('Bases Spring : DTO ou Entity pour créer un compte ?','Code Quality'),
          ('Bases Spring : rôle de @RestController','Code Quality'),
          ('Bases Spring : Spring ou Spring Boot ?','Code Quality'),
          ('Conception : quand utiliser le pattern Strategy ?','Code Quality'),
          ('Conception : pourquoi un Builder ?','Code Quality'),
          ('Conception : Singleton et ses limites','Code Quality'),
          ('Conception : inversion de dépendance (DIP)','Code Quality'),
          ('JPA : relation un-à-plusieurs simple','Code Quality'),
          ('Situation : utilisateurs sans doublons','Problem Solving'),
          ('Situation : retrouver un utilisateur par son identifiant','Problem Solving'),
          ('Situation : un Controller qui fait tout','Problem Solving'),
          ('Situation : deux classes avec beaucoup de code commun','Problem Solving'),
          ('Review Bases : attributs publics','Code Quality'),
          ('Review Bases : equals sans hashCode','Debugging'),
          ('Review Bases : noms et méthode illisibles','Code Quality'),
          ('Review Bases : une classe, trop de responsabilités','Code Quality'),
          ('Review Bases : Controller qui parle directement au Repository','Code Quality'),
          ('Ordre : parcours d''une requête dans Spring Boot','Problem Solving'),
          ('Ordre : créer un endpoint REST','Problem Solving'),
          ('Ordre : try, catch et finally','Debugging'),
          ('Ordre : authentification JWT simple','Problem Solving')
     ) AS v(title, skill)
         JOIN challenges c ON c.title = v.title
         JOIN skills s ON s.name = v.skill
WHERE NOT EXISTS (SELECT 1 FROM challenge_skills cs WHERE cs.challenge_id = c.id AND cs.skill_id = s.id);

INSERT INTO challenge_profiles (challenge_id, profile_id)
SELECT c.id, p.id
FROM (VALUES
          ('Bases Java : HashSet ou HashMap ?'),
          ('Bases Java : HashMap ou TreeMap ?'),
          ('Bases Java : classe abstraite ou interface ?'),
          ('Bases Java : surcharge ou redéfinition ?'),
          ('Bases Java : exception checked ou unchecked ?'),
          ('Bases Java : throw ou throws ?'),
          ('Bases Java : String ou StringBuilder ?'),
          ('Bases Java : lire une chaîne de Stream'),
          ('Bases Java : à quoi sert Optional ?'),
          ('Bases Spring : PathVariable ou RequestParam ?'),
          ('Bases Spring : DTO ou Entity pour créer un compte ?'),
          ('Bases Spring : rôle de @RestController'),
          ('Bases Spring : Spring ou Spring Boot ?'),
          ('Conception : quand utiliser le pattern Strategy ?'),
          ('Conception : pourquoi un Builder ?'),
          ('Conception : Singleton et ses limites'),
          ('Conception : inversion de dépendance (DIP)'),
          ('JPA : relation un-à-plusieurs simple'),
          ('Situation : utilisateurs sans doublons'),
          ('Situation : retrouver un utilisateur par son identifiant'),
          ('Situation : un Controller qui fait tout'),
          ('Situation : deux classes avec beaucoup de code commun'),
          ('Review Bases : attributs publics'),
          ('Review Bases : equals sans hashCode'),
          ('Review Bases : noms et méthode illisibles'),
          ('Review Bases : une classe, trop de responsabilités'),
          ('Review Bases : Controller qui parle directement au Repository'),
          ('Ordre : parcours d''une requête dans Spring Boot'),
          ('Ordre : créer un endpoint REST'),
          ('Ordre : try, catch et finally'),
          ('Ordre : authentification JWT simple')
     ) AS v(title)
         JOIN challenges c ON c.title = v.title
         JOIN profiles p ON p.code = 'DEVELOPER'
WHERE NOT EXISTS (SELECT 1 FROM challenge_profiles cp WHERE cp.challenge_id = c.id AND cp.profile_id = p.id);