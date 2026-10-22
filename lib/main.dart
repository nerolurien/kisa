import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'core/supabase_client.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/presentation/auth_screen.dart';
import 'features/auth/presentation/pairing_screen.dart';
import 'features/navigation/presentation/main_navigation_scaffold.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize locale date formatting for Indonesian ('id_ID')
  await initializeDateFormatting('id_ID', null);

  // Load environment variables (.env) if present
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('Note: .env file not loaded: $e');
  }

  // Edge-to-edge spatial system UI overlay
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize central Supabase BaaS Client
  await KisaSupabaseClient().initialize();

  runApp(
    const ProviderScope(
      child: KisaApp(),
    ),
  );
}

class KisaApp extends ConsumerWidget {
  const KisaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return MaterialApp(
      title: 'Kisa',
      debugShowCheckedModeBanner: false,
      theme: KisaTheme.lightTheme,
      home: _determineHomeScreen(authState),
    );
  }

  Widget _determineHomeScreen(AuthState state) {
    if (state.isLoading) {
      return const Scaffold(
        backgroundColor: KisaColors.background,
        body: Center(
          child: CircularProgressIndicator(
            color: KisaColors.primaryRose,
            strokeWidth: 2.4,
          ),
        ),
      );
    }

    if (state.user == null) {
      return const AuthScreen();
    }

    if (!state.isPaired) {
      return const PairingScreen();
    }

    return const MainNavigationScaffold();
  }
}
