import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../model/songs/song.dart';
import '../../dtos/song_dto.dart';
import 'song_repository.dart';

class SongRepositoryFirebase extends SongRepository {
  final Uri songsUri = Uri.https(
    'g1-project-13926-default-rtdb.asia-southeast1.firebasedatabase.app',
    '/songs.json',
  );

  List<Song>? _cachedSongs;

  @override
  Future<List<Song>> fetchSongs({bool forceFetch = false}) async {
    final http.Response response = await http.get(songsUri);
    if (!forceFetch && _cachedSongs != null) {
      return _cachedSongs!;
    }

    if (response.statusCode == 200) {
      // 1 - Send the retrieved list of songs
      Map<String, dynamic> songJson = json.decode(response.body);

      List<Song> result = [];
      for (final entry in songJson.entries) {
        // Ensure entry.value is a Map before processing
        if (entry.value is Map<String, dynamic>) {
          result.add(SongDto.fromJson(entry.key, entry.value));
        }
      }

      _cachedSongs = result;

      return result;
    } else {
      // 2- Throw expcetion if any issue
      throw Exception('Failed to load posts');
    }
  }

  @override
  Future<Song?> fetchSongById(String id) async {
    return null;
  }

  @override
  Future<void> likeSong(String id, int currentLikes) async {
    // Current song uri with song id

    final Uri url = Uri.https(
      'g1-project-13926-default-rtdb.asia-southeast1.firebasedatabase.app',
      '/songs/$id/likes.json',
    );

    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},

      body: json.encode(currentLikes + 1),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to like song');
    }
  }
}
