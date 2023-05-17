import 'package:flutter/material.dart';

class QuestionAnswer extends StatefulWidget {
  String answerText;
  QuestionAnswer({super.key, required this.answerText});

  @override
  State<QuestionAnswer> createState() => _QuestionAnswerState();
}

class _QuestionAnswerState extends State<QuestionAnswer> {
  @override
  Widget build(BuildContext context) {
    double answerWidth = MediaQuery.of(context).size.width;
    return Container(
      width: answerWidth * 0.85,
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: const Color(0xFF808080)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.answerText,
            style: const TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
          )
        ],
      ),
    );
  }
}
