import 'package:flutter/material.dart';
import 'package:lab5/models/note.dart';
import 'package:lab5/providers/note_provider.dart';
import 'package:provider/provider.dart';

class NoteEditorScreen extends StatefulWidget {
  final Note? note;

  const NoteEditorScreen({super.key, this.note});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;

  bool get _isEditing => widget.note != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final now = DateTime.now();
    final newNote = Note(
      id: widget.note?.id,
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      createdAt: widget.note?.createdAt ?? now,
      updatedAt: now,
    );

    final provider = context.read<NoteProvider>();
    if (_isEditing) {
      await provider.updateNote(newNote);
    } else {
      await provider.addNote(newNote);
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Note' : 'New Note'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a title.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: TextFormField(
                    controller: _contentController,
                    decoration: const InputDecoration(
                      labelText: 'Content',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(),
                    ),
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter note content.';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _saveNote,
                    icon: const Icon(Icons.save_outlined),
                    label: Text(_isEditing ? 'Update Note' : 'Save Note'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
