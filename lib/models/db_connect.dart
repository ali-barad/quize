import 'package:http/http.dart' as http;
import '../models/question_model.dart';

import 'dart:convert';

class Dbconnect {
  final url = Uri.parse(
      'https://istequize-default-rtdb.firebaseio.com/ questions.json');

  Future<List<Question>> fetchQuestions() async {
    // ignore: non_constant_identifier_names
    return http.get(url).then((Response) {
      var data = json.decode(Response.body) as Map<String, dynamic>;

      List<Question> newQuestions = [];

      data.forEach((key, value) {
        var newQuestion = Question(
          id: key,
          title: value['title'],
          options: Map.castFrom(value['options']),
        );
        newQuestions.add(newQuestion);
      });
      return newQuestions;
    });
  }
}
