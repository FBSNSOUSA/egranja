package service

import (
	"crypto/sha256"
	"encoding/json"
	"fmt"
	"testing"
	"time"

	"github.com/FBSNSOUSA/egranja/backend/internal/model"
	"github.com/google/uuid"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestCalcularHash_Deterministico(t *testing.T) {
	loteID := uuid.MustParse("11111111-1111-1111-1111-111111111111")
	evento := "alojamento"
	dados := json.RawMessage(`{"quantidade":10000}`)
	createdAt := time.Date(2026, 3, 1, 10, 0, 0, 0, time.UTC)

	chain := &model.RastreabilidadeChain{
		LoteID:       loteID,
		Evento:       evento,
		Dados:        dados,
		HashAnterior: nil,
		CreatedAt:    createdAt,
	}

	hash1 := chain.CalculaHash()
	hash2 := chain.CalculaHash()

	assert.Equal(t, hash1, hash2, "O hash deve ser deterministico")
	assert.Len(t, hash1, 64, "SHA-256 deve gerar hash de 64 caracteres hexadecimais")
}

func TestCalcularHash_MudaDadosMudaHash(t *testing.T) {
	loteID := uuid.MustParse("11111111-1111-1111-1111-111111111111")
	createdAt := time.Date(2026, 3, 1, 10, 0, 0, 0, time.UTC)

	chain1 := &model.RastreabilidadeChain{
		LoteID:    loteID,
		Evento:    "alojamento",
		Dados:     json.RawMessage(`{"quantidade":10000}`),
		CreatedAt: createdAt,
	}

	chain2 := &model.RastreabilidadeChain{
		LoteID:    loteID,
		Evento:    "alojamento",
		Dados:     json.RawMessage(`{"quantidade":9999}`),
		CreatedAt: createdAt,
	}

	assert.NotEqual(t, chain1.CalculaHash(), chain2.CalculaHash(),
		"Dados diferentes devem produzir hashes diferentes")
}

func TestVerificarIntegridade_CadeiaIntegra(t *testing.T) {
	loteID := uuid.MustParse("22222222-2222-2222-2222-222222222222")

	// Bloco 1 (genesis)
	bloco1 := model.RastreabilidadeChain{
		ID:           uuid.New(),
		LoteID:       loteID,
		Evento:       "alojamento",
		Dados:        json.RawMessage(`{"quantidade":10000}`),
		HashAnterior: nil,
		CreatedAt:    time.Date(2026, 3, 1, 10, 0, 0, 0, time.UTC),
	}
	bloco1.HashAtual = bloco1.CalculaHash()

	// Bloco 2 (encadeado)
	hashAnterior := bloco1.HashAtual
	bloco2 := model.RastreabilidadeChain{
		ID:           uuid.New(),
		LoteID:       loteID,
		Evento:       "pesagem",
		Dados:        json.RawMessage(`{"peso_medio":202}`),
		HashAnterior: &hashAnterior,
		CreatedAt:    time.Date(2026, 3, 8, 10, 0, 0, 0, time.UTC),
	}
	bloco2.HashAtual = bloco2.CalculaHash()

	// Bloco 3 (encadeado)
	hashAnterior2 := bloco2.HashAtual
	bloco3 := model.RastreabilidadeChain{
		ID:           uuid.New(),
		LoteID:       loteID,
		Evento:       "mortalidade",
		Dados:        json.RawMessage(`{"quantidade":15}`),
		HashAnterior: &hashAnterior2,
		CreatedAt:    time.Date(2026, 3, 15, 10, 0, 0, 0, time.UTC),
	}
	bloco3.HashAtual = bloco3.CalculaHash()

	chains := []model.RastreabilidadeChain{bloco1, bloco2, bloco3}

	// Verificar integridade
	integra := verificarCadeiaLocal(chains)
	assert.True(t, integra, "Cadeia integra deve retornar true")
}

func TestVerificarIntegridade_CadeiaCorrompida(t *testing.T) {
	loteID := uuid.MustParse("33333333-3333-3333-3333-333333333333")

	// Bloco 1 (genesis)
	bloco1 := model.RastreabilidadeChain{
		ID:           uuid.New(),
		LoteID:       loteID,
		Evento:       "alojamento",
		Dados:        json.RawMessage(`{"quantidade":10000}`),
		HashAnterior: nil,
		CreatedAt:    time.Date(2026, 3, 1, 10, 0, 0, 0, time.UTC),
	}
	bloco1.HashAtual = bloco1.CalculaHash()

	// Bloco 2 com hash anterior ERRADO (corrompido)
	hashFalso := "0000000000000000000000000000000000000000000000000000000000000000"
	bloco2 := model.RastreabilidadeChain{
		ID:           uuid.New(),
		LoteID:       loteID,
		Evento:       "pesagem",
		Dados:        json.RawMessage(`{"peso_medio":202}`),
		HashAnterior: &hashFalso,
		CreatedAt:    time.Date(2026, 3, 8, 10, 0, 0, 0, time.UTC),
	}
	bloco2.HashAtual = bloco2.CalculaHash()

	chains := []model.RastreabilidadeChain{bloco1, bloco2}

	integra := verificarCadeiaLocal(chains)
	assert.False(t, integra, "Cadeia corrompida deve retornar false")
}

func TestRegistrarEvento_PrimeiroBloco(t *testing.T) {
	// Testa que o primeiro bloco de uma cadeia nao tem hash anterior
	loteID := uuid.MustParse("44444444-4444-4444-4444-444444444444")

	bloco := model.RastreabilidadeChain{
		LoteID:       loteID,
		Evento:       "alojamento",
		Dados:        json.RawMessage(`{"quantidade":10000}`),
		HashAnterior: nil,
		CreatedAt:    time.Now(),
	}
	bloco.HashAtual = bloco.CalculaHash()

	assert.Nil(t, bloco.HashAnterior, "Primeiro bloco nao deve ter hash anterior")
	assert.NotEmpty(t, bloco.HashAtual, "Hash atual deve estar preenchido")
	assert.Len(t, bloco.HashAtual, 64)
}

func TestRegistrarEvento_BlocoSubsequente(t *testing.T) {
	loteID := uuid.MustParse("55555555-5555-5555-5555-555555555555")

	// Primeiro bloco
	bloco1 := model.RastreabilidadeChain{
		LoteID:    loteID,
		Evento:    "alojamento",
		Dados:     json.RawMessage(`{"quantidade":10000}`),
		CreatedAt: time.Now(),
	}
	bloco1.HashAtual = bloco1.CalculaHash()

	// Segundo bloco encadeado
	hashPrevio := bloco1.HashAtual
	bloco2 := model.RastreabilidadeChain{
		LoteID:       loteID,
		Evento:       "pesagem",
		Dados:        json.RawMessage(`{"peso_medio":202}`),
		HashAnterior: &hashPrevio,
		CreatedAt:    time.Now(),
	}
	bloco2.HashAtual = bloco2.CalculaHash()

	require.NotNil(t, bloco2.HashAnterior, "Bloco subsequente deve ter hash anterior")
	assert.Equal(t, bloco1.HashAtual, *bloco2.HashAnterior,
		"Hash anterior do bloco 2 deve ser igual ao hash atual do bloco 1")
}

func TestCalcularHash_FormatoCorreto(t *testing.T) {
	loteID := uuid.MustParse("66666666-6666-6666-6666-666666666666")
	evento := "teste"
	dados := json.RawMessage(`{"key":"value"}`)
	createdAt := time.Date(2026, 1, 1, 0, 0, 0, 0, time.UTC)

	chain := &model.RastreabilidadeChain{
		LoteID:    loteID,
		Evento:    evento,
		Dados:     dados,
		CreatedAt: createdAt,
	}

	// Calcular manualmente
	hashData := fmt.Sprintf("%s|%s|%s|%s|%s",
		loteID.String(),
		evento,
		string(dados),
		"",
		createdAt.UTC().Format(time.RFC3339Nano),
	)
	hash := sha256.Sum256([]byte(hashData))
	expectedHash := fmt.Sprintf("%x", hash)

	assert.Equal(t, expectedHash, chain.CalculaHash(),
		"Hash calculado deve coincidir com calculo manual")
}

// verificarCadeiaLocal verifica a integridade da cadeia localmente (sem repositorio).
// Replica a logica do VerificarCadeia do BlockchainService.
func verificarCadeiaLocal(chains []model.RastreabilidadeChain) bool {
	if len(chains) == 0 {
		return true
	}

	for i := 1; i < len(chains); i++ {
		if chains[i].HashAnterior == nil {
			return false
		}
		if *chains[i].HashAnterior != chains[i-1].HashAtual {
			return false
		}
	}

	return true
}
