import 'package:flutter/material.dart';
import 'package:m3u_playlist/utilities/app_state.dart';
import 'package:provider/provider.dart';

class EditorWidget extends StatelessWidget {
  const EditorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();
    return FutureBuilder<List>(
        future: appState.musicData,
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.hasData) {
            var songs = snapshot.data![1];
            return SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(2),
                        ),
                        for (var audio in songs)
                          ListTile(
                            leading: const Icon(Icons.music_note),
                            title: Text(
                              audio.name(),
                            ),
                            onTap: () {},
                          ),
                      ],
                    ),
                  ),
                  const Expanded(
                    //TODO: read m3u playlist
                    child: Text('TODO: read m3u playlist'),
                  ),
                ],
              ),
            );
          } else {
            return const CircularProgressIndicator();
          }
        });
  }
}
