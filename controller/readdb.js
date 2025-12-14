const pgpLib = require('pg-promise');
const conf = require('config');
const connectionString = conf.postgres.cs;
var cn = conf.postgres.cn;
var cn_common = conf.postgres.cn_common;

async function readdb(ymd) {
  var pgp = pgpLib();
  var db = pgp(cn);
  try {
    let data = await db.query("SELECT * FROM soldata where date = $1", [ymd]);
    return data;
  } catch (reason) {
    console.log(reason);
    throw reason;
  } finally {
    pgp.end();
  }
}

async function uid2name(id) {
  var pgp = pgpLib();
  var db = pgp(cn_common);
  try {
    let data = await db.query("SELECT name FROM employee where ( uid = $1) ", [id]);
    return data;
  } catch (reason) {
    console.log(reason);
    throw reason;
  } finally {
    pgp.end();
  }
}

async function readrefrangetbl() {
  var pgp = pgpLib();
  var db = pgp(cn);
  try {
    let data = await db.query("SELECT * FROM soldatarefrange;");
    return data;
  } catch (reason) {
    console.log(reason);
    throw reason;
  } finally {
    pgp.end();
  }
}

async function getlastetrydate() {
  var pgp = pgpLib();
  var db = pgp(cn);
  try {
    let data = await db.query("SELECT MAX(date) as lastentrydate From soldata where sid >0 ;");
    return data[0].lastentrydate;
  } catch (reason) {
    console.log(reason);
    throw reason;
  } finally {
    pgp.end();
  }
}

async function isexist(ymd) {
  var pgp = pgpLib();
  var db = pgp(cn);
  try {
    let data = await db.query("select count(*) from soldata where date = $1", [ymd]);
    return data[0].count;
  } catch (reason) {
    console.log(reason);
    throw reason;
  } finally {
    pgp.end();
  }
}

async function memberlist() {
  var pgp = pgpLib();
  var db = pgp(cn_common);
  console.log("call memberlist");
  try {
    let data = await db.query('select bid,name from employee where bid >0;');
    return data;
  } catch (reason) {
    console.log(reason);
    throw reason;
  } finally {
    pgp.end();
  }
}

async function listByMonth(year, month) {
  var pgp = pgpLib();
  var db = pgp(cn);
  try {
    // Construct first day and first day of next month
    const start = `${year}-${String(month).padStart(2,'0')}-01`;
    const qry = `SELECT * FROM soldata WHERE date >= $1::date AND date < ($1::date + interval '1 month') ORDER BY date DESC`;
    let data = await db.query(qry, [start]);
    return data;
  } catch (reason) {
    console.log(reason);
    throw reason;
  } finally {
    pgp.end();
  }
}

module.exports.listByMonth = listByMonth;

module.exports.readdb = readdb;
module.exports.uid2name = uid2name;
module.exports.readrefrangetbl = readrefrangetbl;
module.exports.getlastetrydate = getlastetrydate;
module.exports.isexist = isexist;
module.exports.memberlist = memberlist;

