INSERT INTO categories (name, description) VALUES
('Java', 'Core Java, JVM, Concurrency, and modern Java features')
ON CONFLICT (name) DO NOTHING;

INSERT INTO categories (name, description) VALUES
('Spring Boot', 'Spring Framework, Dependency Injection, Boot auto-config, and REST APIs')
ON CONFLICT (name) DO NOTHING;

INSERT INTO categories (name, description) VALUES
('SQL / PostgreSQL', 'Relational database design, queries, indexes, and performance')
ON CONFLICT (name) DO NOTHING;

INSERT INTO categories (name, description) VALUES
('JPA / Hibernate', 'ORM mapping, entity lifecycle, lazy loading, and N+1 query problem')
ON CONFLICT (name) DO NOTHING;

INSERT INTO categories (name, description) VALUES
('API / Backend', 'REST principles, HTTP status codes, payload design, and API security')
ON CONFLICT (name) DO NOTHING;

INSERT INTO categories (name, description) VALUES
('Architecture', 'Design patterns, SOLID principles, monolith vs microservices')
ON CONFLICT (name) DO NOTHING;

INSERT INTO categories (name, description) VALUES
('Testing', 'Unit testing, Integration testing, Mocking, and Test-Driven Development')
ON CONFLICT (name) DO NOTHING;

INSERT INTO categories (name, description) VALUES
('DevOps', 'CI/CD pipelines, Docker, environment configuration, and deployment')
ON CONFLICT (name) DO NOTHING;

INSERT INTO categories (name, description) VALUES
('Distributed Systems', 'Consistency, CAP theorem, caching, messaging, and fault tolerance')
ON CONFLICT (name) DO NOTHING;

INSERT INTO categories (name, description) VALUES
('System Design', 'Scalability, load balancing, database partitioning, and high availability')
ON CONFLICT (name) DO NOTHING;

-- Initialisation des Skills
INSERT INTO skills (name, description) VALUES
('Problem Solving', 'Ability to break down complex engineering problems')
ON CONFLICT (name) DO NOTHING;

INSERT INTO skills (name, description) VALUES
('Debugging', 'Finding root cause of runtime anomalies and failures')
ON CONFLICT (name) DO NOTHING;

INSERT INTO skills (name, description) VALUES
('Performance Analysis', 'Identifying bottlenecks in memory, CPU, DB, or network')
ON CONFLICT (name) DO NOTHING;

INSERT INTO skills (name, description) VALUES
('Code Quality', 'Readability, maintainability, and clean code standards')
ON CONFLICT (name) DO NOTHING;

-- Utilisateur par défaut pour le MVP (sans auth)
INSERT INTO users (username, email, created_at, updated_at) VALUES
('default_user', 'dev@example.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (username) DO NOTHING;