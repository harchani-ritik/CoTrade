import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:co_trade/background/primary_template.dart';
import 'package:co_trade/components/custom_button.dart';
import 'package:co_trade/components/custom_field.dart';
import 'package:co_trade/models/trader.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AuthPage extends StatefulWidget {
  final Function nextPageCallback;
  final Function previousPageCallback;

  AuthPage(this.nextPageCallback, this.previousPageCallback);

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _phoneNoController = TextEditingController();

  Future<bool> _onBackPress() async {
    widget.previousPageCallback();
    return false;
  }

  Future<bool> _checkPhoneNumber(String phoneNo) async{
    bool duplicateFlag=false;
    final dB = FirebaseFirestore.instance;
    await dB.collection('user_data').get().then((querySnapshot) {
      querySnapshot.docs.forEach((result) {
        if(result.data()['phoneNo']==phoneNo){
          duplicateFlag=true;
        }
      });
    });
    return duplicateFlag;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPress,
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
                    controller: _phoneNoController,
                    hintText: 'Phone Number',
                  ),
                  SizedBox(
                    height: 60,
                  ),
                  // CustomField(
                  //   hintText: 'Otp',
                  // ),
                  SizedBox(
                    height: 100,
                  ),
                  CustomButton(
                      text: 'Next ->',
                      onPress: () async{
                        if(_phoneNoController.text.isNotEmpty){
                          bool isDuplicate = await _checkPhoneNumber(_phoneNoController.text);
                          if(!isDuplicate) {
                            Provider
                                .of<Trader>(context, listen: false)
                                .phoneNo = _phoneNoController.text;
                            widget.nextPageCallback();
                          }
                          else{
                            Fluttertoast.showToast(msg: 'Phone Number already registered,\nPlease Sign In');
                          }
                        }
                        else{
                          Fluttertoast.showToast(msg: 'Phone Number is Required');
                        }
                      }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
