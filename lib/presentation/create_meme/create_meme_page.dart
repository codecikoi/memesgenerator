import 'package:flutter/material.dart';
import 'package:memesgenerator/presentation/create_meme/font_settings_bottom_sheet.dart';
import 'package:memesgenerator/presentation/create_meme/models/meme_text_with_offset.dart';
import 'package:memesgenerator/presentation/widgets/app_text_button.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'create_meme_bloc.dart';
import '../../resources/app_colors.dart';
import 'meme_text_on_canvas.dart';
import 'models/meme_text.dart';
import 'models/meme_text_with_selection.dart';
import 'dart:io';

class CreateMemePage extends StatefulWidget {
  final String? id;
  final String? selectedMemePath;

  const CreateMemePage({
    Key? key,
    this.id,
    this.selectedMemePath,
  }) : super(key: key);

  @override
  State<CreateMemePage> createState() => _CreateMemePageState();
}

class _CreateMemePageState extends State<CreateMemePage> {
  late CreateMemeBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = CreateMemeBloc(
      id: widget.id,
      selectedMemePath: widget.selectedMemePath,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: bloc,
      child: WillPopScope(
        onWillPop: () async {
          final allSaved = await bloc.isAllSaved();
          if (allSaved) {
            return true;
          }
          final goBack = await showConfirmationExitTextDialog(context);
          return goBack ?? false;
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            backgroundColor: AppColors.lemon,
            foregroundColor: AppColors.darkGrey,
            title: const Text('Creating meme'),
            bottom: const EditTextBar(),
            actions: [
              AnimatedIconButton(
                onTap: () => bloc.shareMeme(),
                icon: Icons.share,
              ),
              AnimatedIconButton(
                onTap: () => bloc.saveMeme(),
                icon: Icons.save,
              ),
            ],
          ),
          backgroundColor: Colors.white,
          body: const SafeArea(
            child: CreateMemePageContent(),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }

  Future<bool?> showConfirmationExitTextDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Are you sure?'),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16),
          content: const Text('You will lose all changes'),
          actions: [
            AppButton(
              onTap: () => Navigator.of(context).pop(false),
              text: 'Cancel',
              color: AppColors.darkGrey,
            ),
            AppButton(
                onTap: () => Navigator.of(context).pop(true),
                text: 'Exit',
                color: AppColors.fuchsia),
          ],
        );
      },
    );
  }
}

class AnimatedIconButton extends StatefulWidget {
  final VoidCallback onTap;
  final IconData icon;

  const AnimatedIconButton({
    Key? key,
    required this.onTap,
    required this.icon,
  }) : super(key: key);

  @override
  State<AnimatedIconButton> createState() => _AnimatedIconButtonState();
}

class _AnimatedIconButtonState extends State<AnimatedIconButton> {
  double scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onTap;
        setState(() => scale = 1.5);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 200),
          scale: scale,
          curve: Curves.bounceInOut,
          child: Icon(
            widget.icon,
            color: AppColors.darkGrey,
            size: 24,
          ),
          onEnd: () => setState(() => scale = 1.5),
        ),
      ),
    );
  }
}

class EditTextBar extends StatefulWidget implements PreferredSizeWidget {
  const EditTextBar({Key? key}) : super(key: key);

  @override
  State<EditTextBar> createState() => _EditTextBarState();

  @override
  Size get preferredSize => const Size.fromHeight(68.0);
}

class _EditTextBarState extends State<EditTextBar> {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<CreateMemeBloc>(context, listen: false);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: StreamBuilder<MemeText?>(
          stream: bloc.observeSelectedMemeText(),
          builder: (context, snapshot) {
            final MemeText? selectedMemeText =
                snapshot.hasData ? snapshot.data : null;
            if (selectedMemeText?.text != controller.text) {
              final newText = selectedMemeText?.text ?? '';
              controller.text = newText;
              controller.selection =
                  TextSelection.collapsed(offset: newText.length);
            }
            final haveSelected = selectedMemeText != null;
            return TextField(
              enabled: haveSelected,
              controller: controller,
              onChanged: (text) {
                if (haveSelected) {
                  bloc.changeMemeText(selectedMemeText.id, text);
                }
              },
              onEditingComplete: () => bloc.deselectMemeText(),
              cursorColor: AppColors.fuchsia,
              decoration: InputDecoration(
                filled: true,
                hintText: haveSelected ? 'write text' : null,
                hintStyle: TextStyle(fontSize: 16, color: AppColors.darkGrey38),
                fillColor:
                    haveSelected ? AppColors.fuchsia16 : AppColors.darkGrey6,
                disabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.darkGrey38, width: 1),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.fuchsia38, width: 1),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.fuchsia, width: 2),
                ),
              ),
            );
          }),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class CreateMemePageContent extends StatefulWidget {
  const CreateMemePageContent({Key? key}) : super(key: key);

  @override
  State<CreateMemePageContent> createState() => _CreateMemePageContentState();
}

