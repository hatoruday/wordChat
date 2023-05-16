import 'package:flutter/material.dart';
import 'package:milchat/screens/Content/blank_question.dart';

class ContentScreen extends StatefulWidget {
  const ContentScreen({super.key});

  @override
  State<ContentScreen> createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late TabController controller;

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 3, vsync: this);
  }

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
          Navigator.pushNamed(context, '/content', arguments: {
            "selectedIndex": 2,
          });
          break;
        }

      case 3:
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
    double screenWidth = MediaQuery.of(context).size.width;
    Map<String, dynamic> args =
        ModalRoute.of(context)?.settings.arguments as Map<String, Object>;
    _selectedIndex = args["selectedIndex"];
    return MaterialApp(
      theme: ThemeData(canvasColor: Colors.black),
      home: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          centerTitle: false,
          backgroundColor: Colors.black,
          title: const Text(
            "컨텐츠",
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
                    color: Colors.white,
                  )),
            )
          ],
          bottom: TabBar(
            controller: controller,
            tabs: const <Widget>[
              Tab(
                text: '빈칸 맞추기',
              ),
              Tab(
                text: 'second',
              ),
              Tab(
                text: 'third',
              ),
            ],
          ),
        ),
        body: TabBarView(controller: controller, children: <Widget>[
          BlankQuestion(
            screenWidth: screenWidth,
          ),
          const Center(),
          const Center(),
        ]),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(color: Colors.black),
          child: BottomNavigationBar(
            unselectedItemColor: Colors.grey.shade700,
            selectedItemColor: Colors.indigo.shade700,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.article,
                ),
                label: "문장생성",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.add_box_outlined),
                label: "단어장",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.play_circle_outlined),
                label: "컨텐츠",
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
      ),
    );
  }
}
