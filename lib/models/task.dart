import 'dart:convert';
import 'package:equatable/equatable.dart';

enum Priority { high, medium, low }

extension PriorityExt on Priority {
  String get label {
    switch (this) {
      case Priority.high:
        return '🔥 Alta';
      case Priority.medium:
        return '⚡ Media';
      case Priority.low:
        return '🌿 Baja';
    }
  }

  String get key {
    switch (this) {
      case Priority.high:
        return 'high';
      case Priority.medium:
        return 'medium';
      case Priority.low:
        return 'low';
    }
  }

  static Priority fromKey(String k) {
    switch (k) {
      case 'high':
        return Priority.high;
      case 'medium':
        return Priority.medium;
      default:
        return Priority.low;
    }
  }
}

class Task extends Equatable {
  final String id;
  final String name;
  final String subjectId;
  final String deadline;
  final Priority priority;
  final bool done;

  const Task({
    required this.id,
    required this.name,
    required this.subjectId,
    required this.deadline,
    required this.priority,
    this.done = false,
  });

  Task copyWith({bool? done}) => Task(
        id: id,
        name: name,
        subjectId: subjectId,
        deadline: deadline,
        priority: priority,
        done: done ?? this.done,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'subjectId': subjectId,
        'deadline': deadline,
        'priority': priority.key,
        'done': done,
      };

  factory Task.fromMap(Map<String, dynamic> m) => Task(
        id: m['id'],
        name: m['name'],
        subjectId: m['subjectId'],
        deadline: m['deadline'],
        priority: PriorityExt.fromKey(m['priority'] ?? 'medium'),
        done: m['done'] ?? false,
      );

  String toJson() => jsonEncode(toMap());
  factory Task.fromJson(String s) => Task.fromMap(jsonDecode(s));

  @override
  List<Object?> get props => [id, name, subjectId, deadline, priority, done];
}

// ── Subject ───────────────────────────────────────────────────────────────────

class Subject extends Equatable {
  final String id;
  final String name;
  final String emoji;
  final int colorValue;

  const Subject({
    required this.id,
    required this.name,
    required this.emoji,
    required this.colorValue,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'emoji': emoji,
        'colorValue': colorValue,
      };

  factory Subject.fromMap(Map<String, dynamic> m) => Subject(
        id: m['id'],
        name: m['name'],
        emoji: m['emoji'],
        colorValue: m['colorValue'],
      );

  String toJson() => jsonEncode(toMap());
  factory Subject.fromJson(String s) => Subject.fromMap(jsonDecode(s));

  @override
  List<Object?> get props => [id, name, emoji, colorValue];
}

// Materias por defecto
const kDefaultSubjects = <Subject>[
  Subject(id: 'mat', name: 'Matemática', emoji: '📐', colorValue: 0xFF7C6AF7),
  Subject(id: 'fis', name: 'Física', emoji: '⚛️', colorValue: 0xFF6AF7B8),
  Subject(id: 'his', name: 'Historia', emoji: '📜', colorValue: 0xFFF7C26A),
  Subject(id: 'ing', name: 'Inglés', emoji: '🌐', colorValue: 0xFFF76A6A),
  Subject(id: 'bio', name: 'Biología', emoji: '🧬', colorValue: 0xFFC26AF7),
  Subject(id: 'lit', name: 'Literatura', emoji: '📚', colorValue: 0xFF6AB8F7),
];