class _CreateMemePageContentState extends State<CreateMemePageContent> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Expanded(
          flex: 2,
          child: MemeCanvasWidget(),
        ),
        Container(
          height: 1,
          width: double.infinity,
          color: AppColors.darkGrey,
        ),
        const Expanded(
          flex: 1,
          child: BottomList(),
        ),
      ],
    );
  }
}

class BottomList extends StatelessWidget {
  const BottomList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<CreateMemeBloc>(context, listen: false);

    return Container(
      color: Colors.white,
      child: StreamBuilder<List<MemeTextWithSelection>>(
        stream: bloc.observeMemeTextsWithSelection(),
        initialData: const <MemeTextWithSelection>[],
        builder: (context, snapshot) {
          final items =
              snapshot.hasData ? snapshot.data! : <MemeTextWithSelection>[];
          return ListView.separated(
            itemCount: items.length + 1,
            itemBuilder: (BuildContext context, int index) {
              if (index == 0) {
                return const AddNewTextButton();
              }
              final item = items[index - 1];
              return BottomMemeText(item: item);
            },
            separatorBuilder: (BuildContext context, int index) {
              if (index == 0) {
                return const SizedBox.shrink();
              }
              return const BottomSeparator();
            },
          );
        },
      ),
    );
  }
}

class BottomMemeText extends StatelessWidget {
  const BottomMemeText({
    Key? key,
    required this.item,
  }) : super(key: key);

  final MemeTextWithSelection item;

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<CreateMemeBloc>(context, listen: false);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => bloc.selectMemeText(item.memeText.id),
      child: Container(
        color: item.selected ? AppColors.darkGrey16 : null,
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            const SizedBox(width: 16.0),
            Expanded(
              child: Text(
                item.memeText.text,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.darkGrey,
                ),
              ),
            ),
            const SizedBox(width: 4.0),
            BottomMemeTextAction(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  builder: (context) {
                    return Provider.value(
                      value: bloc,
                      child: FontSettingBottomSheet(memeText: item.memeText),
                    );
                  },
                );
              },
              icon: Icons.font_download_outlined,
            ),
            const SizedBox(width: 4),
            BottomMemeTextAction(
              icon: Icons.delete_forever_outlined,
              onTap: () {
                bloc.deleteMemeText(item.memeText.id);
              },
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}

class BottomMemeTextAction extends StatelessWidget {
  const BottomMemeTextAction({
    Key? key,
    required this.onTap,
    required this.icon,
  }) : super(key: key);

  final VoidCallback onTap;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(icon),
      ),
    );
  }
}

class BottomSeparator extends StatelessWidget {
  const BottomSeparator({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 16),
      height: 1,
      color: AppColors.darkGrey,
    );
  }
}

