var express = require('express');
var router = express.Router();
var url = require('url');
var http = require('http');
require('date-utils');
const db = require('../controller/readdb');
const fs = require('fs');


/* GET home page. */
router.get('/', function(req, res, next) {
  res.render('index', { title: 'Express' });
});

/* GET monthly list view */
router.get('/list', async function(req, res, next) {
  try {
    const now = new Date();
    const qyear = req.query.year ? parseInt(req.query.year,10) : now.getFullYear();
    const qmonth = req.query.month ? parseInt(req.query.month,10) : (now.getMonth()+1);

    const rows = await db.listByMonth(qyear, qmonth);

    // compute prev/next month
    let prevYear = qyear, prevMonth = qmonth - 1;
    if (prevMonth < 1) { prevMonth = 12; prevYear -= 1; }
    let nextYear = qyear, nextMonth = qmonth + 1;
    if (nextMonth > 12) { nextMonth = 1; nextYear += 1; }

    res.render('listview', {
      title: `一覧: ${qyear}/${String(qmonth).padStart(2,'0')}`,
      rows: rows,
      year: qyear,
      month: qmonth,
      prev: { year: prevYear, month: prevMonth },
      next: { year: nextYear, month: nextMonth }
    });
  } catch (err) {
    next(err);
  }
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
