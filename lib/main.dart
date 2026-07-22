import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'providers/providers.dart';
import 'screens/home_screen.dart';
import 'screens/tasks_screen.dart';
import 'screens/pomodoro_screen.dart';
import 'screens/progress_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPrefsProvider.overrideWithValue(prefs),
      ],
      child: const FocusStudyApp(),
    ),
  );
}

class FocusStudyApp extends StatelessWidget {
  const FocusStudyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FocusStudy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const MainShell(),
    );
  }
}

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _index = 0;

  static const _pages = [
    HomeScreen(),
    TasksScreen(),
    PomodoroScreen(),
    ProgressScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: BottomNavigationBar(
          currentIndex: _index,
          onTap: (i) => setState(() => _index = i),
          items: const [
            BottomNavigationBarItem(
                icon: Text('🏠', style: TextStyle(fontSize: 22)),
                label: 'Inicio'),
            BottomNavigationBarItem(
                icon: Text('📋', style: TextStyle(fontSize: 22)),
                label: 'Tareas'),
            BottomNavigationBarItem(
                icon: Text('⏱️', style: TextStyle(fontSize: 22)),
                label: 'Timer'),
            BottomNavigationBarItem(
                icon: Text('📊', style: TextStyle(fontSize: 22)),
                label: 'Progreso'),
          ],
          selectedLabelStyle:
              GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 11),
          unselectedLabelStyle:
              GoogleFonts.nunito(fontWeight: FontWeight.w600, fontSize: 11),
        ),
      ),
    );
  }
}
