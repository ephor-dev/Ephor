import 'package:ephor/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EditProfileDialog extends StatefulWidget {
  final VoidCallback updateInfoCallback;
  // final BuildContext dialogContext;

  const EditProfileDialog({
    super.key,
    required this.updateInfoCallback
  });

  @override
  State<EditProfileDialog> createState() => _EdidProfileDialogState();
}

class _EdidProfileDialogState extends State<EditProfileDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Profile'),
      constraints: BoxConstraints.tight(Size(540, 350)),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('This section will provide you options to modify what you use in Ephor.'),
          SizedBox.fromSize(size: Size.fromHeight(16),),
          Card(
            elevation: 1,
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              leading: Icon(Icons.verified_user),
              title: Text("Update your Information", style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text("Update your email, full name and/or image."),
              trailing: Icon(Icons.arrow_forward),
              onTap: widget.updateInfoCallback,
            ),
          ),
          Card(
            elevation: 1,
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              leading: Icon(Icons.password),
              title: Text("Change your Password", style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text("Keep your account secured by changing password."),
              trailing: Icon(Icons.arrow_forward),
              onTap: () {
                context.go(Routes.updatePassword);
              },
            ),
          )
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}