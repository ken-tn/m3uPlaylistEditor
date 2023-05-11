import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:m3u_playlist/utilities/app_state.dart';
import 'package:m3u_playlist/utilities/file_utils.dart';
import 'package:m3u_playlist/widgets/playlist_widget.dart';
import 'package:provider/provider.dart';

var logger = Logger(
  printer: PrettyPrinter(),
);

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _formKey = GlobalKey<FormState>();
  String name = "";

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();
    var musicData = appState.musicData;

    Future<void> pullRefresh() async {
      appState.updateMusicData();
    }

    void showAction(BuildContext context) {
      showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Stack(
              children: [
                const Text("Create Playlist"),
                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24.0),
                        child: TextFormField(
                          onChanged: (value) => {name = value},
                          decoration: const InputDecoration(
                            border: UnderlineInputBorder(),
                            labelText: "Name",
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter playlist name.';
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ElevatedButton(
                          child: const Text("Create"),
                          onPressed: () {
                            // Validate returns true if the form is valid, or false otherwise.
                            if (_formKey.currentState!.validate()) {
                              // If the form is valid, display a snackbar.
                              createPlaylistFile(name).then((value) => {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content:
                                            Text('Created playlist $name.m3u'),
                                      ),
                                    ),
                                    pullRefresh(),
                                  });

                              Navigator.of(context).pop();
                            }
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
    }

    return FutureBuilder<List>(
      future: musicData,
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        return OrientationBuilder(builder: (context, orientation) {
          return Scaffold(
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                showAction(context);
              },
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: const Icon(Icons.add),
            ),
            body: RefreshIndicator(
              onRefresh: pullRefresh,
              child: PlaylistWidget(snapshot: snapshot),
            ),
          );
        });
      },
    );
  }
}
