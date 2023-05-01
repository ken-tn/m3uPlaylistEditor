// Define a function that inserts dogs into the database
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'package:m3u_playlist/models/playlist_model.dart';
import 'package:m3u_playlist/models/audio_model.dart';

const databaseVersion = 2;
const databaseName = 'm3u_playlist_data.db';

Future<Database> connectToDatabase() async {
  return openDatabase(
    join(await getDatabasesPath(), databaseName),
    version: databaseVersion,
  );
}

Future<Database> loadDatabase() async {
  final db = await openDatabase(
    // Set the path to the database. Note: Using the `join` function from the
    // `path` package is best practice to ensure the path is correctly
    // constructed for each platform.
    join(await getDatabasesPath(), 'm3u_playlist_data.db'),
    // When the database is first created, create a table to store the models.
    // TODO: use json tag data instead of explicit tags for files?
    onCreate: (db, version) {
      // Run the CREATE TABLE statement on the database.
      db.execute(
        'CREATE TABLE IF NOT EXISTS Playlist(path VARCHAR PRIMARY KEY);',
      );
      db.execute(
        'CREATE TABLE IF NOT EXISTS Audio(path VARCHAR PRIMARY KEY, filetype VARCHAR);',
      );
      db.execute(
        '''CREATE TABLE IF NOT EXISTS Mp3ID3v1(path VARCHAR PRIMARY KEY, title VARCHAR, artist VARCHAR,
            album VARCHAR, year INTEGER, genre VARCHAR,
            FOREIGN KEY(path) REFERENCES Audio(path));''',
      );
    },

    onUpgrade: (db, oldVersion, newVersion) {
      db.execute(
        'DROP TABLE Playlist',
      );
      db.execute(
        'DROP TABLE Audio',
      );
      db.execute(
        'DROP TABLE Mp3ID3v1',
      );

      db.execute(
        'CREATE TABLE IF NOT EXISTS Playlist(path VARCHAR PRIMARY KEY);',
      );
      db.execute(
        'CREATE TABLE IF NOT EXISTS Audio(path VARCHAR PRIMARY KEY, filetype VARCHAR);',
      );
      db.execute(
        '''CREATE TABLE IF NOT EXISTS Mp3ID3v1(path VARCHAR PRIMARY KEY, title VARCHAR, artist VARCHAR,
            album VARCHAR, year INTEGER, genre VARCHAR,
            FOREIGN KEY(path) REFERENCES Audio(path));''',
      );
    },
    // Set the version. This executes the onCreate function and provides a
    // path to perform database upgrades and downgrades.
    version: databaseVersion,
  );

  return db;
}

Future<void> insertPlaylist(Playlist playlist) async {
  // Insert the Playlist into the correct table. You might also specify the
  // `conflictAlgorithm` to use in case the same Playlist is inserted twice.
  //
  // In this case, replace any previous data.
  connectToDatabase().then(
    (db) => {
      db.insert(
        'Playlist',
        playlist.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      )
    },
  );
}

Future<void> insertAudio(Audio audio) async {
  connectToDatabase().then(
    (db) => {
      db
          .insert(
            'Audio',
            audio.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          )
          .then(
            (value) => {
              db.insert(
                audio.filetype,
                {'path': audio.path, ...audio.audioObject.toMap()},
                conflictAlgorithm: ConflictAlgorithm.replace,
              )
            },
          )
    },
  );
}
