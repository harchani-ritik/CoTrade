import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:co_trade/home_page/profile_page.dart';
import 'package:co_trade/models/feed.dart';
import 'package:co_trade/models/trader.dart';
import 'package:co_trade/services/constants.dart';
import 'package:co_trade/services/notifications.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FeedPage extends StatefulWidget {
  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {

  bool isLoading =false;
  List<Feed> feeds=[];


  _fetchFeed() async{

    final db = FirebaseFirestore.instance;
    List<String> usernames=[];
    String docId = await ProfilePage.getDocId(Provider.of<Trader>(context,listen:false).username);



    await db.collection('user_data').doc(docId).collection('connections').get().then((value) => {
      value.docs.forEach((element) async {
        usernames.add(element.data()['username']);
      })
    });

    List<String> ids=[];
    for(var i in usernames){
      if(i=='')
        continue;
      var snapshot = await db.collection('user_data').where('username',isEqualTo: i).get();
      String id = snapshot.docs[0].id;
      ids.add(id);
    }

    List<Feed> myFeeds = [];
    for(var id in ids){
      var docData = await db.collection('user_data').doc(id).get();
      String connectionName = docData.data()['name'];
      print(connectionName);
      await db.collection('user_data').doc(id).collection('history').get().then((value) => {
        value.docs.forEach((element) {
          myFeeds.add(Feed(connectionName,element.data()['stocks_name'],element.data()['timestamp']));
        })
      });
    }

    setState(() {
      feeds = myFeeds;
    });
  }
  
  
  @override
  void initState() {
    super.initState();
    _fetchFeed();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: feeds.length,
      itemBuilder: (context,index){
        if(Timestamp.now().millisecondsSinceEpoch -int.parse(feeds[index].timestamp)<=10){
          Notifications().generate('Look Out!', '${feeds[index].name} just made an investment in ${feeds[index].stock}');
        }
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: 100,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                border: Border.all(color: kBrightBlue,width: 4)
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text('${feeds[index].name} has invested 10 shares in ${feeds[index].stock}',
                    style: TextStyle(color: Colors.white,fontSize: 18),),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
