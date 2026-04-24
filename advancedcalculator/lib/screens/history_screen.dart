import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/calculation_history.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({
    super.key,
    required this.history,
    required this.onReuse,
    required this.onClear,
  });

  final List<CalculationHistory> history;
  final ValueChanged<CalculationHistory> onReuse;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: <Widget>[
          IconButton(
            onPressed: onClear,
            icon: const Icon(Icons.delete_sweep_rounded),
          ),
        ],
      ),
      body: history.isEmpty
          ? const Center(child: Text('No calculations yet'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (BuildContext context, int index) {
                final CalculationHistory item = history[index];
                return ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  tileColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  title: Text(item.expression),
                  trailing: Text(item.result, style: const TextStyle(fontWeight: FontWeight.bold)),
                  onTap: () {
                    onReuse(item);
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
    );
  }
}
