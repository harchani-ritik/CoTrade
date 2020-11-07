import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:co_trade/background/primary_template.dart';
import 'package:co_trade/components/custom_button.dart';
import 'package:co_trade/components/custom_field.dart';
import 'package:co_trade/home_page/home_page.dart';
import 'package:co_trade/models/trader.dart';
import 'package:co_trade/services/constants.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileSetup extends StatefulWidget {
  final Function previousPageCallback;

  ProfileSetup(this.previousPageCallback);

  @override
  _ProfileSetupState createState() => _ProfileSetupState();
}

class _ProfileSetupState extends State<ProfileSetup> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool isLoading = false;

  Future<bool> _onBackPress() async {
    widget.previousPageCallback();
    return false;
  }

  _registerUser(Trader trader) async{
    final dB = FirebaseFirestore.instance;
    DocumentReference ref = await dB.collection('user_data').add({
      'name': trader.fullName,
      'coins': trader.coins,
      'email': trader.email,
      'username':trader.username,
      'password': trader.password,
      'phoneNo': trader.phoneNo,
    });
    trader.uid = ref.id;
  }

  Future<bool> _checkForDuplicateUsername(String username) async{
    bool duplicateFlag=false;
    final dB = FirebaseFirestore.instance;
    await dB.collection('user_data').get().then((querySnapshot) {
      querySnapshot.docs.forEach((result) {
        if(result.data()['username']==username){
          duplicateFlag=true;
        }
      });
    });
    return duplicateFlag;
  }

  _checkInputData() async{
    setState(() => isLoading=true);

    if(_nameController.text.isEmpty || _emailController.text.isEmpty||
        _usernameController.text.isEmpty|| _passwordController.text.isEmpty){
      Fluttertoast.showToast(msg: 'All fields are required');
      setState(() => isLoading=false);
      return;
    }

    bool isUsernameTaken = await _checkForDuplicateUsername(_usernameController.text);
    if(isUsernameTaken){
      Fluttertoast.showToast(msg: 'Username already taken\nPlease try something else');
      setState(() => isLoading=false);
      return;
    }

    Trader newTrader = Provider.of<Trader>(context,listen: false);
    newTrader.fullName = _nameController.text;
    newTrader.email = _emailController.text;
    newTrader.username = _usernameController.text;
    newTrader.password = _passwordController.text;

    await _registerUser(newTrader);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('uid', Provider.of<Trader>(context,listen: false).uid);

    setState(() => isLoading=false);
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
          body: Container(
            width: double.infinity,
            child: Column(
              children: [
                SizedBox(height: 50,),
                Image(
                  height: 45,
                  image: AssetImage('images/name_logo.png'),
                ),
                SizedBox(
                  height: 100,
                ),
                CustomField(
                  controller: _nameController,
                  hintText: 'Full Name',
                ),
                SizedBox(
                  height: 20,
                ),
                CustomField(
                  controller: _emailController,
                  hintText: 'Email',
                ),
                SizedBox(
                  height: 60,
                ),
                CustomField(
                  controller: _usernameController,
                  hintText: 'Username',
                  large: false,
                ),
                SizedBox(
                  height: 20,
                ),
                CustomField(
                  controller: _passwordController,
                  hintText: 'Password',
                  large: false,
                ),
                SizedBox(
                  height: 60,
                ),
                CustomButton(
                  text: 'Done',
                  onPress: _checkInputData,
                ),
              ],
            ),
          ),
        ),
      ),
    );
    ;
  }
}
