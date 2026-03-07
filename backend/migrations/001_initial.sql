-- ============================================================================
-- eGranja - Migration 001: Schema Inicial Completo
-- ============================================================================
-- Cria todas as tabelas, indices e constraints do sistema eGranja v2.0.
-- PostgreSQL 15+
-- ============================================================================

BEGIN;

-- Extensoes necessarias
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================================
-- USUARIOS
-- ============================================================================
CREATE TABLE usuarios (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    login VARCHAR(100) NOT NULL UNIQUE,
    password_digest VARCHAR(255) NOT NULL,
    nome VARCHAR(200),
    tipo VARCHAR(20) NOT NULL DEFAULT 'produtor'
        CHECK (tipo IN ('produtor', 'tecnico')),
    ativo BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP NOT NULL DEFAULT now(),
    updated_at TIMESTAMP NOT NULL DEFAULT now()
);

-- ============================================================================
-- VINCULO TECNICO-PRODUTOR
-- ============================================================================
CREATE TABLE tecnico_produtores (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tecnico_id UUID NOT NULL REFERENCES usuarios(id),
    produtor_id UUID NOT NULL REFERENCES usuarios(id),
    created_at TIMESTAMP NOT NULL DEFAULT now(),
    UNIQUE(tecnico_id, produtor_id)
);

-- ============================================================================
-- GRANJAS (Multi-granja)
-- ============================================================================
CREATE TABLE granjas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    usuario_id UUID NOT NULL REFERENCES usuarios(id),
    nome VARCHAR(200) NOT NULL,
    endereco TEXT,
    cidade VARCHAR(100),
    estado VARCHAR(2),
    latitude NUMERIC(10,7),
    longitude NUMERIC(10,7),
    created_at TIMESTAMP NOT NULL DEFAULT now(),
    updated_at TIMESTAMP NOT NULL DEFAULT now()
);
CREATE INDEX idx_granjas_usuario ON granjas(usuario_id);

-- ============================================================================
-- GALPOES
-- ============================================================================
CREATE TABLE galpaos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    usuario_id UUID NOT NULL REFERENCES usuarios(id),
    granja_id UUID REFERENCES granjas(id),
    nome VARCHAR(100) NOT NULL,
    capacidade INTEGER,
    latitude NUMERIC(10,7),
    longitude NUMERIC(10,7),
    orientacao_graus INTEGER
        CHECK (orientacao_graus >= 0 AND orientacao_graus < 360),
    comprimento_m NUMERIC(8,2),
    largura_m NUMERIC(8,2),
    tipo_ventilacao VARCHAR(30)
        CHECK (tipo_ventilacao IN ('convencional','tunel','dark_house','misto')),
    lado_cortinas VARCHAR(20)
        CHECK (lado_cortinas IN ('ambos','norte','sul','leste','oeste','nenhum')),
    created_at TIMESTAMP NOT NULL DEFAULT now(),
    updated_at TIMESTAMP NOT NULL DEFAULT now(),
    UNIQUE(usuario_id, nome)
);

-- ============================================================================
-- LOTES
-- ============================================================================
CREATE TABLE lotes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    usuario_id UUID NOT NULL REFERENCES usuarios(id),
    galpao_id UUID NOT NULL REFERENCES galpaos(id),
    data_alojamento DATE NOT NULL,
    data_prevista_abate DATE NOT NULL,
    quantidade INTEGER NOT NULL CHECK (quantidade > 0),
    tipo VARCHAR(10) NOT NULL
        CHECK (tipo IN ('Femea', 'Macho', 'Misto')),
    linhagem VARCHAR(50),
    peso_inicial_g NUMERIC(8,2) NOT NULL DEFAULT 42.0,
    status VARCHAR(20) NOT NULL DEFAULT 'ativo'
        CHECK (status IN ('ativo', 'finalizado')),
    data_finalizacao DATE,
    aves_entregues INTEGER,
    peso_total_entregue NUMERIC(12,3),
    created_at TIMESTAMP NOT NULL DEFAULT now(),
    updated_at TIMESTAMP NOT NULL DEFAULT now()
);
CREATE INDEX idx_lotes_usuario ON lotes(usuario_id);
CREATE INDEX idx_lotes_status ON lotes(usuario_id, status);

