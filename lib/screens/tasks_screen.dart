import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/task.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(filteredTasksProvider);
    final filter = ref.watch(taskFilterProvider);
    final pending = ref.watch(pendingTasksProvider).length;
    final done = ref.watch(doneTasksProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'subject',
            onPressed: () => _showAddSubjectModal(context, ref),
            backgroundColor: AppColors.accent2,
            mini: true,
            child: const Text('🎓', style: TextStyle(fontSize: 18)),
          ),
          const SizedBox(height: 10),
          FloatingActionButton.extended(
            heroTag: 'task',
            onPressed: () => _showAddTaskModal(context, ref),
            backgroundColor: AppColors.accent,
            icon: const Icon(Icons.add, color: Colors.white),
            label: Text('Nueva tarea',
                style: GoogleFonts.nunito(
                    color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('📋 Tareas',
                  style: GoogleFonts.syne(
                      color: AppColors.text,
                      fontWeight: FontWeight.w800,
                      fontSize: 26)),
              const SizedBox(height: 4),
              Text('$pending pendientes · ${done.length} completadas',
                  style: const TextStyle(color: AppColors.muted, fontSize: 13)),
              const SizedBox(height: 16),

              // Filtros
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: TaskFilter.values.map((f) {
                    final label = switch (f) {
                      TaskFilter.all => 'Todas',
                      TaskFilter.pending => 'Pendientes',
                      TaskFilter.done => 'Completadas',
                    };
                    final selected = f == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () =>
                            ref.read(taskFilterProvider.notifier).state = f,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.accent
                                : AppColors.surface2,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: selected
                                  ? AppColors.accent
                                  : AppColors.border,
                            ),
                          ),
                          child: Text(label,
                              style: GoogleFonts.nunito(
                                color:
                                    selected ? Colors.white : AppColors.muted,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              )),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 16),

              // Botón limpiar completadas
              if (done.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: () {
                      final count = done.length;
                      for (final t in done) {
                        ref.read(tasksProvider.notifier).deleteTask(t.id);
                      }
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                          '🗑️ $count tarea${count > 1 ? "s" : ""} eliminada${count > 1 ? "s" : ""}',
                          style:
                              GoogleFonts.nunito(fontWeight: FontWeight.w700),
                        ),
                        backgroundColor: AppColors.surface,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: AppColors.danger),
                        ),
                      ));
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.danger.withOpacity(.1),
                        borderRadius: BorderRadius.circular(10),
                        border:
                            Border.all(color: AppColors.danger.withOpacity(.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.delete_sweep_outlined,
                              color: AppColors.danger, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            'Limpiar completadas (${done.length})',
                            style: GoogleFonts.nunito(
                                color: AppColors.danger,
                                fontWeight: FontWeight.w700,
                                fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              Expanded(
                child: tasks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('📭', style: TextStyle(fontSize: 48)),
                            const SizedBox(height: 12),
                            Text('No hay tareas todavía',
                                style: GoogleFonts.syne(
                                    color: AppColors.muted, fontSize: 15)),
                            const SizedBox(height: 6),
                            const Text('Tocá el botón para agregar una',
                                style: TextStyle(
                                    color: AppColors.muted, fontSize: 12)),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: tasks.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, i) => _TaskTile(task: tasks[i]),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddTaskModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddTaskSheet(ref: ref),
    );
  }

  void _showAddSubjectModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddSubjectSheet(ref: ref),
    );
  }
}

// ── Task tile ─────────────────────────────────────────────────────────────────

