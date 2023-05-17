import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:milchat/screens/ReadIt/chat_block.dart';
import 'package:milchat/screens/ReadIt/readit_screen.dart';
import 'package:milchat/screens/ReadIt/word_block.dart';
import 'package:milchat/services/api_services.dart';
import 'package:milchat/test/storage_test.dart';

class FireHighWord {
  String highWord;
  String wordMeaning;
  String user;
  String date;
  String level;
  String group;

  FireHighWord({
    required this.highWord,
    required this.wordMeaning,
    required this.user,
    required this.date,
    required this.level,
    required this.group,
  });

  FireHighWord.fromJson(Map<String, dynamic> json)
      : highWord = json['highWord'],
        wordMeaning = json['wordMeaning'] ?? "모르겠어요",
        user = json['user'],
        date = json['date'],
        level = json['level'] ?? "어려워요",
        group = json['group'] ?? "non-selected";
  Map<String, dynamic> toJson() => {
        'highWord': highWord,
        'user': user,
        'date': date,
        'level': level,
        'group': group,
        'wordMeaning': wordMeaning,
      };

  static void doHighLight() {
    for (var light in ChatBlock.highlights) {
      for (var j = 0; j < ReadItScreen.blocks.length; j++) {
        for (var k = 0; k < ReadItScreen.blocks[j].wordBlocks.length; k++) {
          if (ReadItScreen.blocks[j].wordBlocks[k].id == light) {
            WordBlock highBlock = WordBlock(
                id: light,
                backColor: Colors.indigo.shade200,
                textColor: Colors.white);
            ReadItScreen.blocks[j].wordBlocks[k] = highBlock;
          }
        }
      }
    }
  }

  static void removeHighLight(String removedWord) {
    for (var block in ReadItScreen.blocks) {
      for (var i = 0; i < block.wordBlocks.length; i++) {
        if (block.wordBlocks[i].id == removedWord) {
          WordBlock highBlock = WordBlock(
              id: block.wordBlocks[i].id, backColor: Colors.transparent);
          block.wordBlocks[i] = highBlock;
        }
      }
    }
  }

  static Future saveFireWord(
      {required String insidedText,
      String? level,
      String? group,
      String? customMeaning}) async {
    try {
      String? user = FirebaseAuth.instance.currentUser?.email;
      DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
      String papagoResponse = await ApiService.getNaverResponse(insidedText);
      final highWord = FireHighWord(
        user: user!,
        highWord: insidedText,
        wordMeaning: customMeaning ?? papagoResponse,
        date: dateFormat.format(DateTime.now()),
        level: level ?? "어려워요",
        group: group ?? "non-selected",
      );
      ChatBlock.highlights.add(insidedText);
      CollectionReference collectionRef =
          FirebaseFirestore.instance.collection("HighWord");
      await collectionRef.add(highWord.toJson());
    } catch (e) {
      showToast("saveFireWord error");
      showToast(e.toString());
    }
  }

  static Future deleteFireWord(String insidedText) async {
    try {
      String? user = FirebaseAuth.instance.currentUser?.email;

      CollectionReference collectionRef =
          FirebaseFirestore.instance.collection("HighWord");
      QuerySnapshot fireWordDocRef = await collectionRef
          .where("highWord", isEqualTo: insidedText)
          .where("user", isEqualTo: user)
          .get();
      for (var quarydocumentsnapshot in fireWordDocRef.docs) {
        quarydocumentsnapshot.reference.delete();
      }
      ChatBlock.highlights.remove(insidedText);
    } catch (e) {
      showToast("deleteFireWord error");
      showToast("deleteFireWordError$e");
    }
  }
}
