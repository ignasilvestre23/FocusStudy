import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final xp = ref.watch(xpProvider);
    final level = ref.watch(levelProvider);
    final xpNeeded = ref.watch(xpForNextLevelProvider);
    final progress = ref.watch(xpProgressProvider);
    final streak = ref.watch(streakProvider);
    final sessions = ref.watch(pomodoroProvider).sessionsToday;
    final done = ref.watch(doneTasksProvider).length;
    final pending = ref.watch(pendingTasksProvider).length;

    final mascot = streak >= 7
        ? '🐲'
        : streak >= 3
            ? '🐥'
            : '🥚';
    final mascotName = streak >= 7
        ? 'Dragon Focus'
        : streak >= 3
            ? 'Pichón Pro'
            : 'Huevo Zen';
    final mascotMood = streak >= 7
        ? '¡Imparable! 🔥'
        : streak >= 3
            ? '¡Vas muy bien!'
            : 'Empecemos 🌱';

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('¡Buenas! 👋',
                  style: GoogleFonts.syne(
                      color: AppColors.text,
                      fontWeight: FontWeight.w800,
                      fontSize: 26)),
              const SizedBox(height: 4),
              Text('$pending tareas pendientes hoy',
                  style: const TextStyle(color: AppColors.muted, fontSize: 13)),
              const SizedBox(height: 20),
              XpBar(
                  level: level, xp: xp, xpNeeded: xpNeeded, progress: progress),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                      child: StatCard(
                          icon: '✅', value: '$done', label: 'Completadas')),
                  const SizedBox(width: 10),
                  Expanded(
                      child: StatCard(
                          icon: '🍅', value: '$sessions', label: 'Pomodoros')),
                  const SizedBox(width: 10),
                  Expanded(
                      child: StatCard(
                          icon: '📋', value: '$pending', label: 'Pendientes')),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mascota
                  Expanded(
                    child: FSCard(
                      child: Column(
                        children: [
                          const FSCardTitle('Tu Mascota'),
                          Text(mascot, style: const TextStyle(fontSize: 60)),
                          const SizedBox(height: 8),
                          Text(mascotName,
                              style: GoogleFonts.syne(
                                  color: AppColors.accent2,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13)),
                          Text(mascotMood,
                              style: const TextStyle(
                                  color: AppColors.muted, fontSize: 12)),
                          const SizedBox(height: 8),
                          Text('Crece con tu racha 🌱',
                              style: const TextStyle(
                                  color: AppColors.muted, fontSize: 11)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Streak
                  Expanded(
                    child: FSCard(
                      borderColor: const Color(0x33F7C26A),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const FSCardTitle('Racha'),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [
                                Color(0x11F7C26A),
                                Color(0x11F7946A),
                              ]),
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: const Color(0x33F7C26A)),
                            ),
                            child: Row(
                              children: [
                                const Text('🔥',
                                    style: TextStyle(fontSize: 26)),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('$streak días',
                                        style: GoogleFonts.syne(
                                            color: AppColors.accent2,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 20)),
                                    const Text('¡Seguí así!',
                                        style: TextStyle(
                                            color: AppColors.muted,
                                            fontSize: 11)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            '🎯 7 días = dragon\n🏅 30 días = Élite',
                            style: TextStyle(
                                color: AppColors.muted,
                                fontSize: 11,
                                height: 1.7),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              FSCard(
                borderColor: AppColors.accent.withOpacity(.3),
                child: Row(
                  children: [
                    const Text('💡', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tip del día',
                              style: GoogleFonts.syne(
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13)),
                          const SizedBox(height: 4),
                          const Text(
                            'Estudiá en bloques de 25 min y tomá descansos. ¡Tu cerebro lo agradece!',
                            style: TextStyle(
                                color: AppColors.muted,
                                fontSize: 12,
                                height: 1.5),
                          ),
                        ],
                      ),
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
