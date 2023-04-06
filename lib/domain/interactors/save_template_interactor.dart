// ignore_for_file: depend_on_referenced_packages

import 'package:memesgenerator/data/models/template.dart';
import 'package:memesgenerator/data/repositories/templates_repository.dart';
import 'package:memesgenerator/domain/interactors/copy_unique_file_interactor.dart';
import 'package:uuid/uuid.dart';

class SaveTemplateInteractor {
  static const templatesPathName = 'templates';

  static SaveTemplateInteractor? _instance;

  factory SaveTemplateInteractor.getInstance() =>
      _instance ??= SaveTemplateInteractor._internal();

  SaveTemplateInteractor._internal();

  Future<bool> saveTemplate({
    required final String imagePath,
  }) async {
    final newImagePath =
        await CopyUniqueFileInteractor.getInstance().copyUniqueFile(
      directoryWithFiles: templatesPathName,
      filePath: imagePath,
    );
    final template = Template(
      id: const Uuid().v4(),
      imageUrl: newImagePath,
    );
    return TemplatesRepository.getInstance().addToTemplates(template);
  }
}
