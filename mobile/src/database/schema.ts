/**
 * Schema do WatermelonDB para armazenamento local offline.
 *
 * Define todas as tabelas locais que espelham o banco PostgreSQL do servidor.
 * Os dados sao sincronizados automaticamente quando a conexao e restaurada.
 *
 * Convencoes:
 * - Campos snake_case para compatibilidade com a API
 * - Todos os registros possuem created_at e updated_at para sync
 * - UUIDs gerados no cliente para permitir operacao offline
 * - Campo _status e _changed usados internamente pelo WatermelonDB para sync
 */

import { appSchema, tableSchema } from '@nozbe/watermelondb';

// ==========================================
// VERSAO DO SCHEMA
// ==========================================

/** Versao atual do schema. Incrementar a cada migracao. */
const SCHEMA_VERSION = 1;

// ==========================================
// DEFINICAO DO SCHEMA
// ==========================================

export const schema = appSchema({
  version: SCHEMA_VERSION,
  tables: [
    // ------------------------------------------
    // LOTES
    // Tabela principal de lotes de aves
    // ------------------------------------------
    tableSchema({
      name: 'lotes',
      columns: [
        { name: 'server_id', type: 'string', isOptional: true },       // UUID do servidor
        { name: 'usuario_id', type: 'string' },
        { name: 'galpao_id', type: 'string' },
        { name: 'galpao_nome', type: 'string', isOptional: true },     // Desnormalizacao para exibicao offline
        { name: 'data_alojamento', type: 'number' },                    // Timestamp
        { name: 'data_prevista_abate', type: 'number' },                // Timestamp
        { name: 'quantidade', type: 'number' },
        { name: 'tipo', type: 'string' },                               // 'Femea' | 'Macho' | 'Misto'
        { name: 'linhagem', type: 'string', isOptional: true },         // 'Cobb 500' | 'Ross 308' | etc
        { name: 'peso_inicial_g', type: 'number' },                     // Padrao 42g
        { name: 'status', type: 'string' },                             // 'ativo' | 'finalizado'
        { name: 'data_finalizacao', type: 'number', isOptional: true }, // Timestamp
        { name: 'aves_entregues', type: 'number', isOptional: true },
        { name: 'peso_total_entregue', type: 'number', isOptional: true },
        { name: 'created_at', type: 'number' },
        { name: 'updated_at', type: 'number' },
      ],
    }),

    // ------------------------------------------
    // PESAGENS
    // Registro de pesagens semanais do lote
    // ------------------------------------------
    tableSchema({
      name: 'pesagens',
      columns: [
        { name: 'server_id', type: 'string', isOptional: true },
        { name: 'lote_id', type: 'string', isIndexed: true },
        { name: 'data', type: 'number' },                               // Timestamp
        { name: 'quantidade_total', type: 'number' },                    // Aves pesadas no total
        { name: 'peso_total', type: 'number' },                         // Peso total em gramas
        { name: 'peso_medio', type: 'number' },                         // Peso medio calculado
        { name: 'created_at', type: 'number' },
        { name: 'updated_at', type: 'number' },
      ],
    }),

    // ------------------------------------------
    // ITENS DE PESAGEM (AMOSTRAS)
    // Cada pesagem pode ter multiplas amostras
    // ------------------------------------------
    tableSchema({
      name: 'pesagem_items',
      columns: [
        { name: 'server_id', type: 'string', isOptional: true },
        { name: 'pesagem_id', type: 'string', isIndexed: true },
        { name: 'quantidade', type: 'number' },                         // Aves na amostra
        { name: 'peso', type: 'number' },                               // Peso total da amostra (g)
        { name: 'peso_medio', type: 'number' },                         // Peso medio da amostra
        { name: 'created_at', type: 'number' },
      ],
    }),

    // ------------------------------------------
    // MORTALIDADES
    // Registro diario de mortalidade com causa
    // ------------------------------------------
    tableSchema({
      name: 'mortalidades',
      columns: [
        { name: 'server_id', type: 'string', isOptional: true },
        { name: 'lote_id', type: 'string', isIndexed: true },
        { name: 'data', type: 'number' },                               // Timestamp
        { name: 'quantidade', type: 'number' },
        { name: 'causa', type: 'string' },                              // Dropdown de causas
        { name: 'observacao', type: 'string', isOptional: true },
        { name: 'foto_url', type: 'string', isOptional: true },
        { name: 'created_at', type: 'number' },
        { name: 'updated_at', type: 'number' },
      ],
    }),

    // ------------------------------------------
    // RECEBIMENTOS DE RACAO
    // Entradas de racao no estoque do lote
    // ------------------------------------------
    tableSchema({
      name: 'feed_receipts',
      columns: [
        { name: 'server_id', type: 'string', isOptional: true },
        { name: 'lote_id', type: 'string', isIndexed: true },
        { name: 'tipo_racao_id', type: 'string', isOptional: true },
        { name: 'tipo_racao_nome', type: 'string', isOptional: true },  // Desnormalizacao
        { name: 'quantidade_kg', type: 'number' },
        { name: 'data_recebimento', type: 'number' },                   // Timestamp
        { name: 'fornecedor', type: 'string', isOptional: true },
        { name: 'lote_racao', type: 'string', isOptional: true },       // Rastreabilidade
        { name: 'origem', type: 'string' },                             // 'compra' | 'remanescente_anterior' | 'sobra_final'
        { name: 'created_at', type: 'number' },
        { name: 'updated_at', type: 'number' },
      ],
    }),

    // ------------------------------------------
    // CONSUMO DE RACAO
    // Registro diario de consumo
    // ------------------------------------------
    tableSchema({
      name: 'feed_consumptions',
      columns: [
        { name: 'server_id', type: 'string', isOptional: true },
        { name: 'lote_id', type: 'string', isIndexed: true },
        { name: 'data', type: 'number' },                               // Timestamp
        { name: 'quantidade_kg', type: 'number' },
        { name: 'created_at', type: 'number' },
        { name: 'updated_at', type: 'number' },
      ],
    }),

    // ------------------------------------------
    // CONSUMO DE AGUA
    // Registro diario de consumo de agua (litros)
    // ------------------------------------------
    tableSchema({
      name: 'water_consumptions',
      columns: [
        { name: 'server_id', type: 'string', isOptional: true },
        { name: 'lote_id', type: 'string', isIndexed: true },
        { name: 'data', type: 'number' },                               // Timestamp
        { name: 'quantidade_litros', type: 'number' },
        { name: 'created_at', type: 'number' },
        { name: 'updated_at', type: 'number' },
      ],
    }),

    // ------------------------------------------
    // CHECKLISTS
    // Checklist diario de manejo (itens em JSON)
    // ------------------------------------------
    tableSchema({
      name: 'checklists',
      columns: [
        { name: 'server_id', type: 'string', isOptional: true },
        { name: 'lote_id', type: 'string', isIndexed: true },
        { name: 'data', type: 'number' },                               // Timestamp
        { name: 'itens_json', type: 'string' },                         // JSON serializado dos itens
        { name: 'completado', type: 'boolean' },
        { name: 'created_at', type: 'number' },
        { name: 'updated_at', type: 'number' },
      ],
    }),

    // ------------------------------------------
    // MENSAGENS (CHAT)
    // Chat produtor-tecnico vinculado ao lote
    // ------------------------------------------
    tableSchema({
      name: 'mensagens',
      columns: [
        { name: 'server_id', type: 'string', isOptional: true },
        { name: 'lote_id', type: 'string', isIndexed: true },
        { name: 'remetente_id', type: 'string' },
        { name: 'tipo', type: 'string' },                               // 'texto' | 'foto' | 'audio' | 'solicitacao' | 'visita'
        { name: 'conteudo', type: 'string', isOptional: true },
        { name: 'midia_url', type: 'string', isOptional: true },
        { name: 'midia_thumbnail_url', type: 'string', isOptional: true },
        { name: 'solicitacao_status', type: 'string', isOptional: true }, // 'pendente' | 'respondida' | 'expirada'
        { name: 'solicitacao_prazo', type: 'number', isOptional: true },  // Timestamp
        { name: 'lida', type: 'boolean' },
        { name: 'created_at', type: 'number' },
      ],
    }),

    // ------------------------------------------
    // GALPAOS
    // Cache local dos galpoes para operacao offline
    // ------------------------------------------
    tableSchema({
      name: 'galpaos',
      columns: [
        { name: 'server_id', type: 'string', isOptional: true },
        { name: 'usuario_id', type: 'string', isIndexed: true },
        { name: 'nome', type: 'string' },
        { name: 'capacidade', type: 'number', isOptional: true },
        { name: 'latitude', type: 'number', isOptional: true },
        { name: 'longitude', type: 'number', isOptional: true },
        { name: 'orientacao_graus', type: 'number', isOptional: true },
        { name: 'comprimento_m', type: 'number', isOptional: true },
        { name: 'largura_m', type: 'number', isOptional: true },
        { name: 'tipo_ventilacao', type: 'string', isOptional: true },
        { name: 'lado_cortinas', type: 'string', isOptional: true },
        { name: 'created_at', type: 'number' },
        { name: 'updated_at', type: 'number' },
      ],
    }),

    // ------------------------------------------
    // BENCHMARKS DE LINHAGEM
    // Tabela de referencia Cobb 500 / Ross 308
    // Cache local para comparacao offline
    // ------------------------------------------
    tableSchema({
      name: 'benchmarks_linhagem',
      columns: [
        { name: 'server_id', type: 'string', isOptional: true },
        { name: 'linhagem', type: 'string', isIndexed: true },
        { name: 'dia', type: 'number' },
        { name: 'peso_g', type: 'number' },
        { name: 'consumo_acum_g', type: 'number', isOptional: true },
        { name: 'ca', type: 'number', isOptional: true },
        { name: 'gpd_g', type: 'number', isOptional: true },
      ],
    }),
  ],
});

export default schema;
