/**
 * Card de solicitacao formal do tecnico no chat do eGranja.
 *
 * Exibe solicitacoes formais com prazo e status:
 * - Pendente: chip amarelo, botao "Responder"
 * - Respondida: chip verde, mostra resposta
 * - Expirada: chip vermelho
 *
 * O produtor pode responder com foto ou texto.
 */

import React, { useCallback } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
} from 'react-native';
import { Chip, Button, IconButton } from 'react-native-paper';
import dayjs from 'dayjs';
import {
  colors,
  typography,
  spacing,
  borders,
  shadows,
  components,
} from '@theme/index';

// ==========================================
// TIPOS
// ==========================================

export type SolicitacaoStatus = 'pendente' | 'respondida' | 'expirada';

interface SolicitacaoCardProps {
  /** Titulo da solicitacao */
  titulo: string;
  /** Descricao detalhada */
  descricao: string;
  /** Data prazo (ISO string) */
  prazo: string;
  /** Status atual */
  status: SolicitacaoStatus;
  /** Texto da resposta (quando respondida) */
  resposta?: string;
  /** URL da midia na resposta */
  respostaMediaUrl?: string;
  /** Callback ao pressionar "Responder" */
  onResponder?: () => void;
  /** Callback ao pressionar "Ver resposta" */
  onVerResposta?: () => void;
  /** Se o usuario atual e o produtor (quem responde) */
  isProdutor?: boolean;
}

// ==========================================
// CONSTANTES
// ==========================================

const STATUS_CONFIG: Record<SolicitacaoStatus, {
  label: string;
  backgroundColor: string;
  textColor: string;
  icon: string;
}> = {
  pendente: {
    label: 'Pendente',
    backgroundColor: colors.warningLight,
    textColor: '#E65100',
    icon: 'clock-outline',
  },
  respondida: {
    label: 'Respondida',
    backgroundColor: colors.successLight,
    textColor: colors.success,
    icon: 'check-circle-outline',
  },
  expirada: {
    label: 'Expirada',
    backgroundColor: colors.dangerLight,
    textColor: colors.danger,
    icon: 'alert-circle-outline',
  },
};

// ==========================================
// COMPONENTE
// ==========================================

export const SolicitacaoCard: React.FC<SolicitacaoCardProps> = ({
  titulo,
  descricao,
  prazo,
  status,
  resposta,
  respostaMediaUrl,
  onResponder,
  onVerResposta,
  isProdutor = true,
}) => {
  const config = STATUS_CONFIG[status];
  const prazoFormatado = dayjs(prazo).format('DD/MM/YYYY [as] HH:mm');
  const prazoExpirado = dayjs(prazo).isBefore(dayjs());
  const diasRestantes = dayjs(prazo).diff(dayjs(), 'day');
  const horasRestantes = dayjs(prazo).diff(dayjs(), 'hour');

  const getPrazoLabel = useCallback((): string => {
    if (status === 'expirada' || prazoExpirado) {
      return 'Prazo expirado';
    }
    if (diasRestantes > 1) {
      return `${diasRestantes} dias restantes`;
    }
    if (diasRestantes === 1) {
      return '1 dia restante';
    }
    if (horasRestantes > 0) {
      return `${horasRestantes}h restantes`;
    }
    return 'Expira em breve';
  }, [status, prazoExpirado, diasRestantes, horasRestantes]);

  return (
    <View style={styles.container}>
      {/* Barra de status lateral */}
      <View style={[styles.statusBar, { backgroundColor: config.textColor }]} />

      <View style={styles.content}>
        {/* Cabecalho: titulo + chip de status */}
        <View style={styles.header}>
          <View style={styles.headerLeft}>
            <IconButton
              icon="clipboard-text-outline"
              iconColor={config.textColor}
              size={20}
              style={styles.headerIcon}
            />
            <Text style={styles.headerLabel}>Solicitacao</Text>
          </View>
          <Chip
            mode="flat"
            icon={config.icon}
            style={[styles.chip, { backgroundColor: config.backgroundColor }]}
            textStyle={[styles.chipText, { color: config.textColor }]}
          >
            {config.label}
          </Chip>
        </View>

        {/* Titulo */}
        <Text style={styles.titulo}>{titulo}</Text>

        {/* Descricao */}
        <Text style={styles.descricao}>{descricao}</Text>

        {/* Prazo */}
        <View style={styles.prazoContainer}>
          <IconButton
            icon="calendar-clock"
            iconColor={prazoExpirado ? colors.danger : colors.textSecondary}
            size={16}
            style={styles.prazoIcon}
          />
          <Text
            style={[
              styles.prazoText,
              prazoExpirado && styles.prazoExpirado,
            ]}
          >
            Prazo: {prazoFormatado}
          </Text>
          {status === 'pendente' && (
            <Text
              style={[
                styles.prazoRestante,
                diasRestantes <= 1 && styles.prazoUrgente,
              ]}
            >
              ({getPrazoLabel()})
            </Text>
          )}
        </View>

        {/* Resposta (quando respondida) */}
        {status === 'respondida' && resposta && (
          <View style={styles.respostaContainer}>
            <Text style={styles.respostaLabel}>Resposta:</Text>
            <Text style={styles.respostaText} numberOfLines={3}>
              {resposta}
            </Text>
            {respostaMediaUrl && onVerResposta && (
              <TouchableOpacity onPress={onVerResposta} style={styles.verMidiaButton}>
                <IconButton icon="image" iconColor={colors.secondary} size={16} style={styles.prazoIcon} />
                <Text style={styles.verMidiaText}>Ver anexo</Text>
              </TouchableOpacity>
            )}
          </View>
        )}

        {/* Botao Responder (para produtor, quando pendente) */}
        {status === 'pendente' && isProdutor && onResponder && (
          <View style={styles.actionContainer}>
            <Button
              mode="contained"
              onPress={onResponder}
              icon="reply"
              style={styles.responderButton}
              contentStyle={styles.responderButtonContent}
              labelStyle={styles.responderButtonLabel}
              buttonColor={colors.secondary}
              textColor={colors.textOnSecondary}
            >
              Responder
            </Button>
          </View>
        )}
      </View>
    </View>
  );
};

