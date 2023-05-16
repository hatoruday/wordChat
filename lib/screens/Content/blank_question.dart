import 'package:flutter/material.dart';

class BlankQuestion extends StatefulWidget {
  double screenWidth;
  BlankQuestion({super.key, required this.screenWidth});

  @override
  State<BlankQuestion> createState() => _BlankQuestionState();
}

class _BlankQuestionState extends State<BlankQuestion> {
  @override
  Widget build(BuildContext context) {
    double containerWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Row(
          children: const [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Text(
                "질의응답형",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
        Container(
          clipBehavior: Clip.hardEdge,
          constraints: const BoxConstraints(minHeight: 100, maxHeight: 200),
          width: widget.screenWidth * 0.8,
          margin: const EdgeInsets.symmetric(vertical: 10),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: const Color(0xFF696969),
          ),
          //ts3883072
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Transform.scale(
                        scale: 1.0,
                        child: Transform.translate(
                            offset: const Offset(-30, 0),
                            child: Image.asset("images/simple_DARK_Q.png"))),
                  ),
                  Flexible(
                    child: Transform.scale(
                        scale: 2.0,
                        child: Transform.translate(
                            offset: const Offset(-20, 0),
                            child: Image.asset("images/simple_DARK_A.png"))),
                  )
                ],
              ),
              // Flexible(
              //   child: Transform.scale(
              //     scale: 1.0,
              //     child: Transform.translate(
              //       offset: const Offset(0, 0),
              //       child: Image.asset("images/question_mark.png"),
              //     ),
              //   ),
              // ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    child: const Text(
                      "Can i take a coffee?",
                      style: TextStyle(color: Colors.black, fontSize: 20),
                    ),
                  ),
                  const Divider(
                    height: 20.0,
                    color: Colors.black,
                    thickness: 3,
                  ),
                  // Container(
                  //   height: 5.0,
                  //   width: containerWidth - 150,
                  //   decoration: const BoxDecoration(
                  //       border: Border(
                  //           bottom:
                  //               BorderSide(color: Colors.black, width: 1.0))),
                  // ),
                  Container(
                    child: const Text(
                      "Yes, It is your coffee.",
                      style: TextStyle(color: Colors.black, fontSize: 20),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
