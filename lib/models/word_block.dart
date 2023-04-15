import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:milchat/services/overLay.dart';

class WordBlock {
  final wordKey = GlobalKey();
  bool isSelected = false;
  final String id;
  final Color backColor;
  final TapGestureRecognizer _tapGestureRecognizer = TapGestureRecognizer();

  WordBlock({required this.id, required this.backColor}) {
    _tapGestureRecognizer.onTapDown = onTapWordBlock;
  }

  void onTapWordBlock(TapDownDetails details) {}

  TextSpan createWordBlock(BuildContext context) {
    final TextSpan wordBlockTextSpan;
    wordBlockTextSpan = TextSpan(
      text: id,
      style: TextStyle(
        color: Colors.black,
        backgroundColor: backColor,
      ),
    );
    //TextSpan을 감싸는 TextPainter를 생성한다.

    return wordBlockTextSpan;
  }

  WidgetSpan createWidgetSpan(BuildContext context) {
    return WidgetSpan(
      child: GestureDetector(
        onTap: () {
          final renderBox =
              wordKey.currentContext!.findRenderObject() as RenderBox;
          final topLeftOffset = renderBox.localToGlobal(Offset.zero);
          MakeOverlay.onTap(context, id, topLeftOffset);
        },
        child: Text(
          id,
          key: wordKey,
          style: TextStyle(
            color: Colors.black,
            backgroundColor: backColor,
          ),
        ),
      ),
    );
  }
}
