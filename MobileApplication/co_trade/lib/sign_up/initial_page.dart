
import 'package:co_trade/background/login_template.dart';
import 'package:co_trade/components/custom_button.dart';
import 'package:co_trade/sign_in/sign_in_page.dart';
import 'package:flutter/material.dart';

class InitialPage extends StatelessWidget {
  final Function nextPageCallback;
  InitialPage(this.nextPageCallback);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            child: CustomPaint(painter: LoginTemplate()),
          ),
          Container(
            width: double.infinity,
            child: Column(
              children: [
                SizedBox(height: 50,),
                Image(
                  height: 45,
                  image: AssetImage('images/name_logo.png'),
                ),
                SizedBox(
                  height: 80,
                ),
                Image(
                  height: 150,
                  image: AssetImage('images/login_page_logo.png'),
                ),
                SizedBox(
                  height: 150,
                ),
                CustomButton(text: 'Sign Up', onPress: nextPageCallback),
                SizedBox(
                  height: 20,
                ),
                Column(
                  children: [
                    Text(
                      'Already have an account?',
                      style: TextStyle(color: Colors.white),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignInPage()));
                      },
                      child: Text(
                        'Please Sign In',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
