import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:milchat/models/fire_high_word.dart';

class WordBox extends StatefulWidget {
  bool isShowed = false;
  FireHighWord fireHighWordObject;
  WordBox({
    super.key,
    required this.fireHighWordObject,
  });

  @override
  State<WordBox> createState() => _WordBoxState();
}

class _WordBoxState extends State<WordBox> {
  Future editWordLevel(String wordToEdit, String wordLevel) async {
    final userEmail = FirebaseAuth.instance.currentUser?.email;
    final storeInstance = FirebaseFirestore.instance;
    //highword를 firebase로부터 load한다.
    final searchingWordQuarySnapShot = await storeInstance
        .collection("HighWord")
        .where("user", isEqualTo: userEmail)
        .where("highWord", isEqualTo: wordToEdit)
        .get();
    final listQuaryDocumentSnapshot = searchingWordQuarySnapShot.docs;
    wordLevel = (wordLevel == "어려워요")
        ? "애매해요"
        : (wordLevel == "애매해요")
            ? "외웠어요"
            : "어려워요";

    //로드한 단어들을 ChatBlock의 static변수에 추가한다.
    for (QueryDocumentSnapshot documentSnapshot in listQuaryDocumentSnapshot) {
      FireHighWord wordObject = FireHighWord.fromJson(
          documentSnapshot.data() as Map<String, dynamic>);
      wordObject.level = wordLevel;
      DocumentReference docRefs =
          storeInstance.collection("HighWord").doc(documentSnapshot.id);
      docRefs.update(wordObject.toJson());
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    //final double screenHeight = MediaQuery.of(context).size.height;
    final Map<String, dynamic> wordMap = widget.fireHighWordObject.toJson();
    return GestureDetector(
      onTap: () {
        setState(() {
          widget.isShowed = !widget.isShowed;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        // width: screenWidth * 0.8,
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
                GestureDetector(
                  onTap: () {
                    editWordLevel(wordMap['highWord'], wordMap['level']);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey[50]),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      child: Text(
                        wordMap['level'] ?? "어려워요",
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                  ),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  wordMap['highWord'],
                  style: const TextStyle(
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
                          wordMap['wordMeaning'],
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  (wordMap['group'] == "none-selected"
                          ? "그룹 미지정"
                          : wordMap['group']) ??
                      "그룹 미지정",
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const FaIcon(
                  FontAwesomeIcons.volumeHigh,
                  color: Colors.white,
                )
              ],
            )
          ]),
        ),
      ),
    );
  }
}
