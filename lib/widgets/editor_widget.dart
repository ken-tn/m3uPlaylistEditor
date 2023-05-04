import 'package:flutter/material.dart';
import 'package:m3u_playlist/models/audio_model.dart';
import 'package:m3u_playlist/models/playlist_model.dart';
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
            List<Audio> songs = snapshot.data![1];
            Map<String, Audio> loadedSongs =
                appState.selectedPlaylist.mapToAudio(songs);

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
                  Expanded(
                    child: ListView(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(2),
                        ),
                        for (var entry in loadedSongs.entries)
                          ListTile(
                            enabled: entry.value.tags.containsKey('isMissing')
                                ? false
                                : true,
                            leading: const Icon(Icons.music_note),
                            title: Text(entry.value.name()),
                            onTap: () {},
                          ),
                      ],
                    ),
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
