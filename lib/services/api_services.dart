import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:dio/dio.dart';

class ApiService {
  String? selectedCategory, selectedLight;
  ApiService({
    this.selectedCategory = "any subject",
    this.selectedLight = "any",
  });

  static Future<String> getNaverResponse(String quary) async {
    String naverURL = "https://openapi.naver.com/";
    var dio = Dio(BaseOptions(
        baseUrl: naverURL,
        connectTimeout: const Duration(
          seconds: 50000,
        ),
        receiveTimeout: const Duration(
          seconds: 50000,
        ),
        headers: {
          HttpHeaders.contentTypeHeader:
              'application/x-www-form-urlencoded; charset=UTF-8',
          'X-Naver-Client-Id': 'gpSXBjpB2Lyper124ybx',
          'X-Naver-Client-Secret': 'WA0Yzk3s6V',
        }));
    try {
      var response = await dio.post('v1/papago/n2mt',
          data: 'source=en&target=ko&text=$quary');
      if (response.statusCode == 200) {
        Map<String, dynamic> responseMap = response.data;
        var result = responseMap['message']['result']['translatedText'];
        print('naverApiResponse: ${result.toString()}');
        return result.toString();
      }
      print(response.statusCode);
    } catch (e) {
      print('dioPostError..$e');
    }
    return "error";
  }

  Future<String?> fireCreateTexts(String inputPrompt) async {
    try {
      final HttpsCallable callable =
          FirebaseFunctions.instance.httpsCallable('generateText');

      final HttpsCallableResult result =
          await callable.call(<String, dynamic>{'prompt': inputPrompt});
      return result.data['text']['text'];
    } on FirebaseFunctionsException catch (error) {
      print('$error occured');
      // print(error.code);
      // print(error.details);
      // print(error.message);
    }
    return null;
  }

  //createText():
  Future makeChatResponse(String? justChat) async {
    String textRequest =
        "Including a word of \"$selectedLight\", Please make short paragraphs excluding enumerating sentences with numbers about \"$selectedCategory\"";

    return await fireCreateTexts(justChat ?? textRequest);
  }
}
