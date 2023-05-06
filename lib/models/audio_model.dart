import 'dart:convert';

import 'package:path/path.dart';

class Audio {
  final String path;
  final String filetype;
  final Map<String, dynamic> tags;

  const Audio({
    required this.path,
    required this.filetype,
    required this.tags,
  });

  String name() {
    if (tags.containsKey('title')) {
      return tags['title'] as String;
    }

    return basename(path);
  }

  // Convert a PlaylistFile into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'path': path,
      'filetype': filetype,
      'tags': json.encode(tags),
    };
  }
}
