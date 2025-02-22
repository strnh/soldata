var express = require('express');
var router = express.Router();
var url = require('url');
var http = require('http');
require('date-utils');


/* GET home page. */
router.get('/', function(req, res, next) {
  res.render('index', { title: 'Express' });
});

/* GET nyanko page. */

router.get('/nyanko',function(req, res,next) {
	res.render('nyanko', { title: 'Nyanko' });

});


/* Get login page. */

//ログインサブミット処理
router.get("/login", function(req, res,next){

    var name = req.body.name;
    var password = req.body.password;

     //user= admin,pass=passwordならOK.
   res.render('login', {
        title: 'login : ',
  			       message: "Enter name  password ."

  		   });
  });


router.post("/login", function(req, res){

    var name = req.body.name;
    var password = req.body.password;
    //user= admin,pass=passwordならOK.
     console.log("test");

      if((name === "admin") && (password === "password")) {
  	res.render('success', {
             title: '糀谷データ入力',
  			     message: 'Login OK:',
  			     name: name,
  			     password: password
  		   });
      } else {
  	res.render('login', {
        title: 'login failure: ',
  			       message: "Error: name or password wrong."
  		   });
      }
});
//

module.exports = router;
