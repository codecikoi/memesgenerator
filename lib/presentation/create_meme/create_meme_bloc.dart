// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:memesgenerator/data/models/meme.dart';
import 'package:memesgenerator/data/models/text_with_position.dart';
import 'package:memesgenerator/data/repositories/memes_repository.dart';
import 'package:memesgenerator/domain/interactors/save_meme_interactor.dart';
import 'package:memesgenerator/domain/interactors/screenshot_interactor.dart';
import 'package:memesgenerator/presentation/create_meme/models/meme_text_offset.dart';
import 'package:memesgenerator/presentation/create_meme/models/meme_text_with_offset.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:screenshot/screenshot.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/position.dart';
import 'models/meme_text.dart';
import 'models/meme_text_with_selection.dart';
import 'package:collection/collection.dart';

class CreateMemeBloc {
  final memeTextsSubject = BehaviorSubject<List<MemeText>>.seeded(<MemeText>[]);
  final selectedMemeTextSubject = BehaviorSubject<MemeText?>.seeded(null);
  final memeTextOffsetsSubject =
      BehaviorSubject<List<MemeTextOffset>>.seeded(<MemeTextOffset>[]);
  final newMemeTextOffsetSubject =
      BehaviorSubject<MemeTextOffset?>.seeded(null);
  final memePathSubject = BehaviorSubject<String?>.seeded(null);
  final screenshotControllerSubject =
      BehaviorSubject<ScreenshotController>.seeded(ScreenshotController());

  StreamSubscription<MemeTextOffset?>? newMemeTextOffsetSubscription;
  StreamSubscription<bool>? saveMemeSubscription;
  StreamSubscription<Meme?>? existentMemeSubscription;
  StreamSubscription<void>? shareMemeSubscription;

  final String id;

  CreateMemeBloc({
    final String? id,
    final String? selectedMemePath,
  }) : id = id ?? const Uuid().v4() {
    memePathSubject.add(selectedMemePath);
    _subscribeToNewMemeTextOffset();
    _subscribeToExistentMeme();
  }

  Future<bool> isAllSaved() async {
    final savedMeme = await MemesRepository.getInstance().getItemById(id);
    if (savedMeme == null) {
      return false;
    }
    final savedMemeTexts = savedMeme.texts.map((textWithPosition) {
      return MemeText.createFromTextWithPosition(textWithPosition);
    }).toList();

    final savedMemeTextOffsets = savedMeme.texts.map((textWithPosition) {
      return MemeTextOffset(
        id: textWithPosition.id,
        offset: Offset(
          textWithPosition.position.left,
          textWithPosition.position.top,
        ),
      );
    }).toList();
    return const DeepCollectionEquality.unordered()
            .equals(savedMemeTexts, memeTextsSubject.value) &&
        const DeepCollectionEquality.unordered()
            .equals(savedMemeTextOffsets, memeTextsSubject.value);
  }

  void _subscribeToExistentMeme() {
    existentMemeSubscription =
        MemesRepository.getInstance().getItemById(id).asStream().listen(
      (meme) {
        if (meme == null) {
          return;
        }
        final memeTexts = meme.texts.map((textWithPosition) {
          return MemeText.createFromTextWithPosition(textWithPosition);
        }).toList();

        final memeTextOffsets = meme.texts.map((textWithPosition) {
          return MemeTextOffset(
            id: textWithPosition.id,
            offset: Offset(
              textWithPosition.position.left,
              textWithPosition.position.top,
            ),
          );
        }).toList();

        print('got memeTextOffsets in constructor: $memeTextOffsets');

        memeTextsSubject.add(memeTexts);
        memeTextOffsetsSubject.add(memeTextOffsets);

        if (meme.memePath != null) {
          getApplicationDocumentsDirectory().then((docsDirectory) {
            final onlyImageName =
                meme.memePath!.split(Platform.pathSeparator).last;
            final fullImagePath =
                "${docsDirectory.absolute.path}${Platform.pathSeparator}${SaveMemeInteractor.memesPathName}${Platform.pathSeparator}$onlyImageName";

            memePathSubject.add(fullImagePath);
          });
        }
      },
      onError: (error, stackTrace) =>
          print('Error in existentMemeSubscription: $error, $stackTrace'),
    );
  }

  void shareMeme() {
    shareMemeSubscription?.cancel();
    shareMemeSubscription = ScreenshotInteractor.getInstance()
        .shareScreenshot(screenshotControllerSubject.value)
        .asStream()
        .listen(
          (event) {},
          onError: (error, stackTrace) =>
              print('Error in shareMemeSubscription: $error, $stackTrace'),
        );
  }

  void changeFontSettings(
    final String textId,
    final Color color,
    final double fontSize,
    final FontWeight fontWeight,
  ) {
    final copiedList = [...memeTextsSubject.value];
    final oldMemeText =
        copiedList.firstWhereOrNull((memeText) => memeText.id == textId);
    if (oldMemeText == null) {
      return;
    }
    copiedList.remove(oldMemeText);
    copiedList.add(
      oldMemeText.copyWithChangedFontSettings(color, fontSize, fontWeight),
    );
    memeTextsSubject.add(copiedList);
  }

  void deleteMemeText(final String textId) {
    final updatedMemeTexts = [...memeTextsSubject.value];
    updatedMemeTexts.removeWhere((memeText) => memeText.id == textId);
    memeTextsSubject.add(updatedMemeTexts);
  }

