import 'package:equatable/equatable.dart';
import '../../data/models/meme.dart';

class MemesWithDocsPath extends Equatable {
  final List<Meme> memes;
  final String docsPath;

  const MemesWithDocsPath(
    this.memes,
    this.docsPath,
  );

  @override
  List<Object?> get props => [memes, docsPath];
}
