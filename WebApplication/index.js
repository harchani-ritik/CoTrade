const express = require('express');
const bodyParser = require("body-parser");
const firebase = require('firebase');
const session = require('express-session');

var config = {
    apiKey: 'AIzaSyBTpx4BLliy_1hjM7uTzc8tPDhXLnwAnCw',
    authDomain: 'ecelivesmatter.firebaseapp.com',
    databaseURL: 'https://ecelivesmatter.firebaseio.com',
    projectId: 'ecelivesmatter',
    storageBucket: 'ecelivesmatter.appspot.com',
    messagingSenderId: '312643276277'
};
firebase.initializeApp(config);



const app = express();

app.set('view engine', 'ejs');
app.use(bodyParser.urlencoded({extended: true}));
app.use(session({secret: 'ssshhhhh',saveUninitialized: false,resave: false}));

console.log("Server running");



var loged = null;
var loged_id = null;

//landing page
app.get('/', (req, res) =>{
	res.render('landing');
})


//signup get and post
app.get('/signup', (req, res) =>{
	res.render('signup')
})

app.post('/submit_signup', async (req, res) =>{
	const database = firebase.firestore();
	const usersCollection = database.collection('user_data');

	const ID= usersCollection.doc();
	// console.log(ID);
	ID.set({
		coins:100000,
		name: req.body.firstName,
		username: req.body.userId,
		password: req.body.password,
		email: req.body.email,
		phoneNo: req.body.phoneno
	}).then( ()=>{
	    console.log('Data has been saved successfully !')
	}).catch(error => {
	    console.error(error)
	});
	const newCollection = await ID.collection('Requests').doc();
	// console.log(newCollection);
	await newCollection.set({
	  name: "",
	  username: ''
	});



	const newCollection1 = await ID.collection('connections').doc();
	// console.log(newCollection);
	await newCollection1.set({
	  name: "",
	  username: ''
	});
	const newCollection2 = await ID.collection('history').doc();
	// console.log(newCollection);
	await newCollection2.set({
	  bought: "",
	  price: '',
	  stocks_name: "",
	  timestamp: ""
	});
	const newCollection3 = await ID.collection('stock').doc();
	// console.log(newCollection);
	await newCollection3.set({
	  count: 0,
	  public: '',
	  purchase_price: "",
	  stock_name: "",
	  timestamp: ""
	});

	res.redirect('login');
})


//login get and post
app.get('/login', (req, res) =>{
	res.render('login')
})
app.post('/submit_login', async (req, res) =>{
	const database = firebase.firestore();
	const usersCollection = database.collection('user_data');
	const snapshot = await usersCollection.where('email', '==', req.body.username).get();
	var msg;

	if (snapshot.empty) {
  		console.log('No matching documents.');
  		res.redirect('login');
	}
	snapshot.forEach(async doc => {
		loged = doc.data();
		loged_id = doc.id;
		var stock_list = [];
		const snapshot1 = await usersCollection.doc(doc.id).collection("stock").get()
		.then(querysnapshot => {
			querysnapshot.forEach(doc => {
        		// console.log(doc.id, " => ", doc.data());
        		stock_list.push(doc.data());
        		console.log(stock_list[0]);
    		});
		})


		console.log(doc.data());
	  	// console.log(doc.id, '=>', doc.data());
	  	if(req.body.password == doc.data().password){
	  		console.log("successfully logged in")
	  		res.render('profile', {user: loged, stock: stock_list});
	  	}
	  	else{
	  		console.log('Wrong Password.');
	  		res.redirect('login');
	  	}
	});
})


app.get('/connection', async (req, res) =>{
	var connections = [];
	var requests = [];
	var suggested = [];
	var suggested1 = [];
	const database = firebase.firestore();
	const usersCollection = database.collection('user_data');
	console.log(loged_id);
	const snapshot1 = await usersCollection.doc(loged_id).collection("Requests").get()
	.then(querysnapshot => {
		querysnapshot.forEach(doc => {
    		// console.log(doc.id, " => ", doc.data());
    		requests.push(doc.data());
    		console.log(requests);
		});
	})
	const snapshot2 = await usersCollection.doc(loged_id).collection("connections").get()
	.then(async querysnapshot => {
		querysnapshot.forEach( async doc => {
    		// console.log(doc.id, " => ", doc.data());
    		const snapshot3 = await usersCollection.where('username', '==', doc.data().username).collection("connections").get()
    		.then(querysnapshot => {
				querysnapshot.forEach(doc => {
		    		// console.log(doc.id, " => ", doc.data());
		    		suggested1.push(doc.data());
		    		// console.log(requests);
				});
			})
    		// console.log(requests);
		});
	})

	res.render('connection', {req: requests, suggested: suggested1});
})

