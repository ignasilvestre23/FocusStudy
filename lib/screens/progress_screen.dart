import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

const _days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final xp = ref.watch(xpProvider);
    final level = ref.watch(levelProvider);
    final xpNeeded = ref.watch(xpForNextLevelProvider);
    final progress = ref.watch(xpProgressProvider);
    final streak = ref.watch(streakProvider);
    final pomo = ref.watch(pomodoroProvider);
    final tasks = ref.watch(tasksProvider);
    final subjects = ref.watch(subjectsProvider);
    final weeklyHours = ref.watch(weeklyHoursProvider);
    final totalHours = weeklyHours.fold(0.0, (a, b) => a + b);

    final subjectStats = subjects
        .map((s) {
          final total = tasks.where((t) => t.subjectId == s.id).length;
          final done = tasks.where((t) => t.subjectId == s.id && t.done).length;
          return (subject: s, total: total, done: done);
        })
        .where((e) => e.total > 0)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('📊 Progreso',
                  style: GoogleFonts.syne(
                      color: AppColors.text,
                      fontWeight: FontWeight.w800,
                      fontSize: 26)),
              const SizedBox(height: 4),
              const Text('Esta semana',
                  style: TextStyle(color: AppColors.muted, fontSize: 13)),
              const SizedBox(height: 20),

              Row(children: [
                Expanded(
                    child: StatCard(
                        icon: '⏱️',
                        value: '${totalHours.toStringAsFixed(1)}h',
                        label: 'Horas')),
                const SizedBox(width: 10),
                Expanded(
                    child: StatCard(
                        icon: '🔥',
                        value: '$streak',
                        label: 'Racha',
                        valueColor: AppColors.accent2)),
                const SizedBox(width: 10),
                Expanded(
                    child: StatCard(
                        icon: '⭐',
                        value: '$xp',
                        label: 'XP',
                        valueColor: AppColors.accent)),
              ]),

              const SizedBox(height: 16),

              // Gráfico
              FSCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FSCardTitle('Horas por día'),
                    SizedBox(
                      height: 140,
                      child: BarChart(BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: weeklyHours.reduce((a, b) => a > b ? a : b) + 0.5,
                        barTouchData: BarTouchData(enabled: false),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (v, _) => Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(_days[v.toInt()],
                                    style: GoogleFonts.dmMono(
                                        color: AppColors.muted, fontSize: 10)),
                              ),
                            ),
                          ),
                          leftTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        gridData: FlGridData(
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (_) =>
                              FlLine(color: AppColors.border, strokeWidth: 1),
                        ),
                        barGroups: weeklyHours.asMap().entries.map((e) {
                          final isMax = e.value ==
                              weeklyHours.reduce((a, b) => a > b ? a : b);
                          return BarChartGroupData(x: e.key, barRods: [
                            BarChartRodData(
                              toY: e.value,
                              color: isMax
                                  ? AppColors.accent
                                  : AppColors.accent.withOpacity(.3),
                              width: 22,
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(6)),
                            ),
                          ]);
                        }).toList(),
                      )),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // XP
              FSCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FSCardTitle('Nivel y XP'),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Nivel $level',
                            style: GoogleFonts.syne(
                                color: AppColors.text,
                                fontWeight: FontWeight.w700,
                                fontSize: 15)),
                        Text('$xp / $xpNeeded XP',
                            style: GoogleFonts.dmMono(
                                color: AppColors.accent, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    FSProgressBar(value: progress),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Por materia
              if (subjectStats.isNotEmpty)
                FSCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const FSCardTitle('Por materia'),
                      ...subjectStats.map((e) {
                        final pct = e.total > 0 ? e.done / e.total : 0.0;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Column(children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${e.subject.emoji} ${e.subject.name}',
                                    style: GoogleFonts.nunito(
                                        color: AppColors.text,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13)),
                                Text('${e.done}/${e.total}',
                                    style: const TextStyle(
                                        color: AppColors.muted, fontSize: 12)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            FSProgressBar(
                                value: pct, color: Color(e.subject.colorValue)),
                          ]),
                        );
                      }),
                    ],
                  ),
                ),

              const SizedBox(height: 14),

              FSCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FSCardTitle('🍅 Sesiones totales'),
                    Text('${pomo.sessionsToday}',
                        style: GoogleFonts.syne(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w800,
                            fontSize: 42)),
                    Text(
                      '≈ ${(pomo.sessionsToday * 25 / 60).toStringAsFixed(1)} horas concentrado',
                      style:
                          const TextStyle(color: AppColors.muted, fontSize: 13),
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
