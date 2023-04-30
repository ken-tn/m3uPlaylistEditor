class Mp3ID3v1 {
  final int id;
  final String path;
  final String title;
  final String artist;
  final String album;
  final int year;
  final String genre;

  const Mp3ID3v1({
    required this.id,
    required this.path,
    required this.title,
    required this.artist,
    required this.album,
    required this.year,
    required this.genre,
  });

  // Convert a PlaylistFile into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'path': path,
    };
  }
}