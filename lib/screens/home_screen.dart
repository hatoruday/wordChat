import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter/material.dart';
import 'package:milchat/models/chat_block.dart';
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
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _createBlock() async {
    ChatBlock block = ChatBlock(text: _controller.text, sender: "user");
    _blocks.insert(0, block);

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
    });
  }

  Widget _buildTextComposer() {
    return Row(children: [
      Expanded(
        child: TextField(
          controller: _controller,
          onSubmitted: (value) => _createBlock(),
          decoration: const InputDecoration.collapsed(
            hintText: "Seand a Message",
          ),
        ),
      ),
      IconButton(
          onPressed: () => _createBlock(),
          icon: const Icon(
            Icons.send,
          ))
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
