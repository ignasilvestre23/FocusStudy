import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/task.dart';

final sharedPrefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Inicializar con ProviderScope override');
});

// ══════════════════════════════════════════════════════════════════════════════
// SUBJECTS
// ══════════════════════════════════════════════════════════════════════════════

class SubjectsNotifier extends Notifier<List<Subject>> {
  static const _key = 'subjects_v1';
  SharedPreferences get _prefs => ref.read(sharedPrefsProvider);

  @override
  List<Subject> build() {
    final raw = _prefs.getStringList(_key);
    if (raw == null || raw.isEmpty) return List.from(kDefaultSubjects);
    return raw.map(Subject.fromJson).toList();
  }

  void _persist() {
    _prefs.setStringList(_key, state.map((s) => s.toJson()).toList());
  }

  void addSubject({
    required String name,
    required String emoji,
    required int colorValue,
  }) {
    final subject = Subject(
      id: const Uuid().v4(),
      name: name,
      emoji: emoji,
      colorValue: colorValue,
    );
    state = [...state, subject];
    _persist();
  }

  void deleteSubject(String id) {
    state = state.where((s) => s.id != id).toList();
    _persist();
  }

  Subject getById(String id) =>
      state.firstWhere((s) => s.id == id, orElse: () => state.first);
}

final subjectsProvider =
    NotifierProvider<SubjectsNotifier, List<Subject>>(SubjectsNotifier.new);

// ══════════════════════════════════════════════════════════════════════════════
// TASKS
// ══════════════════════════════════════════════════════════════════════════════

class TasksNotifier extends Notifier<List<Task>> {
  static const _key = 'tasks_v2';
  SharedPreferences get _prefs => ref.read(sharedPrefsProvider);

  @override
  List<Task> build() {
    final raw = _prefs.getStringList(_key);
    if (raw == null || raw.isEmpty) return [];
    return raw.map(Task.fromJson).toList();
  }

  void _persist() {
    _prefs.setStringList(_key, state.map((t) => t.toJson()).toList());
  }

  void addTask({
    required String name,
    required String subjectId,
    required String deadline,
    required Priority priority,
  }) {
    final task = Task(
      id: const Uuid().v4(),
      name: name,
      subjectId: subjectId,
      deadline: deadline,
      priority: priority,
    );
    state = [...state, task];
    _persist();
    ref.read(xpProvider.notifier).add(20);
  }

  void toggleDone(String id) {
    state = state.map((t) {
      if (t.id != id) return t;
      final updated = t.copyWith(done: !t.done);
      if (updated.done) ref.read(xpProvider.notifier).add(50);
      return updated;
    }).toList();
    _persist();
  }

  void deleteTask(String id) {
    state = state.where((t) => t.id != id).toList();
    _persist();
  }
}

final tasksProvider =
    NotifierProvider<TasksNotifier, List<Task>>(TasksNotifier.new);

final pendingTasksProvider = Provider<List<Task>>(
  (ref) => ref.watch(tasksProvider).where((t) => !t.done).toList(),
);
final doneTasksProvider = Provider<List<Task>>(
  (ref) => ref.watch(tasksProvider).where((t) => t.done).toList(),
);

// ══════════════════════════════════════════════════════════════════════════════
// XP & LEVEL
// ══════════════════════════════════════════════════════════════════════════════

class XpNotifier extends Notifier<int> {
  static const _key = 'xp_v2';
  SharedPreferences get _prefs => ref.read(sharedPrefsProvider);

  @override
  int build() => _prefs.getInt(_key) ?? 0;

  void add(int amount) {
    state = state + amount;
    _prefs.setInt(_key, state);
  }
}

final xpProvider = NotifierProvider<XpNotifier, int>(XpNotifier.new);

final levelProvider =
    Provider<int>((ref) => (ref.watch(xpProvider) ~/ 300) + 1);

final xpForNextLevelProvider =
    Provider<int>((ref) => ref.watch(levelProvider) * 300);

final xpProgressProvider = Provider<double>((ref) {
  final xp = ref.watch(xpProvider);
  final needed = ref.watch(xpForNextLevelProvider);
  return (xp / needed).clamp(0.0, 1.0);
});

// ══════════════════════════════════════════════════════════════════════════════
// STREAK
// ══════════════════════════════════════════════════════════════════════════════