-- ============================================================================
-- PESAGENS
-- ============================================================================
CREATE TABLE pesagens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    lote_id UUID NOT NULL REFERENCES lotes(id) ON DELETE CASCADE,
    data DATE NOT NULL,
    quantidade_total INTEGER NOT NULL CHECK (quantidade_total > 0),
    peso_total NUMERIC(12,3) NOT NULL,
    peso_medio NUMERIC(12,3) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT now(),
    updated_at TIMESTAMP NOT NULL DEFAULT now()
);
CREATE INDEX idx_pesagens_lote_data ON pesagens(lote_id, data DESC);

-- ============================================================================
-- ITENS DE PESAGEM (Amostras)
-- ============================================================================
CREATE TABLE pesagem_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    pesagem_id UUID NOT NULL REFERENCES pesagens(id) ON DELETE CASCADE,
    quantidade INTEGER NOT NULL CHECK (quantidade > 0),
    peso NUMERIC(12,3) NOT NULL,
    peso_medio NUMERIC(12,3) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT now()
);
CREATE INDEX idx_pesagem_items_pesagem ON pesagem_items(pesagem_id);

-- ============================================================================
-- MORTALIDADE
-- ============================================================================
CREATE TABLE mortalidades (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    lote_id UUID NOT NULL REFERENCES lotes(id) ON DELETE CASCADE,
    data DATE NOT NULL,
    quantidade INTEGER NOT NULL CHECK (quantidade > 0),
    causa VARCHAR(50) DEFAULT 'Indefinida'
        CHECK (causa IN ('Indefinida','Ascite','Morte Subita','Problemas Locomotores','Refugo','Onfalite','Infecciosa','Outra')),
    observacao TEXT,
    foto_url TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT now(),
    updated_at TIMESTAMP NOT NULL DEFAULT now()
);
CREATE INDEX idx_mortalidades_lote_data ON mortalidades(lote_id, data DESC);

-- ============================================================================
-- TIPOS DE RACAO
-- ============================================================================
CREATE TABLE tipos_racao (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nome VARCHAR(100) NOT NULL UNIQUE,
    ordem INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT now()
);

-- ============================================================================
-- RECEBIMENTOS DE RACAO
-- ============================================================================
CREATE TABLE feed_receipts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    lote_id UUID REFERENCES lotes(id) ON DELETE CASCADE,
    tipo_racao_id UUID REFERENCES tipos_racao(id),
    quantidade_kg NUMERIC(12,3) NOT NULL,
    data_recebimento DATE NOT NULL,
    fornecedor VARCHAR(200),
    lote_racao VARCHAR(100),
    origem VARCHAR(30) NOT NULL DEFAULT 'compra'
        CHECK (origem IN ('compra', 'remanescente_anterior', 'sobra_final')),
    created_at TIMESTAMP NOT NULL DEFAULT now(),
    updated_at TIMESTAMP NOT NULL DEFAULT now()
);
CREATE INDEX idx_feed_receipts_lote ON feed_receipts(lote_id);

-- ============================================================================
-- CONSUMO DE RACAO
-- ============================================================================
CREATE TABLE feed_consumptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    lote_id UUID NOT NULL REFERENCES lotes(id) ON DELETE CASCADE,
    data DATE NOT NULL,
    quantidade_kg NUMERIC(12,3) NOT NULL CHECK (quantidade_kg > 0),
    created_at TIMESTAMP NOT NULL DEFAULT now(),
    updated_at TIMESTAMP NOT NULL DEFAULT now()
);
CREATE INDEX idx_feed_consumptions_lote ON feed_consumptions(lote_id);

