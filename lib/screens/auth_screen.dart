import 'package:flutter/material.dart';
import 'dart:math';
import 'package:email_validator/email_validator.dart';
import 'package:flutter_password_strength/flutter_password_strength.dart';
import 'package:provider/provider.dart';
import 'package:state_management/exception/http_exception.dart';
import '../providers/auth.dart';

enum AuthMode { Signup, Login }

class AuthScreen extends StatelessWidget {
  static const routeName = '/auth-screen';

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Scaffold(
        //resizeToAvoidBottomInset: true,
        body: Stack(
      children: <Widget>[
        /*  Container(
            decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromRGBO(215, 117, 255, 1).withOpacity(0.5),
              Color.fromRGBO(255, 188, 117, 1).withOpacity(0.9),
            ],

          ),
        )) */
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment(0.8, 0.0),
              stops: [0.2, 0.8], // 10% of the width, so there are ten blinds.
              colors: [
                // const Color(0xFFFFFFEE),
                // const Color(0xFF999999),
                Color.fromRGBO(215, 117, 255, 1).withOpacity(0.5),
                Color.fromRGBO(255, 188, 117, 1).withOpacity(0.9),
              ], // whitish to gray
              tileMode:
                  TileMode.repeated, // repeats the gradient over the canvas
            ),
          ),
        ),
        SingleChildScrollView(
          child: Container(
            height: deviceSize.height,
            width: deviceSize.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Flexible(
                  child: Container(
                    margin: EdgeInsets.only(bottom: 20.0),
                    transform: Matrix4.rotationZ(-8 * pi / 180)
                      ..translate(-10.0),
                    padding:
                        EdgeInsets.symmetric(vertical: 8.00, horizontal: 94.00),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.deepOrange.shade900,
                        border: Border.all(width: 1, style: BorderStyle.solid),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 8,
                            color: Colors.black26,
                            //Dont not why this is used
                            // offset: Offset(0,2),
                          )
                        ]),
                    child: Text(
                      "My Shop",
                      style: TextStyle(
                        color: Theme.of(context).accentTextTheme.title.color,
                        fontSize: 50,
                        fontFamily: 'Anton',
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ),
                Flexible(
                  flex: deviceSize.width > 600 ? 2 : 1,
                  child: AuthCard(),
                )
              ],
            ),
          ),
        )
      ],
    ));
  }
}

