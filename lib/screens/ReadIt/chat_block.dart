import 'package:flutter/material.dart';
import 'package:milchat/screens/ReadIt/word_block.dart';
import 'package:milchat/models/fire_high_word.dart';
import 'package:milchat/services/overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui' as ui;

class ChatBlock extends StatefulWidget {
  ChatBlock({
    super.key,
    required this.text,
    required this.sender,
    required this.adjusting,
    required this.highlights,
  }) {
    createBlocks(); //처음 메모리에 이 클래스가 생성됐을때 실행되는 생성자 내 함수 작성.
    //단어 하나하나마다 wordBlock으로 초기화한 후, wordBlocks리스트에 추가한다.
    //initPref(); //chatblock인스턴스가 생기자마자, prefs객체를 생성하고, wordlist의 값을 받아와 highlight변수에 저장한다.
  }
  final Set<String> highlights;
  final Function adjusting;
  final String text;
  final String sender;
  final List<WordBlock> wordBlocks = [];
  late final SharedPreferences pref;
  final GlobalKey _key = GlobalKey();

  void createBlocks() {
    wordBlocks.clear();
    print(highlights);
    List<String> words = text
        .trimLeft()
        .split(RegExp(r'(?<=[ ,.])|(?=[ ,.])'))
        .where((word) => word.isNotEmpty)
        .toList(); // 리스트에 모든 토큰이 담기게 된다.

    for (var word in words) {
      WordBlock? wordToPut;
      for (var light in highlights) {
        if (light == word) {
          WordBlock highedBlock = WordBlock(
              id: light,
              backColor: Colors.indigo.shade200,
              textColor: Colors.white);
          wordToPut = highedBlock;
          break;
        } else {
          WordBlock original = WordBlock(
            id: word,
            backColor: Colors.transparent,
          );
          wordToPut = original;
        }
      }
      wordBlocks.add(wordToPut!);
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
  void initState() {
    widget.createBlocks();
    super.initState();
  }

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
                            await FireHighWord.saveFireWord(
                                insidedText: insidedText);
                            ContextMenuController.removeAny();
                            setState(() {});
                            //widget.adjusting(isDo: true);
                          },
                        ));

                    buttonItems.insert(
                        1,
                        ContextMenuButtonItem(
                            label: "단어 삭제",
                            onPressed: () async {
                              final String insidedText =
                                  value.selection.textInside(value.text);
                              await FireHighWord.deleteFireWord(insidedText);

                              ContextMenuController.removeAny();
                              setState(() {});
                              // widget.adjusting(
                              //     isDo: false, wordToRemove: insidedText);
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
