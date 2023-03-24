import 'package:flutter/material.dart';
import 'package:milchat/models/word_block.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatBlock extends StatefulWidget {
  ChatBlock({super.key, required this.text, required this.sender}) {
    createBlocks();
    initPref();
  }
  static List<String>? highlights;
  final String text;
  final String sender;
  final List<WordBlock> wordBlocks = [];
  late final SharedPreferences pref;

  void setWordList(List<String>? wordList) async {
    await pref.setStringList('wordList', wordList!);
  }

  Future initPref() async {
    pref = await SharedPreferences.getInstance();
    List<String>? wordList = pref.getStringList('wordList');
    if (wordList == null) {
      await pref.setStringList('wordList', []);
      wordList = pref.getStringList("wordList");
    }
    print(wordList);
    ChatBlock.highlights = wordList!;
    doHighLight();
  }

  void doHighLight() {
    for (var light in highlights!) {
      for (var i = 0; i < wordBlocks.length; i++) {
        if (wordBlocks[i].id == light) {
          WordBlock block = WordBlock(
              id: wordBlocks[i].id,
              textspan: TextSpan(
                  text: wordBlocks[i].id,
                  style: TextStyle(
                    color: Colors.black,
                    backgroundColor: Colors.yellow.shade200,
                  )));
          wordBlocks[i] = block;
        }
      }
    }
  }

  void removeHighLight(String removedWord) {
    for (var i = 0; i < wordBlocks.length; i++) {
      if (wordBlocks[i].id == removedWord) {
        WordBlock block = WordBlock(
            id: wordBlocks[i].id,
            textspan: TextSpan(
                text: wordBlocks[i].id,
                style: const TextStyle(
                  color: Colors.black,
                )));
        wordBlocks[i] = block;
      }
    }
  }

  void createBlocks() {
    List<String> words = text
        .trimLeft()
        .split(RegExp(r'(?<=[ ,.])|(?=[ ,.])'))
        .where((word) => word.isNotEmpty)
        .toList(); // 리스트에 모든 토큰이 담기게 된다.
    for (var word in words) {
      WordBlock original = WordBlock(
        id: word,
        textspan: TextSpan(
          text: word,
          style: const TextStyle(
            color: Colors.black,
          ),
        ),
      );
      wordBlocks.add(original);
    }
  }

  @override
  State<ChatBlock> createState() => _ChatBlockState();
}

class _ChatBlockState extends State<ChatBlock> {
  @override
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
              margin: const EdgeInsets.only(top: 5.0),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.black,
                    width: 2,
                  )),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: SelectableText.rich(
                  TextSpan(text: "", children: <TextSpan>[
                    for (var wordBlock in widget.wordBlocks)
                      wordBlock.textspan!,
                  ]),
                  contextMenuBuilder: (context, editableTextState) {
                    final TextEditingValue value =
                        editableTextState.textEditingValue;
                    final List<ContextMenuButtonItem> buttonItems =
                        editableTextState.contextMenuButtonItems;
                    buttonItems.insert(
                        0,
                        ContextMenuButtonItem(
                          label: "단어 저장",
                          onPressed: () {
                            final String insidedText =
                                value.selection.textInside(value.text);
                            ChatBlock.highlights?.add(insidedText);
                            widget.setWordList(ChatBlock.highlights);
                            widget.doHighLight();
                            setState(() {});
                            ContextMenuController.removeAny();
                          },
                        ));

                    buttonItems.insert(
                        1,
                        ContextMenuButtonItem(
                            label: "단어 삭제",
                            onPressed: () {
                              final String insidedText =
                                  value.selection.textInside(value.text);
                              ChatBlock.highlights?.remove(insidedText);
                              widget.setWordList(ChatBlock.highlights);
                              widget.removeHighLight(insidedText);
                              setState(() {});
                              ContextMenuController.removeAny();
                            }));
                    return AdaptiveTextSelectionToolbar.buttonItems(
                        buttonItems: buttonItems,
                        anchors: editableTextState.contextMenuAnchors);
                  },
                ),
              )),
        ),
      ],
    );
  }
}
