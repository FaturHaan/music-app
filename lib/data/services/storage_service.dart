import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import '../../core/constants/app_constants.dart';

class StorageService {
  final Uuid _uuid = const Uuid();

  Future<String> get _appDir async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  Future<String> get _musicDir async {
    final appDir = await _appDir;
    final dir = Directory(p.join(appDir, AppConstants.musicDir));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir.path;
  }

  Future<String> get _coversDir async {
    final appDir = await _appDir;
    final dir = Directory(p.join(appDir, AppConstants.coversDir));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir.path;
  }

  /// Copy audio file to app's music directory
  /// Returns the new file path
  Future<String> copyAudioFile(String sourcePath) async {
    final musicDir = await _musicDir;
    final ext = p.extension(sourcePath);
    final newFileName = '${_uuid.v4()}$ext';
    final newPath = p.join(musicDir, newFileName);

    final sourceFile = File(sourcePath);
    await sourceFile.copy(newPath);

    return newPath;
  }

  /// Save cover art bytes to covers directory
  /// Returns the cover art file path
  Future<String> saveCoverArt(List<int> bytes) async {
    final coversDir = await _coversDir;
    final fileName = '${_uuid.v4()}.jpg';
    final filePath = p.join(coversDir, fileName);

    final file = File(filePath);
    await file.writeAsBytes(bytes);

    return filePath;
  }

  /// Delete a file
  Future<void> deleteFile(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Check if a file exists
  Future<bool> fileExists(String path) async {
    return File(path).exists();
  }
}
