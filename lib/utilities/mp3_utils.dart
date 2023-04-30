import 'dart:io';

import 'package:m3u_playlist/models/audio_model.dart';
import 'package:m3u_playlist/models/id3v1_mp3_model.dart';

Object toMP3(FileSystemEntity file) {
  var mp3 =
      const Mp3ID3v1(title: 'a', artist: 'a', album: 'a', year: 0, genre: 'a');

  return Audio(path: file.path, type: 'Mp3ID3v1', audioObject: mp3);
}
