import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:milchat/models/word_block.dart';
import 'package:milchat/models/fire_high_word.dart';
import 'package:milchat/services/api_services.dart';
import 'package:milchat/services/overlay.dart';
import 'package:milchat/test/storage_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui' as ui;

class ChatBlock extends StatefulWidget {
  ChatBlock({super.key, required this.text, required this.sender}) {
    createBlocks(); //챗블록 클래스가 생성되고, 매개변수로 받아온 text로 단어 리스트로 변환하고,
    //단어 하나하나마다 wordBlock으로 초기화한 후, wordBlocks리스트에 추가한다.
    //initPref(); //chatblock인스턴스가 생기자마자, prefs객체를 생성하고, wordlist의 값을 받아와 highlight변수에 저장한다.
    doHighLight(); //그리고 dohighlight를 불러오고,
  }

  static Set<String> highlights = {};
  final String text;
  final String sender;
  final List<WordBlock> wordBlocks = [];
  late final SharedPreferences pref;
  final GlobalKey _key = GlobalKey();

  void createBlocks() {
    List<String> words = text
        .trimLeft()
        .split(RegExp(r'(?<=[ ,.])|(?=[ ,.])'))
        .where((word) => word.isNotEmpty)
        .toList(); // 리스트에 모든 토큰이 담기게 된다.
    for (var word in words) {
      WordBlock original = WordBlock(
        id: word,
        backColor: Colors.transparent,
      );
      wordBlocks.add(original);
    }
  }

  void doHighLight() {
    for (var light in highlights) {
      for (var i = 0; i < wordBlocks.length; i++) {
        if (wordBlocks[i].id == light) {
          WordBlock block = WordBlock(
              id: wordBlocks[i].id, backColor: Colors.yellow.shade200);
          wordBlocks[i] = block;
        }
      }
    }
  }

  void removeHighLight(String removedWord) {
    for (var i = 0; i < wordBlocks.length; i++) {
      if (wordBlocks[i].id == removedWord) {
        WordBlock block =
            WordBlock(id: wordBlocks[i].id, backColor: Colors.transparent);
        wordBlocks[i] = block;
      }
    }
  }

  Future saveFireWord(
      {required String insidedText, String? level, String? group}) async {
    try {
      String? user = FirebaseAuth.instance.currentUser?.email;
      DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
      String papagoResponse = await ApiService.getNaverResponse(insidedText);
      final highWord = FireHighWord(
        user: user!,
        highWord: insidedText,
        wordMeaning: papagoResponse,
        date: dateFormat.format(DateTime.now()),
        level: level ?? "어려워요",
        group: group ?? "non-selected",
      );
      highlights.add(insidedText);
      CollectionReference collectionRef =
          FirebaseFirestore.instance.collection("HighWord");
      await collectionRef.add(highWord.toJson());
    } catch (e) {
      showToast("saveFireWord error");
      showToast(e.toString());
    }
  }

  Future deleteFireWord(String insidedText) async {
    try {
      String? user = FirebaseAuth.instance.currentUser?.email;

      CollectionReference collectionRef =
          FirebaseFirestore.instance.collection("HighWord");
      QuerySnapshot fireWordDocRef = await collectionRef
          .where("highWord", isEqualTo: insidedText)
          .where("user", isEqualTo: user)
          .get();
      for (var quarydocumentsnapshot in fireWordDocRef.docs) {
        quarydocumentsnapshot.reference.delete();
      }
      highlights.remove(insidedText);
      removeHighLight(insidedText);
    } catch (e) {
      showToast("deleteFireWord error");
      showToast("deleteFireWordError$e");
    }
  }

  Offset getOffsetForSelection(TextEditingValue value) {
    final TextPainter painter = TextPainter(
      text: TextSpan(
        text: value.text,
      ),
      textDirection: ui.TextDirection.ltr,
      textAlign: TextAlign.left,
    );
    painter.layout(maxWidth: _key.currentContext!.size!.width);
    final double cursorOffset =
        painter.getOffsetForCaret(value.selection.extent, ui.Rect.zero).dx;
    final RenderBox renderBox =
        _key.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset(cursorOffset, 0));
    return offset;
  }

  @override
  State<ChatBlock> createState() => _ChatBlockState();
}

class _ChatBlockState extends State<ChatBlock> {
  String selectedText = '';
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              decoration: BoxDecoration(
                  color: Colors.yellow,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.yellow,
                    width: 2,
                  )),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: SelectableText.rich(
                  TextSpan(text: "", children: <InlineSpan>[
                    for (var wordBlock in widget.wordBlocks)
                      wordBlock.createWordBlock(context)
                  ]),
                  key: widget._key,
                  contextMenuBuilder: (menuContext, editableTextState) {
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
                            await widget.saveFireWord(insidedText: insidedText);
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
                            onPressed: () async {
                              final String insidedText =
                                  value.selection.textInside(value.text);
                              await widget.deleteFireWord(insidedText);
                              setState(() {});
                              ContextMenuController.removeAny();
                            }));
                    buttonItems.insert(
                        2,
                        ContextMenuButtonItem(
                            label: "문장 번역",
                            onPressed: () async {
                              Offset selectionOffset =
                                  widget.getOffsetForSelection(value);
                              MakeOverlay.onTap(
                                  overLayContext: context,
                                  tapSentence:
                                      value.selection.textInside(value.text),
                                  topLeftOffset: selectionOffset);
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
