// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:quize_pro/widgets/next_button.dart';
import 'package:quize_pro/widgets/question_widget.dart';
import '../constants.dart';
import '../models/question_model.dart';
import '../widgets/option_card.dart';
import '../widgets/result_box.dart';
import '../models/db_connect.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var db = Dbconnect();

  // List<Question> _questions = [
  //   Question(
  //       id: '10',
  //       title: 'What  is 2 + 2 ?',
  //       options: {'5': false, '30': false, '4': true, '10': false}),
  //   Question(
  //       id: '11',
  //       title: 'What  is 2 + 3 ?',
  //       options: {'5': true, '30': false, '4': false, '10': false}),
  // ];

  late Future _questions;

  Future<List<Question>> getData() async {
    return db.fetchQuestions();
  }

  @override
  void intState() {
    _questions = getData();
    super.initState();
  }

  int index = 0;
  int score = 0;
  bool ispressed = false;
  bool isAlreadyeSelected = false;

  void nextQuestion(int questionLength) {
    if (index == questionLength - 1) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => ResultBox(
                result: score,
                questionLength: questionLength,
                onPressed: startOver,
              ));
    } else {
      if (ispressed) {
        setState(() {
          index++;
          ispressed = false;
          isAlreadyeSelected = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please select any option'),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.symmetric(vertical: 20.0),
        ));
      }
    }
  }

  // ignore: non_constant_identifier_names
  void CheckAnswerAndUpdate(bool value) {
    if (isAlreadyeSelected) {
      return;
    } else {
      if (value == true) {
        score++;
      }
      setState(() {
        ispressed = true;
        isAlreadyeSelected = true;
      });
    }
  }

  void startOver() {
    setState(() {
      index = 0;
      score = 0;
      ispressed = false;
      isAlreadyeSelected = false;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _questions as Future<List<Question>>,
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Center(
              child: Text('${snapshot.error}'),
            );
          } else if (snapshot.hasData) {
            var extractedData = snapshot.data as List<Question>;
            return Scaffold(
              backgroundColor: background,
              appBar: AppBar(
                title: const Text('Iste Quiz'),
                backgroundColor: background,
                shadowColor: Colors.transparent,
                actions: [
                  Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Text(
                        'Score : $score',
                        // ignore: prefer_const_constructors
                        style: TextStyle(
                          fontSize: 18.0,
                        ),
                      )),
                ],
              ),
              body: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  children: [
                    QuestionWidget(
                        question: extractedData[index].title,
                        indexAction: index,
                        totalQuestions: extractedData.length),
                    const Divider(
                      color: neutral,
                    ),
                    const SizedBox(
                      height: 25.0,
                    ),
                    for (int i = 0;
                        i < extractedData[index].options.length;
                        i++)
                      GestureDetector(
                        onTap: () => CheckAnswerAndUpdate(
                            extractedData[index].options.values.toList()[i]),
                        child: OptionCard(
                          option: extractedData[index].options.keys.toList()[i],
                          color: ispressed
                              ? extractedData[index]
                                          .options
                                          .values
                                          .toList()[i] ==
                                      true
                                  ? correct
                                  : incorrect
                              : neutral,
                        ),
                      ),
                  ],
                ),
              ),
              floatingActionButton: GestureDetector(
                onTap: () => nextQuestion(extractedData.length),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: NextButton(),
                ),
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerFloat,
            );
          }
        } else {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 20.0),
                Text(
                  'please Wait while Questions..',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    decoration: TextDecoration.none,
                    fontSize: 14.0,
                  ),
                )
              ],
            ),
          );
        }
        return const Center(
          child: Text('No Data !'),
        );
      },
    );
  }
}
