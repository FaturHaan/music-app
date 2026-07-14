import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';

class LastFmSource {
  Future<Map<String, dynamic>?> getTrackInfo(String artist, String title) async {
    if (AppConstants.lastfmApiKey == 'YOUR_LASTFM_API_KEY') {
      return null;
    }

    try {
      final uri = Uri.parse(
          '${AppConstants.lastfmBaseUrl}/?method=track.getInfo&api_key=${AppConstants.lastfmApiKey}&artist=${Uri.encodeComponent(artist)}&track=${Uri.encodeComponent(title)}&format=json');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['track'] != null) {
          return data['track'];
        }
      }
    } catch (e) {
      // Ignore
    }
    return null;
  }

  String? extractCoverArtUrl(Map<String, dynamic> trackInfo) {
    if (trackInfo['album'] != null && trackInfo['album']['image'] != null) {
      final List<dynamic> images = trackInfo['album']['image'];
      // Try to find extralarge or large image
      for (var size in ['extralarge', 'large', 'medium', 'small']) {
        final img = images.firstWhere((i) => i['size'] == size, orElse: () => null);
        if (img != null && img['#text'] != null && img['#text'].toString().isNotEmpty) {
          return img['#text'];
        }
      }
    }
    return null;
  }
}
