import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import './expense_card.dart';
import '../../models/expense.dart';
import '../../scoped-models/main.dart';

class Expenses extends StatelessWidget {
  Widget _buildExpenseList(List<Expense> expenses) {
    Widget expenseCards;
    if (expenses.length > 0) {
      expenseCards = ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          return ExpenseCard(expenses[index], index);
        },
        itemCount: expenses.length,
      );
    } else {
      expenseCards = Container();
    }
    return expenseCards;
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return _buildExpenseList(model.displayedExpenses);
      },
    );
  }
}
