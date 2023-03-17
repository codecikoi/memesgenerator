import 'package:image_picker/image_picker.dart';
import 'package:memesgenerator/data/repositories/memes_repository.dart';

import '../../data/models/meme.dart';

class MainBloc {
  Stream<List<Meme>> observeMemes() =>
      MemesRepository.getInstance().observeMemes();

  Future<String?> chooseImagePath() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    print("Got result: $file");
    return file?.path;
  }

  void dispose() {}
}
