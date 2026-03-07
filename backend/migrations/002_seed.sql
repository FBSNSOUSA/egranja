-- ============================================================================
-- eGranja - Migration 002: Carga Inicial (Seed Data)
-- ============================================================================
-- Dados iniciais obrigatorios: tipos de racao, benchmarks e usuario de teste.
-- ============================================================================

BEGIN;

-- ============================================================================
-- USUARIOS DE TESTE (um de cada tipo: produtor e tecnico)
-- So sao inseridos se ainda nao existirem.
-- ============================================================================
INSERT INTO usuarios (id, login, password_digest, nome, tipo, ativo)
SELECT 'a0000000-0000-0000-0000-000000000001'::uuid, 'tecnico', crypt('tecnico123', gen_salt('bf', 12)), 'Tecnico Teste', 'tecnico', true
WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE login = 'tecnico');

INSERT INTO usuarios (id, login, password_digest, nome, tipo, ativo)
SELECT 'a0000000-0000-0000-0000-000000000002'::uuid, 'produtor', crypt('produtor123', gen_salt('bf', 12)), 'Produtor Teste', 'produtor', true
WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE login = 'produtor');

-- Vinculo tecnico-produtor: o tecnico pode ver os lotes do produtor
INSERT INTO tecnico_produtores (tecnico_id, produtor_id)
SELECT 'a0000000-0000-0000-0000-000000000001'::uuid, 'a0000000-0000-0000-0000-000000000002'::uuid
WHERE NOT EXISTS (SELECT 1 FROM tecnico_produtores WHERE tecnico_id = 'a0000000-0000-0000-0000-000000000001'::uuid AND produtor_id = 'a0000000-0000-0000-0000-000000000002'::uuid);

-- ============================================================================
-- TIPOS DE RACAO
-- ============================================================================
INSERT INTO tipos_racao (id, nome, ordem) VALUES
    (gen_random_uuid(), 'Pre-Inicial', 1),
    (gen_random_uuid(), 'Inicial', 2),
    (gen_random_uuid(), 'Crescimento', 3),
    (gen_random_uuid(), 'Finalizacao', 4);

-- ============================================================================
-- BENCHMARKS COBB 500 (Misto - 2022)
-- Fonte: Cobb 500 Performance & Nutrition Supplement 2022
-- ============================================================================
INSERT INTO benchmarks_linhagem (id, linhagem, dia, peso_g, consumo_acum_g, ca, gpd_g) VALUES
    (gen_random_uuid(), 'Cobb 500',  0,   42,    0,     0,     0),
    (gen_random_uuid(), 'Cobb 500',  7,  202,  180, 0.891, 22.9),
    (gen_random_uuid(), 'Cobb 500', 14,  570,  588, 1.029, 37.7),
    (gen_random_uuid(), 'Cobb 500', 21, 1116, 1320, 1.182, 51.1),
    (gen_random_uuid(), 'Cobb 500', 28, 1656, 2359, 1.322, 57.6),
    (gen_random_uuid(), 'Cobb 500', 35, 2348, 3448, 1.469, 65.9),
    (gen_random_uuid(), 'Cobb 500', 42, 2857, 4430, 1.550, 67.0),
    (gen_random_uuid(), 'Cobb 500', 49, 3414, 5600, 1.640, 68.8);

-- ============================================================================
-- BENCHMARKS ROSS 308 (Misto - 2022)
-- Fonte: Aviagen Ross 308 Performance Objectives 2022
-- ============================================================================
INSERT INTO benchmarks_linhagem (id, linhagem, dia, peso_g, consumo_acum_g, ca, gpd_g) VALUES
    (gen_random_uuid(), 'Ross 308',  0,   42,    0,     0,     0),
    (gen_random_uuid(), 'Ross 308',  7,  197,  177, 0.900, 22.1),
    (gen_random_uuid(), 'Ross 308', 14,  545,  568, 1.042, 36.0),
    (gen_random_uuid(), 'Ross 308', 21, 1070, 1274, 1.191, 48.9),
    (gen_random_uuid(), 'Ross 308', 28, 1728, 2292, 1.326, 60.2),
    (gen_random_uuid(), 'Ross 308', 35, 2464, 3592, 1.458, 68.9),
    (gen_random_uuid(), 'Ross 308', 42, 3203, 5106, 1.594, 75.3),
    (gen_random_uuid(), 'Ross 308', 49, 3900, 6798, 1.743, 78.7);

COMMIT;
