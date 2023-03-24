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
          seconds: 30,
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
    final List<String> highlights = prefs.getStringList("wordList")!;
    highlights.shuffle();
    String selectedLight = highlights.pickOne();
    String textRequest =
        "make a sentence that has not ever generated over 100 letter using a word of \"$selectedLight\"";
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
                  hintText: "Seand a Message",
                ),
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
    return Scaffold(
        appBar: AppBar(title: const Text("wordChat")),
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
        ));
  }
}
