import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import './amount_tag.dart';
import './address_tag.dart';
import './title_tag.dart';
import '../../models/expense.dart';
import '../../scoped-models/main.dart';
import '../../pages/expense_edit.dart';

class ExpenseCard extends StatelessWidget {
  final Expense expense;
  final int expenseIndex;

  ExpenseCard(this.expense, this.expenseIndex);
  String formatDate(DateTime date) {
    List<String> _date = date.toIso8601String().substring(0, 10).split("-");

    return "${_date[2]}-${_date[1]}-${_date[0]}";
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Card(
          margin: EdgeInsets.all(5),
          elevation: 3.0,
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Container(
                    width: MediaQuery.of(context).size.width / 6,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 20,
                              child: FadeInImage(
                                image: NetworkImage(expense.image),
                                placeholder: AssetImage('assets/rupee.jpg'),
                              )),
                          IconButton(
                              icon: Icon(Icons.edit),
                              color: Theme.of(context).accentColor,
                              onPressed: () {
                                model.selectExpense(expense.id);
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (BuildContext context) {
                                      return ExpenseEditPage();
                                    },
                                  ),
                                );
                              }),
                        ])),
                Container(
                  width: MediaQuery.of(context).size.width / 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(formatDate(expense.createdAt)),
                      SizedBox(
                        height: 5,
                      ),
                      TitleTag(expense.title),
                      SizedBox(
                        height: 5,
                      ),
                      AddressTag(expense.description == ''
                          ? 'No Description'
                          : expense.description),
                      SizedBox(
                        height: 5,
                      ),
                    ],
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width / 5,
                  alignment: Alignment.center,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        AmountTag(expense.amount.toString()),
                        IconButton(
                          icon: Icon(Icons.delete),
                          color: Colors.red,
                          onPressed: () {
                            model.selectExpense(expense.id);
                            model.deleteExpense();
                          },
                        ),
                      ]),
                ),
              ]));
    });
  }
}
