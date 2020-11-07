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
  final GlobalKey _scaffoldKey = new GlobalKey();

  _signOut() async {
    setState(() => isLoading = true);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('uid');

    setState(() => isLoading = false);
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => SignUpPage()));
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      progressIndicator: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(kBrightBlue),
      ),
      inAsyncCall: isLoading,
      child: Scaffold(
        drawer: Drawer(
          child: Container(
            height: double.infinity,
            width: double.infinity,
            color: kSlightDarkBlue,
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(18)),
                      color: kDarkBlue,
                    ),
                    height: 40,
                    width: double.infinity,
                    child: Row(
                      children: [
                        Expanded(
                            child: TextFormField(
                          style: TextStyle(
                            color: Colors.white,
                          ),
                          decoration: InputDecoration(
                              hintText: 'Search Users',
                              border: InputBorder.none),
                          cursorColor: Colors.white,
                        )),
                        Icon(
                          Icons.search,
                          size: 30,
                          color: kBrightBlue,
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        resizeToAvoidBottomPadding: false,
        body: Builder(
          builder: (context) => Container(
            width: double.infinity,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32,horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap:(){
                          Scaffold.of(context).openDrawer();
                        },
                        child: Image(
                          height: 40,
                          image: AssetImage('images/dots.png'),
                        ),
                      ),
                      Text(
                        'Stocks',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              Image(
                                height: 30,
                                image: AssetImage('images/coins_icon.png'),
                              ),
                              // Text(
                              //     Provider.of<Trader>(context,listen: false).coins.toString(),
                              //   style: TextStyle(color: kGreen),
                              // )
                            ],
                          ),

                          IconButton(
                            iconSize: 35,
                            icon: Icon(Icons.supervised_user_circle_rounded),
                            onPressed: (){
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ProfilePage(
                                        Provider.of<Trader>(context, listen: false)
                                            .uid,
                                        isPersonal: true,
                                        signOutCallback: _signOut,
                                      )));
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