app.post('/respond', async (req, res) => {
	const database = firebase.firestore();
	const usersCollection = database.collection('user_data');
	const to_user = await usersCollection.doc(loged_id).collection("connections")
	// console.log(to_user)
	const from_user1 = await usersCollection.where('username', '==', req.body.from).get();

	var response = req.body.respond
	if(response == 1){
		const ID= to_user.doc();
		ID.set({
			username: req.body.from,
			name: req.body.from_name
		}).then( ()=>{
		    console.log('Accepted !')
		}).catch(error => {
		    console.error(error)
		});
		console.log(loged.username)
		from_user1.forEach(async doc => {
			console.log(doc.id);
			const from_user = await usersCollection.doc(doc.id).collection("connections")
			// console.log(from_user);
			const ID1= from_user.doc();
			ID1.set({
				username: loged.username,
				name: loged.name
			}).then( async ()=>{
			    console.log('added to both !');
			    const request = await usersCollection.doc(loged_id).collection('Requests').where("username", '==', req.body.from).get()
			    .then(querySnapshot => {
			      	querySnapshot.forEach(doc  => {
			      		console.log(doc.id);
			      		var result = usersCollection.doc(loged_id).collection('Requests').doc(doc.id).delete();
			      	});
			    }).catch(error => {
				    console.error(error)
				});
			}).catch(error => {
			    console.error(error)
			});
		})
		
	}
	else{
		const request = await usersCollection.doc(loged_id).collection('Requests').where("username", '==', "").get()
	    .then(querySnapshot => {
	      	querySnapshot.forEach(doc  => {
	      		console.log(doc.id);
	      		var result = usersCollection.doc(loged_id).collection('Requests').doc(doc.id).delete();
	      	});
      	}).catch(error => {
			    console.error(error)
			});
	}
	// console.log(from + " " + response);
	res.redirect('home');
})

app.get('/Home', async (req, res) =>{
	var stocks_name = [];
	var stock_detail = []
	var stocks_map = new Map()
	const database = firebase.firestore();
	const usersCollection = await database.collection('stock_data').get()
	.then(querySnapshot => {
      	querySnapshot.forEach(doc  => {
        	// console.log(doc.data());
        	stocks_name.push(doc.id);
        	stock_detail.push(doc.data());
        	// console.log(stocks_name);
      	});
    });
    for(var i=0; i<stocks_name.length; i++)
    	stocks_map.set(stocks_name[i], stock_detail[i]);
	console.log(stocks_name.length);
	res.render('home', {maping: stocks_map});
})


app.post('/stock_card', async (req, res) =>{
	const database = firebase.firestore();
	const usersCollection = await database.collection('stock_data').get()
	.then(querySnapshot => {
      	querySnapshot.forEach(doc  => {
      		if(doc.id == req.body.key)
    		res.render('stock_card', {name: doc.id, data: doc.data()});
      	});
    }).catch(error => {
	    console.error(error)
	});;
})


app.post('/buy', async (req, res) => {
	const database = firebase.firestore();
	console.log(loged_id)
	const usersCollection = await database.collection('user_data').doc(loged_id).collection("stock");

	const snapshot = await usersCollection.where('stock_name', '==', req.body.buy).get();

	const ID= usersCollection.doc();
	ID.set({
		count: 10,
		purchase_price: req.body.price,
		stock_name: req.body.buy,
		timestamp: String(Date.now()),
		public: req.body.public
	}).then( ()=>{
	    console.log('Data has been saved successfully !')
	}).catch(error => {
	    console.error(error)
	});
	res.redirect('home');
})


app.post('/sell', async (req, res) => {
	const database = firebase.firestore();
	console.log(loged_id)
	const usersCollection = await database.collection('user_data').doc(loged_id).collection("stock");
	const snapshot = await usersCollection.where('stock_name', '==', req.body.sell).where('purchase_price', '==', req.body.price).get()
	.then(querySnapshot => {
      	querySnapshot.forEach(doc  => {
      		console.log(doc.id);
      		var result = usersCollection.doc(doc.id).delete();
      	});
    }).catch(error => {
	    console.error(error)
	});;
    res.redirect('profile');
})

app.use( express.static( "views" ));

app.listen(8000);