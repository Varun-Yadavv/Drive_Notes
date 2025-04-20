import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../models/note_model.dart';
import 'auth_service.dart';
import 'package:http_parser/http_parser.dart';

class DriveService {
  static const String appFolderName = "DriveNotes";
  static String? _appFolderId;

  // Initialize Drive and ensure app folder exists
  static Future<bool> initialize() async {
    try {
      final dio = await AuthService.getAuthenticatedDio();
      if (dio == null) return false;

      _appFolderId = await _getOrCreateAppFolder(dio);
      return _appFolderId != null;
    } catch (e) {
      debugPrint('Error initializing Drive service: $e');
      return false;
    }
  }

  // Get or create the DriveNotes folder
  static Future<String?> _getOrCreateAppFolder(Dio dio) async {
    try {
      final response = await dio.get(
        '/drive/v3/files',
        queryParameters: {
          'q':
          "name='$appFolderName' and mimeType='application/vnd.google-apps.folder' and trashed=false",
          'fields': 'files(id, name)',
        },
      );

      final files = response.data['files'] as List<dynamic>;
      if (files.isNotEmpty) {
        return files.first['id'];
      }

      // Create folder if it doesn't exist
      final folderMetadata = {
        'name': appFolderName,
        'mimeType': 'application/vnd.google-apps.folder',
      };

      final folderResponse = await dio.post(
        '/drive/v3/files',
        data: folderMetadata,
      );

      return folderResponse.data['id'];
    } catch (e) {
      debugPrint('Error creating/accessing folder: $e');
      return null;
    }
  }

  // Fetch list of notes
  static Future<List<NoteModel>> getNotesList() async {
    try {
      if (_appFolderId == null && !(await initialize())) return [];

      final dio = await AuthService.getAuthenticatedDio();
      if (dio == null) return [];

      final response = await dio.get(
        '/drive/v3/files',
        queryParameters: {
          'q':
          "mimeType='text/plain' and '$_appFolderId' in parents and trashed=false",
          'fields': 'files(id, name, modifiedTime)',
        },
      );

      final files = response.data['files'] as List<dynamic>;

      final List<NoteModel> notes = [];

      for (var file in files) {
        final id = file['id'];
        final content = await _getFileContent(dio, id);
        final modifiedTime = DateTime.tryParse(file['modifiedTime'] ?? '') ??
            DateTime.now();

        notes.add(NoteModel(
          id: id,
          title: file['name'] ?? 'Untitled',
          content: content,
          lastModified: modifiedTime,
        ));
      }

      notes.sort((a, b) => b.lastModified.compareTo(a.lastModified));
      return notes;
    } catch (e) {
      debugPrint('Error fetching notes: $e');
      return [];
    }
  }

  // Read file content
  static Future<String> _getFileContent(Dio dio, String fileId) async {
    try {
      final response = await dio.get<ResponseBody>(
        '/drive/v3/files/$fileId',
        queryParameters: {
          'alt': 'media',
        },
        options: Options(responseType: ResponseType.stream),
      );

      final bytes = <int>[];
      await response.data!.stream.listen((chunk) {
        bytes.addAll(chunk);
      }).asFuture();

      return utf8.decode(bytes);
    } catch (e) {
      debugPrint('Error reading file: $e');
      return '';
    }
  }

  // Create a new note
  static Future<NoteModel?> createNote(String title, String content) async {
    try {
      if (_appFolderId == null && !(await initialize())) return null;

      final dio = await AuthService.getAuthenticatedDio();
      if (dio == null) return null;

      final metadata = {
        'name': '$title.txt',
        'mimeType': 'text/plain',
        'parents': [_appFolderId],
      };

      final metadataPart = jsonEncode(metadata);

      final boundary = 'foo_bar_baz';

      final body = '''
--$boundary
Content-Type: application/json; charset=UTF-8

$metadataPart
--$boundary
Content-Type: text/plain

$content
--$boundary--
''';

      final response = await dio.post(
        'https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart',
        data: body,
        options: Options(
          headers: {
            'Content-Type': 'multipart/related; boundary=$boundary',
          },
        ),
      );

      return NoteModel(
        id: response.data['id'],
        title: title,
        content: content,
        lastModified: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Error creating note: $e');
      return null;
    }
  }


  // Update an existing note
  static Future<bool> updateNote(
      String fileId, String title, String content) async {
    try {
      final dio = await AuthService.getAuthenticatedDio();
      if (dio == null) return false;

      final metadata = {
        'name': '$title.txt',
        'mimeType': 'text/plain',
      };

      final contentBytes = utf8.encode(content);
      final media = MultipartFile.fromBytes(contentBytes,
          filename: '$title.txt', contentType: MediaType('text', 'plain'));

      final form = FormData.fromMap({
        'metadata': jsonEncode(metadata),
        'file': media,
      });

      await dio.patch(
        'https://www.googleapis.com/upload/drive/v3/files/$fileId?uploadType=multipart',
        data: form,
        options: Options(headers: {
          'Content-Type': 'multipart/related; boundary=foo_bar_baz',
        }),
      );

      return true;
    } catch (e) {
      debugPrint('Error updating note: $e');
      return false;
    }
  }

  // Delete a note
  static Future<bool> deleteNote(String fileId) async {
    try {
      final dio = await AuthService.getAuthenticatedDio();
      if (dio == null) return false;

      await dio.delete('/drive/v3/files/$fileId');
      return true;
    } catch (e) {
      debugPrint('Error deleting note: $e');
      return false;
    }
  }
}
