import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'providers/auth_provider.dart';
import 'providers/task_provider.dart';
import 'services/auth_service.dart';
import 'services/task_service.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final _authService = AuthService();
  final _taskService = TaskService();
  late final AuthProvider _authProvider;
  late final TaskProvider _taskProvider;

  @override
  void initState() {
    super.initState();
    _authProvider = AuthProvider(_authService);
    _taskProvider = TaskProvider(_taskService);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _authProvider),
        ChangeNotifierProvider.value(value: _taskProvider),
      ],
      child: _RouterApp(authProvider: _authProvider),
    );
  }
}

class _RouterApp extends StatefulWidget {
  const _RouterApp({required this.authProvider});

  final AuthProvider authProvider;

  @override
  State<_RouterApp> createState() => _RouterAppState();
}

class _RouterAppState extends State<_RouterApp> {
  late final router = buildRouter(widget.authProvider);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'TaskFlow',
      theme: buildAppTheme(),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
