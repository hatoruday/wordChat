import 'package:flutter/material.dart';

class BlankContent extends StatefulWidget {
  const BlankContent({super.key});

  @override
  State<BlankContent> createState() => _BlankContentState();
}

class _BlankContentState extends State<BlankContent> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20), color: Colors.grey),
          child: const Text(
            "Cound i take a coffee?",
            style: TextStyle(color: Colors.white),
          ),
        ),
        const SizedBox(
          height: 40,
        ),
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20), color: Colors.grey),
          child: const Text("coffee"),
        ),
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20), color: Colors.grey),
          child: const Text("cake"),
        ),
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20), color: Colors.grey),
          child: const Text("kimchi"),
        ),
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20), color: Colors.grey),
          child: const Text("samdasoo"),
        )
      ],
    );
  }
}