class StreakNotifier extends Notifier<int> {
  static const _key = 'streak_v2';
  SharedPreferences get _prefs => ref.read(sharedPrefsProvider);

  @override
  int build() => _prefs.getInt(_key) ?? 0;

  void increment() {
    state = state + 1;
    _prefs.setInt(_key, state);
  }
}

final streakProvider =
    NotifierProvider<StreakNotifier, int>(StreakNotifier.new);

// ══════════════════════════════════════════════════════════════════════════════
// POMODORO
// ══════════════════════════════════════════════════════════════════════════════

enum PomodoroPhase { study, breakTime }

class PomodoroState {
  final int remainingSeconds;
  final PomodoroPhase phase;
  final bool running;
  final int round;
  final int sessionsToday;

  const PomodoroState({
    required this.remainingSeconds,
    required this.phase,
    required this.running,
    required this.round,
    required this.sessionsToday,
  });

  static const studyDuration = 25 * 60;
  static const breakDuration = 5 * 60;

  int get totalSeconds =>
      phase == PomodoroPhase.study ? studyDuration : breakDuration;

  double get progress => remainingSeconds / totalSeconds;

  String get formattedTime {
    final m = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (remainingSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  PomodoroState copyWith({
    int? remainingSeconds,
    PomodoroPhase? phase,
    bool? running,
    int? round,
    int? sessionsToday,
  }) =>
      PomodoroState(
        remainingSeconds: remainingSeconds ?? this.remainingSeconds,
        phase: phase ?? this.phase,
        running: running ?? this.running,
        round: round ?? this.round,
        sessionsToday: sessionsToday ?? this.sessionsToday,
      );
}

class PomodoroNotifier extends Notifier<PomodoroState> {
  static const _sessionsKey = 'sessions_v2';
  SharedPreferences get _prefs => ref.read(sharedPrefsProvider);
  final _player = AudioPlayer();

  @override
  PomodoroState build() => PomodoroState(
        remainingSeconds: PomodoroState.studyDuration,
        phase: PomodoroPhase.study,
        running: false,
        round: 1,
        sessionsToday: _prefs.getInt(_sessionsKey) ?? 0,
      );

  void toggle() {
    if (state.running) {
      state = state.copyWith(running: false);
    } else {
      state = state.copyWith(running: true);
      _tick();
    }
  }

  void _tick() async {
    await Future.delayed(const Duration(seconds: 1));
    if (!state.running) return;

    if (state.remainingSeconds <= 1) {
      _onPhaseComplete();
      return;
    }

    state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
    _tick();
  }

  void _onPhaseComplete() async {
    await _player.play(AssetSource('sounds/alarm.mp3'));

    if (state.phase == PomodoroPhase.study) {
      final newSessions = state.sessionsToday + 1;
      _prefs.setInt(_sessionsKey, newSessions);
      ref.read(xpProvider.notifier).add(100);
      state = state.copyWith(
        phase: PomodoroPhase.breakTime,
        remainingSeconds: PomodoroState.breakDuration,
        running: false,
        sessionsToday: newSessions,
      );
    } else {
      state = state.copyWith(
        phase: PomodoroPhase.study,
        remainingSeconds: PomodoroState.studyDuration,
        running: false,
        round: state.round + 1,
      );
    }
  }

  void reset() {
    state = state.copyWith(
      remainingSeconds: PomodoroState.studyDuration,
      phase: PomodoroPhase.study,
      running: false,
      round: 1,
    );
  }
}

final pomodoroProvider =
    NotifierProvider<PomodoroNotifier, PomodoroState>(PomodoroNotifier.new);

final weeklyHoursProvider = Provider<List<double>>(
  (_) => [0, 0, 0, 0, 0, 0, 0],
);

// ══════════════════════════════════════════════════════════════════════════════
// TASK FILTER
// ══════════════════════════════════════════════════════════════════════════════

enum TaskFilter { all, pending, done }

final taskFilterProvider = StateProvider<TaskFilter>((_) => TaskFilter.all);

final filteredTasksProvider = Provider<List<Task>>((ref) {
  final filter = ref.watch(taskFilterProvider);
  final tasks = ref.watch(tasksProvider);
  return switch (filter) {
    TaskFilter.pending => tasks.where((t) => !t.done).toList(),
    TaskFilter.done => tasks.where((t) => t.done).toList(),
    _ => tasks,
  };
});
