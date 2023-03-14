import 'meme_text.dart';

class MemeTextWithSelection {
  final MemeText memeText;
  final bool selected;

  MemeTextWithSelection({
    required this.memeText,
    required this.selected,
  });

  @override
  String toString() {
    return 'MemeTextWithSelection{memeText: $memeText, selected: $selected}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MemeTextWithSelection &&
          runtimeType == other.runtimeType &&
          memeText == other.memeText &&
          selected == other.selected;

  @override
  int get hashCode => memeText.hashCode ^ selected.hashCode;
}
