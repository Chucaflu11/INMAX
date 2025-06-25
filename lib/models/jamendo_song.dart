class JamendoSong {
  final String id;
  final String name;
  final String artistName;
  final String albumImage;
  final String audioUrl;

  JamendoSong({
    required this.id,
    required this.name,
    required this.artistName,
    required this.albumImage,
    required this.audioUrl,
  });

  factory JamendoSong.fromJson(Map<String, dynamic> json) {
    return JamendoSong(
      id: json['id'],
      name: json['name'],
      artistName: json['artist_name'],
      albumImage: json['album_image'],
      audioUrl: json['audio'],
    );
  }
}