-- ============================================================================
-- CONSUMO DE AGUA
-- ============================================================================
CREATE TABLE water_consumptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    lote_id UUID NOT NULL REFERENCES lotes(id) ON DELETE CASCADE,
    data DATE NOT NULL,
    quantidade_litros NUMERIC(12,3) NOT NULL CHECK (quantidade_litros > 0),
    created_at TIMESTAMP NOT NULL DEFAULT now(),
    updated_at TIMESTAMP NOT NULL DEFAULT now()
);
CREATE INDEX idx_water_consumptions_lote ON water_consumptions(lote_id);

-- ============================================================================
-- REGISTROS AMBIENTAIS (manual e IoT)
-- ============================================================================
CREATE TABLE registros_ambientais (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    lote_id UUID NOT NULL REFERENCES lotes(id) ON DELETE CASCADE,
    data DATE NOT NULL,
    temperatura_min NUMERIC(5,2),
    temperatura_max NUMERIC(5,2),
    umidade_min NUMERIC(5,2),
    umidade_max NUMERIC(5,2),
    origem VARCHAR(20) NOT NULL DEFAULT 'manual'
        CHECK (origem IN ('manual', 'iot')),
    created_at TIMESTAMP NOT NULL DEFAULT now()
);
CREATE INDEX idx_reg_amb_lote ON registros_ambientais(lote_id, data DESC);

-- ============================================================================
-- CHECKLIST DIARIO
-- ============================================================================
CREATE TABLE checklists (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    lote_id UUID NOT NULL REFERENCES lotes(id) ON DELETE CASCADE,
    data DATE NOT NULL,
    itens JSONB NOT NULL DEFAULT '[]',
    completado BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMP NOT NULL DEFAULT now(),
    updated_at TIMESTAMP NOT NULL DEFAULT now(),
    UNIQUE(lote_id, data)
);

-- ============================================================================
-- MENSAGENS (Chat Produtor-Tecnico)
-- ============================================================================
CREATE TABLE mensagens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    lote_id UUID NOT NULL REFERENCES lotes(id) ON DELETE CASCADE,
    remetente_id UUID NOT NULL REFERENCES usuarios(id),
    tipo VARCHAR(20) NOT NULL
        CHECK (tipo IN ('texto', 'foto', 'audio', 'solicitacao', 'visita')),
    conteudo TEXT,
    midia_url TEXT,
    midia_thumbnail_url TEXT,
    solicitacao_status VARCHAR(20)
        CHECK (solicitacao_status IN ('pendente', 'respondida', 'expirada')),
    solicitacao_prazo TIMESTAMP,
    lida BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMP NOT NULL DEFAULT now()
);
CREATE INDEX idx_mensagens_lote ON mensagens(lote_id, created_at DESC);
CREATE INDEX idx_mensagens_remetente ON mensagens(remetente_id);
CREATE INDEX idx_mensagens_nao_lidas ON mensagens(lote_id, lida) WHERE lida = false;

-- ============================================================================
-- DESTINATARIOS WHATSAPP
-- ============================================================================
CREATE TABLE whatsapp_recipients (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    lote_id UUID NOT NULL REFERENCES lotes(id) ON DELETE CASCADE,
    numero VARCHAR(20) NOT NULL,
    nome VARCHAR(200),
    created_at TIMESTAMP NOT NULL DEFAULT now(),
    UNIQUE(lote_id, numero)
);

-- ============================================================================
-- HISTORICO DE ENVIOS WHATSAPP
-- ============================================================================
CREATE TABLE whatsapp_send_histories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    whatsapp_recipient_id UUID NOT NULL REFERENCES whatsapp_recipients(id),
    pesagem_id UUID REFERENCES pesagens(id) ON DELETE SET NULL,
    mortalidade_id UUID REFERENCES mortalidades(id) ON DELETE SET NULL,
    mensagem TEXT NOT NULL,
    status VARCHAR(20) NOT NULL
        CHECK (status IN ('enviado', 'falha')),
    tipo_envio VARCHAR(30) NOT NULL
        CHECK (tipo_envio IN ('pesagem', 'mortalidade', 'resumo_diario', 'fechamento')),
    created_at TIMESTAMP NOT NULL DEFAULT now()
);
CREATE INDEX idx_wsh_recipient ON whatsapp_send_histories(whatsapp_recipient_id);

