import 'package:flutter/material.dart';

import 'package:scoped_model/scoped_model.dart';

import '../widgets/expenses/expenses.dart';
import '../widgets/ui_elements/logout_list_tile.dart';
import '../widgets/ui_elements/sortBy_tile.dart';
import '../scoped-models/main.dart';
import '.././pages/expense_edit.dart';
import '../widgets/ui_elements/searchQuery.dart';

class ExpensesPage extends StatefulWidget {
  final MainModel model;

  ExpensesPage(this.model);

  @override
  State<StatefulWidget> createState() {
    return _ExpensesPageState();
  }
}

class _ExpensesPageState extends State<ExpensesPage> {
  @override
  initState() {
    widget.model.fetchExpenses();
    super.initState();
  }

  Widget _buildSideDrawer(BuildContext context) {
    return ScopedModelDescendant(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Drawer(
        child: Column(
          children: <Widget>[
            AppBar(
              automaticallyImplyLeading: false,
              title: Text(
                model.user.email,
                style: TextStyle(fontSize: 15),
              ),
            ),
            Divider(),
            SortByTile(),
            Divider(),
            LogoutListTile(),
            Divider(),
          ],
        ),
      );
    });
  }

  Widget _buildExpensesList() {
    return ScopedModelDescendant(
      builder: (BuildContext context, Widget child, MainModel model) {
        Widget content = Center(child: Text('No Expenses Found!'));
        if (model.displayedExpenses.length > 0 && !model.isLoading) {
          content = Expenses();
        } else if (model.isLoading) {
          content = Center(child: CircularProgressIndicator());
        }
        return RefreshIndicator(
          onRefresh: model.fetchExpenses,
          child: content,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomBarColor = Theme.of(context).primaryColor;
    return GestureDetector(onTap: () {
      FocusScope.of(context).requestFocus(FocusNode());
    }, child: ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              model.setSearchQuery();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext context) {
                    return ExpenseEditPage();
                  },
                ),
              );
            },
            child: Icon(Icons.add),
          ),
          drawer: _buildSideDrawer(context),
          bottomNavigationBar: Container(
            child: Text(
              'Total:\n₹' + model.totalExpense.toString(),
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 15),
            ),
            height: 55,
            decoration: BoxDecoration(
                color: bottomBarColor,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(10),
                )),
            margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
            padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
            alignment: Alignment.topLeft,
          ),
          appBar: AppBar(
            title: Text('Expense List'),
          ),
          body: ScopedModelDescendant(
              builder: (BuildContext context, Widget child, MainModel model) {
            return Column(children: <Widget>[
              SearchQuery(),
              Expanded(child: Container(child: _buildExpensesList()))
            ]);
          }));
    }));
  }
}
