import 'package:flutter/material.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("설정")),
        body: Container(
          decoration: BoxDecoration(color: Colors.grey.shade300),
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Row(
                children: [
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 7),
                        child: Text(
                          "앱 설정",
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ),
                      const SettingElement(text: "로그인 설정"),
                      const SettingElement(text: "카테고리 설정")
                    ],
                  ))
                ],
              ),
            )
          ]),
        ));
  }
}

class SettingElement extends StatelessWidget {
  final String text;
  const SettingElement({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/setting/category');
      },
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(
              text,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const Icon(Icons.chevron_right)
          ]),
        ),
      ),
    );
  }
}
