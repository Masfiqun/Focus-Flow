import 'package:flutter/material.dart';

import 'screens/main_screen.dart';
import 'services/focus_session_storage_service.dart';
import 'services/task_storage_service.dart';
import 'theme/app_theme.dart';

/// Global route observer used by screens that need to
/// refresh when they become visible again.
final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await TaskStorageService.init();
  await FocusSessionStorageService.init();

  runApp(const FocusFlowApp());
}

class FocusFlowApp extends StatelessWidget {
  const FocusFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FocusFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,

      navigatorObservers: [
        routeObserver,
      ],

      home: const MainScreen(),
    );
  }
}

