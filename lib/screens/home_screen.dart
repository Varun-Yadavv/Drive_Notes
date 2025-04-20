import 'package:drive_notes/provider/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../provider/notes_provider.dart';

class MyHomePage extends ConsumerWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    bool isDark = false;
    if(theme == ThemeMode.dark) {isDark = true;}
    final notesAsync = ref.watch(notesProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text("Drive Notes", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () async {
              await ref.read(themeProvider.notifier).toggleTheme();
            },
          ),
        ],
      ),
      body: notesAsync.when(
        data: (notes) {
          if (notes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.note_add, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "No notes yet",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Tap the + button to create your first note",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(notesProvider.notifier).refreshNotes(),
            child: ListView.builder(
              padding: EdgeInsets.all(10),
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                final dateFormat = DateFormat('MMM d, yyyy');
                final formattedDate = dateFormat.format(note.lastModified);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    onTap: () {
                      // Navigate to note detail page
                      context.push('/note/${note.id}');
                    },
                    onLongPress: () {
                      // Show delete confirmation
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Delete Note'),
                          content: Text('Are you sure you want to delete "${note.title.split(".txt").first}"?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('CANCEL'),
                            ),
                            TextButton(
                              onPressed: () async {
                                Navigator.pop(context);
                                final success = await ref.read(notesProvider.notifier).deleteNote(note.id);
                                if (success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Note deleted')),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Failed to delete note')),
                                  );
                                }
                              },
                              child: Text('DELETE'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Card(
                      elevation: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              note.title.split(".txt").first,
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 8),
                            Text(
                              note.content,
                              style: TextStyle(fontSize: 16),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 12),
                            Row(
                              children: [
                                Spacer(),
                                Text(
                                  formattedDate,
                                  style: TextStyle(color: Colors.grey, fontSize: 14),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red),
              SizedBox(height: 16),
              Text('Error loading notes'),
              TextButton(
                onPressed: () => ref.read(notesProvider.notifier).refreshNotes(),
                child: Text('RETRY'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/note/new');
        },
        tooltip: 'Add Note',
        child: const Icon(Icons.add),
      ),
    );
  }
}