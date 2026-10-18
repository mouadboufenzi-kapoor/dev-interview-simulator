INSERT INTO skills (name, description) VALUES
 ('Fundamentals', 'Maîtrise des concepts de base et de la théorie d''une technologie (définitions, différences, cas d''usage)')
ON CONFLICT (name) DO NOTHING;
