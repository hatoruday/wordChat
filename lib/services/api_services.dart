import 'package:cloud_functions/cloud_functions.dart';

class ApiService {
  String selectedCategory, selectedLight;
  ApiService({
    required this.selectedCategory,
    required this.selectedLight,
  });

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
  Future makeChatResponse() async {
    String textRequest =
        "Including a word of \"$selectedLight\", Please make short paragraphs excluding enumerating sentences with numbers about \"$selectedCategory\"";
    return await fireCreateTexts(textRequest);
  }
}
