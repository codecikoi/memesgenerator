import 'package:equatable/equatable.dart';

class   MemeThumbnail extends Equatable {
  final String memeId;
  final String fullImageUrl;

  const MemeThumbnail({
    required this.memeId,
    required this.fullImageUrl,
  });

  @override
  List<Object?> get props => [memeId, fullImageUrl];
}
