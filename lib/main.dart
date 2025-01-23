import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'services/services.dart';
import 'routes/routes.dart';
import 'controllers/controllers.dart';
import 'ui/ui.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  ApiBaseHelper.setupDio();

  await _requestPermissions();

  runApp(const MainApp());
}

Future<void> _requestPermissions() async {
  // FirebaseCrashlytics.instance.crash();
  // throw Exception();

  // Request camera permissions
  final cameraStatus = await Permission.camera.request();
  if (cameraStatus != PermissionStatus.granted) {
    debugPrint('Camera permission denied');
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SettingsController()),
      ],
      child: Consumer<SettingsController>(
        builder: (context, settingsController, child) {
          TextTheme textTheme = createTextTheme(context, "Poppins", "Poppins");
          MaterialTheme materialTheme = MaterialTheme(textTheme);

          return MaterialApp(
            title: 'Cricket',
            debugShowCheckedModeBanner: false,
            theme: materialTheme.light().copyWith(
                  brightness: Brightness.light,
                ),
            darkTheme: materialTheme.dark().copyWith(
                  brightness: Brightness.dark,
                ),
            themeMode: settingsController.isDarkMode
                ? ThemeMode.dark
                : ThemeMode.light,
            initialRoute: AppRoutes.home,
            routes: AppRoutes.routes,
            onGenerateRoute: (settings) {
              return FadePageRoute(
                  page: AppRoutes.routes[settings.name]!(context));
            },
          );
        },
      ),
    );
  }
}
