import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:egranja_flutter/core/theme/app_colors.dart';

/// Widget de visualizacao de vento e sol para um galpao.
///
/// Usa [CustomPainter] para desenhar:
/// - Pontos cardeais (N, S, L, O)
/// - Arco solar com posicao atual do sol
/// - Retangulo do galpao rotacionado
/// - Indicadores de cortinas (aberta/fechada)
/// - Seta de direcao do vento
/// - Legenda com informacoes
class GalpaoWindSunView extends StatelessWidget {
  const GalpaoWindSunView({
    super.key,
    required this.largura,
    required this.comprimento,
    required this.orientacaoGraus,
    this.ventoVelocidade = 0,
    this.ventoDirecao = 0,
    this.temperaturaExterna = 0,
    this.cortinasAbertas = false,
  });

  final double largura;
  final double comprimento;
  final double orientacaoGraus;
  final double ventoVelocidade;
  final int ventoDirecao;
  final double temperaturaExterna;
  final bool cortinasAbertas;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 320,
          height: 280,
          child: CustomPaint(
            size: const Size(320, 280),
            painter: _GalpaoWindSunPainter(
              largura: largura,
              comprimento: comprimento,
              orientacaoGraus: orientacaoGraus,
              ventoVelocidade: ventoVelocidade,
              ventoDirecao: ventoDirecao,
              temperaturaExterna: temperaturaExterna,
              cortinasAbertas: cortinasAbertas,
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildLegend(context),
        const SizedBox(height: 8),
        _buildWindScale(context),
      ],
    );
  }

  Widget _buildLegend(BuildContext context) {
    final theme = Theme.of(context);
    final direcaoTexto = _direcaoVentoTexto(ventoDirecao);
    final cortinasTexto = cortinasAbertas ? 'Abertas' : 'Fechadas';
    final cortinasColor = cortinasAbertas ? AppColors.success : AppColors.danger;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.air, size: 16, color: _windColor()),
              const SizedBox(width: 4),
              Text(
                'Vento: $direcaoTexto - ${ventoVelocidade.toStringAsFixed(0)} km/h',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.curtains, size: 16, color: cortinasColor),
              const SizedBox(width: 4),
              Text(
                'Cortinas: $cortinasTexto',
                style: theme.textTheme.bodySmall?.copyWith(color: cortinasColor),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.thermostat, size: 16, color: AppColors.warning),
              const SizedBox(width: 4),
              Text(
                'Temp. externa: ${temperaturaExterna.toStringAsFixed(1)} C',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWindScale(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text('Vento:', style: theme.textTheme.labelSmall),
          const SizedBox(width: 8),
          _scaleChip('<15 km/h', AppColors.success),
          const SizedBox(width: 4),
          _scaleChip('15-30', AppColors.warning),
          const SizedBox(width: 4),
          _scaleChip('>30', AppColors.danger),
        ],
      ),
    );
  }

  Widget _scaleChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(40),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  Color _windColor() {
    if (ventoVelocidade < 15) return AppColors.success;
    if (ventoVelocidade <= 30) return AppColors.warning;
    return AppColors.danger;
  }

  static String _direcaoVentoTexto(int graus) {
    const direcoes = ['N', 'NE', 'L', 'SE', 'S', 'SO', 'O', 'NO'];
    final index = ((graus + 22.5) / 45).floor() % 8;
    return direcoes[index];
  }
}

class _GalpaoWindSunPainter extends CustomPainter {
  _GalpaoWindSunPainter({
    required this.largura,
    required this.comprimento,
    required this.orientacaoGraus,
    required this.ventoVelocidade,
    required this.ventoDirecao,
    required this.temperaturaExterna,
    required this.cortinasAbertas,
  });

  final double largura;
  final double comprimento;
  final double orientacaoGraus;
  final double ventoVelocidade;
  final int ventoDirecao;
  final double temperaturaExterna;
  final bool cortinasAbertas;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.38;

