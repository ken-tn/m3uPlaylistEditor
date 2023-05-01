import 'package:flutter/material.dart';
import 'package:m3u_playlist/widgets/playlist_widget.dart';

class PlaylistPage extends StatelessWidget {
  const PlaylistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: const PlaylistWidget(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Add your onPressed code here!
          },
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: const Icon(Icons.add),
        ),
      );
    });
  }
}
