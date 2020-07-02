import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scoped_model/scoped_model.dart';
import '../scoped-models/main.dart';
import '../models/auth.dart';

class AuthPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AuthPageState();
  }
}

class _AuthPageState extends State<AuthPage> {
  final Map<String, dynamic> _formData = {
    'email': null,
    'password': null,
  };
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordTextController = TextEditingController();
  AuthMode _authMode = AuthMode.Login;

  DecorationImage _buildBackgroundImage() {
    return DecorationImage(
      fit: BoxFit.cover,
      colorFilter:
          ColorFilter.mode(Colors.black.withOpacity(0.6), BlendMode.dstATop),
      image: AssetImage('assets/background.png'),
    );
  }

  Future<bool> onWillPop() {
    return showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            backgroundColor: Colors.white,
            shape: Border.all(color: Colors.teal),
            title: new Text('Are you sure?',
                style: TextStyle(color: Colors.black)),
            content: new Text('Do you want to exit?',
                style: TextStyle(color: Colors.black)),
            actions: <Widget>[
              new FlatButton(
                splashColor: Colors.teal,
                shape: Border.all(color: Colors.teal),
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  "NO",
                  style: TextStyle(color: Colors.black),
                ),
              ),
              SizedBox(height: 30),
              new FlatButton(
                splashColor: Colors.white,
                shape: Border.all(color: Colors.teal),
                onPressed: () => SystemNavigator.pop(),
                child: Text(
                  "YES",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  Widget _buildEmailTextField() {
    return TextFormField(
      decoration: InputDecoration(
          labelText: 'E-Mail', filled: true, fillColor: Colors.white),
      keyboardType: TextInputType.emailAddress,
      validator: (String value) {
        if (value.isEmpty ||
            !RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                .hasMatch(value)) {
          return 'Please enter a valid email';
        }
      },
      onSaved: (String value) {
        _formData['email'] = value;
      },
    );
  }

  Widget _buildPasswordTextField() {
    return TextFormField(
      decoration: InputDecoration(
          labelText: 'Password (6-15 characters)',
          filled: true,
          fillColor: Colors.white),
      obscureText: true,
      controller: _passwordTextController,
      validator: (String value) {
        if (value.isEmpty || value.length < 6 || value.length > 15) {
          return 'Password invalid';
        }
      },
      onSaved: (String value) {
        _formData['password'] = value;
      },
    );
  }

  Widget _buildPasswordConfirmTextField() {
    return TextFormField(
      decoration: InputDecoration(
          labelText: 'Confirm Password', filled: true, fillColor: Colors.white),
      obscureText: true,
      validator: (String value) {
        if (_passwordTextController.text != value) {
          return 'Passwords do not match.';
        }
      },
    );
  }

  void _submitForm(Function authenticate) async {
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();
    Map<String, dynamic> successInformation;
    successInformation = await authenticate(
        _formData['email'], _formData['password'], _authMode);
    if (successInformation['success']) {
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('An Error Occurred!'),
            content: Text(successInformation['message']),
            actions: <Widget>[
              FlatButton(
                child: Text('Okay'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth * 0.95;
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: WillPopScope(
            onWillPop: onWillPop,
            child: Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: false,
                centerTitle: true,
                title: Text(_authMode == AuthMode.Login ? 'Login' : 'Sign Up'),
              ),
              body: Container(
                decoration: BoxDecoration(
                  image: _buildBackgroundImage(),
                ),
                padding: EdgeInsets.all(10.0),
                child: Center(
                  child: SingleChildScrollView(
                    child: Container(
                      width: targetWidth,
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: <Widget>[
                            _buildEmailTextField(),
                            SizedBox(
                              height: 10.0,
                            ),
                            _buildPasswordTextField(),
                            SizedBox(
                              height: 10.0,
                            ),
                            _authMode == AuthMode.Signup
                                ? _buildPasswordConfirmTextField()
                                : Container(),
                            SizedBox(
                              height: 10.0,
                            ),
                            ScopedModelDescendant<MainModel>(
                              builder: (BuildContext context, Widget child,
                                  MainModel model) {
                                return model.isLoading
                                    ? CircularProgressIndicator()
                                    : RaisedButton(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        textColor: Colors.white,
                                        child: Text(_authMode == AuthMode.Login
                                            ? 'Login'
                                            : 'Sign Up'),
                                        onPressed: () =>
                                            _submitForm(model.authenticate),
                                      );
                              },
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            FlatButton(
                              textColor: Colors.teal,
                              child: Text(
                                _authMode == AuthMode.Login
                                    ? "New Here?\nSwitch to " + 'Signup'
                                    : "Already a Member?\nSwitch to " 'Login',
                                textAlign: TextAlign.center,
                              ),
                              onPressed: () {
                                setState(() {
                                  _authMode = _authMode == AuthMode.Login
                                      ? AuthMode.Signup
                                      : AuthMode.Login;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )));
  }
}
