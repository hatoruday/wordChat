import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:milchat/models/chat_block.dart';
import 'package:milchat/models/fire_chat_block.dart';
import 'package:milchat/services/api_services.dart';
import 'package:milchat/test/storage_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:velocity_x/velocity_x.dart';

class ReadItScreen extends StatefulWidget {
  const ReadItScreen({super.key});

  @override
  State<ReadItScreen> createState() => _ReadItScreenState();
}

class _ReadItScreenState extends State<ReadItScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatBlock> _blocks = [];

  late bool isGenerating;
  int _selectedIndex = 0;
  //final ScrollController _scrollController = ScrollController();
  void changeIndex(int value) {
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
  void initState() {
    isGenerating = true;
    loadFireChat();

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future loadFireChat() async {
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
      ChatBlock.highlights.add(element.get("highWord"));
    }

    //firebase에 저장된 chatblock을 가져온다.
    final chatBlockQuarySnapShot = await storeInstance
        .collection("ChatBlock")
        .where("user", isEqualTo: userEmail)
        .orderBy("date")
        .get();
    final chatBlockDocs = chatBlockQuarySnapShot.docs;
    for (var element in chatBlockDocs) {
      ChatBlock botMessage =
          ChatBlock(text: element.get("chatBlock"), sender: "bot");
      _blocks.insert(0, botMessage);
    }
    setState(() {
      isGenerating = false;
    });
  }

  Future saveFireChat(String responsetext) async {
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
      print(e);
    }
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
    if (ChatBlock.highlights.isNotEmpty) {
      selectedLight = ChatBlock.highlights.pickOne();
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

    await saveFireChat(fireResponseMessage); //응답을 firebase document내에 저장한다.
    ChatBlock botMessage = ChatBlock(text: fireResponseMessage, sender: "bot");
    setState(() {
      _blocks.insert(0, botMessage);
      isGenerating = false;
    });
  }

  void _createChats() async {
    setState(() {
      isGenerating = true;
    });
    String inputMessage = _controller.text;
    _controller.clear();
    String fireResponseMessage =
        await ApiService().makeChatResponse(inputMessage);

    // ChatBlock block = ChatBlock(text: textRequest, sender: "user");
    //_blocks.insert(0, block);

    await saveFireChat(fireResponseMessage); //응답을 firebase document내에 저장한다.
    ChatBlock botMessage = ChatBlock(text: fireResponseMessage, sender: "bot");
    setState(() {
      _blocks.insert(0, botMessage);
      isGenerating = false;
    });
  }

  Widget _buildTextComposer() {
    return isGenerating
        ? Row(
            children: const [
              Expanded(
                  child: Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: CircularProgressIndicator()),
              ))
            ],
          )
        : Row(children: [
            Expanded(
              child: TextField(
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
                controller: _controller,
                onSubmitted: (value) => _createChats(),
                decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 1, horizontal: 10),
                  filled: true,
                  fillColor: Colors.black,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: BorderSide(color: Colors.grey.shade700)),
                  hintText: "Send a Message",
                ),
                minLines: 1,
                maxLines: 3,
              ),
            ),
            IconButton(
                onPressed: () => _createChats(),
                icon: const Icon(
                  Icons.send,
                  color: Colors.white,
                )),
            IconButton(
                onPressed: () => createBlock(),
                icon: const Icon(
                  Icons.ad_units,
                  color: Colors.white,
                )),
          ]).px12();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          centerTitle: false,
          backgroundColor: Colors.black,
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
                  itemCount: _blocks.length,
                  itemBuilder: (context, index) {
                    ChatBlock chatblock = _blocks[index];
                    return chatblock;
                  },
                ),
              ),
              Container(
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.black,
                ),
                child: _buildTextComposer(),
              )
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.black,
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
