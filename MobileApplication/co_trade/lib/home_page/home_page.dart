import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:co_trade/components/custom_search.dart';
import 'package:co_trade/home_page/profile_page.dart';
import 'package:co_trade/home_page/stock_details.dart';
import 'package:co_trade/models/trader.dart';
import 'package:co_trade/services/constants.dart';
import 'package:co_trade/services/notifications.dart';
import 'package:co_trade/sign_up/sign_up_page.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String docId;
  bool isLoading = false;
  List<Trader> connectionRequest = [];
  List<Trader> suggestions = [];
  List<Trader> yourConnections = [];

  _signOut() async {
    setState(() => isLoading = true);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('username');

    setState(() => isLoading = false);
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => SignUpPage()));
  }

  _fetchConnectionRequests(String docId) async {
    final db = FirebaseFirestore.instance;
    await for(var snapshots in db.collection('user_data').doc(docId).collection('Requests').snapshots()){
      List<Trader> traders = [];
      for (var snapshot in snapshots.docs){
        if(snapshot.data()['username']!=''){
          Notifications().generate(
              'New Connection Request',
              'You have received connection request from ${snapshot.data()['name']}'
          );
          traders.add(
              Trader(
                fullName: snapshot.data()['name'],
                username: snapshot.data()['username'],
              )
          );
        }
      }
      setState(()=> connectionRequest=traders);
    }
  }


  _fetchYourConnections(String docId) async {
    final db = FirebaseFirestore.instance;
    await for(var snapshots in db.collection('user_data').doc(docId).collection('connections').snapshots()){
      List<Trader> traders = [];
      for (var snapshot in snapshots.docs){
        if(snapshot.data()['username']!=''){
          traders.add(
              Trader(
                fullName: snapshot.data()['name'],
                username: snapshot.data()['username'],
              )
          );
        }
      }
      setState(()=> yourConnections=traders);
    }
  }

  _fetchSuggestions() async {
    final db = FirebaseFirestore.instance;
    await db.collection('user_data').get().then((value) => {
          value.docs.forEach((element) {
            //TODO: SOME CONDITION HERE
            var data = element.data();
            if(data['username']!=Provider.of<Trader>(context,listen: false).username){
              suggestions.add(
                  Trader(fullName: data['name'], username: data['username']));
            }
          })
        });
    print(suggestions.length);
  }

  _fetchData() async{
    docId= await ProfilePage.getDocId(Provider.of<Trader>(context,listen: false).username);
    _fetchSuggestions();
    _fetchYourConnections(docId);
    _fetchConnectionRequests(docId);
  }

  _acceptRequest(String username,String name)async{
    final db = FirebaseFirestore.instance;
    String connectionID = await ProfilePage.getDocId(username);
    await db.collection('user_data').doc(connectionID).collection('connections').add({
      'name': Provider.of<Trader>(context,listen: false).fullName,
      'username':Provider.of<Trader>(context,listen: false).username,
    });

    await db.collection('user_data').doc(docId).collection('connections').add({
      'name': name,
      'username':username,
    });
    await _rejectRequest(username);
  }

  _rejectRequest(String username) async{
    final db = FirebaseFirestore.instance;
    QuerySnapshot ss= await db.collection('user_data').doc(docId).collection('Requests').where('username',isEqualTo: username).get();
    await db.collection('user_data').doc(docId).collection('Requests').doc(ss.docs[0].id).delete();
  }

  _sendRequest(String username) async{
    final db = FirebaseFirestore.instance;
    QuerySnapshot ss= await db.collection('user_data').where('username',isEqualTo: username).get();
    String dId = ss.docs[0].id;
    await db.collection('user_data').doc(dId).collection('Requests').add({
      'name': Provider.of<Trader>(context,listen: false).fullName,
      'username': Provider.of<Trader>(context,listen: false).username,
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  int _currentIndex = 0;
  final PageController _pageController = PageController();

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
                    hintText: 'Search Users',
                    onChange: (value) {
                      //TODO: Implement Searching
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
                Expanded(
                  child: ListView.builder(
                    itemCount: connectionRequest.length,
                    itemBuilder: (context,index){
                      return ListTile(
                        leading: Image(
                          height: 30,
                          image: AssetImage('images/unknown_request.png'),
                        ),
                        title: Text(
                          connectionRequest[index].fullName,
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          connectionRequest[index].username,
                          style: TextStyle(color: Colors.white),
                        ),
                        trailing: Container(
                          width: 80,
                          child: Row(
                            children: [
                              Flexible(
                                child: IconButton(
                                  icon: Icon(Icons.clear),
                                  onPressed: (){
                                    _rejectRequest(connectionRequest[index].username);
                                    Fluttertoast.showToast(msg: 'Request Rejected');
                                  }
                                ),
                              ),
                              SizedBox(width: 20,),
                              Flexible(
                                child: IconButton(
                                  icon: Icon(Icons.check),
                                  onPressed: (){
                                    _acceptRequest(connectionRequest[index].username,connectionRequest[index].fullName);
                                    Fluttertoast.showToast(msg: 'Request Accepted');
                                  }
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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
                Expanded(
                  child: ListView.builder(
                    itemCount: suggestions.length,
                    itemBuilder: (context,index){
                      return ListTile(
                        leading: Image(
                          height: 30,
                          image: AssetImage('images/coins_icon.png'),
                        ),
                        title: Text(
                          suggestions[index].fullName,
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                            suggestions[index].username,
                            style: TextStyle(color: Colors.white),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.connect_without_contact),
                          onPressed: (){
                            _sendRequest(suggestions[index].username);
                            Fluttertoast.showToast(msg: 'Connection Request Sent');
                          },
                        ),
                      );
                    },
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
                Expanded(
                  child: ListView.builder(
                    itemCount: yourConnections.length,
                    itemBuilder: (context,index){
                      return GestureDetector(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(
                              builder: (context)=> ProfilePage(yourConnections[index].username)
                          ));
                        },
                        child: ListTile(
                          leading: Image(
                            height: 30,
                            image: AssetImage('images/bald_man.png'),
                          ),
                          title: Text(
                            yourConnections[index].fullName,
                            style: TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            yourConnections[index].username,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    },
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
                        _currentIndex==0?'Stocks':'Feeds',
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
                            ],
                          ),
                          IconButton(
                            iconSize: 35,
                            icon: Icon(Icons.supervised_user_circle_rounded,),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ProfilePage(
                                            Provider.of<Trader>(context,
                                                    listen: false)
                                                .username,
                                            isPersonal: true,
                                            signOutCallback: _signOut,
                                          ),
                                  ),
                              );
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                Flexible(
                  child: Container(
                    // color: Colors.red,
                    height: double.infinity,
                    width: double.infinity,
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() => _currentIndex = index);
                      },
                      children: [
                        StockDetailsPage(),
                        Text('TWO',style: TextStyle(color: Colors.white),),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
