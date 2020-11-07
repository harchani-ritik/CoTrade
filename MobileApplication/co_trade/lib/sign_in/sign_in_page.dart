import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:co_trade/background/primary_template.dart';
import 'package:co_trade/components/custom_button.dart';
import 'package:co_trade/components/custom_field.dart';
import 'package:co_trade/models/trader.dart';
import 'package:co_trade/services/constants.dart';
import 'package:co_trade/sign_up/sign_up_page.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../home_page/home_page.dart';

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isLoading =false;

  Future<bool> _onBackPress() async {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => SignUpPage()));
    return false;
  }


  _checkCredentials(String username, String password)async{

    setState(() => isLoading=true);
    bool credentialsVerified=false;

    final dB = FirebaseFirestore.instance;
    await dB.collection('user_data').get().then((querySnapshot) {
      querySnapshot.docs.forEach((result) {
        if(result.data()['username']==username && result.data()['password']==password){
          credentialsVerified=true;
          print(result.id);
          Trader trader = Provider.of<Trader>(context,listen: false);
          var data = result.data();
          trader.uid=result.id;
          trader.username = data['username'];
          trader.phoneNo = data['phoneNo'];
          trader.email = data['email'];
          trader.fullName = data['name'];
          trader.coins = data['coins'];
          trader.password = data['password'];
        }
      });
    });

    setState(() => isLoading=false);

    if(!credentialsVerified){
      Fluttertoast.showToast(msg: 'Invalid username or password');
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('uid', Provider.of<Trader>(context,listen: false).uid);

    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPress,
      child: ModalProgressHUD(
        progressIndicator: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(kBrightBlue),
        ),
        inAsyncCall: isLoading,
        child: Scaffold(
          resizeToAvoidBottomPadding: false,
          body: Stack(
            children: [
              Container(
                height: double.infinity,
                width: double.infinity,
                child: CustomPaint(painter: PrimaryTemplate()),
              ),
              Container(
                width: double.infinity,
                child: Column(
                  children: [
                    SizedBox(
                      height: 260,
                    ),
                    CustomField(
                      controller: _usernameController,
                      hintText: 'Username',
                    ),
                    SizedBox(
                      height: 60,
                    ),
                    CustomField(
                      controller: _passwordController,
                      hintText: 'Password',
                    ),
                    SizedBox(
                      height: 100,
                    ),
                    CustomButton(
                        text: 'Sign In',
                        onPress: (){
                          _checkCredentials(_usernameController.text,_passwordController.text);
                        }
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
