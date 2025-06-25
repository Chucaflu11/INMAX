import 'package:flutter/material.dart';

class Song {
  final String title;
  final String artist;

  Song({required this.title, required this.artist});
}

class MusicProvider with ChangeNotifier {
  bool isPlaying = false;
  bool isLiked = false;
  bool isRepeat = false;
  bool isRepeatOne = false;
  bool isShuffle = false;

  Song? currentSong = Song(title: "Taxman", artist: "The Beatles");

  void togglePlayPause() {
    isPlaying = !isPlaying;
    notifyListeners();
  }

  void setSong(Song song) {
    currentSong = song;
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
