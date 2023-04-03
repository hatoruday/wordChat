import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:milchat/models/chat_block.dart';
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
      token: dotenv.env['apiKey'],
      baseOption: HttpSetup(
        receiveTimeout: const Duration(
          seconds: 60,
        ),
      ),
      isLog: true,
    );
    isGenerating = true;
    _createTexts();

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _createTexts() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    //List<String>? highlights = prefs.getStringList("wordList");

    final storeInstance = FirebaseFirestore.instance;
    final userEmail = FirebaseAuth.instance.currentUser?.email;
    final highWordQuarySnapShot = await storeInstance
        .collection("HighWord")
        .where("user", isEqualTo: userEmail)
        .get();
    final docs = highWordQuarySnapShot.docs;
    for (var element in docs) {
      ChatBlock.highlights.add(element.get("highWord"));
    }
    // if (highlights == null) {
    //   await prefs.setStringList('wordList', []);
    //   highlights = prefs.getStringList('wordList');
    // }
    List<String>? selectedCategories = prefs.getStringList("categoryList");
    if (selectedCategories == null) {
      await prefs.setStringList('categoryList', []);
      selectedCategories = prefs.getStringList('categoryList');
    }
    String selectedLight;
    if (ChatBlock.highlights.isNotEmpty) {
      selectedLight = ChatBlock.highlights.pickOne();
    } else {
      selectedLight = "any";
    }
    String selectedCategory;
    if (selectedCategories!.isNotEmpty) {
      selectedCategory = selectedCategories.pickOne();
    } else {
      selectedCategory = "any word";
    }
    String textRequest =
        "Including a word of \"$selectedLight\", Please make short paragraphs instead of enumerating sentences with numbers about a subject of \"$selectedCategory\"";
    //ChatBlock block = ChatBlock(text: _controller.text, sender: "user");
    //print(textRequest);
    ChatBlock block = ChatBlock(text: textRequest, sender: "user");
    //_blocks.insert(0, block);

    _controller.clear();

    final request = CompleteText(
      prompt: block.text,
      model: kTextDavinci3,
      maxTokens: 1000,
    );

    final botBlock = await openAI?.onCompletion(request: request);
    final String responseMessage = botBlock!.choices[0].text;

    ChatBlock botMessage = ChatBlock(text: responseMessage, sender: "bot");
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
                onPressed: () => _createTexts(),
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
