INSERT INTO challenges (
    title, type, selection_type, difficulty, context, question,
    code_snippet, code_language, explanation, estimated_time_seconds,
    active, points, created_at, updated_at
)
SELECT
    'Optimisation Endpoint Orders', 'CODE_REVIEW', 'MULTIPLE_CHOICE', 'INTERMEDIATE',
    'Une API Spring Boot permet de récupérer les commandes d''un utilisateur.',
    'Quels problèmes ou points d''amélioration identifiez-vous dans ce code ?',
    '@GetMapping("/users/{userId}/orders")
public List<OrderDto> getOrders(@PathVariable Long userId) {
    User user = userRepository.findById(userId).orElseThrow();
    List<Order> orders = orderRepository.findByUserId(userId);

    return orders.stream()
            .map(order -> {
                Customer customer = customerRepository
                        .findById(order.getCustomerId())
                        .orElseThrow();
                return new OrderDto(order.getId(), customer.getName(), order.getTotal());
            })
            .toList();
}',
    'java',
    'Ce code présente un problème critique de performance N+1 ainsi qu''une requête inutile vers userRepository.',
    180, true, 20, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (
    SELECT 1 FROM challenges WHERE title = 'Optimisation Endpoint Orders'
);

INSERT INTO challenge_categories (challenge_id, category_id)
SELECT c.id, cat.id
FROM challenges c, categories cat
WHERE c.title = 'Optimisation Endpoint Orders'
  AND cat.name IN ('Spring Boot', 'JPA / Hibernate', 'API / Backend')
  AND NOT EXISTS (
      SELECT 1 FROM challenge_categories
      WHERE challenge_id = c.id AND category_id = cat.id
  );

INSERT INTO challenge_skills (challenge_id, skill_id)
SELECT c.id, s.id
FROM challenges c, skills s
WHERE c.title = 'Optimisation Endpoint Orders'
  AND s.name IN ('Performance Analysis', 'Code Quality')
  AND NOT EXISTS (
      SELECT 1 FROM challenge_skills
      WHERE challenge_id = c.id AND skill_id = s.id
  );

INSERT INTO challenge_options (
    challenge_id, content, is_correct, display_order, severity, explanation
)
SELECT c.id, 'Risque de problème N+1 / nombreuses requêtes SQL', true, 1,
       'PERFORMANCE',
       'Chaque élément du stream déclenche une requête SQL synchrone pour charger Customer via customerRepository.findById().'
FROM challenges c
WHERE c.title = 'Optimisation Endpoint Orders'
  AND NOT EXISTS (
      SELECT 1 FROM challenge_options
      WHERE challenge_id = c.id AND display_order = 1
  );

INSERT INTO challenge_options (
    challenge_id, content, is_correct, display_order, severity, explanation
)
SELECT c.id, 'Appel inutile à userRepository', true, 2,
       'CODE_QUALITY',
       'La variable user est chargée en base mais n''est jamais réutilisée par la suite.'
FROM challenges c
WHERE c.title = 'Optimisation Endpoint Orders'
  AND NOT EXISTS (
      SELECT 1 FROM challenge_options
      WHERE challenge_id = c.id AND display_order = 2
  );

INSERT INTO challenge_options (
    challenge_id, content, is_correct, display_order, severity, explanation
)
SELECT c.id, 'Mauvaise gestion de la transaction', false, 3,
       'ARCHITECTURE',
       'Aucune écriture n''est effectuée ici. L''absence de @Transactional(readOnly = true) n''est pas un bug bloquant.'
FROM challenges c
WHERE c.title = 'Optimisation Endpoint Orders'
  AND NOT EXISTS (
      SELECT 1 FROM challenge_options
      WHERE challenge_id = c.id AND display_order = 3
  );

INSERT INTO challenge_options (
    challenge_id, content, is_correct, display_order, severity, explanation
)
SELECT c.id, 'Aucun problème particulier', false, 4,
       'MAINTAINABILITY',
       'Le code présente au moins un problème majeur de performance (N+1).'
FROM challenges c
WHERE c.title = 'Optimisation Endpoint Orders'
  AND NOT EXISTS (
      SELECT 1 FROM challenge_options
      WHERE challenge_id = c.id AND display_order = 4
  );
