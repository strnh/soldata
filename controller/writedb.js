const pgpLib = require('pg-promise');
const conf = require('config');
const JSON = require('JSON');
const fs = require('fs');

const connectionString = conf.postgres.cs;
const cn = conf.postgres.cn;
const cn_common = conf.postgres.cn_common;

const tpl = () => {
  const es = JSON.parse(fs.readFileSync('config/es.json', 'utf8'));
  const esl = es.es.length;
  const fal = es.factor.length;

  const arr = [];
  for (let i = 0; i < fal; i++) {
    const name = es.factor[i];
    arr.push(name);
  }
  for (let i = 0; i < esl - 1; i++) {
    const name = es.es[i].contents[2];
    const name2 = es.es[i].contents[3];
    arr.push(name, name2);
  }
  return arr;
};

const csv2db = async (tablename, blob) => {
  const pgp = pgpLib();
  const db = pgp(cn);
  // Implement CSV bulk upload logic here
};

const deleterecord = async (ymd) => {
  const pgp = pgpLib();
  const db = pgp(cn);
  try {
    const data = await db.one("SELECT * FROM soldata WHERE date = $1", [ymd]);
    console.log(data);
    await db.none("DELETE FROM soldata WHERE date = $1", [ymd]);
    console.log(`${ymd} deleted.`);
  } catch (reason) {
    console.log(reason);
  } finally {
    pgp.end();
  }
};

const updateoneline = async (ymd, sid, kid, tuple, values) => {
  const pgp = pgpLib();
  const db = pgp(cn);
  let str = "";
  const colnum = tuple.length;
  const sidstr = sid ? `sid = ${sid},` : "";
  const kidstr = kid ? `kid = ${kid},` : "";
  str = sidstr + kidstr;
  for (let i = 0; i < colnum - 1; i++) {
    str += `${tuple[i]} = ${values[i]},`;
  }
  str += `${tuple[colnum - 1]} = ${values[colnum - 1]}`;
  const querystring = `UPDATE soldata SET ${str} WHERE (date = $1)`;
  try {
    const data = await db.query(querystring, [ymd, str]);
    console.log(`update data ${querystring}`);
    return data;
  } catch (reason) {
    console.log(`ERR: ${reason} from update nest -- ${str}`);
  } finally {
    pgp.end();
  }
};

const insertoneline = async (ymd, sid = 0, kid = 0, tuple, values) => {
  const pgp = pgpLib();
  const db = pgp(cn);
  const querystring = `INSERT INTO soldata (date,kid,sid,${tuple.toString()}) values ('${ymd}',${sid},${kid},${values.toString()})`;
  console.log(`insert: ${querystring}`);
  try {
    const data = await db.query(querystring);
    return data;
  } catch (reason) {
    console.log(`ERR: ${reason} from insert into`);
  } finally {
    pgp.end();
  }
};

const writedb = async (ymd, key, value) => {
  const pgp = pgpLib();
  const db = pgp(cn);
  try {
    const data = await db.one("SELECT * FROM soldata WHERE (date = $1)", [ymd]);
    console.log(`check datetime... : id = ${data.id}`);
    await db.none('UPDATE soldata SET ' + key + ' = $2 WHERE (date = $1)', [ymd, value]);
    console.log("update data");
    return data;
  } catch (reason) {
    try {
      await db.none('INSERT INTO soldata (date,' + key + ') values($1,$2)', [ymd, value]);
      console.log("insert data");
    } catch (reason) {
      console.log(`${reason}: from insert nest -- ${key},${value}`);
    }
  } finally {
    pgp.end();
  }
};

module.exports = {
  writedb,
  insertoneline,
  updateoneline,
  tpl,
  deleterecord
};
