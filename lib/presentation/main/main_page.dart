import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memesgenerator/presentation/create_meme/create_meme_bloc.dart';
import 'package:memesgenerator/presentation/main/memes_with_docs_path.dart';
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
              title: Text(
                'Memesgenerator',
                style: GoogleFonts.seymourOne(fontSize: 24),
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
    final bloc = Provider.of<CreateMemeBloc>(context, listen: false);
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
            builder: (_) => const CreateMemePage(
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
            return GridItem(meme: item, docsPath, docsPath,);
          }).toList(),
        );
      },
    );
  }
}

class GridItem extends StatelessWidget {
  final String docsPath;
  final Meme meme;

  const GridItem({
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
      child: Container(
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
            border: Border.all(color: AppColors.darkGrey, width: 1)),
        child: imageFile.existsSync()
            ? Image.file(
                File("$docsPath${Platform.pathSeparator}${meme.id}.png"),
              )
            : Text(meme.id),
      ),
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
        final items = snapshot.requireData.memes;
        final docsPath = snapshot.requireData.docsPath;
        return GridView.extent(
          maxCrossAxisExtent: 180,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          children: items.map((item) {
            return GridItem(meme: item, docsPath, docsPath);
          }).toList(),
        );
      },
    );
  }
}
