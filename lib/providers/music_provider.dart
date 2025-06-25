import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/jamendo_song.dart';

class MusicProvider with ChangeNotifier {
  List<JamendoSong> jamendoSongs = [];
  JamendoSong? currentSong;

  bool isPlaying = false;
  bool isLiked = false;
  bool isRepeat = false;
  bool isRepeatOne = false;
  bool isShuffle = false;

  Future<void> fetchJamendoSongs() async {
    final url = Uri.parse(
      'https://api.jamendo.com/v3.0/tracks/?client_id=1465d521&format=json&limit=20&include=musicinfo+stats+lyrics&audioformat=mp32'
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      jamendoSongs = (data['results'] as List)
          .map((e) => JamendoSong.fromJson(e))
          .toList();
      notifyListeners();
    }
  }

  void setSong(JamendoSong song) {
    currentSong = song;
    notifyListeners();
  }

  void togglePlayPause() {
    isPlaying = !isPlaying;
    notifyListeners();
  }

  void toggleLike() {
    isLiked = !isLiked;
    notifyListeners();
  }

  void setRepeatMode() {
    isRepeat = true;
    isRepeatOne = false;
    isShuffle = false;
    notifyListeners();
  }

  void setRepeatOneMode() {
    isRepeatOne = true;
    isRepeat = false;
    isShuffle = false;
    notifyListeners();
  }

  void setShuffleMode() {
    isShuffle = true;
    isRepeat = false;
    isRepeatOne = false;
    notifyListeners();
  }
}