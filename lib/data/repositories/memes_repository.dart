// ignore_for_file: depend_on_referenced_packages, prefer_void_to_null

import 'dart:convert';
import 'package:memesgenerator/data/models/meme.dart';
import 'package:memesgenerator/data/repositories/list_with_ids_reactive_repository.dart';
import 'package:memesgenerator/data/shared_preference_data.dart';

class MemesRepository extends ListWithIdsReactiveRepository<Meme> {
  final SharedPreferenceData spData;

  static MemesRepository? _instance;

  factory MemesRepository.getInstance() => _instance ??=
      MemesRepository._internal(SharedPreferenceData.getInstance());

  MemesRepository._internal(this.spData);

  @override
  Meme convertFromString(String rawItem) => Meme.fromJson(json.decode(rawItem));

  @override
  String convertToString(Meme item) => json.encode(item.toJson());

  @override
  dynamic getId(Meme item) => item.id;

  @override
  Future<List<String>> getRawData() => spData.getMemes();

  @override
  Future<bool> saveRawData(List<String> items) => spData.setMemes(items);
}
