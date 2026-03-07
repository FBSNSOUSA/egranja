/**
 * Tela de chat Produtor-Tecnico do eGranja.
 *
 * Funcionalidades:
 * - WebSocket para mensagens em tempo real
 * - Tipos: texto, foto (camera/galeria com compressao), audio (gravacao 2min)
 * - Solicitacoes formais com prazo e status
 * - Indicador de digitacao (typing)
 * - Mensagens do sistema (alertas automaticos)
 * - Badge de mensagens nao lidas
 */

import React, { useState, useCallback, useEffect, useRef, useMemo } from 'react';
import {
  View,
  Text,
  StyleSheet,
  Alert,
  Platform,
  KeyboardAvoidingView,
  TouchableOpacity,
  Image,
  ActivityIndicator,
} from 'react-native';
import { GiftedChat, IMessage, Bubble, InputToolbar, Send, Composer, Actions } from 'react-native-gifted-chat';
import { Appbar, IconButton, Snackbar, Badge } from 'react-native-paper';
import { useNavigation, useRoute, RouteProp } from '@react-navigation/native';
import * as ImagePicker from 'expo-image-picker';
import * as ImageManipulator from 'expo-image-manipulator';
import { Audio } from 'expo-av';
import dayjs from 'dayjs';
import { apiGet, apiUpload, apiPost } from '@services/api';
import { useAuthStore } from '@stores/authStore';
import { wsClient, WSMessage, WSSendPayload } from '@services/websocket';
import { SolicitacaoCard } from '@components/SolicitacaoCard';
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

interface ChatRouteParams {
  loteId: string;
  loteNome: string;
}

interface ChatMessage extends IMessage {
  messageType?: 'text' | 'photo' | 'audio' | 'solicitacao' | 'system';
  audioUrl?: string;
  solicitacao?: {
    id: string;
    titulo: string;
    descricao: string;
    prazo: string;
    status: 'pendente' | 'respondida' | 'expirada';
    resposta?: string;
    resposta_media_url?: string;
  };
}

interface ApiChatMessage {
  id: string;
  type: string;
  sender_id: string;
  sender_nome: string;
  sender_tipo: string;
  content?: string;
  media_url?: string;
  thumbnail_url?: string;
  solicitacao?: {
    id: string;
    titulo: string;
    descricao: string;
    prazo: string;
    status: 'pendente' | 'respondida' | 'expirada';
    resposta?: string;
    resposta_media_url?: string;
  };
  created_at: string;
}

/** Duracao maxima de gravacao de audio (ms) */
const MAX_AUDIO_DURATION = 120000; // 2 minutos

/** Resolucao maxima de foto */
const MAX_PHOTO_SIZE = 1024;

/** Qualidade de compressao JPEG */
const PHOTO_QUALITY = 0.8;

// ==========================================
// COMPONENTE
// ==========================================

