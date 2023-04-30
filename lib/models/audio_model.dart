class Audio {
  final String path;
  final String type;
  // TODO: there should be a better way of doing this
  final dynamic audioObject;

  const Audio({
    required this.path,
    required this.type,
    required this.audioObject,
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
