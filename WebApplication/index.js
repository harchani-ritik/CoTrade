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



var loged;

//signup get and post
app.get('/signup', (req, res) =>{
	res.render('signup')
})

app.post('/submit_signup', (req, res) =>{
	const database = firebase.firestore();
	const usersCollection = database.collection('user_data');

	const ID= usersCollection.doc();
	ID.set({
		coins:1000,
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
	res.redirect('login');
})


//login get and post
app.get('/login', (req, res) =>{
	loged = req.session;
	res.render('login')
})
app.post('/submit_login', async (req, res) =>{
	loged = req.session;
	const database = firebase.firestore();
	const usersCollection = database.collection('user_data');
	const snapshot = await usersCollection.where('email', '==', req.body.username).get();
	var msg;
	if (snapshot.empty) {
  		console.log('No matching documents.');
  		res.redirect('login');
	}  
	snapshot.forEach(doc => {
		loged = doc.data();
		console.log(loged);
	  	// console.log(doc.id, '=>', doc.data());
	  	if(req.body.password == doc.data().password){
	  		console.log("successfully logged in")
	  		res.render('profile', {user: loged});
	  	}
	  	else{
	  		console.log('Wrong Password.');
	  		res.redirect('login');
	  	}
	});
})



app.use( express.static( "views" ));

app.listen(8000);