class _TaskTile extends ConsumerWidget {
  final Task task;
  const _TaskTile({required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjects = ref.watch(subjectsProvider);
    final sub = subjects.firstWhere(
      (s) => s.id == task.subjectId,
      orElse: () => subjects.first,
    );

    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.danger.withOpacity(.2),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_outline, color: AppColors.danger),
      ),
      onDismissed: (_) => ref.read(tasksProvider.notifier).deleteTask(task.id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface2,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => ref.read(tasksProvider.notifier).toggleDone(task.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: task.done ? AppColors.accent3 : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: task.done ? AppColors.accent3 : AppColors.border,
                    width: 2,
                  ),
                ),
                child: task.done
                    ? const Icon(Icons.check,
                        size: 14, color: Color(0xFF0D0F18))
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(task.name,
                      style: GoogleFonts.nunito(
                        color: task.done ? AppColors.muted : AppColors.text,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        decoration:
                            task.done ? TextDecoration.lineThrough : null,
                      )),
                  const SizedBox(height: 4),
                  Row(children: [
                    Text('${sub.emoji} ${sub.name}',
                        style: TextStyle(
                            color: Color(sub.colorValue),
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                    if (task.deadline.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Text('📅 ${task.deadline}',
                          style: const TextStyle(
                              color: AppColors.muted, fontSize: 11)),
                    ],
                  ]),
                ],
              ),
            ),
            const SizedBox(width: 8),
            PriorityBadge(task.priority.key),
          ],
        ),
      ),
    );
  }
}

// ── Add Task Sheet ────────────────────────────────────────────────────────────

class _AddTaskSheet extends ConsumerStatefulWidget {
  final WidgetRef ref;
  const _AddTaskSheet({required this.ref});

