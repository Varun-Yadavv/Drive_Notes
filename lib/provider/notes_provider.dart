
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/note_model.dart';
import '../services/drive_service.dart';

// Provider for the currently selected note (if any)
final selectedNoteProvider = StateProvider<NoteModel?>((ref) => null);

// Provider for the list of notes
final notesProvider = AsyncNotifierProvider<NotesNotifier, List<NoteModel>>(() {
  return NotesNotifier();
});

class NotesNotifier extends AsyncNotifier<List<NoteModel>> {
  @override
  Future<List<NoteModel>> build() async {
    // Load notes when the provider is first used
    return await DriveService.getNotesList();
  }

  // Refresh notes list
  Future<void> refreshNotes() async {
    state = const AsyncValue.loading();
    state = AsyncValue.data(await DriveService.getNotesList());
  }

  // Add a new note
  Future<bool> addNote(String title, String content) async {
    final newNote = await DriveService.createNote(title, content);

    if (newNote != null) {
      state = AsyncValue.data([newNote, ...state.value ?? []]);
      return true;
    }

    return false;
  }

  // Update an existing note
  Future<bool> updateNote(String id, String title, String content) async {
    final success = await DriveService.updateNote(id, title, content);

    if (success) {
      // Update the note in the local state
      List<NoteModel> updatedNotes  =
        state.value?.map((note) {
          if (note.id == id) {
            return NoteModel(
              id: id,
              title: title,
              content: content,
              lastModified: DateTime.now(),
            );
          }
          return note;
        }).toList() ?? [];

      updatedNotes.sort((a, b) => b.lastModified.compareTo(a.lastModified));

      // Update state
      state = AsyncValue.data(updatedNotes);
      return true;
    }

    return false;
  }

  // Delete a note
  Future<bool> deleteNote(String id) async {
    final success = await DriveService.deleteNote(id);

    if (success) {
      // Remove the note from local state
      state = AsyncValue.data(
        state.value?.where((note) => note.id != id).toList() ?? [],
      );

      return true;
    }

    return false;
  }
}