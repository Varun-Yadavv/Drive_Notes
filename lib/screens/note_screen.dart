import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/note_model.dart';
import '../provider/notes_provider.dart';

class NoteScreen extends ConsumerStatefulWidget {
  final String? noteId;

  const NoteScreen({super.key, this.noteId});

  @override
  ConsumerState<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends ConsumerState<NoteScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isEditing = false;
  bool _isLoading = false;
  bool _isNew = false;
  late NoteModel currentNote;

  @override
  void initState() {
    super.initState();
    _isNew = widget.noteId == 'new';
    _isEditing = _isNew;

    if (!_isNew) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadNote();
      });
    }
  }

  Future<void> _loadNote() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final notesAsync = ref.read(notesProvider);
      if (notesAsync is AsyncData) {
        final notesList = notesAsync.value;
        final note = notesList?.firstWhere((note) => note.id == widget.noteId);

        currentNote = note!;

        _titleController.text = note.title.split(".txt").first;
        _contentController.text = note.content;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading note')),
      );
      context.pop();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveNote() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Title cannot be empty')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      bool success;

      if (_isNew) {
        success = await ref.read(notesProvider.notifier).addNote(
          _titleController.text.trim(),
          _contentController.text.trim(),
        );
      } else {
        success = await ref.read(notesProvider.notifier).updateNote(
          widget.noteId!,
          _titleController.text.trim(),
          _contentController.text.trim(),
        );
      }

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_isNew ? 'Note created' : 'Note updated')),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_isNew ? 'Failed to create note' : 'Failed to update note')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isNew ? 'New Note' : (_isEditing ? 'Edit Note' : 'View Note'),
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          if (!_isNew && !_isEditing)
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
          if (_isEditing)
            IconButton(
              icon: Icon(Icons.save),
              onPressed: _saveNote,
            ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
              ),
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              readOnly: !_isEditing,
            ),
            SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _contentController,
                decoration: InputDecoration(
                  labelText: 'Content',
                  alignLabelWithHint: true,
                ),
                style: TextStyle(fontSize: 16),
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                readOnly: !_isEditing,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}