import 'package:path/path.dart';

class Playlist {
  final String path;

  const Playlist({
    required this.path,
  });

  // Convert a PlaylistFile into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'path': path,
    };
  }

  String name() {
    return basename(path);
  }

  @override
  String toString() {
    return 'Playlist{path: $path}';
  }
}