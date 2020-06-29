import 'package:flutter/material.dart';

import 'package:scoped_model/scoped_model.dart';

import '../../scoped-models/main.dart';

class SearchQuery extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SearchQueryState();
  }
}

class _SearchQueryState extends State<SearchQuery> {
  bool hasSearch = false;
  TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant(
      builder: (BuildContext context, Widget child, MainModel model) {
        return Card(
          clipBehavior: Clip.none,
          elevation: 3.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          child: TextField(
            controller: controller,
            onChanged: (String value) {
              model.updateSearchQuery(value);
            },
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 30.0,
                vertical: 15.0,
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(30.0),
              ),
              hintText: "Search",
              hintStyle: TextStyle(
                fontWeight: FontWeight.w600,
              ),
              prefixIcon: IconButton(
                icon: Icon(Icons.search),
                onPressed: () {},
              ),
              suffixIcon: IconButton(
                icon: Icon(Icons.clear),
                onPressed: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                  setState(() {
                    controller.text = "";
                  });
                  model.updateSearchQuery("");
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