// ==========================================
// ESTILOS
// ==========================================

const styles = StyleSheet.create({
  container: {
    backgroundColor: colors.surface,
    borderRadius: borders.radiusL,
    flexDirection: 'row',
    overflow: 'hidden',
    marginVertical: spacing.sm,
    marginHorizontal: spacing.xs,
    ...shadows.medium,
  },
  statusBar: {
    width: 4,
  },
  content: {
    flex: 1,
    padding: spacing.md,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: spacing.sm,
  },
  headerLeft: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  headerIcon: {
    margin: 0,
    padding: 0,
  },
  headerLabel: {
    fontSize: typography.fontSizeXS,
    fontWeight: typography.fontWeightMedium,
    color: colors.textSecondary,
    textTransform: 'uppercase',
    letterSpacing: 0.5,
  },
  chip: {
    height: 28,
  },
  chipText: {
    fontSize: 12,
    fontWeight: typography.fontWeightMedium,
  },
  titulo: {
    fontSize: typography.fontSizeM,
    fontWeight: typography.fontWeightBold,
    color: colors.text,
    marginBottom: spacing.xs,
  },
  descricao: {
    fontSize: typography.fontSizeS,
    color: colors.textSecondary,
    lineHeight: typography.fontSizeS * 1.5,
    marginBottom: spacing.sm,
  },
  prazoContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: spacing.sm,
  },
  prazoIcon: {
    margin: 0,
    padding: 0,
    marginRight: 2,
  },
  prazoText: {
    fontSize: typography.fontSizeXS,
    color: colors.textSecondary,
  },
  prazoExpirado: {
    color: colors.danger,
    fontWeight: typography.fontWeightMedium,
  },
  prazoRestante: {
    fontSize: typography.fontSizeXS,
    color: colors.textSecondary,
    marginLeft: spacing.xs,
  },
  prazoUrgente: {
    color: colors.danger,
    fontWeight: typography.fontWeightMedium,
  },
  respostaContainer: {
    backgroundColor: colors.successLight,
    borderRadius: borders.radiusM,
    padding: spacing.sm,
    marginTop: spacing.xs,
  },
  respostaLabel: {
    fontSize: typography.fontSizeXS,
    fontWeight: typography.fontWeightBold,
    color: colors.success,
    marginBottom: spacing.xs,
  },
  respostaText: {
    fontSize: typography.fontSizeS,
    color: colors.text,
    lineHeight: typography.fontSizeS * 1.4,
  },
  verMidiaButton: {
    flexDirection: 'row',
    alignItems: 'center',
    marginTop: spacing.xs,
  },
  verMidiaText: {
    fontSize: typography.fontSizeXS,
    color: colors.secondary,
    fontWeight: typography.fontWeightMedium,
  },
  actionContainer: {
    marginTop: spacing.sm,
    alignItems: 'flex-start',
  },
  responderButton: {
    borderRadius: components.button.borderRadius,
  },
  responderButtonContent: {
    minHeight: 40,
  },
  responderButtonLabel: {
    fontSize: typography.fontSizeS,
    fontWeight: typography.fontWeightBold,
  },
});

export default SolicitacaoCard;
