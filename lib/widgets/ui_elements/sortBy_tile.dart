import 'package:flutter/material.dart';

import 'package:scoped_model/scoped_model.dart';

import '../../scoped-models/main.dart';

class SortByTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant(
      builder: (BuildContext context, Widget child, MainModel model) {
        return ListTile(
          leading: Icon(Icons.sort),
          title:
              Text('Sort By ' + (model.sortBy == 'Date' ? 'Amount' : 'Date')),
          onTap: () {
            model.updateSort();
            Navigator.pop(context);
          },
        );
      },
    );
  }
}