  @override
  ConsumerState<_AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends ConsumerState<_AddTaskSheet> {
  final _ctrl = TextEditingController();
  String _subjectId = '';
  String _deadline = '';
  Priority _priority = Priority.medium;

  @override
  void initState() {
    super.initState();
    final subjects = ref.read(subjectsProvider);
    if (subjects.isNotEmpty) _subjectId = subjects.first.id;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_ctrl.text.trim().isEmpty || _subjectId.isEmpty) return;
    ref.read(tasksProvider.notifier).addTask(
          name: _ctrl.text.trim(),
          subjectId: _subjectId,
          deadline: _deadline,
          priority: _priority,
        );
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('📝 Tarea creada! +20 XP',
          style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
      backgroundColor: AppColors.surface,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.accent),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final subjects = ref.watch(subjectsProvider);

    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          Text('✏️ Nueva Tarea',
              style: GoogleFonts.syne(
                  color: AppColors.text,
                  fontWeight: FontWeight.w800,
                  fontSize: 20)),
          const SizedBox(height: 20),
          TextField(
            controller: _ctrl,
            autofocus: true,
            style: const TextStyle(color: AppColors.text),
            decoration: const InputDecoration(
                labelText: 'Nombre', hintText: 'ej: Estudiar derivadas...'),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            value: _subjectId.isEmpty ? null : _subjectId,
            dropdownColor: AppColors.surface2,
            decoration: const InputDecoration(labelText: 'Materia'),
            style: const TextStyle(color: AppColors.text, fontSize: 14),
            items: subjects
                .map((s) => DropdownMenuItem(
                    value: s.id, child: Text('${s.emoji} ${s.name}')))
                .toList(),
            onChanged: (v) => setState(() => _subjectId = v!),
          ),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  final d = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 3)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    builder: (ctx, child) => Theme(
                      data: ThemeData.dark().copyWith(
                          colorScheme: const ColorScheme.dark(
                              primary: AppColors.accent)),
                      child: child!,
                    ),
                  );
                  if (d != null) {
                    setState(() => _deadline =
                        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}');
                  }
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.surface2,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    _deadline.isEmpty ? '📅 Fecha límite' : '📅 $_deadline',
                    style: TextStyle(
                        color: _deadline.isEmpty
                            ? AppColors.muted
                            : AppColors.text,
                        fontSize: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: DropdownButtonFormField<Priority>(
                value: _priority,
                dropdownColor: AppColors.surface2,
                decoration: const InputDecoration(labelText: 'Prioridad'),
                style: const TextStyle(color: AppColors.text, fontSize: 13),
                items: const [
                  DropdownMenuItem(
                      value: Priority.high, child: Text('🔥 Alta')),
                  DropdownMenuItem(
                      value: Priority.medium, child: Text('⚡ Media')),
                  DropdownMenuItem(value: Priority.low, child: Text('🌿 Baja')),
                ],
                onChanged: (v) => setState(() => _priority = v!),
              ),
            ),
          ]),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: Text('Agregar tarea',
                  style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w700, fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Add Subject Sheet ─────────────────────────────────────────────────────────

const _kEmojis = [
  '📐',
  '⚛️',
  '📜',
  '🌐',
  '🧬',
  '📚',
  '🎨',
  '🎵',
  '💻',
  '🏃',
  '🍎',
  '🌍',
  '🔬',
  '📊',
  '🎭',
  '✏️',
  '🏛️',
  '🧮',
  '🗣️',
  '🎯',
];

const _kColors = [
  0xFF7C6AF7,
  0xFF6AF7B8,
  0xFFF7C26A,
  0xFFF76A6A,
  0xFFC26AF7,
  0xFF6AB8F7,
  0xFFf76ab8,
  0xFF6af7e0,
  0xFFf7a96a,
  0xFF98f76a,
];

class _AddSubjectSheet extends ConsumerStatefulWidget {
  final WidgetRef ref;
  const _AddSubjectSheet({required this.ref});

  @override
  ConsumerState<_AddSubjectSheet> createState() => _AddSubjectSheetState();
}

class _AddSubjectSheetState extends ConsumerState<_AddSubjectSheet> {
  final _ctrl = TextEditingController();
  String _emoji = '📐';
  int _color = 0xFF7C6AF7;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_ctrl.text.trim().isEmpty) return;
    ref.read(subjectsProvider.notifier).addSubject(
          name: _ctrl.text.trim(),
          emoji: _emoji,
          colorValue: _color,
        );
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('🎓 Materia creada!',
          style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
      backgroundColor: AppColors.surface,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.accent2),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          Text('🎓 Nueva Materia',
              style: GoogleFonts.syne(
                  color: AppColors.text,
                  fontWeight: FontWeight.w800,
                  fontSize: 20)),
          const SizedBox(height: 20),

          TextField(
            controller: _ctrl,
            autofocus: true,
            style: const TextStyle(color: AppColors.text),
            decoration: const InputDecoration(
                labelText: 'Nombre', hintText: 'ej: Química...'),
            onSubmitted: (_) => _submit(),
            onChanged: (_) => setState(() {}),
          ),

          const SizedBox(height: 16),

          Text('Ícono',
              style: GoogleFonts.nunito(
                  color: AppColors.muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _kEmojis.map((e) {
              final selected = e == _emoji;
              return GestureDetector(
                onTap: () => setState(() => _emoji = e),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.accent.withOpacity(.2)
                        : AppColors.surface2,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selected ? AppColors.accent : AppColors.border,
                      width: selected ? 2 : 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(e, style: const TextStyle(fontSize: 20)),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          Text('Color',
              style: GoogleFonts.nunito(
                  color: AppColors.muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _kColors.map((c) {
              final selected = c == _color;
              return GestureDetector(
                onTap: () => setState(() => _color = c),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Color(c),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? Colors.white : Colors.transparent,
                      width: 3,
                    ),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                                color: Color(c).withOpacity(.5), blurRadius: 8)
                          ]
                        : [],
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Preview
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Color(_color).withOpacity(.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Color(_color).withOpacity(.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(
                  _ctrl.text.isEmpty ? 'Vista previa' : _ctrl.text,
                  style: TextStyle(
                      color: Color(_color),
                      fontWeight: FontWeight.w700,
                      fontSize: 14),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent2,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: Text('Crear materia',
                  style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w700, fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }
}
