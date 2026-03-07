/**
 * Inicializacao do WatermelonDB com adapter SQLite.
 *
 * Configura o banco de dados local para operacao offline-first.
 * O WatermelonDB usa SQLite como storage e fornece:
 * - Queries reativas (observables)
 * - Suporte nativo a sincronizacao com backend
 * - Performance otimizada com lazy loading
 *
 * Uso: importar `database` deste modulo em qualquer parte do app.
 */

import { Database } from '@nozbe/watermelondb';
import SQLiteAdapter from '@nozbe/watermelondb/adapters/sqlite';
import { schema } from './schema';

// Nota: os Models do WatermelonDB serao definidos em arquivos separados
// em /src/database/models/ conforme o app crescer.
// Por enquanto, o adapter e o database sao inicializados apenas com o schema.

// ==========================================
// ADAPTER SQLite
// ==========================================

const adapter = new SQLiteAdapter({
  schema,
  // Nome do arquivo do banco SQLite no dispositivo
  dbName: 'egranja_local',
  // Modo de execucao: 'jsi' para melhor performance em React Native
  jsi: true,
  // Ativar logs de migracao em desenvolvimento
  onSetUpError: (error) => {
    console.error('[WatermelonDB] Erro na inicializacao do banco local:', error);
  },
});

// ==========================================
// INSTANCIA DO DATABASE
// ==========================================

/**
 * Instancia principal do WatermelonDB.
 *
 * Uso:
 * ```typescript
 * import { database } from '@database/index';
 *
 * // Query
 * const lotes = await database.get('lotes').query().fetch();
 *
 * // Escrita
 * await database.write(async () => {
 *   await database.get('lotes').create((lote) => {
 *     lote.galpaoId = '...';
 *     // ...
 *   });
 * });
 * ```
 */
export const database = new Database({
  adapter,
  modelClasses: [
    // Os model classes serao adicionados aqui conforme forem criados:
    // LoteModel,
    // PesagemModel,
    // PesagemItemModel,
    // MortalidadeModel,
    // FeedReceiptModel,
    // FeedConsumptionModel,
    // WaterConsumptionModel,
    // ChecklistModel,
    // MensagemModel,
    // GalpaoModel,
    // BenchmarkLinhagemModel,
  ],
});

// ==========================================
// FUNCOES AUXILIARES
// ==========================================

/**
 * Reseta o banco de dados local (usado em logout ou debug).
 * CUIDADO: Remove todos os dados locais permanentemente.
 */
export async function resetDatabase(): Promise<void> {
  try {
    await database.write(async () => {
      await database.unsafeResetDatabase();
    });
    console.log('[WatermelonDB] Banco de dados local resetado com sucesso.');
  } catch (error) {
    console.error('[WatermelonDB] Erro ao resetar banco de dados:', error);
    throw error;
  }
}

/**
 * Retorna estatisticas do banco local (util para debug e indicador de sync).
 */
export async function getDatabaseStats(): Promise<Record<string, number>> {
  const tables = [
    'lotes',
    'pesagens',
    'pesagem_items',
    'mortalidades',
    'feed_receipts',
    'feed_consumptions',
    'water_consumptions',
    'checklists',
    'mensagens',
    'galpaos',
    'benchmarks_linhagem',
  ];

  const stats: Record<string, number> = {};

  for (const table of tables) {
    try {
      const count = await database.get(table).query().fetchCount();
      stats[table] = count;
    } catch (error) {
      stats[table] = -1; // Indica erro na contagem
    }
  }

  return stats;
}

export default database;
