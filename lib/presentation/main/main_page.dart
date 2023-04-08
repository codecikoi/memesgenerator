import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memesgenerator/presentation/create_meme/create_meme_bloc.dart';
import 'package:memesgenerator/presentation/easter_egg/easter_egg_page.dart';
import 'package:memesgenerator/presentation/main/memes_with_docs_path.dart';
import 'package:memesgenerator/presentation/main/models/template_full.dart';
import 'package:memesgenerator/resources/app_colors.dart';
import 'package:provider/provider.dart';
import '../../data/models/meme.dart';
import '../widgets/app_text_button.dart';
import 'main_bloc.dart';
import '../create_meme/create_meme_page.dart';
import 'dart:io';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late MainBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = MainBloc();
  }

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: bloc,
      child: WillPopScope(
        onWillPop: () async {
          final goBack = await showConfirmationExitTextDialog(context);
          return goBack ?? false;
        },
        child: DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              centerTitle: true,
              backgroundColor: AppColors.lemon,
              foregroundColor: AppColors.darkGrey,
              title: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const EasterEggPage(),
                    ),
                  );
                },
                child: Text(
                  'Memesgenerator',
                  style: GoogleFonts.seymourOne(fontSize: 24),
                ),
              ),
              bottom: TabBar(
                labelColor: AppColors.darkGrey,
                indicatorColor: AppColors.fuchsia,
                indicatorWeight: 3,
                tabs: [
                  Tab(text: 'Created'.toUpperCase()),
                  Tab(text: 'Templates'.toUpperCase()),
                ],
              ),
            ),
            floatingActionButton: const CreateMemeFab(),
            backgroundColor: Colors.white,
            body: const TabBarView(
              children: [
                SafeArea(child: CreatedMemesGrid()),
                SafeArea(child: CreatedMemesGrid()),
              ],
            ),
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
}

class CreateMemeFab extends StatelessWidget {
  const CreateMemeFab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<MainBloc>(context, listen: false);
    return FloatingActionButton.extended(
      backgroundColor: AppColors.fuchsia,
      icon: const Icon(Icons.add, color: Colors.white),
      label: const Text('Create'),
      onPressed: () async {
        final selectedMemePath = await bloc.selectMeme();
        if (selectedMemePath == null) {
          return;
        }
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CreateMemePage(
              selectedMemePath: selectedMemePath,
            ),
          ),
        );
      },
    );
  }
}

Future<bool?> showConfirmationExitTextDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Are you sure you want to quit?'),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16),
        content: const Text('Memes can\'t make by themselves'),
        actions: [
          AppButton(
            onTap: () => Navigator.of(context).pop(false),
            text: 'Stay',
            color: AppColors.darkGrey,
          ),
          AppButton(
            onTap: () => Navigator.of(context).pop(true),
            text: 'Exit',
            color: Colors.transparent,
          ),
        ],
      );
    },
  );
}

class CreatedMemesGrid extends StatelessWidget {
  const CreatedMemesGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<MainBloc>(context, listen: false);
    return StreamBuilder<MemesWithDocsPath>(
      stream: bloc.observeMemesWithDocsPath(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }
        final items = snapshot.requireData.memes;
        final docsPath = snapshot.requireData.docsPath;
        return GridView.extent(
          maxCrossAxisExtent: 180,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          children: items.map((item) {
            return MemeGridItem(
              meme: item,
              docsPath: docsPath,
            );
          }).toList(),
        );
      },
    );
  }
}

class MemeGridItem extends StatelessWidget {
  final String docsPath;
  final Meme meme;

  const MemeGridItem({
    Key? key,
    required this.docsPath,
    required this.meme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageFile = File('$docsPath${Platform.pathSeparator}${meme.id}.png');
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return CreateMemePage(id: meme.id);
            },
          ),
        );
      },
      child: Stack(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
                border: Border.all(color: AppColors.darkGrey, width: 1)),
            child: imageFile.existsSync()
                ? Image.file(
                    File("$docsPath${Platform.pathSeparator}${meme.id}.png"),
                  )
                : Text(meme.id),
          ),
           Positioned(
            bottom: 4,
            right: 4,
            child: DeleteButton(memeId: meme.id),
          ),
        ],
      ),
    );
  }
}

class DeleteButton extends StatelessWidget {

  final String memeId;

  const DeleteButton({
    Key? key, required this.memeId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<MainBloc>(context, listen: false);
    return GestureDetector(
      onTap: () async {
        final delete = await showConfirmationDeleteDialog(context) ?? false;
        if (delete) {
          bloc.deleteMeme(memeId);
        }
      },
      child: Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.darkGrey38,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.delete_outline,
          size: 24,
          color: Colors.white,
        ),
      ),
    );
  }

  Future<bool?> showConfirmationDeleteDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete meme?'),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16),
          content: const Text('Meme will be deleted forever'),
          actions: [
            AppButton(
              onTap: () => Navigator.of(context).pop(false),
              text: 'Cancel',
              color: AppColors.darkGrey,
            ),
            AppButton(
              onTap: () => Navigator.of(context).pop(true),
              text: 'Delete',
              color: Colors.transparent,
            ),
          ],
        );
      },
    );
  }
}

class TemplatesGrid extends StatelessWidget {
  const TemplatesGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<MainBloc>(context, listen: false);
    return StreamBuilder<MemesWithDocsPath>(
      stream: bloc.observeMemesWithDocsPath(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }
        final templates = snapshot.requireData.memes;
        return GridView.extent(
          maxCrossAxisExtent: 180,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          children: templates.map((template) {
            return TemplateGridItem(template: template);
          }).toList(),
        );
      },
    );
  }
}

class TemplateGridItem extends StatelessWidget {
  final TemplateFull template;

  const TemplateGridItem({
    Key? key,
    required this.template,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageFile = File(template.fullImagePath);
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CreateMemePage(
              selectedMemePath: template.fullImagePath,
            ),
          ),
        );
      },
      child: Container(
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
            border: Border.all(color: AppColors.darkGrey, width: 1)),
        child:
            imageFile.existsSync() ? Image.file(imageFile) : Text(template.id),
      ),
    );
  }
}
