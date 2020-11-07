import 'package:co_trade/background/primary_template.dart';
import 'package:co_trade/components/custom_button.dart';
import 'package:co_trade/home_page/profile_page.dart';
import 'package:co_trade/models/trader.dart';
import 'package:co_trade/services/constants.dart';
import 'package:co_trade/sign_up/sign_up_page.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = false;

  _signOut() async{
    setState(() => isLoading=true);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('uid');

    setState(() => isLoading=false);
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context)=> SignUpPage()
        ));
  }

  @override
  Widget build(BuildContext context) {
    // Fluttertoast.showToast(msg: Provider.of<Trader>(context,listen:false).uid);
    return ModalProgressHUD(
      progressIndicator: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(kBrightBlue),
      ),
      inAsyncCall: isLoading,
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
        body: Container(
          width: double.infinity,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text(
                  'Welcome to Home Page',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
              CustomButton(text: 'Sign Out',
                  onPress: _signOut
              ),
              CustomButton(text: 'Profile',
                  onPress: (){
                Navigator.push(context, MaterialPageRoute(
                  builder: (context)=> ProfilePage(Provider.of<Trader>(context,listen: false).uid)
                ));
                  }
              )
            ],
          ),
        ),
      ),
    );
  }
}
