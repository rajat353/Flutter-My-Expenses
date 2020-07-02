import 'dart:convert';
import 'dart:async';
import 'package:scoped_model/scoped_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rxdart/subjects.dart';
import '../models/expense.dart';
import '../models/user.dart';
import '../models/auth.dart';

mixin ConnectedExpensesModel on Model {
  List<Expense> _expenses = [];
  double totalExpense = 0;
  double today = 0;
  String _selExpenseId;
  String _sortBy = "Date";
  String _searchQuery = "";
  User _authenticatedUser;
  bool _isLoading = false;
}

mixin ExpensesModel on ConnectedExpensesModel {
  List<Expense> get allExpenses {
    return List.from(_expenses);
  }

  String get searchQuery {
    return _searchQuery;
  }

  void setSearchQuery() {
    _searchQuery = '';
  }

  void updateSearchQuery(String value) {
    _searchQuery = value.toLowerCase();
    notifyListeners();
  }

  List<Expense> get filteredExpenses {
    List<Expense> searchOutput = [];
    List<Expense> finalOutput = _expenses;
    if (searchQuery != null) {
      searchOutput = _expenses.where((expense) {
        return expense.title.toLowerCase().contains(searchQuery) ||
            expense.description.toLowerCase().contains(searchQuery);
      }).toList();
      finalOutput = searchOutput;
    }
    finalOutput.sort(
      (a, b) {
        if (_sortBy == 'Date')
          return b.createdAt.compareTo(a.createdAt);
        else
          return a.amount < b.amount ? 1 : -1;
      },
    );
    return finalOutput;
  }

  String get sortBy {
    return _sortBy;
  }

  void updateSort() {
    _sortBy = (_sortBy == 'Date' ? 'Amount' : 'Date');
    notifyListeners();
  }

  String formatDate(DateTime date) {
    List<String> _date = date.toIso8601String().substring(0, 10).split("-");

    return "${_date[2]}-${_date[1]}-${_date[0]}";
  }

  List<Expense> get displayedExpenses {
    List<Expense> filterd = _expenses;
    filterd = filteredExpenses;
    return List.from(
        (filterd == null && searchQuery == null) ? _expenses : filterd);
  }

  int get selectedExpenseIndex {
    return _expenses.indexWhere((Expense expense) {
      return expense.id == _selExpenseId;
    });
  }

  String get selectedExpenseId {
    return _selExpenseId;
  }

  void setSelctedExpense() => _selExpenseId = null;

  Expense get selectedExpense {
    if (selectedExpenseId == null) {
      return null;
    }

    return _expenses.firstWhere((Expense expense) {
      return expense.id == _selExpenseId;
    });
  }

  double categoryExpenses(value) {
    double sum = 0;
    for (int i = 0; i < allExpenses.length; i++) {
      if (allExpenses[i].category == value) sum = sum + allExpenses[i].amount;
    }
    return sum;
  }

  Map<String, double> categoryMap() {
    Map<String, double> dataMap = {
      'No Category': categoryExpenses('No Category'),
      'Food': categoryExpenses('Food'),
      'Bills': categoryExpenses('Bills'),
      'Entertainment': categoryExpenses('Entertainment'),
      'Shopping': categoryExpenses('Shopping'),
      'Health': categoryExpenses('Health'),
      'Education': categoryExpenses('Education'),
      'Travel': categoryExpenses('Travel')
    };
    return dataMap;
  }

  void todayExpense(_expenses) {
    today = 0;
    for (var i = 0; i < _expenses.length; i++)
      if (formatDate(_expenses[i].createdAt) == formatDate(DateTime.now()))
        today = today + _expenses[i].amount;
  }

  void totalExpenses(_expenses) {
    totalExpense = 0;
    for (var i = 0; i < _expenses.length; i++)
      totalExpense = totalExpense + _expenses[i].amount;
  }

  Future<bool> addExpense(String title, String description, double amount,
      DateTime createdAt, String category) async {
    _isLoading = true;
    notifyListeners();
    final Map<String, dynamic> expenseData = {
      'title': title,
      'description': description,
      // 'image':
      //     'https://img.etimg.com/thumb/width-640,height-480,imgsize-186055,resizemode-1,msid-66135358/rupee-tanks-32-paise-to-hit-fresh-lifetime-low-of-74-39.jpg',
      'amount': amount,
      'createdAt': createdAt.toIso8601String(),
      'category': category,
      'userEmail': _authenticatedUser.email,
      'userId': _authenticatedUser.id,
    };
    try {
      final http.Response response = await http.post(
          'https://Your-Project-Id.firebaseio.com/expenses/${_authenticatedUser.id}.json?auth=${_authenticatedUser.token}',
          body: json.encode(expenseData));

      if (response.statusCode != 200 && response.statusCode != 201) {
        _isLoading = false;
        notifyListeners();
        return false;
      }
      final Map<String, dynamic> responseData = json.decode(response.body);
      final Expense newExpense = Expense(
          id: responseData['name'],
          title: title,
          description: description,
          //image: image,
          amount: amount,
          createdAt: DateTime.parse(createdAt.toString()),
          category: category,
          userEmail: _authenticatedUser.email,
          userId: _authenticatedUser.id);
      _expenses.add(newExpense);
      totalExpenses(_expenses);
      todayExpense(_expenses);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (error) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateExpense(String title, String description, double amount,
      DateTime createdAt, String category) {
    _isLoading = true;
    notifyListeners();
    final Map<String, dynamic> updateData = {
      'title': title,
      'description': description,
      // 'image':
      //     'https://img.etimg.com/thumb/width-640,height-480,imgsize-186055,resizemode-1,msid-66135358/rupee-tanks-32-paise-to-hit-fresh-lifetime-low-of-74-39.jpg',
      'amount': amount,
      'createdAt': createdAt.toIso8601String(),
      'category': category,
      'userEmail': selectedExpense.userEmail,
      'userId': selectedExpense.userId,
    };
    return http
        .put(
            'https://Your-Project-Id.firebaseio.com/expenses/${_authenticatedUser.id}/${selectedExpense.id}.json?auth=${_authenticatedUser.token}',
            body: json.encode(updateData))
        .then((http.Response reponse) {
      _isLoading = false;
      final Expense updatedExpense = Expense(
          id: selectedExpense.id,
          title: title,
          description: description,
          //image: image,
          amount: amount,
          createdAt: DateTime.parse(createdAt.toString()),
          category: category,
          userEmail: selectedExpense.userEmail,
          userId: selectedExpense.userId);
      _expenses[selectedExpenseIndex] = updatedExpense;
      _selExpenseId = null;
      totalExpenses(_expenses);
      todayExpense(_expenses);
      notifyListeners();
      return true;
    }).catchError((error) {
      _isLoading = false;
      notifyListeners();
      return false;
    });
  }

  Future<bool> deleteExpense() {
    _isLoading = true;
    final deletedExpenseId = selectedExpense.id;
    _expenses.removeAt(selectedExpenseIndex);
    _selExpenseId = null;
    notifyListeners();
    return http
        .delete(
            'https://Your-Project-Id.firebaseio.com/expenses/${_authenticatedUser.id}/$deletedExpenseId.json?auth=${_authenticatedUser.token}')
        .then((http.Response response) {
      totalExpenses(_expenses);
      todayExpense(_expenses);
      _isLoading = false;
      notifyListeners();
      return true;
    }).catchError((error) {
      _isLoading = false;
      notifyListeners();
      return false;
    });
  }

  Future<bool> clearAllExpense() {
    _isLoading = true;
    _selExpenseId = null;
    notifyListeners();
    return http
        .delete(
            'https://Your-Project-Id.firebaseio.com/expenses/${_authenticatedUser.id}.json?auth=${_authenticatedUser.token}')
        .then((http.Response response) {
      _expenses.clear();
      totalExpenses(_expenses);
      todayExpense(_expenses);
      _isLoading = false;
      notifyListeners();
      return true;
    }).catchError((error) {
      _isLoading = false;
      notifyListeners();
      return false;
    });
  }

  Future<Null> fetchExpenses() {
    _isLoading = true;
    notifyListeners();
    return http
        .get(
            'https://Your-Project-Id.firebaseio.com/expenses/${_authenticatedUser.id}.json?auth=${_authenticatedUser.token}')
        .then<Null>((http.Response response) {
      final List<Expense> fetchedExpenseList = [];
      final Map<String, dynamic> expenseListData = json.decode(response.body);
      if (expenseListData == null) {
        _isLoading = false;
        notifyListeners();
        return;
      }
      expenseListData.forEach((String expenseId, dynamic expenseData) {
        final Expense expense = Expense(
          id: expenseId,
          title: expenseData['title'],
          description: expenseData['description'],
          //image: expenseData['image'],
          amount: expenseData['amount'],
          createdAt: DateTime.parse(expenseData['createdAt']),
          category: expenseData['category'],
          userEmail: expenseData['userEmail'],
          userId: expenseData['userId'],
        );
        fetchedExpenseList.add(expense);
      });
      _expenses = fetchedExpenseList.toList();
      totalExpenses(_expenses);
      todayExpense(_expenses);
      _isLoading = false;
      notifyListeners();
      _selExpenseId = null;
    }).catchError((error) {
      _isLoading = false;
      notifyListeners();
      return;
    });
  }

  void selectExpense(String expenseId) {
    _selExpenseId = expenseId;
    notifyListeners();
  }
}

mixin UserModel on ConnectedExpensesModel {
  Timer _authTimer;
  PublishSubject<bool> _userSubject = PublishSubject();

  User get user {
    return _authenticatedUser;
  }

  PublishSubject<bool> get userSubject {
    return _userSubject;
  }

  Future<Map<String, dynamic>> authenticate(String email, String password,
      [AuthMode mode = AuthMode.Login]) async {
    _isLoading = true;
    notifyListeners();
    final Map<String, dynamic> authData = {
      'email': email,
      'password': password,
      'returnSecureToken': true
    };
    http.Response response;
    if (mode == AuthMode.Login) {
      response = await http.post(
        'https://www.googleapis.com/identitytoolkit/v3/relyingparty/verifyPassword?key=Your-Web-Api',
        body: json.encode(authData),
        headers: {'Content-Type': 'application/json'},
      );
    } else {
      _authenticatedUser = null;
      notifyListeners();
      response = await http.post(
        'https://www.googleapis.com/identitytoolkit/v3/relyingparty/signupNewUser?key=Your-Web-Api',
        body: json.encode(authData),
        headers: {'Content-Type': 'application/json'},
      );
    }

    final Map<String, dynamic> responseData = json.decode(response.body);
    bool hasError = true;
    String message = 'Something went wrong.';
    print(responseData);
    if (responseData.containsKey('idToken')) {
      hasError = false;
      message = 'Authentication succeeded!';
      _authenticatedUser = User(
          id: responseData['localId'],
          email: email,
          token: responseData['idToken']);
      setAuthTimeout(int.parse(responseData['expiresIn']));
      _userSubject.add(true);
      final DateTime now = DateTime.now();
      final DateTime expiryTime =
          now.add(Duration(seconds: int.parse(responseData['expiresIn'])));
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('token', responseData['idToken']);
      prefs.setString('userEmail', email);
      prefs.setString('userId', responseData['localId']);
      prefs.setString('expiryTime', expiryTime.toIso8601String());
    } else if (responseData['error']['message'] == 'EMAIL_EXISTS') {
      message = 'This email already exists.';
    } else if (responseData['error']['message'] == 'EMAIL_NOT_FOUND') {
      message = 'This email was not found.';
    } else if (responseData['error']['message'] == 'INVALID_PASSWORD') {
      message = 'The password is invalid.';
    }
    _isLoading = false;
    notifyListeners();
    return {'success': !hasError, 'message': message};
  }

  void autoAuthenticate() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token');
    final String expiryTimeString = prefs.getString('expiryTime');
    if (token != null) {
      final DateTime now = DateTime.now();
      final parsedExpiryTime = DateTime.parse(expiryTimeString);
      if (parsedExpiryTime.isBefore(now)) {
        _authenticatedUser = null;
        notifyListeners();
        return;
      }
      final String userEmail = prefs.getString('userEmail');
      final String userId = prefs.getString('userId');
      final int tokenLifespan = parsedExpiryTime.difference(now).inSeconds;
      _authenticatedUser = User(id: userId, email: userEmail, token: token);
      _userSubject.add(true);
      setAuthTimeout(tokenLifespan);
      notifyListeners();
    }
  }

  void logout() async {
    _expenses = [];
    _authenticatedUser = null;
    totalExpense = 0;
    _authTimer.cancel();
    _userSubject.add(false);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  void setAuthTimeout(int time) {
    _authTimer = Timer(Duration(seconds: time), logout);
  }
}

mixin UtilityModel on ConnectedExpensesModel {
  bool get isLoading {
    return _isLoading;
  }
}
