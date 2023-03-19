import 'package:flutter/material.dart';
import 'package:memesgenerator/presentation/create_meme/create_meme_bloc.dart';
import 'package:memesgenerator/presentation/create_meme/create_meme_page.dart';
import 'package:memesgenerator/presentation/create_meme/models/meme_text.dart';
import 'package:memesgenerator/presentation/widgets/app_text_button.dart';
import 'package:memesgenerator/resources/app_colors.dart';
import 'package:provider/provider.dart';

class FontSettingBottomSheet extends StatefulWidget {
  final MemeText memeText;
  const FontSettingBottomSheet({
    Key? key,
    required this.memeText,
  }) : super(key: key);

  @override
  State<FontSettingBottomSheet> createState() => _FontSettingBottomSheetState();
}

class _FontSettingBottomSheetState extends State<FontSettingBottomSheet> {
  late double fontSize;
  late Color color;

  @override
  void initState() {
    super.initState();
    fontSize = widget.memeText.fontSize;
    color = widget.memeText.color;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8.0),
          Center(
            child: Container(
              height: 4,
              width: 64,
              decoration: BoxDecoration(
                color: AppColors.darkGrey38,
                borderRadius: BorderRadius.circular(2.0),
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          MemeTextOnCanvas(
            selected: true,
            parentConstraints: BoxConstraints.expand(),
            padding: 8,
            text: widget.memeText.text,
            color: color,
          ),
          const SizedBox(height: 16.0),
          FontSizeSlider(
            initialFontSize: fontSize,
            changeFontSize: (value) {
              setState(() => fontSize = value);
            },
          ),
          const SizedBox(height: 16.0),
          ColorSelection(
            changeColor: (color) {
              setState(() => this.color = color);
            },
          ),
          const SizedBox(height: 36.0),
          Align(
            alignment: Alignment.centerRight,
            child: Buttons(
              textId: widget.memeText.id,
              color: color,
              fontSize: fontSize,
            ),
          ),
          const SizedBox(height: 48.0),
        ],
      ),
    );
  }
}

class Buttons extends StatelessWidget {
  final String textId;
  final Color color;
  final double fontSize;

  const Buttons({
    Key? key,
    required this.textId,
    required this.color,
    required this.fontSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<CreateMemeBloc>(context, listen: false);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppButton(
          onTap: () => Navigator.of(context).pop(),
          text: 'Cancel',
          color: AppColors.darkGrey,
        ),
        const SizedBox(width: 24.0),
        AppButton(
          onTap: () {
            bloc.changeFontSettings(textId, color, fontSize);
            Navigator.of(context).pop();
          },
          text: 'Save',
          color: AppColors.fuchsia,
        ),
        const SizedBox(width: 16.0),
      ],
    );
  }
}

class ColorSelection extends StatelessWidget {
  final ValueChanged<Color> changeColor;

  const ColorSelection({Key? key, required this.changeColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const SizedBox(width: 16.0),
        const Text(
          'Color',
          style: TextStyle(
            fontSize: 20,
            color: AppColors.darkGrey,
          ),
        ),
        const SizedBox(width: 16.0),
        ColorSelectionBox(changeColor: changeColor, color: Colors.white),
        const SizedBox(width: 16.0),
        ColorSelectionBox(changeColor: changeColor, color: Colors.black),
        const SizedBox(width: 16.0),
      ],
    );
  }
}

class ColorSelectionBox extends StatelessWidget {
  final ValueChanged<Color> changeColor;
  final Color color;
  const ColorSelectionBox({
    Key? key,
    required this.changeColor,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => changeColor(color),
      child: Container(
        height: 32,
        width: 32,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: Colors.black, width: 1),
        ),
      ),
    );
  }
}

class FontSizeSlider extends StatefulWidget {
  final ValueChanged<double> changeFontSize;
  final double initialFontSize;

  const FontSizeSlider({
    Key? key,
    required this.changeFontSize,
    required this.initialFontSize,
  }) : super(key: key);

  @override
  State<FontSizeSlider> createState() => _FontSizeSliderState();
}

class _FontSizeSliderState extends State<FontSizeSlider> {
  late double fontSize;

  @override
  void initState() {
    super.initState();
    fontSize = widget.initialFontSize;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 16),
        const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Text(
            'Size:',
            style: TextStyle(
              fontSize: 20,
              color: AppColors.darkGrey,
            ),
          ),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
                activeTrackColor: AppColors.fuchsia,
                inactiveTrackColor: AppColors.fuchsia38,
                valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
                thumbColor: AppColors.fuchsia,
                inactiveTickMarkColor: AppColors.fuchsia,
                valueIndicatorColor: AppColors.fuchsia),
            child: Slider(
              value: fontSize,
              min: 16,
              max: 32,
              divisions: 10,
              label: fontSize.round().toString(),
              onChanged: (double value) {
                setState(
                  () {
                    fontSize = value;
                    widget.changeFontSize(value);
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}