import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatBlock> _blocks = [];
  OpenAI? openAI;
  late bool isGenerating;
  //final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    openAI = OpenAI.instance.build(
      token: "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",
      baseOption: HttpSetup(
        receiveTimeout: const Duration(
          seconds: 60,
        ),
      ),
      isLog: true,
    );
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
    String fireResponseMessage = await service.makeChatResponse();

    await saveFireChat(fireResponseMessage);
    ChatBlock botMessage = ChatBlock(text: fireResponseMessage, sender: "bot");
    setState(() {
      _blocks.insert(0, botMessage);
      isGenerating = false;
    });
  }

  void _createChats() async {
    // String textRequest =
    //     "make a sentence that has not ever generated over 100 letter using a word of $selectedLight";
    ChatBlock block = ChatBlock(text: _controller.text, sender: "user");
    // ChatBlock block = ChatBlock(text: textRequest, sender: "user");
    //_blocks.insert(0, block);

    _controller.clear();

    final request = CompleteText(
      prompt: block.text,
      model: kTextDavinci3,
      maxTokens: 1000,
    );

    final botBlock = await openAI?.onCompletion(request: request);
    ChatBlock botMessage =
        ChatBlock(text: botBlock!.choices[0].text, sender: "bot");
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
                controller: _controller,
                onSubmitted: (value) => _createChats(),
                decoration: const InputDecoration.collapsed(
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
                )),
            IconButton(
                onPressed: () => createBlock(),
                icon: const Icon(
                  Icons.ad_units,
                )),
          ]).px16();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: const Text(
              "wordChat",
              style: TextStyle(color: Colors.black),
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
                  decoration: BoxDecoration(
                    color: context.cardColor,
                  ),
                  child: _buildTextComposer(),
                )
              ],
            ),
          )),
    );
  }
}