class AuthCard extends StatefulWidget {
  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard>
    with SingleTickerProviderStateMixin {
  AuthMode _authMode = AuthMode.Login;
  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };
  final GlobalKey<FormState> _formKey = GlobalKey();
  var _isLoading = false;
  AnimationController _animationController;
  Animation<Offset> _slideAnimation;
  Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 350),
    );
    // _animate = Tween<Size>(
    //         begin: Size(double.infinity, 260), end: Size(double.infinity, 320))
    //     .animate(CurvedAnimation(
    //   parent: _animationController,
    //   curve: Curves.elasticOut,
    // ));
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        curve: Curves.easeIn,
        parent: _animationController,
      ),
    );
    _slideAnimation =
        Tween<Offset>(begin: Offset(0, -1.5), end: Offset(0, 0)).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    // _animationController.addListener(() {
    //   setState(() {});
    // });
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
    //_animationController.removeListener(() {});
  }

  Future<void> _errorDialog(String content, String title) {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text("$content"),
        title: Text("$title"),
        actions: <Widget>[
          FlatButton.icon(
            icon: Icon(
              Icons.check,
            ),
            label: Text("Okay"),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  Future<void> _validateForm() async {
    if (!_formKey.currentState.validate()) return;
    _formKey.currentState.save();

    setState(() {
      _isLoading = true;
    });
    try {
      print("Button pressed");
      if (_authMode == AuthMode.Login) {
        print("Inside auth login method");
        await Provider.of<Auth>(context, listen: false).signIn(
          _authData['email'],
          _authData['password'],
        );
      } else {
        await Provider.of<Auth>(context, listen: false).signUp(
          _authData['email'],
          _authData['password'],
        );
      }
    } on HttpException catch (error) {
      var errorMessage = "Authentication failed";
      if (error.toString().contains("EMAIL_EXISTS"))
        errorMessage = "This Email is address already in use";
      else if (error.toString().contains("INVALID_EMAIL"))
        errorMessage = "This is not a valid Email addresss";
      else if (error.toString().contains('EMAIL_NOT_FOUND'))
        errorMessage = "Please enter a valid email address";
      else if (error.toString().contains("WEAK_PASSWORD"))
        errorMessage = "The Password is too weak..";
      else if (error.toString().contains("INVALID_PASSWORD"))
        errorMessage = "Please enter the correct password";
      _errorDialog(errorMessage, "An User Error Occured");
    } catch (error) {
      const errorMessage =
          "Some problem with the internet or the server has been occured\nPlease try again Later";
      _errorDialog(errorMessage, "An internal error occurred");
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
      _animationController.forward();
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final _deviceSize = MediaQuery.of(context).size;
    final _passwordFocus = FocusNode();
    final _confirmPasswordFocus = FocusNode();
    final _passwordController = TextEditingController();
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 8.0,
      // child: AnimatedBuilder(
      //   animation: _animate,
      //   builder: (ctx, ch) => Container(
      //       // height: _authMode == AuthMode.Signup ? 320 : 260,
      //       height: _animate.value.height,
      //       constraints: BoxConstraints(
      //         // minHeight: _authMode == AuthMode.Signup ? 320 : 260,
      //         minHeight: _animate.value.height,
      //       ),
      //       width: _deviceSize.width * 0.75,
      //       padding: const EdgeInsets.all(16.00),
      //       child: ch),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 350),
        curve: Curves.easeIn,
        height: _authMode == AuthMode.Signup ? 320 : 260,
        constraints: BoxConstraints(
          minHeight: _authMode == AuthMode.Signup ? 320 : 260,
        ),
        width: _deviceSize.width * 0.75,
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_passwordFocus);
                  },
                  validator: (value) {
                    if (value.isEmpty) return "Please Enter Email Address!!..";
                    return EmailValidator.validate(value)
                        ? null
                        : "Please Enter valid Email address....";
                  },
                  onSaved: (value) {
                    _authData['email'] = value;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: "Password"),
                  obscureText: true,
                  textInputAction: _authMode == AuthMode.Login
                      ? TextInputAction.done
                      : TextInputAction.next,
                  onFieldSubmitted: (_) {
                    if (_authMode == AuthMode.Signup)
                      FocusScope.of(context)
                          .requestFocus(_confirmPasswordFocus);
                    else if (_authMode == AuthMode.Login) _validateForm();
                  },
                  controller: _passwordController,
                  focusNode: _passwordFocus,
                  validator: (value) {
                    if (value.isEmpty) return "Please Enter Password!..";
                    if (value.length < 8)
                      return "Password should be atleast 8 letter wrong";
                    if (value.contains(new RegExp(r'[A-Z]')))
                      return "Password should contains atleat one capital letter";
                    return null;
                  },
                  onSaved: (value) {
                    _authData['password'] = value;
                  },
                ),
                AnimatedContainer(
                  duration: Duration(milliseconds: 350),
                  curve: Curves.easeIn,
                  height: _authMode == AuthMode.Signup ? 60: 0,
                  constraints: BoxConstraints(
                      minHeight: _authMode == AuthMode.Signup ? 60 : 0,
                      maxHeight: _authMode == AuthMode.Signup ? 140 : 0),
                  child: FadeTransition(
                    opacity: _opacityAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child:   TextFormField(
                        obscureText: true,
                        enabled: _authMode == AuthMode.Signup,
                        decoration:
                            InputDecoration(labelText: "Confirm Password"),
                        focusNode: _confirmPasswordFocus,
                        validator: (value) {
                          if (_authMode == AuthMode.Signup)
                            if (_passwordController.text != value)
                              return "Confirm Password does not match";
                          return null;
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                if (_isLoading)
                  CircularProgressIndicator()
                else
                  RaisedButton(
                    child:
                        Text(_authMode == AuthMode.Login ? "Login" : "Signup"),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding:
                        EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
                    color: Theme.of(context).primaryColor,
                    textColor: Theme.of(context).primaryTextTheme.button.color,
                    onPressed: _validateForm,
                  ),
                FlatButton(
                  child: Text(
                      '${_authMode == AuthMode.Login ? 'SIGNUP' : 'LOGIN'} INSTEAD'),
                  onPressed: _switchAuthMode,
                  padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textColor: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
