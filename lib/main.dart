  import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';
import 'screens/main_screen.dart';
import 'theme/app_theme.dart';
import 'services/notification_service.dart';
  import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().initialize();
  // Initialize locale data for Intl (used for Swedish date formatting)
  await initializeDateFormatting('sv');
  runApp(const LivsstilApp());
}

class LivsstilApp extends StatelessWidget {
  const LivsstilApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState()..loadData(),
      child: Consumer<AppState>(
        builder: (context, state, _) {
          return MaterialApp(
            title: 'Livsstil',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: state.themeMode,
            home: const MainScreen(),
          );
        },
      ),
    );
  }
}
