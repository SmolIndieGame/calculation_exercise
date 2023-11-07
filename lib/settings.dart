import 'package:shared_preferences/shared_preferences.dart';

late final SharedPreferences _instance;

const _highScore = "calc_ex_high_score";

Future<void> init() async {
  _instance = await SharedPreferences.getInstance();
}

double getHighestScore() {
  var ret = _instance.getDouble(_highScore);
  if (ret == null) {
    ret = 0;
    _instance.setDouble(_highScore, ret);
  }
  return ret == 0 ? double.infinity : ret;
}

void setHighestScore(double value) {
  _instance.setDouble(_highScore, value);
}