const ChatScreen: React.FC = () => {
  const navigation = useNavigation<any>();
  const route = useRoute<RouteProp<{ Chat: ChatRouteParams }, 'Chat'>>();
  const { loteId, loteNome } = route.params;

  const user = useAuthStore((state) => state.user);
  const userId = user?.id || '';
  const userName = user?.nome || 'Usuario';

  const [messages, setMessages] = useState<ChatMessage[]>([]);
  const [isTyping, setIsTyping] = useState(false);
  const [isRecording, setIsRecording] = useState(false);
  const [recordingDuration, setRecordingDuration] = useState(0);
  const [uploading, setUploading] = useState(false);
  const [snackbarMessage, setSnackbarMessage] = useState('');
  const [snackbarVisible, setSnackbarVisible] = useState(false);
  const [wsConnected, setWsConnected] = useState(false);
  const [loadingMore, setLoadingMore] = useState(false);
  const [hasMore, setHasMore] = useState(true);

  const recordingRef = useRef<Audio.Recording | null>(null);
  const recordingTimerRef = useRef<ReturnType<typeof setInterval> | null>(null);
  const typingTimerRef = useRef<ReturnType<typeof setTimeout> | null>(null);

  // ==========================================
  // WEBSOCKET
  // ==========================================

  useEffect(() => {
    // Conectar WebSocket
    wsClient.connect(loteId);

    // Listener de mensagens
    const unsubMessage = wsClient.onMessage((wsMsg: WSMessage) => {
      if (wsMsg.lote_id !== loteId) return;

      const newMessage = convertWSToGifted(wsMsg);
      setMessages((prev) => GiftedChat.append(prev, [newMessage]));
    });

    // Listener de conexao
    const unsubConnection = wsClient.onConnectionChange((connected) => {
      setWsConnected(connected);
    });

    // Listener de typing
    const unsubTyping = wsClient.onTyping((_loteId, _userId, typing) => {
      if (_loteId === loteId && _userId !== userId) {
        setIsTyping(typing);
        // Auto-desligar typing apos 3s
        if (typing) {
          setTimeout(() => setIsTyping(false), 3000);
        }
      }
    });

    // Marcar como lido
    wsClient.sendRead(loteId);

    return () => {
      unsubMessage();
      unsubConnection();
      unsubTyping();
    };
  }, [loteId, userId]);

  // ==========================================
  // CARREGAR HISTORICO
  // ==========================================

  useEffect(() => {
    carregarMensagens();
  }, [loteId]);

  const carregarMensagens = useCallback(async (before?: string) => {
    try {
      setLoadingMore(true);
      const params: Record<string, unknown> = { limit: 50 };
      if (before) {
        params.before = before;
      }

      const response = await apiGet<ApiChatMessage[]>(
        `/chat/lotes/${loteId}/mensagens`,
        params,
      );

      const giftedMessages = response.data.map(convertApiToGifted);

      if (before) {
        setMessages((prev) => [...prev, ...giftedMessages]);
      } else {
        setMessages(giftedMessages);
      }

      setHasMore(response.data.length === 50);
    } catch (error) {
      console.error('[Chat] Erro ao carregar mensagens:', error);
      showSnackbar('Erro ao carregar mensagens.');
    } finally {
      setLoadingMore(false);
    }
  }, [loteId]);

  const loadEarlier = useCallback(() => {
    if (!hasMore || loadingMore) return;
    const oldest = messages[messages.length - 1];
    if (oldest) {
      carregarMensagens(oldest.createdAt as string);
    }
  }, [hasMore, loadingMore, messages, carregarMensagens]);

  // ==========================================
  // CONVERSAO DE MENSAGENS
  // ==========================================

  const convertApiToGifted = useCallback((msg: ApiChatMessage): ChatMessage => {
    return {
      _id: msg.id,
      text: msg.content || '',
      createdAt: new Date(msg.created_at),
      user: {
        _id: msg.sender_id,
        name: msg.sender_nome,
      },
      messageType: msg.type as ChatMessage['messageType'],
      image: msg.type === 'photo' ? msg.media_url : undefined,
      audioUrl: msg.type === 'audio' ? msg.media_url : undefined,
      solicitacao: msg.solicitacao,
      system: msg.type === 'system',
    };
  }, []);

  const convertWSToGifted = useCallback((wsMsg: WSMessage): ChatMessage => {
    return {
      _id: wsMsg.id || `ws_${Date.now()}_${Math.random()}`,
      text: wsMsg.content || '',
      createdAt: new Date(wsMsg.created_at || Date.now()),
      user: {
        _id: wsMsg.sender_id,
        name: wsMsg.sender_nome || '',
      },
      messageType: wsMsg.type as ChatMessage['messageType'],
      image: wsMsg.type === 'photo' ? wsMsg.media_url : undefined,
      audioUrl: wsMsg.type === 'audio' ? wsMsg.media_url : undefined,
      solicitacao: wsMsg.solicitacao,
      system: wsMsg.type === 'system',
    };
  }, []);

  // ==========================================
  // ENVIAR MENSAGEM DE TEXTO
  // ==========================================

  const onSend = useCallback(
    (newMessages: IMessage[] = []) => {
      const msg = newMessages[0];
      if (!msg || !msg.text?.trim()) return;

      const payload: WSSendPayload = {
        type: 'text',
        lote_id: loteId,
        content: msg.text.trim(),
      };

      const sent = wsClient.send(payload);

      if (sent) {
        setMessages((prev) =>
          GiftedChat.append(prev, [
            {
              ...msg,
              _id: `local_${Date.now()}`,
              createdAt: new Date(),
              user: { _id: userId, name: userName },
              messageType: 'text',
            } as ChatMessage,
          ]),
        );
      } else {
        showSnackbar('Sem conexao. Tente novamente.');
      }
    },
    [loteId, userId, userName],
  );

  // ==========================================
  // INDICADOR DE DIGITACAO
  // ==========================================

  const handleInputTextChanged = useCallback(
    (text: string) => {
      if (text.length > 0) {
        wsClient.sendTyping(loteId);

        // Debounce para nao enviar typing a cada tecla
        if (typingTimerRef.current) {
          clearTimeout(typingTimerRef.current);
        }
        typingTimerRef.current = setTimeout(() => {
          // Parar typing apos 2s sem digitar
        }, 2000);
      }
    },
    [loteId],
  );

  // ==========================================
  // ENVIAR FOTO
  // ==========================================

  const handlePhotoPress = useCallback(() => {
    Alert.alert('Enviar foto', 'Escolha a origem da foto', [
      {
        text: 'Camera',
        onPress: () => pickImage('camera'),
      },
      {
        text: 'Galeria',
        onPress: () => pickImage('gallery'),
      },
      {
        text: 'Cancelar',
        style: 'cancel',
      },
    ]);
  }, []);

  const pickImage = useCallback(
    async (source: 'camera' | 'gallery') => {
      try {
        let result: ImagePicker.ImagePickerResult;

        if (source === 'camera') {
          const permission = await ImagePicker.requestCameraPermissionsAsync();
          if (!permission.granted) {
            showSnackbar('Permissao de camera necessaria.');
            return;
          }
          result = await ImagePicker.launchCameraAsync({
            mediaTypes: ImagePicker.MediaTypeOptions.Images,
            quality: 1,
          });
        } else {
          const permission = await ImagePicker.requestMediaLibraryPermissionsAsync();
          if (!permission.granted) {
            showSnackbar('Permissao de galeria necessaria.');
            return;
          }
          result = await ImagePicker.launchImageLibraryAsync({
            mediaTypes: ImagePicker.MediaTypeOptions.Images,
            quality: 1,
          });
        }

        if (result.canceled || !result.assets?.[0]) return;

        const asset = result.assets[0];

        // Comprimir imagem (max 1024px, 80% qualidade)
        setUploading(true);
        const manipulated = await ImageManipulator.manipulateAsync(
          asset.uri,
          [
            {
              resize: {
                width: Math.min(asset.width || MAX_PHOTO_SIZE, MAX_PHOTO_SIZE),
              },
            },
          ],
          {
            compress: PHOTO_QUALITY,
            format: ImageManipulator.SaveFormat.JPEG,
          },
        );

        // Upload para o servidor
        const uploadResponse = await apiUpload(
          manipulated.uri,
          'image/jpeg',
          `chat_${loteId}_${Date.now()}.jpg`,
        );

        // Enviar via WebSocket
        const payload: WSSendPayload = {
          type: 'photo',
          lote_id: loteId,
          media_url: uploadResponse.data.url,
          thumbnail_url: uploadResponse.data.thumbnail_url,
        };

        const sent = wsClient.send(payload);

        if (sent) {
          const photoMessage: ChatMessage = {
            _id: `local_photo_${Date.now()}`,
            text: '',
            createdAt: new Date(),
            user: { _id: userId, name: userName },
            messageType: 'photo',
            image: uploadResponse.data.url,
          };
          setMessages((prev) => GiftedChat.append(prev, [photoMessage]));
          showSnackbar('Foto enviada.');
        }
      } catch (error) {
        console.error('[Chat] Erro ao enviar foto:', error);
        showSnackbar('Erro ao enviar foto.');
      } finally {
        setUploading(false);
      }
    },
    [loteId, userId, userName],
  );

  // ==========================================
  // GRAVAR AUDIO
  // ==========================================

  const startRecording = useCallback(async () => {
    try {
      const permission = await Audio.requestPermissionsAsync();
      if (!permission.granted) {
        showSnackbar('Permissao de microfone necessaria.');
        return;
      }

      await Audio.setAudioModeAsync({
        allowsRecordingIOS: true,
        playsInSilentModeIOS: true,
      });

      const { recording } = await Audio.Recording.createAsync(
        Audio.RecordingOptionsPresets.HIGH_QUALITY,
      );

      recordingRef.current = recording;
      setIsRecording(true);
      setRecordingDuration(0);

      // Timer de duracao
      recordingTimerRef.current = setInterval(() => {
        setRecordingDuration((prev) => {
          const next = prev + 1;
          if (next >= MAX_AUDIO_DURATION / 1000) {
            stopRecording();
          }
          return next;
        });
      }, 1000);
    } catch (error) {
      console.error('[Chat] Erro ao iniciar gravacao:', error);
      showSnackbar('Erro ao iniciar gravacao.');
    }
  }, []);

  const stopRecording = useCallback(async () => {
    try {
      if (!recordingRef.current) return;

      if (recordingTimerRef.current) {
        clearInterval(recordingTimerRef.current);
        recordingTimerRef.current = null;
      }

      setIsRecording(false);
      setRecordingDuration(0);

      await recordingRef.current.stopAndUnloadAsync();
      const uri = recordingRef.current.getURI();
      recordingRef.current = null;

      if (!uri) {
        showSnackbar('Gravacao vazia.');
        return;
      }

      // Upload do audio
      setUploading(true);
      const uploadResponse = await apiUpload(
        uri,
        'audio/m4a',
        `chat_audio_${loteId}_${Date.now()}.m4a`,
      );

      // Enviar via WebSocket
      const payload: WSSendPayload = {
        type: 'audio',
        lote_id: loteId,
        media_url: uploadResponse.data.url,
      };

      const sent = wsClient.send(payload);

      if (sent) {
        const audioMessage: ChatMessage = {
          _id: `local_audio_${Date.now()}`,
          text: 'Audio',
          createdAt: new Date(),
          user: { _id: userId, name: userName },
          messageType: 'audio',
          audioUrl: uploadResponse.data.url,
        };
        setMessages((prev) => GiftedChat.append(prev, [audioMessage]));
        showSnackbar('Audio enviado.');
      }
    } catch (error) {
      console.error('[Chat] Erro ao finalizar gravacao:', error);
      showSnackbar('Erro ao enviar audio.');
    } finally {
      setUploading(false);
    }
  }, [loteId, userId, userName]);

  const cancelRecording = useCallback(async () => {
    if (!recordingRef.current) return;

    if (recordingTimerRef.current) {
      clearInterval(recordingTimerRef.current);
      recordingTimerRef.current = null;
    }

    try {
      await recordingRef.current.stopAndUnloadAsync();
    } catch {
      // Ignorar erro ao cancelar
    }
    recordingRef.current = null;
    setIsRecording(false);
    setRecordingDuration(0);
  }, []);

  // ==========================================
  // RESPONDER SOLICITACAO
  // ==========================================

  const handleResponderSolicitacao = useCallback(
    (solicitacaoId: string) => {
      Alert.alert(
        'Responder solicitacao',
        'Como deseja responder?',
        [
          {
            text: 'Com texto',
            onPress: () => {
              // Foca no input de texto - a mensagem sera enviada como resposta
              showSnackbar('Digite sua resposta abaixo.');
            },
          },
          {
            text: 'Com foto',
            onPress: () => pickImage('camera'),
          },
          {
            text: 'Cancelar',
            style: 'cancel',
          },
        ],
      );
    },
    [pickImage],
  );

  // ==========================================
  // HELPERS
  // ==========================================

  const showSnackbar = useCallback((message: string) => {
    setSnackbarMessage(message);
    setSnackbarVisible(true);
  }, []);

  const formatRecordingTime = useCallback((seconds: number): string => {
    const min = Math.floor(seconds / 60);
    const sec = seconds % 60;
    return `${min}:${sec.toString().padStart(2, '0')}`;
  }, []);

  // ==========================================
  // RENDER CUSTOMIZADO
  // ==========================================

  const renderBubble = useCallback((props: any) => {
    const currentMessage: ChatMessage = props.currentMessage;

    // Renderizar solicitacao como card especial
    if (currentMessage.messageType === 'solicitacao' && currentMessage.solicitacao) {
      return (
        <SolicitacaoCard
          titulo={currentMessage.solicitacao.titulo}
          descricao={currentMessage.solicitacao.descricao}
          prazo={currentMessage.solicitacao.prazo}
          status={currentMessage.solicitacao.status}
          resposta={currentMessage.solicitacao.resposta}
          respostaMediaUrl={currentMessage.solicitacao.resposta_media_url}
          isProdutor={user?.tipo === 'produtor'}
          onResponder={() =>
            handleResponderSolicitacao(currentMessage.solicitacao!.id)
          }
        />
      );
    }

    // Renderizar audio como botao de play
    if (currentMessage.messageType === 'audio') {
      const isMe = currentMessage.user._id === userId;
      return (
        <View
          style={[
            styles.audioBubble,
            isMe ? styles.audioBubbleRight : styles.audioBubbleLeft,
          ]}
        >
          <IconButton
            icon="play-circle"
            iconColor={isMe ? colors.textOnPrimary : colors.primary}
            size={32}
          />
          <View style={styles.audioWaveform}>
            <View style={[styles.audioBar, { height: 12 }]} />
            <View style={[styles.audioBar, { height: 20 }]} />
            <View style={[styles.audioBar, { height: 16 }]} />
            <View style={[styles.audioBar, { height: 24 }]} />
            <View style={[styles.audioBar, { height: 14 }]} />
            <View style={[styles.audioBar, { height: 18 }]} />
            <View style={[styles.audioBar, { height: 10 }]} />
          </View>
          <Text
            style={[
              styles.audioTime,
              { color: isMe ? colors.textOnPrimary : colors.textSecondary },
            ]}
          >
            {dayjs(currentMessage.createdAt).format('HH:mm')}
          </Text>
        </View>
      );
    }

    return (
      <Bubble
        {...props}
        wrapperStyle={{
          left: styles.bubbleLeft,
          right: styles.bubbleRight,
        }}
        textStyle={{
          left: styles.bubbleTextLeft,
          right: styles.bubbleTextRight,
        }}
        timeTextStyle={{
          left: styles.timeText,
          right: styles.timeTextRight,
        }}
      />
    );
  }, [userId, user, handleResponderSolicitacao]);

  const renderInputToolbar = useCallback((props: any) => {
    if (isRecording) {
      return (
        <View style={styles.recordingBar}>
          <TouchableOpacity onPress={cancelRecording} style={styles.recordingCancel}>
            <IconButton icon="close" iconColor={colors.danger} size={24} />
          </TouchableOpacity>

          <View style={styles.recordingIndicator}>
            <View style={styles.recordingDot} />
            <Text style={styles.recordingText}>
              Gravando... {formatRecordingTime(recordingDuration)}
            </Text>
          </View>

          <TouchableOpacity onPress={stopRecording} style={styles.recordingSend}>
            <IconButton icon="send" iconColor={colors.primary} size={28} />
          </TouchableOpacity>
        </View>
      );
    }

    return (
      <InputToolbar
        {...props}
        containerStyle={styles.inputToolbar}
        primaryStyle={styles.inputPrimary}
      />
    );
  }, [isRecording, recordingDuration, cancelRecording, stopRecording, formatRecordingTime]);

  const renderActions = useCallback((props: any) => {
    return (
      <View style={styles.actionsContainer}>
        <TouchableOpacity
          onPress={handlePhotoPress}
          style={styles.actionButton}
          disabled={uploading}
        >
          <IconButton icon="camera" iconColor={colors.gray600} size={24} />
        </TouchableOpacity>
        <TouchableOpacity
          onPress={startRecording}
          style={styles.actionButton}
          disabled={uploading}
        >
          <IconButton icon="microphone" iconColor={colors.gray600} size={24} />
        </TouchableOpacity>
      </View>
    );
  }, [handlePhotoPress, startRecording, uploading]);

  const renderSend = useCallback((props: any) => {
    return (
      <Send {...props} containerStyle={styles.sendContainer}>
        <View style={styles.sendButton}>
          <IconButton icon="send" iconColor={colors.primary} size={24} />
        </View>
      </Send>
    );
  }, []);

  const renderComposer = useCallback((props: any) => {
    return (
      <Composer
        {...props}
        textInputStyle={styles.composerInput}
        placeholder="Digite sua mensagem..."
        placeholderTextColor={colors.gray500}
      />
    );
  }, []);

  const renderLoading = useCallback(() => {
    return (
      <View style={styles.loadingContainer}>
        <ActivityIndicator size="large" color={colors.primary} />
      </View>
    );
  }, []);

  const renderFooter = useCallback(() => {
    if (uploading) {
      return (
        <View style={styles.footerContainer}>
          <ActivityIndicator size="small" color={colors.primary} />
          <Text style={styles.footerText}>Enviando...</Text>
        </View>
      );
    }
    return null;
  }, [uploading]);

  // ==========================================
  // RENDER PRINCIPAL
  // ==========================================

  return (
    <View style={styles.container}>
      {/* Header */}
      <Appbar.Header style={styles.header}>
        <Appbar.BackAction
          color={colors.textOnPrimary}
          onPress={() => navigation.goBack()}
        />
        <Appbar.Content
          title={loteNome}
          titleStyle={styles.headerTitle}
          subtitle={wsConnected ? 'Online' : 'Reconectando...'}
          subtitleStyle={[
            styles.headerSubtitle,
            { color: wsConnected ? colors.successLight : colors.warningLight },
          ]}
        />
      </Appbar.Header>

      {/* Chat */}
      <KeyboardAvoidingView
        style={styles.chatContainer}
        behavior={Platform.OS === 'ios' ? 'padding' : undefined}
        keyboardVerticalOffset={Platform.OS === 'ios' ? 0 : 0}
      >
        <GiftedChat
          messages={messages}
          onSend={onSend}
          user={{
            _id: userId,
            name: userName,
          }}
          isTyping={isTyping}
          renderBubble={renderBubble}
          renderInputToolbar={renderInputToolbar}
          renderActions={renderActions}
          renderSend={renderSend}
          renderComposer={renderComposer}
          renderLoading={renderLoading}
          renderFooter={renderFooter}
          onInputTextChanged={handleInputTextChanged}
          loadEarlier={hasMore}
          onLoadEarlier={loadEarlier}
          isLoadingEarlier={loadingMore}
          scrollToBottom
          scrollToBottomComponent={() => (
            <IconButton icon="chevron-down" iconColor={colors.gray600} size={24} />
          )}
          placeholder="Digite sua mensagem..."
          locale="pt-br"
          dateFormat="DD/MM/YYYY"
          timeFormat="HH:mm"
          alwaysShowSend
          infiniteScroll
        />
      </KeyboardAvoidingView>

      {/* Snackbar */}
      <Snackbar
        visible={snackbarVisible}
        onDismiss={() => setSnackbarVisible(false)}
        duration={3000}
        style={styles.snackbar}
      >
        {snackbarMessage}
      </Snackbar>
    </View>
  );
};

