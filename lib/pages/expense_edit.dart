import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import '../widgets/helpers/ensure_visible.dart';
import '../models/expense.dart';
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
    //'image': 'assets/rupee.jpg',
  };
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  DateTime _date;
  final List<String> _category = [
    'No Category',
    'Food',
    'Bills',
    'Entertainment',
    'Shopping',
    'Health',
    'Education',
    'Travel',
  ];
  String _catValue;
  final _titleFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _amountFocusNode = FocusNode();
  final _titleTextController = TextEditingController();
  final _descriptionTextController = TextEditingController();

  String formatDate(DateTime date) {
    List<String> dateFormat =
        date.toIso8601String().substring(0, 10).split("-");

    return "${dateFormat[2]}-${dateFormat[1]}-${dateFormat[0]}";
  }

  Widget _buildTitleTextField(Expense expense) {
    if (expense == null && _titleTextController.text.trim() == '') {
      _titleTextController.text = '';
    } else if (expense != null && _titleTextController.text.trim() == '') {
      _titleTextController.text = expense.title;
    }
    return EnsureVisibleWhenFocused(
      focusNode: _titleFocusNode,
      child: TextFormField(
        controller: _titleTextController,
        maxLength: 30,
        focusNode: _titleFocusNode,
        decoration: InputDecoration(labelText: 'Expense Title'),
        validator: (String value) {
          if (value.isEmpty) {
            return 'Title is required.';
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
        maxLines: 3,
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
          if (value.isEmpty || double.parse(value)<=0 ||
              !RegExp(r'^(?:[0-9]\d*|0)?(?:\.\d+)?$').hasMatch(value)) {
            return 'amount is required and should be a number.';
          }
        },
        onSaved: (String value) {
          _formData['amount'] = double.parse(value);
        },
      ),
    );
  }

  String setCategory(String value) {
    _catValue = value;
    return _catValue;
  }

  Widget _buildCategoryField(Expense expense) {
    return Container(
      alignment: Alignment.center,
        decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(
          side: BorderSide(
              width: 2.0, style: BorderStyle.solid, color: Colors.teal),
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
        )),
        child: DropdownButton(
          style: TextStyle(color: Colors.teal),
          onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
          focusColor: Colors.blue,
          iconEnabledColor: Colors.teal,
          autofocus: true,
          elevation: 50,
          value: _catValue == null
              ? (expense == null
                  ? setCategory('No Category')
                  : setCategory(expense.category))
              : _catValue,
          onChanged: (newValue) {
            setState(() {
              _catValue = newValue;
            });
          },
          items: _category.map((category) {
            return DropdownMenuItem(child: Text(category), value: category);
          }).toList(),
        ));
  }

  String setDate(DateTime date) {
    _date = date;
    List<String> dateFormat =
        date.toIso8601String().substring(0, 10).split("-");

    return "${dateFormat[2]}-${dateFormat[1]}-${dateFormat[0]}";
  }

  Widget _buildDateOption(Expense expense) {
    return Container(
      decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
        side: BorderSide(
            width: 2.0, style: BorderStyle.solid, color: Colors.teal),
        borderRadius: BorderRadius.all(Radius.circular(5.0)),
      )),
      child: MaterialButton(
        minWidth: 100,
        child: _date == null
            ? Text(expense == null
                ? 'Date: ' + setDate(DateTime.now())
                : 'Date: ' + setDate(expense.createdAt))
            : Text('Date: ' + formatDate(_date)),
        onPressed: () async {
          FocusScope.of(context).requestFocus(FocusNode());
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
                onPressed: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                  _submitForm(model.addExpense, model.updateExpense,
                      model.selectExpense, model.selectedExpenseIndex);
                });
      },
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
              _titleTextController.text.trim(),
              _descriptionTextController.text.trim(),
              //_formData['image'],
              _formData['amount'],
              _date,
              _catValue)
          .then((bool success) {
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
              //_formData['image'],
              _formData['amount'],
              _date,
              _catValue)
          .then((_) => Navigator.pushReplacementNamed(context, '/expenses')
              .then((_) => setSelectedExpense(null)));
    }
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
                height: 20.0,
              ),
              _buildCategoryField(expense),
              SizedBox(
                height: 10.0,
              ),
              _buildDateOption(expense),
              //ImageInput(),
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
