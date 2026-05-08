import 'package:flutter/material.dart';
import 'package:lab5/database/db_helper.dart';
import 'package:lab5/models/note.dart';

class NoteProvider extends ChangeNotifier {
  final List<Note> _notes = [];
  List<Note> get notes => List.unmodifiable(_notes);

  Future<void> loadNotes() async {
    final fetchedNotes = await DatabaseHelper.instance.readAllNotes();
    _notes
      ..clear()
      ..addAll(fetchedNotes);
    notifyListeners();
  }

  Future<void> addNote(Note note) async {
    await DatabaseHelper.instance.create(note);
    await loadNotes();
  }

  Future<void> updateNote(Note note) async {
    await DatabaseHelper.instance.update(note);
    await loadNotes();
  }

  Future<void> deleteNote(int id) async {
    await DatabaseHelper.instance.delete(id);
    await loadNotes();
  }
}
