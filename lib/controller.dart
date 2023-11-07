import 'dart:async';
import 'dart:math';

import 'package:calculation_exercise/settings.dart' show getHighestScore, setHighestScore;

typedef Query = ({String question, String answer});

const _queriesPer1Game = 10;
const _skipPenalty = 5;

const _minNum = 1111;
const _maxNum = 9999;

final random = Random(DateTime.timestamp().millisecondsSinceEpoch);

Query _generateQuery() {
  final a = random.nextInt(_maxNum - _minNum + 1) + _minNum;
  final b = random.nextInt(_maxNum - _minNum + 1) + _minNum;
  String question = "$a + $b";
  String answer = (a + b).toString();
  return (question: question, answer: answer);
}

final StreamController<void> _onNewAnswerController = StreamController();
Stream<void> onNewAnswer = _onNewAnswerController.stream;

String _question = "no question yet";
String? _answer;

DateTime gameStart = DateTime(0);
int queryCount = 0;
int skipCount = 0;
double? _lastGameScore;

String get displayStr => "$queryCount/$_queriesPer1Game: $_question";

double? get lastGameScore => _lastGameScore;

void initGame() {
  queryCount = 1;
  skipCount = 0;
  gameStart = DateTime.now();
  _getNewAnswer();
}

void _getNewAnswer() {
  final query = _generateQuery();
  _answer = query.answer;
  _question = query.question;
  _onNewAnswerController.add(null);
}

String? submit(String? ans) {
  if (ans == null) return "Please enter answer.";
  if (_answer == null) return "Actual answer does not exist.";
  if (ans != _answer) return "Incorrect answer.";
  if (queryCount < _queriesPer1Game) {
    queryCount++;
    _getNewAnswer();
    return null;
  }
  _lastGameScore = DateTime.now().difference(gameStart).inMilliseconds / 1000 + skipCount * _skipPenalty;
  if (_lastGameScore! < getHighestScore()) setHighestScore(_lastGameScore!);
  initGame();
  return null;
}

void skip() {
  skipCount++;
  _getNewAnswer();
}
