import 'package:flutter/material.dart';

class WordBox extends StatefulWidget {
  bool isShowed = false;
  WordBox({super.key});

  @override
  State<WordBox> createState() => _WordBoxState();
}

class _WordBoxState extends State<WordBox> {
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () {
        setState(() {
          widget.isShowed = !widget.isShowed;
        });
      },
      child: Container(
        width: screenWidth * 0.9,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 33, 31, 31),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey[50]),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    child: Text(
                      "어려워요",
                      style: TextStyle(fontSize: 10),
                    ),
                  ),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: const [
                Text(
                  "upset",
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 23,
                      color: Colors.white),
                ),
              ],
            ),
            widget.isShowed
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Text(
                          "화난",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Colors.indigo.shade700),
                        ),
                      ],
                    ),
                  )
                : const SizedBox(
                    height: 23,
                  ),
            Row(
              children: const [
                Text(
                  "그룹 미지정",
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            )
          ]),
        ),
      ),
    );
  }
}
