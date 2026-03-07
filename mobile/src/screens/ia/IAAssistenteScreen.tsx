/**
 * Tela do Assistente IA (Chat com Gemini) do eGranja.
 *
 * Funcionalidades:
 * - Chat estilo conversa com bolhas (esquerda=IA, direita=usuario)
 * - Sugestoes rapidas para perguntas frequentes
 * - Seletor de lote no topo
 * - Historico de conversas carregado da API
 * - Formatacao markdown simples (bold, listas)
 * - Loading indicator enquanto IA processa
 */

import React, { useState, useCallback, useEffect, useRef } from 'react';
import {
  View,
  Text,
  StyleSheet,
  FlatList,
  TouchableOpacity,
  KeyboardAvoidingView,
  Platform,
  ActivityIndicator,
  ScrollView,
} from 'react-native';
import { Appbar, IconButton, TextInput, Chip } from 'react-native-paper';
import { useNavigation } from '@react-navigation/native';
import dayjs from 'dayjs';
import { apiGet, apiPost } from '@services/api';
import { useAuthStore } from '@stores/authStore';
import { useLoteStore } from '@stores/loteStore';
import { DropdownField, DropdownOption } from '@components/DropdownField';
import {
  colors,
  typography,
  spacing,
  borders,
  shadows,
} from '@theme/index';

// ==========================================
// TIPOS
// ==========================================

interface Mensagem {
  id: string;
  remetente: 'usuario' | 'ia';
  texto: string;
  timestamp: string;
}

interface ApiMensagem {
  id: string;
  role: 'user' | 'assistant';
  content: string;
  created_at: string;
}

// ==========================================
// SUGESTOES RAPIDAS
// ==========================================

const SUGESTOES_RAPIDAS = [
  'Como melhorar o ICA?',
  'Qual a mortalidade ideal?',
  'Quando trocar a racao?',
  'Analisar meu lote',
];

// ==========================================
// COMPONENTE DE BOLHA DE MENSAGEM
// ==========================================

const BolhaMensagem: React.FC<{ mensagem: Mensagem }> = ({ mensagem }) => {
  const isIA = mensagem.remetente === 'ia';

  /**
   * Renderiza texto com formatacao markdown simples.
   * Suporta: **bold**, listas com - ou *
   */
  const renderTextoFormatado = (texto: string) => {
    const linhas = texto.split('\n');

    return linhas.map((linha, index) => {
      // Detectar listas
      const isLista = /^\s*[-*]\s/.test(linha);
      const linhaLimpa = isLista ? linha.replace(/^\s*[-*]\s/, '') : linha;

      // Processar bold (**texto**)
      const partes = linhaLimpa.split(/(\*\*[^*]+\*\*)/g);

      const conteudo = partes.map((parte, i) => {
        if (parte.startsWith('**') && parte.endsWith('**')) {
          return (
            <Text key={i} style={styles.boldText}>
              {parte.slice(2, -2)}
            </Text>
          );
        }
        return <Text key={i}>{parte}</Text>;
      });

      return (
        <View key={index} style={isLista ? styles.listaItem : undefined}>
          {isLista && <Text style={isIA ? styles.listaBulletIA : styles.listaBulletUser}>{'\u2022  '}</Text>}
          <Text
            style={[
              styles.mensagemTexto,
              isIA ? styles.mensagemTextoIA : styles.mensagemTextoUser,
              isLista && styles.listaTexto,
            ]}
          >
            {conteudo}
          </Text>
        </View>
      );
    });
  };

  return (
    <View style={[styles.bolhaContainer, isIA ? styles.bolhaContainerIA : styles.bolhaContainerUser]}>
      {isIA && (
        <View style={styles.avatarIA}>
          <IconButton icon="robot" iconColor={colors.white} size={18} style={styles.avatarIcon} />
        </View>
      )}
      <View style={[styles.bolha, isIA ? styles.bolhaIA : styles.bolhaUser]}>
        {renderTextoFormatado(mensagem.texto)}
        <Text style={[styles.timestamp, isIA ? styles.timestampIA : styles.timestampUser]}>
          {dayjs(mensagem.timestamp).format('HH:mm')}
        </Text>
      </View>
    </View>
  );
};

