import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:milchat/screens/ReadIt/build_text_composer.dart';
import 'package:milchat/screens/ReadIt/chat_block.dart';
import 'package:milchat/models/fire_chat_block.dart';
import 'package:milchat/services/api_services.dart';
import 'package:milchat/test/storage_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:velocity_x/velocity_x.dart';

class ReadItScreen extends StatefulWidget {
  ReadItScreen({super.key});
  List<ChatBlock> blocks = [];
  static final Set<String> highlights = {};
  static Future saveFireChat(String responsetext) async {
    try {
      String? user = FirebaseAuth.instance.currentUser?.email;
      DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
      final highWord = FireChatBlock(
        user: user!,
        chatBlock: responsetext,
        date: dateFormat.format(DateTime.now()),
      );
      CollectionReference collectionRef =
          FirebaseFirestore.instance.collection("ChatBlock");
      await collectionRef.add(highWord.toJson());
    } catch (e) {
      showToast("saveFireChat error");
    }
  }

  @override
  State<ReadItScreen> createState() => _ReadItScreenState();
}

class _ReadItScreenState extends State<ReadItScreen> {
  final TextEditingController _controller = TextEditingController();
  Color testColor = Colors.black;
  late bool isGenerating;
  int _selectedIndex = 0;
  //final ScrollController _scrollController = ScrollController();
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
          Navigator.pushReplacementNamed(context, '/readIt', arguments: {
            "selectedIndex": 0,
          });
          Navigator.pop(context);
          break;
        }
      case 1:
        {
          Navigator.pushReplacementNamed(context, '/wordPad', arguments: {
            "selectedIndex": 1,
          });
          break;
        }
      case 2:
        {
          Navigator.pushReplacementNamed(context, '/content', arguments: {
            "selectedIndex": 2,
          });
          break;
        }

      case 3:
        {
          Navigator.pushReplacementNamed(context, '/wordPad', arguments: {
            "selectedIndex": 1,
          });
          break;
        }
    }
  }

  @override
  void initState() {
    isGenerating = false;
    if (ReadItScreen.blocks.isEmpty) {
      isGenerating = true;
      loadFireChat();
    }

    super.initState();
  }

  Future loadFireChat() async {
    setState(() {});
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
      ReadItScreen.highlights.add(element.get("highWord"));
    }

    //firebase에 저장된 chatblock을 가져온다.
    final chatBlockQuarySnapShot = await storeInstance
        .collection("ChatBlock")
        .where("user", isEqualTo: userEmail)
        .orderBy("date")
        .get();
    final chatBlockDocs = chatBlockQuarySnapShot.docs;
    for (var element in chatBlockDocs) {
      ChatBlock botMessage = ChatBlock(
        text: element.get("chatBlock"),
        sender: "bot",
        adjusting: adjusting,
        highlights: ReadItScreen.highlights,
      );
      ReadItScreen.blocks.insert(0, botMessage);
    }
    setState(() {
      isGenerating = false;
    });
  }

  void createBlock() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    //List<String>? highlights = prefs.getStringList("wordList");
    setState(() {
      isGenerating = true;
    });

    List<String>? selectedCategories = prefs.getStringList("categoryList");
    if (selectedCategories == null) {
      await prefs.setStringList('categoryList', []);
      selectedCategories = prefs.getStringList('categoryList');
    }
    //highlights 중 하나를 뽑는다.
    String selectedLight;
    if (ReadItScreen.highlights.isNotEmpty) {
      selectedLight = ReadItScreen.highlights.pickOne();
    } else {
      selectedLight = "any";
    }
    //selectedCategory중 하나를 뽑는다.
    String selectedCategory;
    if (selectedCategories!.isNotEmpty) {
      selectedCategory = selectedCategories.pickOne();
    } else {
      selectedCategory = "any subject";
    }
    //firebase cloud functions을 이용해 chatgpt Api Response를 가져온다.
    ApiService service = ApiService(
        selectedCategory: selectedCategory, selectedLight: selectedLight);
    String fireResponseMessage =
        await service.makeChatResponse(null); //응답을 텍스트로 받아온다.

    await ReadItScreen.saveFireChat(
        fireResponseMessage); //응답을 firebase document내에 저장한다.
    ChatBlock botMessage = ChatBlock(
      text: fireResponseMessage,
      sender: "bot",
      adjusting: adjusting,
      highlights: ReadItScreen.highlights,
    );
    setState(() {
      ReadItScreen.blocks.insert(0, botMessage);
      isGenerating = false;
    });
  }

  void createChats() async {
    setState(() {
      isGenerating = true;
    });
    String inputMessage = _controller.text;
    _controller.clear();
    String fireResponseMessage =
        await ApiService().makeChatResponse(inputMessage);

    // ChatBlock block = ChatBlock(text: textRequest, sender: "user");
    //_blocks.insert(0, block);

    await ReadItScreen.saveFireChat(
        fireResponseMessage); //응답을 firebase document내에 저장한다.
    ChatBlock botMessage = ChatBlock(
      text: fireResponseMessage,
      sender: "bot",
      adjusting: adjusting,
      highlights: ReadItScreen.highlights,
    );
    setState(() {
      ReadItScreen.blocks.insert(0, botMessage);
      isGenerating = false;
    });
  }

  void adjusting({
    required bool isDo,
    String? wordToRemeve,
  }) {
    if (isDo) {
      setState(() {});
    } else {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(canvasColor: Colors.black),
      home: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          centerTitle: false,
          backgroundColor: testColor,
          title: const Text(
            "Read It!",
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
        body: SafeArea(
          child: Column(
            children: [
              Flexible(
                child: ListView.builder(
                  reverse: true,
                  padding: Vx.m8,
                  itemCount: ReadItScreen.blocks.length,
                  itemBuilder: (context, index) {
                    ChatBlock chatblock = ReadItScreen.blocks[index];
                    return chatblock;
                  },
                ),
              ),
              Container(
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                ),
                child: BuildTextComposer(
                  controller: _controller,
                  createBlock: createBlock,
                  createChats: createChats,
                  isGenerating: isGenerating,
                ),
              )
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
                icon: Icon(Icons.article),
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
