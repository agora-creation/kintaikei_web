import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kintaikei_web/common/style.dart';
import 'package:kintaikei_web/providers/home.dart';
import 'package:kintaikei_web/providers/login.dart';
import 'package:kintaikei_web/providers/plan.dart';
import 'package:kintaikei_web/providers/plan_shift.dart';
import 'package:kintaikei_web/providers/user.dart';
import 'package:kintaikei_web/screens/home.dart';
import 'package:kintaikei_web/screens/login.dart';
import 'package:kintaikei_web/screens/splash.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_localizations/syncfusion_localizations.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyBXbOKzBrySVERTtKD4H5JzRHTa2s5E8ZM",
      authDomain: "kintaikei-project.firebaseapp.com",
      projectId: "kintaikei-project",
      storageBucket: "kintaikei-project.appspot.com",
      messagingSenderId: "50104600007",
      appId: "1:50104600007:web:98dc41f95a2151d40745e2",
      measurementId: "G-2WBD69KZK2",
    ),
  );
  await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  if (FirebaseAuth.instance.currentUser == null) {
    await Future.any([
      FirebaseAuth.instance.userChanges().firstWhere((e) => e != null),
      Future.delayed(const Duration(milliseconds: 3000)),
    ]);
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: LoginProvider.initialize()),
        ChangeNotifierProvider.value(value: HomeProvider()),
        ChangeNotifierProvider.value(value: PlanProvider()),
        ChangeNotifierProvider.value(value: PlanShiftProvider()),
        ChangeNotifierProvider.value(value: UserProvider()),
      ],
      child: FluentApp(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          FluentLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          SfGlobalLocalizations.delegate,
        ],
        supportedLocales: const [Locale('ja')],
        locale: const Locale('ja'),
        title: '勤怠計 - 会社用ダッシュボード',
        theme: customTheme(),
        home: const SplashController(),
      ),
    );
  }
}

class SplashController extends StatelessWidget {
  const SplashController({super.key});

  @override
  Widget build(BuildContext context) {
    final loginProvider = Provider.of<LoginProvider>(context);
    switch (loginProvider.status) {
      case AuthStatus.uninitialized:
        return const SplashScreen();
      case AuthStatus.unauthenticated:
      case AuthStatus.authenticating:
        return const LoginScreen();
      case AuthStatus.authenticated:
        return const HomeScreen();
      default:
        return const LoginScreen();
    }
  }
}
