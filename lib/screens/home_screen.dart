import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter/material.dart';
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
  final ScrollController _scrollController = ScrollController();

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
    _createTexts();

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _createTexts() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? highlights = prefs.getStringList("wordList");
    if (highlights == null) {
      await prefs.setStringList('wordList', []);
      highlights = prefs.getStringList('wordList');
    }
    List<String>? selectedCategories = prefs.getStringList("categoryList");
    if (selectedCategories == null) {
      await prefs.setStringList('categoryList', []);
      selectedCategories = prefs.getStringList('categoryList');
    }
    String selectedLight;
    if (highlights!.isNotEmpty) {
      selectedLight = highlights.pickOne();
    } else {
      selectedLight = "아무";
    }
    String selectedCategory;
    if (selectedCategories!.isNotEmpty) {
      selectedCategory = selectedCategories.pickOne();
    } else {
      selectedCategory = "아무";
    }
    String textRequest =
        "문장을 열거하지 말고 \"$selectedLight\" 단어를 포함해서, \"$selectedCategory\"와 관련된 주제로 긴 영어로 된 문단을 만들어줘. 이전에 생성했던거랑 겹치지 않게. ";
    //ChatBlock block = ChatBlock(text: _controller.text, sender: "user");
    print(textRequest);
    ChatBlock block = ChatBlock(text: textRequest, sender: "user");
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
