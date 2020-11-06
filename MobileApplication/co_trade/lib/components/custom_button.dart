import 'package:flutter/material.dart';
import '../services/constants.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final Function onPress;

  CustomButton({@required this.text,@required this.onPress});
  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      color: kBrightBlue,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(text,style: TextStyle(fontSize: 16),),
      ),
      onPressed: onPress,
    );
  }
}
