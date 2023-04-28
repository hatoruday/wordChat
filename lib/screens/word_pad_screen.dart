import 'package:flutter/material.dart';
import 'package:milchat/models/wordBox.dart';

class WordPadScreen extends StatefulWidget {
  const WordPadScreen({super.key});

  @override
  State<WordPadScreen> createState() => _WordPadScreenState();
}

class _WordPadScreenState extends State<WordPadScreen> {
  int _selectedIndex = 0;

  void changeIndex(int value) {
    if (_selectedIndex == value) {
      return;
    }
    setState(() {
      _selectedIndex = value;
    });

    switch (value) {
      case 0:
        {
          Navigator.pushNamed(context, '/readIt', arguments: {
            "selectedIndex": 0,
          });
          break;
        }
      case 1:
        {
          Navigator.pushNamed(context, '/wordPad', arguments: {
            "selectedIndex": 1,
          });
          break;
        }
      case 2:
        {
          Navigator.pushNamed(context, '/wordPad', arguments: {
            "selectedIndex": 1,
          });
          break;
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> args =
        ModalRoute.of(context)?.settings.arguments as Map<String, Object>;
    _selectedIndex = args["selectedIndex"];
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          centerTitle: false,
          backgroundColor: Colors.black,
          title: const Text(
            "단어장",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          actions: [
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/setting');
              },
              child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Icon(
                    Icons.settings,
                    color: Colors.black,
                  )),
            )
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Center(
                child: WordBox(),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.article),
              label: "문장생성",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_box_outlined),
              label: "단어장",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: "설정",
            )
          ],
          currentIndex: _selectedIndex,
          onTap: (value) {
            changeIndex(value);
          },
        ),
      ),
    );
  }
}
