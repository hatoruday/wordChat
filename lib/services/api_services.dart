import 'package:cloud_functions/cloud_functions.dart';
import 'package:dio/dio.dart';

class ApiService {
  String? selectedCategory, selectedLight;
  ApiService({
    this.selectedCategory = "any subject",
    this.selectedLight = "any",
  });
  static Future<String> getNaverResponse(String quary) async {
    String naverURL = "https://openapi.naver.com/v1/papago/n2mt";
    var dio = Dio(BaseOptions(
      baseUrl: naverURL,
      connectTimeout: const Duration(
        seconds: 50000,
      ),
      receiveTimeout: const Duration(
        seconds: 50000,
      ),
    ));
    return "";
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