// ==========================================
// COMPONENTE PRINCIPAL
// ==========================================

const IAAssistenteScreen: React.FC = () => {
  const navigation = useNavigation();
  const flatListRef = useRef<FlatList>(null);
  const user = useAuthStore((state) => state.user);
  const lotes = useLoteStore((state) => state.lotes);

  const [mensagens, setMensagens] = useState<Mensagem[]>([]);
  const [textoInput, setTextoInput] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [isCarregandoHistorico, setIsCarregandoHistorico] = useState(true);
  const [loteId, setLoteId] = useState<string>(lotes[0]?.id || '');

  // Opcoes de lote para o dropdown
  const lotesOptions: DropdownOption[] = lotes
    .filter((l) => l.status === 'ativo')
    .map((l) => ({
      value: l.id,
      label: `${l.galpaoNome} - Lote ${l.id.slice(0, 6)}`,
      subtitle: `${l.avesVivas || l.quantidade} aves | Dia ${l.diasDeVida || 0}`,
    }));

  // Carregar historico ao montar ou trocar lote
  const carregarHistorico = useCallback(async () => {
    if (!loteId) return;
    setIsCarregandoHistorico(true);
    try {
      const response = await apiGet<ApiMensagem[]>(`/lotes/${loteId}/ia/historico`);
      const historico: Mensagem[] = response.data.map((msg) => ({
        id: msg.id,
        remetente: msg.role === 'user' ? 'usuario' : 'ia',
        texto: msg.content,
        timestamp: msg.created_at,
      }));
      setMensagens(historico);
    } catch {
      // Sem historico - comecar conversa vazia
      setMensagens([]);
    } finally {
      setIsCarregandoHistorico(false);
    }
  }, [loteId]);

  useEffect(() => {
    carregarHistorico();
  }, [carregarHistorico]);

  // Enviar mensagem
  const enviarMensagem = useCallback(async (texto?: string) => {
    const pergunta = (texto || textoInput).trim();
    if (!pergunta || !loteId || isLoading) return;

    const novaMensagemUser: Mensagem = {
      id: `user-${Date.now()}`,
      remetente: 'usuario',
      texto: pergunta,
      timestamp: new Date().toISOString(),
    };

    setMensagens((prev) => [...prev, novaMensagemUser]);
    setTextoInput('');
    setIsLoading(true);

    try {
      const response = await apiPost<{ resposta: string; id: string }>(
        `/lotes/${loteId}/ia/consultar`,
        { pergunta },
      );

      const novaMensagemIA: Mensagem = {
        id: response.data.id || `ia-${Date.now()}`,
        remetente: 'ia',
        texto: response.data.resposta,
        timestamp: new Date().toISOString(),
      };

      setMensagens((prev) => [...prev, novaMensagemIA]);
    } catch {
      const mensagemErro: Mensagem = {
        id: `erro-${Date.now()}`,
        remetente: 'ia',
        texto: 'Desculpe, ocorreu um erro ao processar sua pergunta. Tente novamente.',
        timestamp: new Date().toISOString(),
      };
      setMensagens((prev) => [...prev, mensagemErro]);
    } finally {
      setIsLoading(false);
    }
  }, [textoInput, loteId, isLoading]);

  // Renderizar mensagem
  const renderMensagem = useCallback(({ item }: { item: Mensagem }) => (
    <BolhaMensagem mensagem={item} />
  ), []);

  // Header da lista (sugestoes)
  const renderListHeader = useCallback(() => {
    if (mensagens.length > 0) return null;

    return (
      <View style={styles.sugestoesContainer}>
        <View style={styles.bemVindoCard}>
          <IconButton icon="robot" iconColor={colors.secondary} size={40} />
          <Text style={styles.bemVindoTitulo}>Assistente IA</Text>
          <Text style={styles.bemVindoTexto}>
            Tire duvidas sobre seu lote, indicadores e boas praticas de manejo avicola.
          </Text>
        </View>

        <Text style={styles.sugestoesLabel}>Sugestoes rapidas:</Text>
        <ScrollView horizontal showsHorizontalScrollIndicator={false} style={styles.sugestoesScroll}>
          {SUGESTOES_RAPIDAS.map((sugestao) => (
            <Chip
              key={sugestao}
              mode="outlined"
              onPress={() => enviarMensagem(sugestao)}
              style={styles.sugestaoChip}
              textStyle={styles.sugestaoChipText}
              icon="lightning-bolt"
            >
              {sugestao}
            </Chip>
          ))}
        </ScrollView>
      </View>
    );
  }, [mensagens.length, enviarMensagem]);

  return (
    <KeyboardAvoidingView
      style={styles.container}
      behavior={Platform.OS === 'ios' ? 'padding' : undefined}
      keyboardVerticalOffset={Platform.OS === 'ios' ? 0 : 0}
    >
      {/* Header */}
      <Appbar.Header style={styles.header}>
        <Appbar.BackAction onPress={() => navigation.goBack()} color={colors.textOnPrimary} />
        <Appbar.Content
          title="Assistente IA"
          titleStyle={styles.headerTitle}
          color={colors.textOnPrimary}
        />
        <IconButton icon="robot" iconColor={colors.textOnPrimary} size={24} />
      </Appbar.Header>

      {/* Seletor de lote */}
      {lotesOptions.length > 1 && (
        <View style={styles.seletorLote}>
          <DropdownField
            label="Lote"
            value={loteId}
            options={lotesOptions}
            onSelect={setLoteId}
            placeholder="Selecione o lote"
          />
        </View>
      )}

      {/* Loading historico */}
      {isCarregandoHistorico ? (
        <View style={styles.loadingContainer}>
          <ActivityIndicator size="large" color={colors.secondary} />
          <Text style={styles.loadingText}>Carregando historico...</Text>
        </View>
      ) : (
        /* Lista de mensagens */
        <FlatList
          ref={flatListRef}
          data={mensagens}
          keyExtractor={(item) => item.id}
          renderItem={renderMensagem}
          ListHeaderComponent={renderListHeader}
          contentContainerStyle={styles.listaContent}
          onContentSizeChange={() => {
            if (mensagens.length > 0) {
              flatListRef.current?.scrollToEnd({ animated: true });
            }
          }}
        />
      )}

      {/* Indicador de processamento */}
      {isLoading && (
        <View style={styles.loadingIA}>
          <ActivityIndicator size="small" color={colors.secondary} />
          <Text style={styles.loadingIAText}>Analisando...</Text>
        </View>
      )}

      {/* Input de mensagem */}
      <View style={styles.inputContainer}>
        <TextInput
          value={textoInput}
          onChangeText={setTextoInput}
          placeholder="Digite sua pergunta..."
          mode="outlined"
          outlineColor={colors.gray300}
          activeOutlineColor={colors.secondary}
          style={styles.textInput}
          contentStyle={styles.textInputContent}
          multiline
          maxLength={1000}
          returnKeyType="send"
          onSubmitEditing={() => enviarMensagem()}
          right={
            <TextInput.Icon
              icon="send"
              iconColor={textoInput.trim() ? colors.secondary : colors.gray400}
              onPress={() => enviarMensagem()}
              disabled={!textoInput.trim() || isLoading}
              size={24}
            />
          }
        />
      </View>
    </KeyboardAvoidingView>
  );
};

