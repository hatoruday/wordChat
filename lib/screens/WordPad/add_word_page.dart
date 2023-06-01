import 'package:flutter/material.dart';

class AddWordPage extends StatelessWidget {
  AddWordPage({super.key});

  final GlobalKey _formKey = GlobalKey<FormState>();
  Widget addForm() {
    late String wordToAdd;
    late String wordMean;
    return Form(
      key: _formKey,
      child: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10, left: 20),
            child: Row(
              children: const [
                Text(
                  "단어",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),
          TextFormField(
            style: const TextStyle(fontSize: 10),
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey.shade200,
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(
                    color: Colors.black,
                    width: 1.0,
                  )),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(
                    color: Colors.black,
                    width: 1.0,
                  )),
              // border: OutlineInputBorder(
              //     borderRadius: BorderRadius.circular(40),
              //     borderSide:
              //         const BorderSide(color: Colors.red, width: 3.0)),
            ),
            validator: (value) {
              if (value?.isEmpty ?? false) {
                return 'please enter email';
              }
              return null;
            },
            onSaved: (String? value) {
              wordToAdd = value ?? "";
            },
          ),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10, left: 20),
            child: Row(
              children: const [
                Text(
                  "단어 뜻",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),
          TextFormField(
            style: const TextStyle(fontSize: 10),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey.shade200,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(
                  color: Colors.black,
                  width: 1.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(
                  color: Colors.black,
                  width: 1.0,
                ),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 1, horizontal: 5),
            ),
            validator: (value) {
              if (value?.isEmpty ?? false) {
                return "please enter the password";
              }
              return null;
            },
            obscureText: true,
            onSaved: (String? value) {
              wordMean = value ?? "";
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                "단어 추가",
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 15),
              )
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(color: Colors.grey.shade200),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Text("유저 12191962님"),
                  ],
                ),
                const SizedBox(
                  height: 7,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "현재 사용 단어수",
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    const Text("23 개 단어")
                  ],
                )
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    RichText(
                        text: const TextSpan(
                            text: "단어",
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                            children: [
                          TextSpan(
                              text: " 추가",
                              style:
                                  TextStyle(color: Colors.black, fontSize: 20)),
                        ]))
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  RichText(
                      text: TextSpan(
                          text: "현재 사용 단어",
                          style: TextStyle(color: Colors.grey.shade700),
                          children: const [
                        TextSpan(
                            text: " 23개",
                            style: TextStyle(color: Colors.black)),
                      ])),
                  Container(
                    decoration: BoxDecoration(color: Colors.grey.shade400),
                    width: 2,
                    height: 15,
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                  ),
                  RichText(
                      text: TextSpan(
                          text: "단어장 용량",
                          style: TextStyle(color: Colors.grey.shade700),
                          children: const [
                        TextSpan(
                            text: " 50개",
                            style: TextStyle(color: Colors.black)),
                      ])),
                ],
              ),
              addForm(),
            ],
          ),
        ),
      ],
    ));
  }
}
