import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddWordPage extends StatefulWidget {
  const AddWordPage({super.key});

  @override
  State<AddWordPage> createState() => _AddWordPageState();
}

class _AddWordPageState extends State<AddWordPage> {
  final GlobalKey _formKey = GlobalKey<FormState>();
  void loadUserInformation() async {
    String? userEmail = FirebaseAuth.instance.currentUser?.email;
    String userName = userEmail!.split("@")[0];

    String? userId = FirebaseAuth.instance.currentUser?.uid;
    final instance = FirebaseFirestore.instance;
    final highWordQuarySnapshot = await instance
        .collection("HighWord")
        .where("uid", isEqualTo: userId)
        .get();
    final highWordDocs = highWordQuarySnapshot.docs;
    final highWordLength = highWordDocs.length;
    Map<String, Object> userInformation = {
      "userName": userName,
      "highWordLength": highWordLength
    };
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

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
            style: const TextStyle(fontSize: 20),
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
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 1, horizontal: 15)),
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
            style: const TextStyle(fontSize: 20),
            decoration: InputDecoration(
              hintText: "단어",
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
                  const EdgeInsets.symmetric(vertical: 1, horizontal: 15),
            ),
            validator: (value) {
              if (value?.isEmpty ?? false) {
                return "단어를 입력해주세요.";
              }
              return null;
            },
            obscureText: false,
            onSaved: (String? value) {
              wordMean = value ?? "";
            },
          ),
        ],
      ),
    );
  }

  void saveTheWord() {
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
              ElevatedButton(
                onPressed: saveTheWord,
                style: const ButtonStyle(
                    fixedSize: MaterialStatePropertyAll(Size(100, 10))),
                child: const Text(
                  "단어저장",
                  style: TextStyle(fontSize: 15, color: Colors.black),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