    _drawCardinalPoints(canvas, size, center, radius);
    _drawSolarArc(canvas, center, radius);
    _drawSunPosition(canvas, center, radius);
    _drawBarn(canvas, center);
    _drawWindArrow(canvas, center, radius);
  }

  void _drawCardinalPoints(
      Canvas canvas, Size size, Offset center, double radius) {
    final textStyle = TextStyle(
      color: AppColors.gray600,
      fontSize: 13,
      fontWeight: FontWeight.w600,
    );

    final points = {
      'N': Offset(center.dx, center.dy - radius - 18),
      'S': Offset(center.dx, center.dy + radius + 10),
      'L': Offset(center.dx + radius + 10, center.dy),
      'O': Offset(center.dx - radius - 18, center.dy),
    };

    for (final entry in points.entries) {
      final tp = TextPainter(
        text: TextSpan(text: entry.key, style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(
          entry.value.dx - tp.width / 2,
          entry.value.dy - tp.height / 2,
        ),
      );
    }
  }

  void _drawSolarArc(Canvas canvas, Offset center, double radius) {
    final arcPaint = Paint()
      ..color = const Color(0xFFFFC107).withAlpha(100)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Arco solar de Leste (direita) a Oeste (esquerda), passando pelo topo
    // Arco no topo da visualizacao
    final arcRadius = radius * 0.85;

    // Desenhar arco tracejado
    const dashLength = 6.0;
    const gapLength = 4.0;
    final totalAngle = math.pi; // 180 graus
    final circumference = arcRadius * totalAngle;
    final dashes = (circumference / (dashLength + gapLength)).floor();

    for (int i = 0; i < dashes; i++) {
      final startAngle =
          math.pi + (i * (dashLength + gapLength) / circumference) * totalAngle;
      final sweepAngle = (dashLength / circumference) * totalAngle;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: arcRadius),
        startAngle,
        sweepAngle,
        false,
        arcPaint,
      );
    }

    // Labels: Nasc. (Leste) e Poente (Oeste)
    final nascStyle = TextStyle(
      color: const Color(0xFFFF9800),
      fontSize: 9,
      fontWeight: FontWeight.w500,
    );

    final nascTp = TextPainter(
      text: TextSpan(text: 'Nasc.', style: nascStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    nascTp.paint(
      canvas,
      Offset(center.dx + arcRadius + 4, center.dy + 4),
    );

    final poenteTp = TextPainter(
      text: TextSpan(text: 'Poente', style: nascStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    poenteTp.paint(
      canvas,
      Offset(center.dx - arcRadius - poenteTp.width - 4, center.dy + 4),
    );
  }

  void _drawSunPosition(Canvas canvas, Offset center, double radius) {
    final now = DateTime.now();
    final hour = now.hour + now.minute / 60.0;

    // Sol visivel entre 5h e 19h
    if (hour < 5 || hour > 19) return;

    final arcRadius = radius * 0.85;
    // Mapear hora para angulo no arco (5h = Leste/0, 19h = Oeste/pi)
    final t = (hour - 5) / 14.0; // 0 a 1
    // Angulo: de 0 (Leste) a pi (Oeste), passando pelo topo (-pi/2)
    final angle = math.pi + t * math.pi;

    final sunX = center.dx + arcRadius * math.cos(angle);
    final sunY = center.dy + arcRadius * math.sin(angle);

    // Circulo externo (halo)
    final haloPaint = Paint()
      ..color = const Color(0xFFFFC107).withAlpha(60)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(sunX, sunY), 14, haloPaint);

    // Circulo do sol
    final sunPaint = Paint()
      ..color = const Color(0xFFFFC107)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(sunX, sunY), 8, sunPaint);

    // Circulo interno
    final innerPaint = Paint()
      ..color = const Color(0xFFFFEB3B)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(sunX, sunY), 4, innerPaint);
  }

  void _drawBarn(Canvas canvas, Offset center) {
    final barnWidth = 50.0; // largura visual
    final barnHeight = 80.0; // comprimento visual

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(orientacaoGraus * math.pi / 180);

    // Sombra
    final shadowPaint = Paint()
      ..color = Colors.black.withAlpha(30)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: const Offset(3, 3),
          width: barnWidth,
          height: barnHeight,
        ),
        const Radius.circular(4),
      ),
      shadowPaint,
    );

    // Galpao com gradiente
    final barnRect = Rect.fromCenter(
      center: Offset.zero,
      width: barnWidth,
      height: barnHeight,
    );
    final barnPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFE0E0E0), Color(0xFFBDBDBD)],
      ).createShader(barnRect)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(barnRect, const Radius.circular(4)),
      barnPaint,
    );

    // Borda do galpao
    final borderPaint = Paint()
      ..color = AppColors.gray600
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(
      RRect.fromRectAndRadius(barnRect, const Radius.circular(4)),
      borderPaint,
    );

    // Linha central tracejada (cumeeira)
    final dashPaint = Paint()
      ..color = AppColors.gray500
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    const dashCount = 8;
    final dashSpan = barnHeight / (dashCount * 2);
    for (int i = 0; i < dashCount; i++) {
      final y = -barnHeight / 2 + (i * 2 + 0.5) * dashSpan;
      canvas.drawLine(
        Offset(0, y),
        Offset(0, y + dashSpan),
        dashPaint,
      );
    }

    // Indicadores de cortinas (linhas nas laterais)
    final curtinaColor =
        cortinasAbertas ? AppColors.success : AppColors.danger;
    final curtainPaint = Paint()
      ..color = curtinaColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // Cortina esquerda
    canvas.drawLine(
      Offset(-barnWidth / 2 - 2, -barnHeight / 2 + 8),
      Offset(-barnWidth / 2 - 2, barnHeight / 2 - 8),
      curtainPaint,
    );
    // Cortina direita
    canvas.drawLine(
      Offset(barnWidth / 2 + 2, -barnHeight / 2 + 8),
      Offset(barnWidth / 2 + 2, barnHeight / 2 - 8),
      curtainPaint,
    );

    canvas.restore();
  }

  void _drawWindArrow(Canvas canvas, Offset center, double radius) {
    if (ventoVelocidade <= 0) return;

    // Converter direcao meteorologica para angulo do canvas
    // Direcao meteorologica: de onde o vento vem (0=N, 90=L, 180=S, 270=O)
    // Canvas: 0=Leste, pi/2=Sul, pi=Oeste, 3pi/2=Norte
    final windAngle = (ventoDirecao - 90) * math.pi / 180;

    final arrowLength = radius * 0.7;
    final startX = center.dx + arrowLength * math.cos(windAngle);
    final startY = center.dy + arrowLength * math.sin(windAngle);

    // Seta aponta para o centro
    final endX = center.dx + 35 * math.cos(windAngle);
    final endY = center.dy + 35 * math.sin(windAngle);

    final windColor = _getWindColor();
    final arrowPaint = Paint()
      ..color = windColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(startX, startY), Offset(endX, endY), arrowPaint);

    // Ponta da seta
    final arrowAngle = math.atan2(endY - startY, endX - startX);
    final headLength = 10.0;
    final headAngle = 0.4;

    final head1X = endX - headLength * math.cos(arrowAngle - headAngle);
    final head1Y = endY - headLength * math.sin(arrowAngle - headAngle);
    final head2X = endX - headLength * math.cos(arrowAngle + headAngle);
    final head2Y = endY - headLength * math.sin(arrowAngle + headAngle);

    final headPaint = Paint()
      ..color = windColor
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(endX, endY)
      ..lineTo(head1X, head1Y)
      ..lineTo(head2X, head2Y)
      ..close();

    canvas.drawPath(path, headPaint);
  }

  Color _getWindColor() {
    if (ventoVelocidade < 15) return AppColors.success;
    if (ventoVelocidade <= 30) return AppColors.warning;
    return AppColors.danger;
  }

  @override
  bool shouldRepaint(covariant _GalpaoWindSunPainter oldDelegate) {
    return oldDelegate.orientacaoGraus != orientacaoGraus ||
        oldDelegate.ventoVelocidade != ventoVelocidade ||
        oldDelegate.ventoDirecao != ventoDirecao ||
        oldDelegate.temperaturaExterna != temperaturaExterna ||
        oldDelegate.cortinasAbertas != cortinasAbertas;
  }
}
