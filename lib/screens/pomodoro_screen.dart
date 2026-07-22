import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

class PomodoroScreen extends ConsumerWidget {
  const PomodoroScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pomo = ref.watch(pomodoroProvider);
    final notifier = ref.read(pomodoroProvider.notifier);
    final isStudy = pomo.phase == PomodoroPhase.study;
    final color = isStudy ? AppColors.accent : AppColors.accent3;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('⏱️ Pomodoro',
                  style: GoogleFonts.syne(
                      color: AppColors.text,
                      fontWeight: FontWeight.w800,
                      fontSize: 26)),
              const SizedBox(height: 4),
              Text('Técnica 25/5 · Ronda #${pomo.round}',
                  style: const TextStyle(color: AppColors.muted, fontSize: 13)),
              const SizedBox(height: 32),

              // Ring timer
              Center(
                child: SizedBox(
                  width: 220,
                  height: 220,
                  child: CustomPaint(
                    painter:
                        _RingPainter(progress: pomo.progress, color: color),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(pomo.formattedTime,
                            style: GoogleFonts.dmMono(
                                color: AppColors.text,
                                fontWeight: FontWeight.w500,
                                fontSize: 48,
                                letterSpacing: -2)),
                        const SizedBox(height: 4),
                        Text(isStudy ? 'ESTUDIO' : 'DESCANSO',
                            style: GoogleFonts.dmMono(
                                color: AppColors.muted,
                                fontSize: 11,
                                letterSpacing: 2)),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color.withOpacity(.4)),
                  ),
                  child: Text(
                    isStudy ? '🧠 Modo estudio' : '☕ Descansando',
                    style: GoogleFonts.nunito(
                        color: color,
                        fontWeight: FontWeight.w700,
                        fontSize: 13),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: notifier.reset,
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.surface2,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(Icons.replay_rounded,
                          color: AppColors.muted, size: 22),
                    ),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: notifier.toggle,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 130,
                      height: 56,
                      decoration: BoxDecoration(
                        color:
                            pomo.running ? AppColors.danger : AppColors.accent,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: (pomo.running
                                    ? AppColors.danger
                                    : AppColors.accent)
                                .withOpacity(.4),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        pomo.running ? '⏸ Pausar' : '▶ Iniciar',
                        style: GoogleFonts.nunito(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              FSCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FSCardTitle('Sesiones de hoy'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(8, (i) {
                        final filled = i < pomo.sessionsToday;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color:
                                filled ? AppColors.accent : AppColors.surface2,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color:
                                  filled ? AppColors.accent : AppColors.border,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(filled ? '🍅' : '',
                              style: const TextStyle(fontSize: 18)),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  const _RingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 10;
    const sw = 10.0;

    canvas.drawCircle(
        c,
        r,
        Paint()
          ..color = AppColors.surface2
          ..style = PaintingStyle.stroke
          ..strokeWidth = sw);

    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = sw
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color;
}
