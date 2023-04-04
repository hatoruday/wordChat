import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:milchat/models/word_block.dart';
import 'package:milchat/models/fire_high_word.dart';
import 'package:milchat/test/storage_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatBlock extends StatefulWidget {
  ChatBlock({super.key, required this.text, required this.sender}) {
    createBlocks(); //챗블록 클래스가 생성되고, 매개변수로 받아온 text로 단어 리스트로 변환하고,
    //단어 하나하나마다 wordBlock으로 초기화한 후, wordBlocks리스트에 추가한다.
    //
    //
    //initPref(); //chatblock인스턴스가 생기자마자, prefs객체를 생성하고, wordlist의 값을 받아와 highlight변수에 저장한다.
    doHighLight(); //그리고 dohighlight를 불러오고,
  }
  static Set<String> highlights = {};
  final String text;
  final String sender;
  final List<WordBlock> wordBlocks = [];
  late final SharedPreferences pref;

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

  // void setWordList(List<String>? wordList) async {
  //   await pref.setStringList(
  //       'wordList', wordList!); //현재 기기 내부 데이터를 wordList 변수의 값으로 초기화한다.
  // }

  // Future initPref() async {
  //   pref = await SharedPreferences.getInstance();
  //   List<String>? wordList =
  //       pref.getStringList('wordList'); // 기기내부에서 wordList 데이터를 가져온다.
  //   if (wordList == null) {
  //     //만약 처음 chatblock클래스가 생성되어서
  //     await pref.setStringList('wordList', []);
  //     wordList = pref.getStringList("wordList");
  //   }
  //   print(wordList);
  //   ChatBlock.highlights =
  //       wordList!.toSet(); //ChatBlock 클래스의 스태틱 변수 highlights에
  //   //sharedPreference에서 가져온 기기 내부 데이터 wordList를 넣는다.
  //   doHighLight();
  // }

  void doHighLight() {
    for (var light in highlights) {
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
    print(highlights);
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

  Future saveFireWord(String insidedText) async {
    try {
      String? user = FirebaseAuth.instance.currentUser?.email;
      DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
      final highWord = FireHighWord(
        user: user!,
        highWord: insidedText,
        date: dateFormat.format(DateTime.now()),
      );
      CollectionReference collectionRef =
          FirebaseFirestore.instance.collection("HighWord");
      await collectionRef.add(highWord.toJson());
    } catch (e) {
      showToast("setFireWord error");
      print(e);
    }
  }

  @override
  State<ChatBlock> createState() => _ChatBlockState();
}

class _ChatBlockState extends State<ChatBlock> {
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
                          onPressed: () async {
                            final String insidedText =
                                value.selection.textInside(value.text);
                            ChatBlock.highlights
                                .add(insidedText); //하이라이트 변수에 단어를 추가한후
                            await widget.saveFireWord(insidedText);
                            //widget.setWordList(ChatBlock
                            //    .highlights); //하이라이트 변수로 prefs를 업데이트한다.
                            widget
                                .doHighLight(); //즉각적인 핫로드를 위해 다시 한번 하이라이트 변수를 가져와 모든 wordBlock을 업데이트한다.
                            setState(() {}); //그리고 다시 스크린 빌드.
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
                              ChatBlock.highlights
                                  .remove(insidedText); //하이라이트 변수에서 해당 단어 삭제후
                              //widget.setWordList(
                              //    ChatBlock.highlights!.toList()); //prefs를 업데이트하고
                              widget.removeHighLight(
                                  insidedText); //삭제된 wordBlock을 탐색으로 다 찾아 검은색 wordBlock으로 업데이트한다.
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