-- ============================================================================
-- BENCHMARKS DE LINHAGEM
-- ============================================================================
CREATE TABLE benchmarks_linhagem (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    linhagem VARCHAR(50) NOT NULL,
    dia INTEGER NOT NULL,
    peso_g NUMERIC(10,2) NOT NULL,
    consumo_acum_g NUMERIC(10,2),
    ca NUMERIC(6,3),
    gpd_g NUMERIC(6,2),
    UNIQUE(linhagem, dia)
);

-- ============================================================================
-- VACINACOES
-- ============================================================================
CREATE TABLE vacinacoes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    lote_id UUID NOT NULL REFERENCES lotes(id) ON DELETE CASCADE,
    data DATE NOT NULL,
    vacina VARCHAR(200) NOT NULL,
    lote_produto VARCHAR(100),
    via_administracao VARCHAR(50),
    responsavel VARCHAR(200),
    observacao TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT now()
);
CREATE INDEX idx_vacinacoes_lote ON vacinacoes(lote_id);

-- ============================================================================
-- MEDICAMENTOS
-- ============================================================================
CREATE TABLE medicamentos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    lote_id UUID NOT NULL REFERENCES lotes(id) ON DELETE CASCADE,
    data_inicio DATE NOT NULL,
    data_fim DATE,
    medicamento VARCHAR(200) NOT NULL,
    dosagem VARCHAR(100),
    via VARCHAR(50),
    periodo_carencia_dias INTEGER DEFAULT 0,
    responsavel VARCHAR(200),
    observacao TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT now()
);
CREATE INDEX idx_medicamentos_lote ON medicamentos(lote_id);

-- ============================================================================
-- VISITANTES (Livro de Registro Digital)
-- ============================================================================
CREATE TABLE visitantes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    granja_id UUID NOT NULL REFERENCES granjas(id),
    nome VARCHAR(200) NOT NULL,
    documento VARCHAR(50),
    origem VARCHAR(200),
    motivo VARCHAR(200),
    ultimo_contato_aves DATE,
    placa_veiculo VARCHAR(20),
    data_entrada TIMESTAMP NOT NULL,
    data_saida TIMESTAMP,
    observacao TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT now()
);
CREATE INDEX idx_visitantes_granja ON visitantes(granja_id, data_entrada DESC);

-- ============================================================================
-- CUSTOS DE PRODUCAO
-- ============================================================================
CREATE TABLE custos_lote (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    lote_id UUID NOT NULL REFERENCES lotes(id) ON DELETE CASCADE,
    categoria VARCHAR(50) NOT NULL
        CHECK (categoria IN ('mao_de_obra','energia','aquecimento','cama','manutencao','depreciacao','agua','outros')),
    descricao VARCHAR(200),
    valor NUMERIC(12,2) NOT NULL,
    data DATE,
    created_at TIMESTAMP NOT NULL DEFAULT now()
);
CREATE INDEX idx_custos_lote ON custos_lote(lote_id);

-- ============================================================================
-- REMUNERACAO DA INTEGRADORA
-- ============================================================================
CREATE TABLE remuneracoes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    lote_id UUID NOT NULL REFERENCES lotes(id) ON DELETE CASCADE,
    valor NUMERIC(12,2) NOT NULL,
    tipo VARCHAR(30)
        CHECK (tipo IN ('por_kg', 'por_ave', 'por_iep', 'outro')),
    data_pagamento DATE,
    observacao TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT now()
);

