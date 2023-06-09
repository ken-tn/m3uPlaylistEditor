import 'package:flutter/material.dart';
import 'package:m3u_playlist/models/playlist_model.dart';
import 'package:m3u_playlist/screens/editor_page.dart';
import 'package:m3u_playlist/utilities/app_state.dart';
import 'package:provider/provider.dart';

class PlaylistWidget extends StatefulWidget {
  final AsyncSnapshot snapshot;
  const PlaylistWidget({
    super.key,
    required this.snapshot,
  });

  @override
  State<PlaylistWidget> createState() => _PlaylistWidget();
}

void _onRenameClick(
    BuildContext context, Playlist playlist, AppState appState) {
  //File p = File(playlist.path).rename(newPath);
}

void _onDeleteClick(
    BuildContext context, Playlist playlist, AppState appState) async {
  late String message;
  Navigator.of(context).pop();
  final bool? success = await playlist.delete();
  if (success == null) {
    message = 'Failed to read ${playlist.name()}';
  } else {
    if (success) {
      appState.updatePlaylists();
      message = 'Deleted ${playlist.name()}';
    } else {
      message = 'Failed to delete ${playlist.name()}';
    }
  }

  // ignore: use_build_context_synchronously
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
    ),
  );
}

const Map<String, Function> buttons = {
  'Rename': _onRenameClick,
  'Delete': _onDeleteClick,
};

class _PlaylistWidget extends State<PlaylistWidget> {
  void showAction(BuildContext context, var playlist, AppState appState) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("${playlist.name()}"),
                  ),
                  for (var entry in buttons.entries)
                    ListTile(
                      title: Text(entry.key),
                      onTap: () => entry.value(context, playlist, appState),
                    ),
                ],
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

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();

    return LayoutBuilder(builder: (context, constraints) {
      var snapshot = widget.snapshot;
      if (snapshot.hasData) {
        var playlists = snapshot.data!;

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
              for (Playlist playlist in playlists)
                ListTile(
                  leading: const Icon(Icons.music_note),
                  title: Text(
                    playlist.name(),
                  ),
                  subtitle: Text('${playlist.songs.length} songs'),
                  onTap: () {
                    appState.updateSelectedPlaylist(playlist);
                    Navigator.of(context).push(_editorRoute());
                  },
                  onLongPress: () {
                    showAction(context, playlist, appState);
                  },
                ),
            ],
          ),
        );
      } else {
        return const Center(child: CircularProgressIndicator());
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
