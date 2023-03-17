import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceData {
  static const memeKey = 'meme_key';

  Future<bool> setMemes(final List<String> memes) async {
    final sp = await SharedPreferences.getInstance();
    final result = sp.setStringList(memeKey, memes);
    return result;
  }

  Future<List<String>> getMemes() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getStringList(memeKey) ?? [];
  }
}
