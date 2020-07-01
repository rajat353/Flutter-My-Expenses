import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import './pages/auth.dart';
import './pages/expenses.dart';
import './scoped-models/main.dart';



void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  final MainModel _model = MainModel();
  bool _isAuthenticated = false;

  @override
  void initState() {
    _model.autoAuthenticate();
    _model.userSubject.listen((bool isAuthenticated) {
      setState(() {
        _isAuthenticated = isAuthenticated;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<MainModel>(
      model: _model,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.teal,
            accentColor: Colors.blue[700],
            buttonColor: Colors.red),
        routes: {
          '/': (BuildContext context) =>
              !_isAuthenticated ? AuthPage() : ExpensesPage(_model),
        },
        onUnknownRoute: (RouteSettings settings) {
          return MaterialPageRoute(
              builder: (BuildContext context) =>
                  !_isAuthenticated ? AuthPage() : ExpensesPage(_model));
        },
      ),
    );
  }
}
