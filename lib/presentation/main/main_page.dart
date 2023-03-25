import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memesgenerator/resources/app_colors.dart';
import 'package:provider/provider.dart';
import '../../data/models/meme.dart';
import '../widgets/app_text_button.dart';
import 'main_bloc.dart';
import '../create_meme/create_meme_page.dart';

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
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: AppColors.lemon,
            foregroundColor: AppColors.darkGrey,
            title: Text(
              'Memesgenerator',
              style: GoogleFonts.seymourOne(fontSize: 24),
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: AppColors.fuchsia,
            icon: const Icon(
              Icons.add,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const CreateMemePage(),
                ),
              );
            },
            label: const Text('Create'),
          ),
          backgroundColor: Colors.white,
          body: const SafeArea(
            child: MainPageContent(),
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

class MainPageContent extends StatefulWidget {
  const MainPageContent({Key? key}) : super(key: key);

  @override
  State<MainPageContent> createState() => _MainPageContentState();
}

class _MainPageContentState extends State<MainPageContent> {
  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<MainBloc>(context, listen: false);
    return StreamBuilder<List<Meme>>(
      initialData: const <Meme>[],
      stream: bloc.observeMemes(),
      builder: (context, snapshot) {
        final items = snapshot.hasData ? snapshot.data! : <Meme>[];
        print("MAIN. $items");
        return ListView(
          children: items.map(
            (meme) {
              return GestureDetector(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) {
                    return CreateMemePage(id: meme.id);
                  },
                )),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Text(meme.id),
                ),
              );
            },
          ).toList(),
        );
      },
    );
  }
}