// ==========================================
// ESTILOS
// ==========================================

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.gray100,
  },
  header: {
    backgroundColor: colors.primary,
  },
  headerTitle: {
    fontSize: typography.fontSizeL,
    fontWeight: typography.fontWeightBold,
    color: colors.textOnPrimary,
  },
  headerSubtitle: {
    fontSize: typography.fontSizeXS,
  },
  chatContainer: {
    flex: 1,
  },

  // Bolhas
  bubbleLeft: {
    backgroundColor: colors.surface,
    borderRadius: borders.radiusL,
    borderBottomLeftRadius: borders.radiusS,
    ...shadows.small,
  },
  bubbleRight: {
    backgroundColor: colors.secondary,
    borderRadius: borders.radiusL,
    borderBottomRightRadius: borders.radiusS,
  },
  bubbleTextLeft: {
    fontSize: typography.fontSizeS,
    color: colors.text,
  },
  bubbleTextRight: {
    fontSize: typography.fontSizeS,
    color: colors.textOnSecondary,
  },
  timeText: {
    fontSize: 11,
    color: colors.textSecondary,
  },
  timeTextRight: {
    fontSize: 11,
    color: 'rgba(255,255,255,0.7)',
  },

  // Audio bubble
  audioBubble: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: spacing.sm,
    paddingVertical: spacing.xs,
    borderRadius: borders.radiusL,
    maxWidth: 260,
    marginVertical: spacing.xs,
  },
  audioBubbleLeft: {
    backgroundColor: colors.surface,
    borderBottomLeftRadius: borders.radiusS,
    ...shadows.small,
  },
  audioBubbleRight: {
    backgroundColor: colors.secondary,
    borderBottomRightRadius: borders.radiusS,
    alignSelf: 'flex-end',
  },
  audioWaveform: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 2,
    flex: 1,
    marginHorizontal: spacing.xs,
  },
  audioBar: {
    width: 3,
    backgroundColor: colors.gray400,
    borderRadius: 1.5,
  },
  audioTime: {
    fontSize: 11,
    marginLeft: spacing.xs,
  },

  // Input toolbar
  inputToolbar: {
    backgroundColor: colors.surface,
    borderTopWidth: 1,
    borderTopColor: colors.divider,
    paddingVertical: spacing.xs,
  },
  inputPrimary: {
    alignItems: 'center',
  },
  composerInput: {
    fontSize: typography.fontSizeS,
    color: colors.text,
    backgroundColor: colors.gray100,
    borderRadius: borders.radiusXL,
    paddingHorizontal: spacing.lg,
    paddingTop: Platform.OS === 'ios' ? spacing.sm : 0,
    marginLeft: spacing.xs,
    marginRight: spacing.xs,
    minHeight: 40,
  },
  actionsContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    marginLeft: spacing.xs,
  },
  actionButton: {
    padding: 0,
    margin: 0,
  },
  sendContainer: {
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: spacing.xs,
  },
  sendButton: {
    justifyContent: 'center',
    alignItems: 'center',
  },

  // Recording bar
  recordingBar: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: colors.surface,
    borderTopWidth: 1,
    borderTopColor: colors.divider,
    paddingVertical: spacing.sm,
    paddingHorizontal: spacing.md,
    minHeight: 56,
  },
  recordingCancel: {
    marginRight: spacing.sm,
  },
  recordingIndicator: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
  },
  recordingDot: {
    width: 10,
    height: 10,
    borderRadius: 5,
    backgroundColor: colors.danger,
    marginRight: spacing.sm,
  },
  recordingText: {
    fontSize: typography.fontSizeS,
    color: colors.danger,
    fontWeight: typography.fontWeightMedium,
  },
  recordingSend: {
    marginLeft: spacing.sm,
  },

  // Loading/Footer
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  footerContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: spacing.sm,
    gap: spacing.sm,
  },
  footerText: {
    fontSize: typography.fontSizeXS,
    color: colors.textSecondary,
  },

  snackbar: {
    backgroundColor: colors.gray800,
  },
});

export default ChatScreen;
