import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memesgenerator/presentation/create_meme/create_meme_bloc.dart';
import 'package:memesgenerator/presentation/easter_egg/easter_egg_page.dart';
import 'package:memesgenerator/presentation/main/memes_with_docs_path.dart';
import 'package:memesgenerator/presentation/main/models/meme_thumbnail.dart';
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

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  late MainBloc bloc;
  late TabController tabController;

  double tabIndex = 0;

  @override
  void initState() {
    super.initState();
    bloc = MainBloc();

    tabController = TabController(length: 2, vsync: this);

    tabController.animation!.addListener(() {
      setState(() => tabIndex = tabController.animation!.value);
    });
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
                controller: tabController,
                labelColor: AppColors.darkGrey,
                indicatorColor: AppColors.fuchsia,
                indicatorWeight: 3,
                tabs: [
                  Tab(text: 'Created'.toUpperCase()),
                  Tab(text: 'Templates'.toUpperCase()),
                ],
              ),
            ),
            floatingActionButton: tabIndex <= 0.5
                ? AnimatedScale(
                    scale: 1 - tabIndex / 0.5,
                    duration: const Duration(milliseconds: 100),
                    child: const CreateMemeFab(),
                  )
                : AnimatedScale(
                    scale: (tabIndex - 0.5) / 0.5,
                    duration: const Duration(milliseconds: 100),
                    child: const CreateTemplateFab(),
                  ),
            backgroundColor: Colors.white,
            body: const TabBarView(
              children: [
                SafeArea(child: CreatedMemesGrid()),
                SafeArea(child: TemplatesGrid()),
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
      label: const Text('Meme'),
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

class CreateTemplateFab extends StatelessWidget {
  const CreateTemplateFab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<MainBloc>(context, listen: false);
    return FloatingActionButton.extended(
      backgroundColor: AppColors.fuchsia,
      icon: const Icon(Icons.add, color: Colors.white),
      label: const Text('Template'),
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
    return StreamBuilder<List<MemeThumbnail>>(
      stream: bloc.observeMemes(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }
        final items = snapshot.requireData;
        return GridView.extent(
          maxCrossAxisExtent: 180,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          children: items.map((item) {
            return MemeGridItem(
              memeThumbnail: item,
            );
          }).toList(),
        );
      },
    );
  }
}

class MemeGridItem extends StatelessWidget {
  final MemeThumbnail memeThumbnail;

  const MemeGridItem({
    Key? key,
    required this.memeThumbnail,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<MainBloc>(context, listen: false);
    final imageFile = File(memeThumbnail.fullImageUrl);
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return CreateMemePage(id: memeThumbnail.memeId);
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
                ? Image.file(imageFile)
                : Text(memeThumbnail.memeId),
          ),
          Positioned(
            bottom: 4,
            right: 4,
            child: DeleteButton(
              onDeleteAction: () => bloc.deleteMeme(memeThumbnail.memeId),
              itemName: 'meme',
            ),
          ),
        ],
      ),
    );
  }
}

class DeleteButton extends StatelessWidget {
  final VoidCallback onDeleteAction;
  final String itemName;

  const DeleteButton({
    Key? key,
    required this.onDeleteAction,
    required this.itemName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final delete = await showConfirmationDeleteDialog(context) ?? false;
        if (delete) {
          onDeleteAction();
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
          title: Text('Delete $itemName?'),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16),
          content: Text('Selected $itemName will be deleted forever'),
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
    return StreamBuilder<List<TemplateFull>>(
      stream: bloc.observeTemplates(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }
        final templates = snapshot.requireData;
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
    final bloc = Provider.of<MainBloc>(context, listen: false);
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
      child: Stack(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.darkGrey, width: 1),
            ),
            child: imageFile.existsSync()
                ? Image.file(imageFile)
                : Text(template.id),
          ),
          Positioned(
            bottom: 4,
            right: 4,
            child: DeleteButton(
              onDeleteAction: () => bloc.deleteTemplate(template.id),
              itemName: 'template',
            ),
          ),
        ],
      ),
    );
  }
}
