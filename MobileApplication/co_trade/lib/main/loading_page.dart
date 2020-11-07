import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:co_trade/home_page/home_page.dart';
import 'package:co_trade/models/trader.dart';
import 'package:co_trade/sign_up/sign_up_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/constants.dart';

class LoadingPage extends StatefulWidget {
  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {

  _checkLogin() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool loggedIn = prefs.containsKey('uid');
    if(loggedIn){
      Trader trader = Provider.of<Trader>(context,listen: false);
      trader.uid = prefs.getString('uid');

      // print(trader.uid);
      var db = FirebaseFirestore.instance;
      var snapshot = await db.collection('user_data').doc(trader.uid).get();
      var data = snapshot.data();
      print(data);
      trader.username = data['username'];
      trader.phoneNo = data['phoneNo'];
      trader.email = data['email'];
      trader.fullName = data['name'];
      trader.coins = data['coins'];
      trader.password = data['password'];

      Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context)=>HomePage()
      ));
    }
    else{
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context)=>SignUpPage()
      ));
    }
  }
  
  @override
  void initState(){
    super.initState();
    _checkLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image(
            height: 60,
            image: AssetImage('images/name_logo.png'),
          ),
        ),
      ),
    );
  }
}
