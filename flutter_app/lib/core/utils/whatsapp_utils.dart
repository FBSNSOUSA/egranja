import 'package:url_launcher/url_launcher.dart';

/// Utilitarios para compartilhamento via WhatsApp.
///
/// Utiliza deep links `https://wa.me/{phone}?text={message}`
/// para abrir o WhatsApp instalado no dispositivo.
/// Nao depende da WhatsApp Business API.
class WhatsAppUtils {
  WhatsAppUtils._();

  /// Abre o WhatsApp com uma mensagem pre-formatada para o numero informado.
  ///
  /// [phone] numero de telefone no formato internacional sem `+` (ex: `5511999998888`).
  /// [message] texto da mensagem a ser enviada.
  ///
  /// Retorna `true` se o WhatsApp foi aberto com sucesso.
  static Future<bool> compartilhar({
    required String phone,
    required String message,
  }) async {
    // Limpar numero: apenas digitos
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanPhone.isEmpty) return false;

    final encodedMessage = Uri.encodeComponent(message);
    final uri = Uri.parse('https://wa.me/$cleanPhone?text=$encodedMessage');

    if (await canLaunchUrl(uri)) {
      return launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }

  /// Formata resumo de pesagem para envio via WhatsApp.
  ///
  /// [galpaoNome] nome do galpao.
  /// [data] data da pesagem formatada (DD/MM/AAAA).
  /// [numAmostras] quantidade de amostras.
  /// [pesoMedio] peso medio em gramas.
  /// [totalAves] total de aves pesadas.
  static String formatarPesagem({
    required String galpaoNome,
    required String data,
    required int numAmostras,
    required double pesoMedio,
    required int totalAves,
  }) {
    return '\u{1F4CA} *Pesagem - $galpaoNome*\n'
        'Data: $data\n'
        'Amostras: $numAmostras\n'
        'Peso Medio: ${pesoMedio.toStringAsFixed(0)}g\n'
        'Total Aves: $totalAves\n'
        '\n_Enviado via eGranja_';
  }

  /// Formata resumo de mortalidade para envio via WhatsApp.
  ///
  /// [galpaoNome] nome do galpao.
  /// [data] data do registro formatada (DD/MM/AAAA).
  /// [quantidade] numero de aves mortas.
  /// [causa] causa da mortalidade.
  /// [observacao] observacao opcional.
  static String formatarMortalidade({
    required String galpaoNome,
    required String data,
    required int quantidade,
    required String causa,
    String? observacao,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('\u{26A0}\u{FE0F} *Mortalidade - $galpaoNome*');
    buffer.writeln('Data: $data');
    buffer.writeln('Quantidade: $quantidade aves');
    buffer.writeln('Causa: $causa');
    if (observacao != null && observacao.isNotEmpty) {
      buffer.writeln('Obs: $observacao');
    }
    buffer.writeln();
    buffer.write('_Enviado via eGranja_');
    return buffer.toString();
  }

  /// Formata resumo de checklist para envio via WhatsApp.
  ///
  /// [galpaoNome] nome do galpao.
  /// [data] data do checklist formatada (DD/MM/AAAA).
  /// [completados] numero de itens completados.
  /// [total] numero total de itens.
  /// [itensDescricao] lista de descricoes dos itens com status.
  static String formatarChecklist({
    required String galpaoNome,
    required String data,
    required int completados,
    required int total,
    List<({String descricao, bool completado})>? itensDescricao,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('\u{2705} *Checklist - $galpaoNome*');
    buffer.writeln('Data: $data');
    buffer.writeln('Progresso: $completados/$total');
    if (itensDescricao != null && itensDescricao.isNotEmpty) {
      buffer.writeln();
      for (final item in itensDescricao) {
        final check = item.completado ? '\u{2705}' : '\u{2B1C}';
        buffer.writeln('$check ${item.descricao}');
      }
    }
    buffer.writeln();
    buffer.write('_Enviado via eGranja_');
    return buffer.toString();
  }
}
