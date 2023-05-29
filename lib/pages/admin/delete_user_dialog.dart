import 'package:flutter/material.dart';

class DeleteUserDialog extends StatelessWidget {
  final VoidCallback onDelete;

  const DeleteUserDialog({required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Delete User'),
      content: Text('Are you sure you want to delete this user?'),
      actions: <Widget>[
        TextButton(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text('Delete'),
          onPressed: onDelete,
        ),
      ],
    );
  }
}
