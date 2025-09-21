import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/app_config.dart';
import 'data/api/api_client.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/menu_repository.dart';
import 'data/repositories/order_repository.dart';
import 'viewmodels/auth_view_model.dart';
import 'viewmodels/home_view_model.dart';
import 'viewmodels/pos_view_model.dart';
import 'views/auth/login_view.dart';
import 'views/home/home_view.dart';
import 'views/pos/pos_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Change this to your server URL (see PHP API below)
  // const baseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'https://cafe.csstrats.dk/api');
  const baseUrl = "http://10.0.2.2:8000/api"; // DEBUGGING: Android emulator localhost
  // const baseUrl = "http://localhost:8000/api"; // DEBUGGING: iOS simulator localhost or web


  final config = AppConfig(baseUrl: baseUrl);
  final apiClient = ApiClient(config: config);

runApp(MultiProvider(
  providers: [
    Provider<AppConfig>.value(value: config),
    Provider<ApiClient>.value(value: apiClient),
    Provider<AuthRepository>(create: (_) => AuthRepository(apiClient)),
    Provider<MenuRepository>(create: (_) => MenuRepository(apiClient)),
    Provider<OrderRepository>(create: (_) => OrderRepository(apiClient)),
    
    // AuthViewModel must come before PosViewModel
    ChangeNotifierProvider<AuthViewModel>(
        create: (ctx) => AuthViewModel(ctx.read<AuthRepository>(), ctx.read<OrderRepository>())),
    ChangeNotifierProvider<HomeViewModel>(
        create: (ctx) => HomeViewModel(ctx.read<OrderRepository>())),
    
    // Global PosViewModel with access to AuthViewModel
    ChangeNotifierProvider<PosViewModel>(
        create: (ctx) => PosViewModel(
              ctx.read<MenuRepository>(),
              ctx.read<OrderRepository>(),
              ctx.read<AuthViewModel>(), // <-- safely read here
            )),
  ],
  child: const VesuvivusApp(),
));

}

class VesuvivusApp extends StatelessWidget {
  const VesuvivusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vesuvivus POS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.deepOrange,
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginView(),
        '/home': (_) => const HomeView(),
        PosView.route: (_) => const PosView(),
      },
    );
  }
}