class MemeCanvasWidget extends StatelessWidget {
  const MemeCanvasWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<CreateMemeBloc>(context, listen: false);
    return Container(
      color: AppColors.darkGrey38,
      padding: const EdgeInsets.all(8),
      alignment: Alignment.topCenter,
      child: AspectRatio(
        aspectRatio: 1,
        child: GestureDetector(
          onTap: () => bloc.deselectMemeText(),
          child: StreamBuilder<ScreenshotController>(
            stream: bloc.observeScreenshotController(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox.shrink();
              }
              return Screenshot(
                controller: snapshot.requireData,
                child: Stack(
                  children: const [
                    BackgroundImage(),
                    MemeTexts(),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class MemeTexts extends StatelessWidget {
  const MemeTexts({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<CreateMemeBloc>(context, listen: false);
    return StreamBuilder<List<MemeTextWithOffset>>(
      initialData: const <MemeTextWithOffset>[],
      stream: bloc.observeMemeTextWithOffsets(),
      builder: (context, snapshot) {
        final memeTextWithOffsets =
            snapshot.hasData ? snapshot.data! : const <MemeTextWithOffset>[];
        return LayoutBuilder(builder: (context, constraints) {
          return Stack(
            children: memeTextWithOffsets.map((memeTextWithOffsets) {
              return DraggableMemeText(
                key: ValueKey(memeTextWithOffsets.memeText.id),
                memeTextWithOffset: memeTextWithOffsets,
                parentConstraints: constraints,
              );
            }).toList(),
          );
        });
      },
    );
  }
}

class BackgroundImage extends StatelessWidget {
  const BackgroundImage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<CreateMemeBloc>(context, listen: false);
    return StreamBuilder<String?>(
      stream: bloc.observeMemePath(),
      builder: (context, snapshot) {
        final path = snapshot.hasData ? snapshot.data : null;
        if (path == null) {
          return Container(color: Colors.white);
        }
        return Image.file(File(path));
      },
    );
  }
}

class DraggableMemeText extends StatefulWidget {
  final MemeTextWithOffset memeTextWithOffset;
  final BoxConstraints parentConstraints;

  const DraggableMemeText({
    Key? key,
    required this.parentConstraints,
    required this.memeTextWithOffset,
  }) : super(key: key);

  @override
  State<DraggableMemeText> createState() => _DraggableMemeTextState();
}

class _DraggableMemeTextState extends State<DraggableMemeText> {
  late double top;
  late double left;
  final double padding = 8;

  @override
  void initState() {
    super.initState();

    top = widget.memeTextWithOffset.offset?.dy ??
        widget.parentConstraints.maxHeight / 2;
    left = widget.memeTextWithOffset.offset?.dx ??
        widget.parentConstraints.maxWidth / 3;

    if (widget.memeTextWithOffset.offset == null) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        final bloc = Provider.of<CreateMemeBloc>(context, listen: false);
        bloc.changeMemeTextOffset(
          widget.memeTextWithOffset.memeText.id,
          Offset(left, top),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<CreateMemeBloc>(context, listen: false);
    return Positioned(
      top: top,
      left: left,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => bloc.selectMemeText(widget.memeTextWithOffset.memeText.id),
        onPanUpdate: (details) {
          bloc.selectMemeText(widget.memeTextWithOffset.memeText.id);
          setState(() {
            left = calculateLeft(details);
            top = calculateTop(details);

            bloc.changeMemeTextOffset(
              widget.memeTextWithOffset.memeText.id,
              Offset(left, top),
            );
          });
        },
        child: StreamBuilder<MemeText?>(
          stream: bloc.observeSelectedMemeText(),
          builder: (context, snapshot) {
            final selectedItem = snapshot.hasData ? snapshot.data : null;
            final selected =
                widget.memeTextWithOffset.memeText.id == selectedItem?.id;
            return MemeTextOnCanvas(
              selected: selected,
              padding: padding,
              parentConstraints: widget.parentConstraints,
              text: widget.memeTextWithOffset.memeText.text,
              fontSize: widget.memeTextWithOffset.memeText.fontSize,
              fontWeight: widget.memeTextWithOffset.memeText.fontWeight,
              color: widget.memeTextWithOffset.memeText.color,
            );
          },
        ),
      ),
    );
  }

  double calculateTop(DragUpdateDetails details) {
    final rawTop = top + details.delta.dy;
    if (rawTop < 0) {
      return 0;
    }
    if (rawTop > widget.parentConstraints.maxHeight - padding * 2 - 30) {
      return widget.parentConstraints.maxHeight - padding * 2 - 30;
    }
    return rawTop;
  }

  double calculateLeft(DragUpdateDetails details) {
    final rawLeft = left + details.delta.dx;
    if (rawLeft < 0) {
      return 0;
    }
    if (rawLeft > widget.parentConstraints.maxWidth - padding * 2 - 10) {
      return widget.parentConstraints.maxWidth - padding * 2 - 10;
    }
    return rawLeft;
  }
}

class AddNewTextButton extends StatelessWidget {
  const AddNewTextButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<CreateMemeBloc>(context, listen: false);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => bloc.addNewText(),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add, color: AppColors.fuchsia),
              const SizedBox(width: 8),
              Text(
                'Add text'.toUpperCase(),
                style: const TextStyle(
                  color: AppColors.fuchsia,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
