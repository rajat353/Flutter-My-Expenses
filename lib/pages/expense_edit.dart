import 'package:flutter/material.dart';

import 'package:scoped_model/scoped_model.dart';

import '../widgets/helpers/ensure_visible.dart';
import '../models/expense.dart';
import '../widgets/ui_elements/image.dart';
import '../scoped-models/main.dart';

class ExpenseEditPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ExpenseEditPageState();
  }
}

class _ExpenseEditPageState extends State<ExpenseEditPage> {
  final Map<String, dynamic> _formData = {
    'title': null,
    'description': null,
    'amount': null,
    'image': 'assets/rupee.jpg',
    "createdAt": DateTime.now()
  };
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  DateTime _date;
  final _titleFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _amountFocusNode = FocusNode();
  final _titleTextController = TextEditingController();
  final _descriptionTextController = TextEditingController();

  String formatDate(DateTime date) {
    List<String> _date = date.toIso8601String().substring(0, 10).split("-");

    return "${_date[2]}-${_date[1]}-${_date[0]}";
  }

  Widget _buildTitleTextField(Expense expense) {
    if (expense == null && _titleTextController.text.trim() == '') {
      _titleTextController.text = '';
    } else if (expense != null && _titleTextController.text.trim() == '') {
      _titleTextController.text = expense.title;
    } else if (expense != null && _titleTextController.text.trim() != '') {
      _titleTextController.text = _titleTextController.text;
    } else if (expense == null && _titleTextController.text.trim() != '') {
      _titleTextController.text = _titleTextController.text;
    } else {
      _titleTextController.text = '';
    }
    return EnsureVisibleWhenFocused(
      focusNode: _titleFocusNode,
      child: TextFormField(
        controller: _titleTextController,
        focusNode: _titleFocusNode,
        decoration: InputDecoration(labelText: 'Expense Title'),
        validator: (String value) {
          if (value.isEmpty) {
            return 'Title is required';
          }
        },
        onSaved: (String value) {
          _formData['title'] = value;
        },
      ),
    );
  }

  Widget _buildDescriptionTextField(Expense expense) {
    if (expense == null && _descriptionTextController.text.trim() == '') {
      _descriptionTextController.text = '';
    } else if (expense != null &&
        _descriptionTextController.text.trim() == '') {
      _descriptionTextController.text = expense.description;
    }
    return EnsureVisibleWhenFocused(
      focusNode: _descriptionFocusNode,
      child: TextFormField(
        controller: _descriptionTextController,
        focusNode: _descriptionFocusNode,
        maxLines: 4,
        decoration: InputDecoration(labelText: 'Expense Description'),
        onSaved: (String value) {
          _formData['description'] = value;
        },
      ),
    );
  }

  Widget _buildamountTextField(Expense expense) {
    return EnsureVisibleWhenFocused(
      focusNode: _amountFocusNode,
      child: TextFormField(
        focusNode: _amountFocusNode,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: 'Expense amount'),
        initialValue: expense == null ? '' : expense.amount.toString(),
        validator: (String value) {
          if (value.isEmpty ||
              !RegExp(r'^(?:[1-9]\d*|0)?(?:\.\d+)?$').hasMatch(value)) {
            return 'amount is required and should be a number.';
          }
        },
        onSaved: (String value) {
          _formData['amount'] = double.parse(value);
        },
      ),
    );
  }

  Widget _buildDateOption(Expense expense) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: MaterialButton(
        minWidth: 100,
        child: _date == null
            ? Text(expense == null
                ? 'Date: ' + formatDate(DateTime.now())
                : 'Date: ' + formatDate(expense.createdAt))
            : Text('Date: ' + formatDate(_date)),
        onPressed: () async {
          await showDatePicker(
            context: context,
            firstDate: DateTime(2000),
            initialDate: _date == null
                ? (expense == null ? DateTime.now() : expense.createdAt)
                : _date,
            lastDate: DateTime.now(),
          ).then((date) {
            if (date != null) {
              setState(() {
                _date = date;

                _formData["createdAt"] = date;
              });
            }
          });
        },
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return model.isLoading
            ? Center(child: CircularProgressIndicator())
            : RaisedButton(
                child: Text('Save'),
                textColor: Colors.white,
                onPressed: () => _submitForm(
                    model.addExpense,
                    model.updateExpense,
                    model.selectExpense,
                    model.selectedExpenseIndex),
              );
      },
    );
  }

  Widget _buildPageContent(BuildContext context, Expense expense) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth * 0.95;
    final double targetPadding = deviceWidth - targetWidth;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Container(
        margin: EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: targetPadding / 2),
            children: <Widget>[
              _buildTitleTextField(expense),
              _buildDescriptionTextField(expense),
              _buildamountTextField(expense),
              SizedBox(
                height: 10.0,
              ),
              _buildDateOption(expense),
              ImageInput(),
              SizedBox(
                height: 10.0,
              ),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm(
      Function addExpense, Function updateExpense, Function setSelectedExpense,
      [int selectedExpenseIndex]) {
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();
    if (selectedExpenseIndex == -1) {
      addExpense(
        _titleTextController.text,
        _descriptionTextController.text,
        _formData['image'],
        _formData['amount'],
        _formData['createdAt'],
      ).then((bool success) {
        if (success) {
          Navigator.pushReplacementNamed(context, '/expenses')
              .then((_) => setSelectedExpense(null));
        } else {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Something went wrong'),
                  content: Text('Please try again!'),
                  actions: <Widget>[
                    FlatButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Okay'),
                    )
                  ],
                );
              });
        }
      });
    } else {
      updateExpense(
        _titleTextController.text,
        _descriptionTextController.text,
        _formData['image'],
        _formData['amount'],
        _formData['createdAt'],
      ).then((_) => Navigator.pushReplacementNamed(context, '/expenses')
          .then((_) => setSelectedExpense(null)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        final Widget pageContent =
            _buildPageContent(context, model.selectedExpense);
        return model.selectedExpenseIndex == -1
            ? Scaffold(
                appBar: AppBar(
                  title: Text('Add Expense'),
                ),
                body: pageContent,
              )
            : Scaffold(
                appBar: AppBar(
                  leading: IconButton(
                    icon: Icon(Icons.keyboard_backspace),
                    onPressed: () {
                      model.setSelctedExpense();
                      Navigator.of(context).pop();
                    },
                  ),
                  title: Text('Edit Expense'),
                ),
                body: pageContent,
              );
      },
    );
  }
}
