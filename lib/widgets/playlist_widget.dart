import 'package:flutter/material.dart';
import 'package:m3u_playlist/utilities/app_state.dart';
import 'package:provider/provider.dart';

class PlaylistWidget extends StatelessWidget {
  const PlaylistWidget({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();
    var playlists = appState.musicData.elementAt(0);

    if (playlists.isEmpty) {
      return const Center(
        child: Text('Tap the + button to create a new playlist.'),
      );
    }

    return LayoutBuilder(builder: (context, constraints) {
      return SafeArea(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text('You have ${playlists.length} playlists: '),
            ),
            for (var playlist in playlists)
              ListTile(
                leading: const Icon(Icons.music_note),
                title: Text(
                  playlist.name(),
                ),
                onTap: () {
                  appState.updateSelectedPlaylist(playlist);
                  appState.changeToPage(1);
                },
              ),
          ],
        ),
      );
    });
  }
}
