import 'package:json_annotation/json_annotation.dart';

// This generates a corresponding part file (note_model.g.dart)
part 'note_model.g.dart';

@JsonSerializable()
class NoteModel {
  /// Unique identifier for the note (Google Drive file ID)
  final String id;

  /// Title of the note (displayed in the UI)
  final String title;

  /// Content/body of the note
  final String content;

  /// When the note was last modified
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime lastModified;

  NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.lastModified,
  });

  /// Create a note from JSON data - generated
  factory NoteModel.fromJson(Map<String, dynamic> json) => _$NoteModelFromJson(json);

  /// Convert note to JSON for storage - generated
  Map<String, dynamic> toJson() => _$NoteModelToJson(this);

  // Helper methods for DateTime conversion
  static DateTime _dateTimeFromJson(String date) => DateTime.parse(date);
  static String _dateTimeToJson(DateTime date) => date.toIso8601String();
}