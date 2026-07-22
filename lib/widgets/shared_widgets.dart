import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class FSCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? borderColor;

  const FSCard(
      {super.key, required this.child, this.padding, this.borderColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor ?? AppColors.border),
      ),
      child: child,
    );
  }
}

class FSCardTitle extends StatelessWidget {
  final String title;
  const FSCardTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.dmMono(
          color: AppColors.muted,
          fontSize: 10,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String icon;
  final String value;
  final String label;
  final Color? valueColor;

  const StatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.syne(
              color: valueColor ?? AppColors.text,
              fontWeight: FontWeight.w800,
              fontSize: 26,
            ),
          ),
          Text(label,
              style: const TextStyle(color: AppColors.muted, fontSize: 11)),
        ],
      ),
    );
  }
}

class FSProgressBar extends StatelessWidget {
  final double value;
  final Color color;
  final double height;

  const FSProgressBar({
    super.key,
    required this.value,
    this.color = AppColors.accent,
    this.height = 8,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: LinearProgressIndicator(
        value: value.clamp(0.0, 1.0),
        minHeight: height,
        backgroundColor: AppColors.surface2,
        valueColor: AlwaysStoppedAnimation(color),
      ),
    );
  }
}

class PriorityBadge extends StatelessWidget {
  final String priority;
  const PriorityBadge(this.priority, {super.key});

  @override
  Widget build(BuildContext context) {
    final data = switch (priority) {
      'high' => ('🔥 Alta', AppColors.danger, const Color(0x22F76A6A)),
      'medium' => ('⚡ Media', AppColors.accent2, const Color(0x22F7C26A)),
      _ => ('🌿 Baja', AppColors.accent3, const Color(0x226AF7B8)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: data.$3,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: data.$2.withOpacity(.4)),
      ),
      child: Text(
        data.$1,
        style: GoogleFonts.nunito(
            color: data.$2, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class XpBar extends StatelessWidget {
  final int level;
  final int xp;
  final int xpNeeded;
  final double progress;

  const XpBar({
    super.key,
    required this.level,
    required this.xp,
    required this.xpNeeded,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withOpacity(.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              '$level',
              style: GoogleFonts.syne(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 18),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nivel $level · Estudiante Épico',
                    style:
                        const TextStyle(color: AppColors.muted, fontSize: 11)),
                const SizedBox(height: 6),
                FSProgressBar(value: progress),
                const SizedBox(height: 4),
                Text('$xp / $xpNeeded XP',
                    style: GoogleFonts.dmMono(
                        color: AppColors.accent, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
