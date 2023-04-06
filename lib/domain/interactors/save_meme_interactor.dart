// ignore_for_file: depend_on_referenced_packages

import 'package:memesgenerator/domain/interactors/copy_unique_file_interactor.dart';
import 'package:memesgenerator/domain/interactors/screenshot_interactor.dart';
import 'package:screenshot/screenshot.dart';
import '../../data/models/meme.dart';
import '../../data/models/text_with_position.dart';
import 'package:memesgenerator/data/repositories/memes_repository.dart';

class SaveMemeInteractor {
  static const memesPathName = 'memes';

  static SaveMemeInteractor? _instance;

  factory SaveMemeInteractor.getInstance() =>
      _instance ??= SaveMemeInteractor._internal();

  SaveMemeInteractor._internal();

  Future<bool> saveMeme({
    required final String id,
    required final List<TextWithPosition> textWithPositions,
    required final ScreenshotController screenshotController,
    final String? imagePath,
  }) async {
    if (imagePath == null) {
      final meme = Meme(id: id, texts: textWithPositions);
      return MemesRepository.getInstance().addToMemes(meme);
    }

    await ScreenshotInteractor.getInstance()
        .saveThumbnail(id, screenshotController);
    final newImagePath = await CopyUniqueFileInteractor.getInstance()
        .copyUniqueFile(directoryWithFiles: memesPathName, filePath: imagePath);

    final meme = Meme(
      id: id,
      texts: textWithPositions,
      memePath: newImagePath,
    );
    return MemesRepository.getInstance().addToMemes(meme);
  }
}
