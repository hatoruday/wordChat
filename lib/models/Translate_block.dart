import 'package:flutter/material.dart';

class TrnaslateBlock extends StatelessWidget {
  final String singWord, langType, sentences;
  final Image image;
  final bool isSentence;
  final Color _blackColor = const Color(0xFF1F2123);
  final double widgetWidth;

  const TrnaslateBlock({
    super.key,
    required this.singWord,
    required this.langType,
    required this.sentences,
    required this.image,
    required this.isSentence,
    required this.widgetWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widgetWidth,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: isSentence ? Colors.white : _blackColor,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    singWord,
                    style: TextStyle(
                      fontSize: isSentence ? 20 : 30,
                      color: isSentence ? _blackColor : Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Text(
                        sentences,
                        style: TextStyle(
                          fontSize: isSentence ? 15 : 20,
                          fontWeight: FontWeight.w600,
                          color: isSentence ? _blackColor : Colors.white,
                        ),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(langType,
                          style: TextStyle(
                            fontSize: isSentence ? 10 : 20,
                            color: isSentence
                                ? _blackColor
                                : Colors.white.withOpacity(0.8),
                          )),
                    ],
                  ),
                ],
              ),
            ),
            Transform.scale(
                scale: 1.0,
                child: Transform.translate(
                    offset: const Offset(0, 0), child: image))
          ],
        ),
      ),
    );
  }
}
