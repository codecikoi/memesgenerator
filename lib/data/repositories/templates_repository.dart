// ignore_for_file: depend_on_referenced_packages, prefer_void_to_null
import 'dart:convert';

import 'package:memesgenerator/data/repositories/list_with_ids_reactive_repository.dart';
import '../models/template.dart';
import '../shared_preference_data.dart';

class TemplatesRepository extends ListWithIdsReactiveRepository<Template> {
  final SharedPreferenceData spData;

  static TemplatesRepository? _instance;

  factory TemplatesRepository.getInstance() => _instance ??=
      TemplatesRepository._internal(SharedPreferenceData.getInstance());

  TemplatesRepository._internal(this.spData);

  @override
  Template convertFromString(String rawItem) =>
      Template.fromJson(json.decode(rawItem));

  @override
  String convertToString(Template item) => json.encode(item.toJson());

  @override
  dynamic getId(Template item) => item.id;

  @override
  Future<List<String>> getRawData() => spData.getTemplates();

  @override
  Future<bool> saveRawData(List<String> items) => spData.setTemplates(items);
}
