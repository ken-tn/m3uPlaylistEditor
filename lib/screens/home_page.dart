import 'package:flutter/material.dart';
import 'package:m3u_playlist/widgets/playlist_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: PlaylistWidget(),
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
