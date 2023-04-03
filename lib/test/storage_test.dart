import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

showToast(String msg) {
  Fluttertoast.showToast(
    msg: msg,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.CENTER,
    timeInSecForIosWeb: 1,
    backgroundColor: Colors.red,
    textColor: Colors.white,
    fontSize: 16.0,
  );
}

class Content {
  String content;
  String downloadurl;
  String date;

  Content({
    required this.content,
    required this.downloadurl,
    required this.date,
  });

  Content.fromJson(Map<String, dynamic> json)
      : content = json['content'],
        downloadurl = json['downloadurl'],
        date = json['date'];
  Map<String, dynamic> toJson() => {
        'content': content,
        'downloadurl': downloadurl,
        'date': date,
      };
}

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});
  @override
  ListScreenState createState() => ListScreenState();
}

class ListScreenState extends State<ListScreen> {
  final contentsRef = FirebaseFirestore.instance
      .collection('contents')
      .withConverter<Content>(
        fromFirestore: (snapshots, _) => Content.fromJson(snapshots.data()!),
        toFirestore: (content, _) => content.toJson(),
      );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test'),
      ),
      body: StreamBuilder<QuerySnapshot<Content>>(
        stream: contentsRef
            .snapshots(), //snapshots()는 contentsRef에 대한 실시간 데이터 스트림을 리턴함.
        //이 스트림은 해당 컬렉션의 추가, 변경, 혹은 제거될 때마다 업데이트됨.
        //StreamBuilder와 사용하면, 컬렉션의 변경사항에 대한 실시간 업데이트를 반영하여 UI를 빌드할 수 있습니다.
        //이는 데이터를 변경할 때마다 UI를 자동으로 업데이트하여 최신 정보를 표시하는데 도움을 준다.
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            //스냅샷을 가져오는데 에러가 잡힌다면,
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }
          if (!snapshot.hasData) {
            //아직 데이터를 못받았다면,
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.requireData;
          //print("size : ${data.size}");
          return ListView.builder(
            itemCount: data.docs.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.network(data.docs[index].data().downloadurl),
                    Text(
                      data.docs[index].data().date,
                      style: const TextStyle(color: Colors.black54),
                    ),
                    Text(
                      data.docs[index].data().content,
                      style: const TextStyle(fontSize: 20),
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/input');
        },
        tooltip: 'add',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});
  @override
  InputScreenState createState() => InputScreenState();
}

class InputScreenState extends State<InputScreen> {
  final controller = TextEditingController();
  bool isImageVisible = false;
  XFile? _image;

  String? downloadurl;
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future getGalleryImage() async {
    var image = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
      isImageVisible = true;
    });
  }

  uploadFile() async {
    if (_image == null) {
      showToast('no file selected');
      return null;
    }
    Reference ref =
        FirebaseStorage.instance.ref().child('images/${_image?.name}');
    await ref.putFile(File(_image!.path));
    downloadurl = await ref.getDownloadURL();
    //print('downloadurl : $downloadurl');
  }

  _save() async {
    await uploadFile();
    if (_image == null || downloadurl == null || controller.text.isEmpty) {
      showToast('invalid save data');
      return null;
    }
    CollectionReference collectionRef =
        FirebaseFirestore.instance.collection('contents');

    try {
      DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
      Content content = Content(
          content: controller.text,
          downloadurl: downloadurl!,
          date: dateFormat.format(DateTime.now()));
      await collectionRef.add(content.toJson());
      Navigator.pop(context);
    } catch (e) {
      print('save error.... $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text('Store, Storage Test'), actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.photo_album),
          onPressed: getGalleryImage,
        ),
        IconButton(
          icon: const Icon(Icons.save),
          onPressed: _save,
        ),
      ]),
      body: Column(
        children: [
          Visibility(
            visible: isImageVisible,
            child: isImageVisible
                ? SizedBox(
                    height: 200,
                    child: Image.file(
                      File(_image!.path),
                    ),
                  )
                : Container(),
          ),
          Container(
            margin: const EdgeInsets.all(10),
            child: TextField(
              style: const TextStyle(fontSize: 15.0),
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Data',
                prefixIcon: Icon(Icons.input),
                border: OutlineInputBorder(),
                hintText: "Hint Text",
                helperText: "데이터를 입력하세요.",
              ),
            ),
          ),
        ],
      ),
    );
  }
}