// ==========================================
// ESTILOS
// ==========================================

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.background,
  },
  header: {
    backgroundColor: colors.secondary,
  },
  headerTitle: {
    fontSize: typography.fontSizeL,
    fontWeight: typography.fontWeightBold,
    color: colors.textOnPrimary,
  },

  // Seletor de lote
  seletorLote: {
    paddingHorizontal: spacing.lg,
    paddingTop: spacing.sm,
    backgroundColor: colors.surface,
    borderBottomWidth: borders.widthThin,
    borderBottomColor: colors.divider,
  },

  // Loading
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    gap: spacing.md,
  },
  loadingText: {
    fontSize: typography.fontSizeS,
    color: colors.textSecondary,
  },

  // Lista de mensagens
  listaContent: {
    paddingHorizontal: spacing.lg,
    paddingVertical: spacing.md,
    flexGrow: 1,
  },

  // Bem vindo
  bemVindoCard: {
    backgroundColor: colors.surface,
    borderRadius: borders.radiusL,
    padding: spacing.xxl,
    alignItems: 'center',
    marginBottom: spacing.lg,
    ...shadows.small,
  },
  bemVindoTitulo: {
    fontSize: typography.fontSizeXL,
    fontWeight: typography.fontWeightBold,
    color: colors.secondary,
    marginBottom: spacing.sm,
  },
  bemVindoTexto: {
    fontSize: typography.fontSizeS,
    color: colors.textSecondary,
    textAlign: 'center',
    lineHeight: typography.fontSizeS * 1.5,
  },

  // Sugestoes
  sugestoesContainer: {
    marginBottom: spacing.lg,
  },
  sugestoesLabel: {
    fontSize: typography.fontSizeS,
    fontWeight: typography.fontWeightMedium,
    color: colors.textSecondary,
    marginBottom: spacing.sm,
  },
  sugestoesScroll: {
    flexDirection: 'row',
  },
  sugestaoChip: {
    marginRight: spacing.sm,
    borderColor: colors.secondary,
    backgroundColor: colors.surface,
  },
  sugestaoChipText: {
    fontSize: typography.fontSizeXS,
    color: colors.secondary,
  },

  // Bolhas de mensagem
  bolhaContainer: {
    flexDirection: 'row',
    marginBottom: spacing.md,
    alignItems: 'flex-end',
  },
  bolhaContainerIA: {
    justifyContent: 'flex-start',
    marginRight: spacing.huge,
  },
  bolhaContainerUser: {
    justifyContent: 'flex-end',
    marginLeft: spacing.huge,
  },
  avatarIA: {
    width: 32,
    height: 32,
    borderRadius: 16,
    backgroundColor: colors.secondary,
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: spacing.sm,
  },
  avatarIcon: {
    margin: 0,
    padding: 0,
  },
  bolha: {
    maxWidth: '85%',
    borderRadius: borders.radiusL,
    padding: spacing.md,
  },
  bolhaIA: {
    backgroundColor: colors.surface,
    borderBottomLeftRadius: borders.radiusS,
    ...shadows.small,
  },
  bolhaUser: {
    backgroundColor: colors.secondary,
    borderBottomRightRadius: borders.radiusS,
  },
  mensagemTexto: {
    fontSize: typography.fontSizeS,
    lineHeight: typography.fontSizeS * 1.5,
  },
  mensagemTextoIA: {
    color: colors.text,
  },
  mensagemTextoUser: {
    color: colors.textOnSecondary,
  },
  boldText: {
    fontWeight: typography.fontWeightBold,
  },
  listaItem: {
    flexDirection: 'row',
    alignItems: 'flex-start',
    paddingLeft: spacing.sm,
  },
  listaBulletIA: {
    color: colors.text,
    fontSize: typography.fontSizeS,
    lineHeight: typography.fontSizeS * 1.5,
  },
  listaBulletUser: {
    color: colors.textOnSecondary,
    fontSize: typography.fontSizeS,
    lineHeight: typography.fontSizeS * 1.5,
  },
  listaTexto: {
    flex: 1,
  },
  timestamp: {
    fontSize: 12,
    marginTop: spacing.xs,
    textAlign: 'right',
  },
  timestampIA: {
    color: colors.gray500,
  },
  timestampUser: {
    color: 'rgba(255, 255, 255, 0.7)',
  },

  // Loading IA
  loadingIA: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: spacing.sm,
    gap: spacing.sm,
  },
  loadingIAText: {
    fontSize: typography.fontSizeS,
    color: colors.secondary,
    fontWeight: typography.fontWeightMedium,
  },

  // Input
  inputContainer: {
    padding: spacing.md,
    backgroundColor: colors.surface,
    borderTopWidth: borders.widthThin,
    borderTopColor: colors.divider,
  },
  textInput: {
    backgroundColor: colors.white,
    maxHeight: 100,
    fontSize: typography.fontSizeS,
  },
  textInputContent: {
    fontSize: typography.fontSizeS,
    minHeight: 48,
  },
});

export default IAAssistenteScreen;
