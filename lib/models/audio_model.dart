class Audio {
  final String path;
  final String type;

  const Audio({
    required this.path,
    required this.type,
  });

  // Convert a PlaylistFile into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'path': path,
      'type': type,
    };
  }
}