-- ============================================================================
-- REGISTROS IoT (dados de sensores em alta frequencia)
-- ============================================================================
CREATE TABLE iot_readings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    galpao_id UUID NOT NULL REFERENCES galpaos(id),
    sensor_tipo VARCHAR(30) NOT NULL
        CHECK (sensor_tipo IN ('temperatura','umidade','nh3','co2','peso','agua','racao','luminosidade')),
    valor NUMERIC(12,3) NOT NULL,
    unidade VARCHAR(10) NOT NULL,
    timestamp TIMESTAMP NOT NULL DEFAULT now()
);
CREATE INDEX idx_iot_galpao_tipo ON iot_readings(galpao_id, sensor_tipo, timestamp DESC);
-- NOTA: Para producao com alto volume, considerar particionar por mes.

-- ============================================================================
-- CADEIA DE RASTREABILIDADE (blockchain simplificada)
-- ============================================================================
CREATE TABLE rastreabilidade_chain (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    lote_id UUID NOT NULL REFERENCES lotes(id),
    evento VARCHAR(50) NOT NULL,
    dados JSONB NOT NULL,
    hash_atual VARCHAR(64) NOT NULL,
    hash_anterior VARCHAR(64),
    created_at TIMESTAMP NOT NULL DEFAULT now()
);
CREATE INDEX idx_rastreabilidade_lote ON rastreabilidade_chain(lote_id, created_at);

-- ============================================================================
-- INTERACOES COM IA (cache de respostas Gemini)
-- ============================================================================
CREATE TABLE ia_interacoes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    lote_id UUID REFERENCES lotes(id),
    usuario_id UUID NOT NULL REFERENCES usuarios(id),
    tipo VARCHAR(30) NOT NULL
        CHECK (tipo IN ('predicao_peso','anomalia','recomendacao','analise_foto','chat_assistente')),
    prompt_resumo TEXT,
    resposta TEXT NOT NULL,
    modelo VARCHAR(50) NOT NULL DEFAULT 'gemini-2.0-flash',
    tokens_usados INTEGER,
    created_at TIMESTAMP NOT NULL DEFAULT now()
);
CREATE INDEX idx_ia_lote ON ia_interacoes(lote_id, created_at DESC);

-- ============================================================================
-- PREVISOES DO TEMPO (cache por granja)
-- ============================================================================
CREATE TABLE previsoes_tempo (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    granja_id UUID NOT NULL REFERENCES granjas(id),
    data DATE NOT NULL,
    temperatura_min NUMERIC(5,2),
    temperatura_max NUMERIC(5,2),
    umidade_min NUMERIC(5,2),
    umidade_max NUMERIC(5,2),
    precipitacao_mm NUMERIC(8,2),
    probabilidade_chuva INTEGER,
    vento_velocidade_kmh NUMERIC(6,2),
    vento_direcao INTEGER,
    indice_uv NUMERIC(4,1),
    provedor VARCHAR(30) NOT NULL DEFAULT 'open-meteo',
    created_at TIMESTAMP NOT NULL DEFAULT now()
);
CREATE INDEX idx_previsoes_granja_data ON previsoes_tempo(granja_id, data DESC);

-- ============================================================================
-- FUNCAO AUXILIAR: Atualizar updated_at automaticamente
-- ============================================================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers de updated_at
CREATE TRIGGER tr_usuarios_updated_at BEFORE UPDATE ON usuarios
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER tr_granjas_updated_at BEFORE UPDATE ON granjas
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER tr_galpaos_updated_at BEFORE UPDATE ON galpaos
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER tr_lotes_updated_at BEFORE UPDATE ON lotes
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER tr_pesagens_updated_at BEFORE UPDATE ON pesagens
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER tr_mortalidades_updated_at BEFORE UPDATE ON mortalidades
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER tr_feed_receipts_updated_at BEFORE UPDATE ON feed_receipts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER tr_feed_consumptions_updated_at BEFORE UPDATE ON feed_consumptions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER tr_water_consumptions_updated_at BEFORE UPDATE ON water_consumptions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER tr_checklists_updated_at BEFORE UPDATE ON checklists
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

COMMIT;
