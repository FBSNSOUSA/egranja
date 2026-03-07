-- ============================================================================
-- eGranja - Migration 003: Sistema de Colaboradores por Granja
-- ============================================================================
-- Permite que o proprietario de uma granja convide outros usuarios para
-- colaborar (editor ou visualizador). Colaboradores acessam galpoes, lotes
-- e todos os dados da granja conforme sua permissao.
-- ============================================================================

BEGIN;

CREATE TABLE granja_colaboradores (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    granja_id UUID NOT NULL REFERENCES granjas(id) ON DELETE CASCADE,
    usuario_id UUID NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    permissao VARCHAR(20) NOT NULL DEFAULT 'editor'
        CHECK (permissao IN ('editor', 'visualizador')),
    convidado_por UUID NOT NULL REFERENCES usuarios(id),
    created_at TIMESTAMP NOT NULL DEFAULT now(),
    UNIQUE(granja_id, usuario_id)
);

CREATE INDEX idx_granja_colab_usuario ON granja_colaboradores(usuario_id);
CREATE INDEX idx_granja_colab_granja ON granja_colaboradores(granja_id);

COMMIT;
