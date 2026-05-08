import 'package:flutter/material.dart';
import 'package:lab5/models/note.dart';
import 'package:lab5/providers/note_provider.dart';
import 'package:lab5/screens/note_editor_screen.dart';
import 'package:lab5/widgets/note_card.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _openEditor(BuildContext context, {Note? note}) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NoteEditorScreen(note: note),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Note note) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete note?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true && context.mounted && note.id != null) {
      await context.read<NoteProvider>().deleteNote(note.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Notes'),
        centerTitle: true,
      ),
      body: Consumer<NoteProvider>(
        builder: (context, provider, child) {
          if (provider.notes.isEmpty) {
            return const Center(
              child: Text(
                'No notes yet.\nTap + to create your first note.',
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: provider.notes.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final note = provider.notes[index];
              return NoteCard(
                note: note,
                onTap: () => _openEditor(context, note: note),
                onDelete: () => _confirmDelete(context, note),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(context),
        icon: const Icon(Icons.add),
        label: const Text('New Note'),
      ),
    );
  }
}
