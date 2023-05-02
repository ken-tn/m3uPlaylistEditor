import 'package:flutter/material.dart';
import 'package:m3u_playlist/screens/editor_page.dart';
import 'package:m3u_playlist/utilities/app_state.dart';
import 'package:provider/provider.dart';

class PlaylistWidget extends StatelessWidget {
  const PlaylistWidget({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();
    var musicData = appState.musicData;

    return FutureBuilder<List>(
        future: musicData,
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.hasData) {
            var playlists = snapshot.data![0];

            if (playlists.isEmpty) {
              return const Center(
                child: Text('Tap the + button to create a new playlist.'),
              );
            }

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
                        Navigator.of(context).push(_editorRoute());
                      },
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

Route _editorRoute() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => const EditorPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}
