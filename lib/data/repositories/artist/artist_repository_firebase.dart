import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../model/artist/artist.dart';
import '../../dtos/artist_dto.dart';
import 'artist_repository.dart';

class ArtistRepositoryFirebase implements ArtistRepository {
  final Uri artistsUri = Uri.https(
    'g1-project-13926-default-rtdb.asia-southeast1.firebasedatabase.app',
    '/artists.json',
  );

  List<Artist>? _cacheArtists;

  @override
  Future<List<Artist>> fetchArtists({bool forceFetch = false}) async {
    final http.Response response = await http.get(artistsUri);

    if (!forceFetch && _cacheArtists != null) {
      return _cacheArtists!;
    }

    if (response.statusCode == 200) {
      // 1 - Send the retrieved list of songs
      Map<String, dynamic> songJson = json.decode(response.body);

      List<Artist> result = [];
      for (final entry in songJson.entries) {
        result.add(ArtistDto.fromJson(entry.key, entry.value));
      }

      _cacheArtists = result;
      return result;
    } else {
      // 2- Throw expcetion if any issue
      throw Exception('Failed to load posts');
    }
  }

  @override
  Future<Artist?> fetchArtistById(String id) async {
    return null;
  }
}