  void saveMeme() {
    final memeTexts = memeTextsSubject.value;
    final memeTextOffsets = memeTextOffsetsSubject.value;
    final textsWithPositions = memeTexts.map((memeText) {
      final memeTextPosition =
          memeTextOffsets.firstWhereOrNull((memeTextOffset) {
        return memeTextOffset.id == memeText.id;
      });
      final position = Position(
        top: memeTextPosition?.offset.dy ?? 0,
        left: memeTextPosition?.offset.dx ?? 0,
      );
      return TextWithPosition(
        id: memeText.id,
        text: memeText.text,
        position: position,
        fontSize: memeText.fontSize,
        color: memeText.color,
        fontWeight: memeText.fontWeight,
      );
    }).toList();

    saveMemeSubscription = SaveMemeInteractor.getInstance()
        .saveMeme(
          id: id,
          textWithPositions: textsWithPositions,
          screenshotController: screenshotControllerSubject.value,
          imagePath: memePathSubject.value,
        )
        .asStream()
        .listen(
      (saved) {
        print('meme saved: $saved');
      },
      onError: (error, stackTrace) =>
          print('Error in saveMemeSubscription $error, $stackTrace'),
    );
  }

  void _subscribeToNewMemeTextOffset() {
    newMemeTextOffsetSubscription = newMemeTextOffsetSubject
        .debounceTime(const Duration(milliseconds: 300))
        .listen(
      (newMemeTextOffset) {
        if (newMemeTextOffset != null) {
          _changeMemeTextOffsetInternal(newMemeTextOffset);
        }
      },
      onError: (error, stackTrace) =>
          print('Error in newMemeTextOffsetSubscription $error, $stackTrace'),
    );
  }

  void changeMemeTextOffset(final String id, final Offset offset) {
    newMemeTextOffsetSubject.add(MemeTextOffset(id: id, offset: offset));
  }

  void _changeMemeTextOffsetInternal(final MemeTextOffset newMemeTextOffset) {
    final copiedMemeTextOffsets = [...memeTextOffsetsSubject.value];
    final currentMemeTextOffset = copiedMemeTextOffsets.firstWhereOrNull(
        (memeTextOffset) => memeTextOffset.id == newMemeTextOffset.id);

    if (currentMemeTextOffset != null) {
      copiedMemeTextOffsets.remove(currentMemeTextOffset);
    }
    copiedMemeTextOffsets.add(newMemeTextOffset);
    memeTextOffsetsSubject.add(copiedMemeTextOffsets);
  }

  void addNewText() {
    final newMemeText = MemeText.create();

    memeTextsSubject.add([...memeTextsSubject.value, newMemeText]);
    selectedMemeTextSubject.add(newMemeText);
  }

  void changeMemeText(final String id, final String text) {
    final copiedList = [...memeTextsSubject.value];
    final index = copiedList.indexWhere((memeText) => memeText.id == id);

    if (index == -1) {
      return;
    }
    final oldMemeText = copiedList[index];
    copiedList.removeAt(index);
    copiedList.insert(
      index,
      oldMemeText.copyWithChangedText(text),
    );
    memeTextsSubject.add(copiedList);
  }

  void selectMemeText(final String id) {
    final foundMemeText = memeTextsSubject.value
        .firstWhereOrNull((memeText) => memeText.id == id);
    selectedMemeTextSubject.add(foundMemeText);
  }

  void deselectMemeText() {
    selectedMemeTextSubject.add(null);
  }

  Stream<String?> observeMemePath() => memePathSubject.distinct();

  Stream<List<MemeText>> observeMemeTexts() => memeTextsSubject
      .distinct((prev, next) => const ListEquality().equals(prev, next));

  Stream<ScreenshotController> observeScreenshotController() =>
      screenshotControllerSubject.distinct();

  Stream<List<MemeTextWithOffset>> observeMemeTextWithOffsets() {
    return Rx.combineLatest2<List<MemeText>, List<MemeTextOffset>,
            List<MemeTextWithOffset>>(
        observeMemeTexts(), memeTextOffsetsSubject.distinct(),
        (memeTexts, memeTextOffsets) {
      return memeTexts.map((memeText) {
        final memeTextOffset = memeTextOffsets.firstWhereOrNull((element) {
          return element.id == memeText.id;
        });
        return MemeTextWithOffset(
          memeText: memeText,
          offset: memeTextOffset?.offset,
        );
      }).toList();
    }).distinct((prev, next) => const ListEquality().equals(prev, next));
  }

  Stream<MemeText?> observeSelectedMemeText() =>
      selectedMemeTextSubject.distinct();

  Stream<List<MemeTextWithSelection>> observeMemeTextsWithSelection() {
    return Rx.combineLatest2<List<MemeText>, MemeText?,
        List<MemeTextWithSelection>>(
      observeMemeTexts(),
      observeSelectedMemeText(),
      (memeTexts, selectedMemeText) {
        return memeTexts.map((memeText) {
          return MemeTextWithSelection(
              memeText: memeText,
              selected: memeText.id == selectedMemeText?.id);
        }).toList();
      },
    );
  }

  void dispose() {
    memeTextsSubject.close();
    selectedMemeTextSubject.close();
    memeTextOffsetsSubject.close();
    newMemeTextOffsetSubject.close();
    memePathSubject.close();
    screenshotControllerSubject.close();
    newMemeTextOffsetSubscription?.cancel();
    saveMemeSubscription?.cancel();
    existentMemeSubscription?.cancel();
    shareMemeSubscription?.cancel();
  }
}
