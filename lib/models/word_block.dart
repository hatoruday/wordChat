import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class WordBlock {
  final wordKey = GlobalKey();

  void showOveray(BuildContext context, Offset topLeft, Offset bottomRight) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(builder: ((context) {
      final width = bottomRight.dx - topLeft.dx;
      final height = bottomRight.dy - topLeft.dy;
      return Positioned(
        left: topLeft.dx,
        top: topLeft.dy,
        child: GestureDetector(
          onTap: () => overlayEntry.remove(),
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text("hello"),
            ),
          ),
        ),
      );
    }));
    overlay.insert(overlayEntry);
  }

  void onTap(BuildContext context) {
    //key.currentContext: 이 키를 갖고 있는 위젯이 빌드 되는 곳의 buildContext를 가져온다.
    final renderBox = wordKey.currentContext!.findRenderObject() as RenderBox;
    final topLeftOffset = renderBox.localToGlobal(Offset.zero);
    final bottomRightOffset =
        renderBox.localToGlobal(renderBox.size.bottomRight(Offset.zero));
    showOveray(context, topLeftOffset, bottomRightOffset);
  }

  final String id;
  final Color backColor;
  WordBlock({required this.id, required this.backColor});

  TextSpan createWordBlock() {
    return TextSpan(
      recognizer: TapGestureRecognizer()..onTap = () {},
      text: id,
      style: TextStyle(
        color: Colors.black,
        backgroundColor: backColor,
      ),
    );
  }

  WidgetSpan createWidgetSpan(BuildContext context) {
    return WidgetSpan(
      child: GestureDetector(
        onTap: () {
          onTap(context);
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
