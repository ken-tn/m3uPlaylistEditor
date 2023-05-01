import 'dart:convert';

class Audio {
  final String path;
  final String filetype;
  final Map<String, Object> tags;

  const Audio({
    required this.path,
    required this.filetype,
    required this.tags,
  });

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
