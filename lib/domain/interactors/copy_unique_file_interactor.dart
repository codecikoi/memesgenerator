import 'dart:io';
import 'package:collection/collection.dart';
import 'package:path_provider/path_provider.dart';

class CopyUniqueFileInteractor {
  static CopyUniqueFileInteractor? _instance;

  factory CopyUniqueFileInteractor.getInstance() =>
      _instance ??= CopyUniqueFileInteractor._internal();

  CopyUniqueFileInteractor._internal();

  Future<String> copyUniqueFile({
    required final String directoryWithFiles,
    required final String filePath,
  }) async {
    final docsPath = await getApplicationDocumentsDirectory();
    final memePath =
        "${docsPath.absolute.path}${Platform.pathSeparator}$directoryWithFiles";
    final memesDirectory = Directory(memePath);
    await memesDirectory.create(recursive: true);
    final currentFiles = memesDirectory.listSync();

    final imageName = _getFileNameByPath(filePath);
    final oldFileWithTheSameName = currentFiles.firstWhereOrNull(
      (element) {
        return _getFileNameByPath(element.path) == imageName && element is File;
      },
    );

    final newImagePath = "$memePath${Platform.pathSeparator}$imageName";
    final tempFile = File(filePath);
    if (oldFileWithTheSameName == null) {
      // файлов с таким названием нет, сохраняем файл в документы

      await tempFile.copy(newImagePath);
      return imageName;
    }

    final oldFileLength = await (oldFileWithTheSameName as File).length();
    final newFileLength = await tempFile.length();
    if (oldFileLength == newFileLength) {
      // такой файл уже существует, не сохраняем его заново

      return imageName;
    }
    final indexOfLastDot = imageName.lastIndexOf(".");
    if (indexOfLastDot == -1) {
      // у файла нет расширения, сохраняем файл в документы

      await tempFile.copy(newImagePath);
      return imageName;
    }
    final extension = imageName.substring(indexOfLastDot);
    final imageNameWithoutExtension = imageName.substring(0, indexOfLastDot);
    final indexOfLastUnderscore = imageNameWithoutExtension.lastIndexOf("_");
    if (indexOfLastUnderscore == -1) {
      // файл с таким именем есть, но с дургим размером
      // суффик не является числом
      // сохраняем файл в документы и добавляем суфикс "_1"

      final newImageName = '${imageNameWithoutExtension}_1$extension';

      final correctedNewImagePath =
          "$memePath${Platform.pathSeparator}$newImageName";
      await tempFile.copy(correctedNewImagePath);
      return newImageName;
    }

    final suffixNumberString =
        imageNameWithoutExtension.substring(indexOfLastUnderscore + 1);

    final suffixNumber = int.tryParse(suffixNumberString);

    if (suffixNumber == null) {
      // файл с таким именем есть, но с дургим размером
      // увеличивам число в суффиксе и сохраняем файл в документы и добавляем суфикс "_1"

      final newImageName = '${imageNameWithoutExtension}_1$extension';
      final correctedNewImagePath =
          "$memePath${Platform.pathSeparator}$newImageName";
      await tempFile.copy(correctedNewImagePath);
      return newImageName;
    }
    final imageNameWithoutSuffix =
        imageNameWithoutExtension.substring(0, indexOfLastUnderscore);
    final newImageName =
        '${imageNameWithoutSuffix}_${suffixNumber + 1}$extension';
    final correctedNewImagePath =
        "$memePath${Platform.pathSeparator}$newImageName";
    await tempFile.copy(correctedNewImagePath);
    return newImageName;
  }

  String _getFileNameByPath(String imagePath) =>
      imagePath.split(Platform.pathSeparator).last;
}
