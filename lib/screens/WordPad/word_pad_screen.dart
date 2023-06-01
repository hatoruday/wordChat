import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:milchat/models/fire_high_word.dart';
import 'package:milchat/screens/WordPad/add_word_page.dart';
import 'package:milchat/screens/WordPad/wordBox.dart';
import 'package:milchat/services/util.dart';

class WordPadScreen extends StatefulWidget {
  const WordPadScreen({super.key});

  @override
  State<WordPadScreen> createState() => _WordPadScreenState();
}

class _WordPadScreenState extends State<WordPadScreen> {
  late bool isGenerating = true;
  List<FireHighWord> padWordObjectList = [];
  final int _selectedIndex = 1;

  @override
  void initState() {
    loadFireWord();
    super.initState();
  }

  Future loadFireWord() async {
    final userEmail = FirebaseAuth.instance.currentUser?.email;
    final storeInstance = FirebaseFirestore.instance;
    //highword를 firebase로부터 load한다.
    final highWordQuarySnapShot = await storeInstance
        .collection("HighWord")
        .where("user", isEqualTo: userEmail)
        .get();
    final highWordDocs = highWordQuarySnapShot.docs;
    //로드한 단어들을 ChatBlock의 static변수에 추가한다.
    for (var element in highWordDocs) {
      FireHighWord padWordObject = FireHighWord.fromJson(element.data());
      padWordObjectList.add(padWordObject);
    }
    setState(() {
      isGenerating = false;
    });
  }

  void showAddWordPage() {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.white,
        builder: (context) {
          return AddWordPage();
        });
  }

  @override
  Widget build(BuildContext context) {
    // Map<String, dynamic> args =
    //     ModalRoute.of(context)?.settings.arguments as Map<String, Object>;
    // int selectedIndex = args["selectedIndex"];
    return MaterialApp(
      theme: ThemeData(canvasColor: Colors.black),
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
                    color: Colors.white,
                  )),
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.grey.shade800,
          onPressed: () {
            showAddWordPage();
          },
          child: const Icon(
            Icons.add,
          ),
        ),
        body: isGenerating
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    Flexible(
                      child: ListView.builder(
                          itemCount: padWordObjectList.length,
                          itemBuilder: (context, index) {
                            return WordBox(
                              fireHighWordObject: padWordObjectList[index],
                            );
                          }),
                    ),
                  ],
                ),
              ),
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
              UtilFunc.changeIndex(value, context, _selectedIndex);
            },
          ),
        ),
      ),
    );
  }
}
