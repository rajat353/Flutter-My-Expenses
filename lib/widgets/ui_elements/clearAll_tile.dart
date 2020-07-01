import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import '../../scoped-models/main.dart';

class ClearAllListTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant(
      builder: (BuildContext context, Widget child, MainModel model) {
        return ListTile(
          leading: Icon(Icons.delete_forever),
          title: Text('Clear All'),
          onTap: () {
            model.clearAllExpense();
            Navigator.pop(context);
          },
        );
      },
    );
  }
}
