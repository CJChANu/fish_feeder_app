import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

Future<void> showRenameDialog({
  required BuildContext context,
  required String deviceId,
  required String currentName,
}) async {
  final controller = TextEditingController(text: currentName);

  final result = await showDialog<String>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Rename Tank'),
      content: TextField(
        controller: controller,
        textInputAction: TextInputAction.done,
        decoration: const InputDecoration(
          labelText: 'Tank name',
          hintText: 'Tank 1',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.edit),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final name = controller.text.trim();
            Navigator.pop(context, name);
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );

  if (result == null) return;
  final name = result.trim();
  if (name.isEmpty) return;

  // Save to Firebase: /<deviceId>/name
  await FirebaseDatabase.instance.ref('/$deviceId/name').set(name);
}
