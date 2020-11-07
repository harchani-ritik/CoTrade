import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:co_trade/background/primary_template.dart';
import 'package:co_trade/components/custom_button.dart';
import 'package:co_trade/components/search_bar.dart';
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
  List<Trader> recommendedTraders = [];

  _fetchTraderRecommendation() async {
    final db = FirebaseFirestore.instance;
    await db.collection('user_data').get().then((value) => {
          value.docs.forEach((element) {
            //TODO: SOME CONDITION HERE
            print(element.id);
            var data = element.data();
            recommendedTraders.add(
                Trader(uid: element.id,fullName: data['name'], username: data['username']));
          })
        });
    print(recommendedTraders.length);
  }

  _signOut() async {
    setState(() => isLoading = true);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('uid');

    setState(() => isLoading = false);
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => SignUpPage()));
  }

  @override
  void initState() {
    super.initState();
    _fetchTraderRecommendation();
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
                  padding: const EdgeInsets.fromLTRB(16, 32, 16, 12),
                  child: CustomSearch(
                    onChange: (value) {
                      print(value);
                    },
                  ),
                ),
                Align(
                    alignment: Alignment(-0.7, 0),
                    child: Text(
                      'Connection Requests',
                      style: TextStyle(
                          color: kGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    )),
                ListTile(
                  leading: Image(
                    height: 30,
                    image: AssetImage('images/coins_icon.png'),
                  ),
                  title: Text(
                    'Nitin Madhukar',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    '@nitinmadhukar',
                    style: TextStyle(color: Colors.white),
                  ),
                  trailing: Container(
                    width: 50,
                    child: Row(
                      children: [
                        Flexible(
                          child: IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: (){
                              //TODO: REJECT
                            },
                          ),
                        ),
                        Flexible(
                          child: IconButton(
                            icon: Icon(Icons.check),
                            onPressed: (){
                              //TODO: REJECT
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Divider(),
                Align(
                    alignment: Alignment(-0.7, 0),
                    child: Text(
                      'Suggestions',
                      style: TextStyle(
                          color: kGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    )),
                ListTile(
                  leading: Image(
                    height: 30,
                    image: AssetImage('images/coins_icon.png'),
                  ),
                  title: Text(
                    'Nitin Madhukar',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    '@nitinmadhukar',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                Divider(),
                Align(
                    alignment: Alignment(-0.7, 0),
                    child: Text(
                      'Your Connections',
                      style: TextStyle(
                          color: kGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    )),
                ListTile(
                  leading: Image(
                    height: 30,
                    image: AssetImage('images/coins_icon.png'),
                  ),
                  title: Text(
                    'Nitin Madhukar',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    '@nitinmadhukar',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
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
                  padding:
                      const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
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
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ProfilePage(
                                            Provider.of<Trader>(context,
                                                    listen: false)
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
