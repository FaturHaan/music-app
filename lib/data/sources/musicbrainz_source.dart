import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';

class MusicBrainzSource {
  Future<String?> getReleaseMbid(String artist, String title) async {
    try {
      // MusicBrainz requires a proper User-Agent
      final headers = {
        'User-Agent': 'MusicApp/${AppConstants.appVersion} ( support@musicapp.local )',
      };
      
      final query = 'recording:"$title" AND artist:"$artist"';
      final uri = Uri.parse(
          '${AppConstants.musicbrainzBaseUrl}/recording?query=${Uri.encodeComponent(query)}&limit=1&fmt=json');
      
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['recordings'] != null && data['recordings'].isNotEmpty) {
          final recording = data['recordings'][0];
          if (recording['releases'] != null && recording['releases'].isNotEmpty) {
            return recording['releases'][0]['id'];
          }
        }
      }
    } catch (e) {
      // Ignore
    }
    return null;
  }

  Future<String?> getCoverArtUrl(String releaseMbid) async {
    try {
      final uri = Uri.parse('${AppConstants.coverArtArchiveBaseUrl}/release/$releaseMbid');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['images'] != null && data['images'].isNotEmpty) {
          // Find the front image
          final frontImage = data['images'].firstWhere(
            (img) => img['front'] == true, 
            orElse: () => data['images'][0]
          );
          if (frontImage != null && frontImage['image'] != null) {
            return frontImage['image'];
          }
        }
      }
    } catch (e) {
      // Ignore
    }
    return null;
  }
}
