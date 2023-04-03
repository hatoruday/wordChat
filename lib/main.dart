import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:milchat/screens/auth_screen.dart';
import 'package:milchat/screens/category_screen.dart';
import 'package:milchat/screens/home_screen.dart';
import 'package:milchat/screens/register_screen.dart';
import 'package:milchat/screens/setting_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

showToast(String msg) {
  Fluttertoast.showToast(
    msg: msg,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.CENTER,
    timeInSecForIosWeb: 1,
    backgroundColor: Colors.red,
    textColor: Colors.white,
    fontSize: 16.0,
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dotenv.load(fileName: ".env");
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/home': (context) => const HomeScreen(),
        '/setting': (context) => const SettingScreen(),
        '/setting/category': (context) => CategoryScreen(),
        '/': (context) => const AuthForm(),
        '/register': (context) => const RegisterForm(),
      },
      debugShowCheckedModeBanner: false,
      title: "WordChat",
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
    );
  }
}
