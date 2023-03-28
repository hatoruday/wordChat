import 'package:flutter/material.dart';
import 'package:milchat/screens/category_screen.dart';
import 'package:milchat/screens/home_screen.dart';
import 'package:milchat/screens/setting_screen.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/setting': (context) => const SettingScreen(),
        '/setting/category': (context) => CategoryScreen(),
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
