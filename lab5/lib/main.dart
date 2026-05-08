import 'package:flutter/material.dart';
import 'package:lab5/providers/note_provider.dart';
import 'package:lab5/screens/home_page.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const NotesApp());
}

class NotesApp extends StatelessWidget {
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NoteProvider()..loadNotes(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Simple Notes',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF7AA6A1),
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: const Color(0xFFF6F8F8),
          useMaterial3: true,
        ),
        home: const HomePage(),
      ),
    );
  }
}


