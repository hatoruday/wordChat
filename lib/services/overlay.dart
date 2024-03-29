import 'package:flutter/material.dart';
import 'package:milchat/screens/ReadIt/translate_block.dart';
import 'package:milchat/services/api_services.dart';

class MakeOverlay {
  final BuildContext context;
  final String tapWord;

  MakeOverlay(this.context, this.tapWord);

  static void showWordOverlay(
      BuildContext context, Offset topLeft, String papagoResult) {
    //MediaQuery를 통해 현재 화면의 스크린 사이즈를 구하고 반으로 나눠 TranslateBlock을 생성할 가운데 x좌표를 구한다.
    final screenWidth = MediaQuery.of(context).size.width;
    final centerCoordinate = screenWidth / 2;

    //overay를 할 컨테이너 TranslateBlock에 key를 부여하여 buildcontext로 부터 renderBox를 가져온다. => creentContext가 null이다.

    // final renderBox = blockKey.currentContext?.findRenderObject() as RenderBox;
    // renderBox.globalToLocal(Offset.zero);

    final overlay = Overlay.of(context);
    late OverlayEntry wordOverlayEntry;
    wordOverlayEntry = OverlayEntry(builder: ((context) {
      return Positioned(
        top: topLeft.dy,
        left: centerCoordinate / 5,
        child: GestureDetector(
          onTap: () => wordOverlayEntry.remove(),
          child: Material(
              color: Colors.transparent,
              child: TrnaslateBlock(
                widgetWidth: centerCoordinate * 1.6,
                singWord: papagoResult,
                langType: "[EngToKo]",
                sentences: "단어검색",
                image: Image.asset(
                  'images/translate_icon.png',
                  width: 75,
                  height: 75,
                  color: Colors.white,
                ),
                isSentence: false,
              )),
        ),
      );
    }));
    overlay.insert(wordOverlayEntry);
  }

  static void showSentenceOverlay(
      BuildContext context, Offset topLeft, String papagoResult) {
    //MediaQuery를 통해 현재 화면의 스크린 사이즈를 구하고 반으로 나눠 TranslateBlock을 생성할 가운데 x좌표를 구한다.
    final screenWidth = MediaQuery.of(context).size.width;
    final centerCoordinate = screenWidth / 2;
    final overlay = Overlay.of(context);
    late OverlayEntry sentenceOverlayEntry;
    sentenceOverlayEntry = OverlayEntry(builder: ((context) {
      return Positioned(
        top: topLeft.dy,
        left: 0,
        child: GestureDetector(
          onTap: () => sentenceOverlayEntry.remove(),
          child: Material(
              color: Colors.transparent,
              child: TrnaslateBlock(
                widgetWidth: screenWidth,
                singWord: papagoResult,
                langType: "[EngToKo]",
                sentences: "문장번역",
                image: Image.asset(
                  'images/ppaggo.png',
                  width: 75,
                  height: 75,
                ),
                isSentence: true,
              )),
        ),
      );
    }));
    overlay.insert(sentenceOverlayEntry);
  }

  static void onTap(
      {required BuildContext overLayContext,
      String? tapWord,
      String? tapSentence,
      required Offset topLeftOffset}) {
    //key.currentContext: 이 키를 갖고 있는 위젯이 빌드 되는 곳의 buildContext를 가져온다.
    if (tapSentence == null) {
      ApiService.getNaverResponse(tapWord!).then((value) {
        showWordOverlay(overLayContext, topLeftOffset, value);
      });
    } else {
      ApiService.getNaverResponse(tapSentence).then((value) {
        showSentenceOverlay(overLayContext, topLeftOffset, value);
      });
    }
  }
}
