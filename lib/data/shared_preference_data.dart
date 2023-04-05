import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceData {
  static const memeKey = 'meme_key';
  static const templateKey = 'template_key';

  static SharedPreferenceData? _instance;

  factory SharedPreferenceData.getInstance() =>
      _instance ??= SharedPreferenceData._internal();

  SharedPreferenceData._internal();

  Future<bool> setMemes(final List<String> memes) => setItems(memes, memeKey);

  Future<List<String>> getMemes() => getItems(memeKey);

  Future<bool> setTemplates(final List<String> templates) =>
      setItems(templates, templateKey);

  Future<List<String>> getTemplates() => getItems(templateKey);

  Future<bool> setItems(
    final List<String> items,
    final String key,
  ) async {
    final sp = await SharedPreferences.getInstance();
    final result = sp.setStringList(key, items);
    return result;
  }

  Future<List<String>> getItems(
    final String key,
  ) async {
    final sp = await SharedPreferences.getInstance();
    return sp.getStringList(key) ?? [];
  }
}
