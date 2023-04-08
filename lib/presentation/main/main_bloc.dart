import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:memesgenerator/data/models/template.dart';
import 'package:memesgenerator/data/repositories/memes_repository.dart';
import 'package:memesgenerator/data/repositories/templates_repository.dart';
import 'package:memesgenerator/domain/interactors/save_template_interactor.dart';
import 'package:memesgenerator/presentation/main/models/template_full.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import '../../data/models/meme.dart';
import 'memes_with_docs_path.dart';

class MainBloc {
  Stream<MemesWithDocsPath> observeMemesWithDocsPath() {
    return Rx.combineLatest2<List<Meme>, Directory, MemesWithDocsPath>(
      MemesRepository.getInstance().observeMemes(),
      getApplicationDocumentsDirectory().asStream(),
      (memes, docsDirectory) => MemesWithDocsPath(
        memes,
        docsDirectory.path,
      ),
    );
  }

  Stream<List<TemplateFull>> observeTemplates() {
    return Rx.combineLatest2<List<Template>, Directory, List<TemplateFull>>(
        TemplatesRepository.getInstance().observeTemplates(),
        getApplicationDocumentsDirectory().asStream(),
        (templates, docsDirectory) {
      return templates.map((template) {
        final fullImagePath =
            "${docsDirectory.absolute.path}${Platform.pathSeparator}${SaveTemplateInteractor.templatesPathName}${Platform.pathSeparator}${template.imageUrl}";
        return TemplateFull(
          id: template.id,
          fullImagePath: fullImagePath,
        );
      }).toList();
    });
  }

  Future<String?> selectMeme() async {
    final xfile = await ImagePicker().pickImage(source: ImageSource.gallery);
    final imagePath = xfile?.path;
    if (imagePath != null) {
      await SaveTemplateInteractor.getInstance()
          .saveTemplate(imagePath: imagePath);
    }
    return imagePath;
  }

  void deleteMeme(final String memeId) {
    print('deleted');
  }

  void dispose() {}
}
