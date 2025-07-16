import 'package:spotify_sdk/models/track.dart';
import 'dart:typed_data';

class Song {
  final String name;
  final String artistName;
  final String albumImage;
  final String spotifyUri;
  final Track? spotifyTrack;
  final Uint8List? imageBytes;

  Song({
    required this.name,
    required this.artistName,
    required this.albumImage,
    required this.spotifyUri,
    this.spotifyTrack,
    this.imageBytes,
  });
}
