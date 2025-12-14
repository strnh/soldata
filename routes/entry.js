const express = require('express');
const router = express.Router();
const fs = require('fs');
const url = require('url');
const db = require('../controller/readdb.js');
const wdb = require ('../controller/writedb.js');

// router ( "/" -> url = http[s*]://hogehoge/router/ )
router.get("/", async (req, res, next) => {
    console.log("start");
    const entrydate = new Date();
    const formatstring = "YYYY/MM/DD HH24:MI:SS+09";
    const jsondate = entrydate.toJSON();
    const { name, password } = req.body || {};
    console.log(`password: ${password}`);
    console.log("db..");
    const es = JSON.parse(fs.readFileSync('./config/es.json', 'utf8'));
    console.log(`es: ${es.toString()}`);
    const dbfetchdate = "2012/12/14 00:00:00+09";
    let nf = 0; // 新規入力フラグ
    let dg = 0; // dialog経由のフラグ
    let dp = 0; // datepicker 経由フラグ
    const url_parts = url.parse(req.url, true);
    const { date: checkdate } = url_parts.query;
    let querydatevalid = 0;

    if (checkdate !== undefined) {
        querydatevalid = await db.isexist(checkdate);
        console.log(querydatevalid);
        console.log(url_parts.query.date);
    }

    console.log("getlastentrydate:");
    const lastentrydate = await db.getlastetrydate();
    console.log("db.getlastentrydate()::");
    let dt = new Date(lastentrydate);
    let dts = "", nc = "";
    let fld = dt.toFormat(formatstring);
    nc = typeof req.query.noclear === "undefined" ? 0 : 1;

    if (req.query.date) {
        if (req.query.nofetch == 1) {
            nf = 1;
            if (req.query.dialog == 1) {
                dg = 1;
                const rdate = req.query.date;
                dt = new Date(rdate);
                dts = dt.toFormat(formatstring);
                const dtc = new Date(lastentrydate);
                fld = dtc.toFormat(formatstring);
                console.log("date :specific & new.. ");
            } else {
                dt = new Date(lastentrydate);
                fld = dt.toFormat(formatstring);
                console.log("date : entrydate = now().. ");
            }
        } else {
            if (querydatevalid == 1) {
                console.log("date: data exists. modify mode ");
                dp = req.query.dp;
                const rdate = req.query.date;
                dt = new Date(rdate);
                dts = dt.toFormat(formatstring);
                fld = dt.toFormat(formatstring);
            } else {
                console.log("date: not valid..");
                dt = new Date(lastentrydate);
                fld = dt.toFormat(formatstring);
            }
        }
    } else {
        console.log("date: not specify..");
        dt = new Date(lastentrydate);
        fld = dt.toFormat(formatstring);
    }

    console.log(` -> ${fld}`);
    const eds = new Date(lastentrydate);
    const ed = eds.toFormat(formatstring);
    const ed2s = new Date();
    const ed2 = ed2s.toFormat(formatstring);

    const range = await db.readrefrangetbl();
    const result = await db.readdb(fld);
    const kj = (result && result.length > 0) ? result[0] : {};
    let sname = [];
    let kname = [];
    if (kj && kj.sid) {
        sname = await db.uid2name(kj.sid) || [];
    }
    if (kj && kj.kid) {
        kname = await db.uid2name(kj.kid) || [];
    }

    const sn_name = (sname && sname[0] && sname[0].name) ? sname[0].name : '';
    const kn_name = (kname && kname[0] && kname[0].name) ? kname[0].name : '';

    res.render('entry', {
        title: '鍍金液分析結果',
        message: "データ入力: ",
        ed: ed,
        ed2: ed2,
        kj: kj,
        sn: sn_name,
        kn: kn_name,
        rg: (range && range[0]) ? range[0] : {},
        ld: fld,
        dt: dts,
        nf: nf,
        dp: dp,
        es: es,
        dvalid: querydatevalid,
        dg: dg,
        nc: nc
    });
});

router.get("/submitdata", (req, res, next) => {
    const entrydate = new Date();
    const url_parts = url.parse(req.url, true);
    const jsondate = entrydate.toJSON();
    console.log(url_parts.query);

    res.render('submit', { title: '' });
});

router.post("/submit", async (req, res, next) => {
    const values = [];
    const keys = Object.keys(req.body);
    const { datepicker: entrydate, sid, kid, mode } = req.body;

    const subkeys = keys.filter(k => ![
        "submit", "lastentrydate", "newentrydate",
        "datepicker", "sid", "kid", "nf", "mode"
    ].includes(k));

    for (let i = 0; i < subkeys.length; i++) {
        const s = subkeys[i];
        values[i] = req.body[s] === undefined ? "-1" : req.body[s];
    }

    console.log(mode);

    let querydatevalid;
    switch (mode) {
        case "insert":
            querydatevalid = await wdb.insertoneline(entrydate, sid, kid, subkeys, values);
            break;
        default:
            querydatevalid = await wdb.updateoneline(entrydate, sid, kid, subkeys, values);
    }

    res.render('submit', {
        title: '登録しました。',
        r: querydatevalid.length,
        date: entrydate
    });
});

router.get("/checkdate", async (req, res, next) => {
    const url_parts = url.parse(req.url, true);
    const { date: checkdate } = url_parts.query;
    const formatstring = "YYYY/MM/DD HH24:MI:SS+09";

    const querydatevalid = await db.isexist(checkdate);
    console.log(querydatevalid);

    res.render('checkdate', {
        title: 'checkdate',
        chk: querydatevalid
    });
});

router.get("/memberlist", async (req, res, next) => {
    const url_parts = url.parse(req.url, true);

    const memberlist = await db.memberlist();
    res.render('memberlist', {
        title: 'memberlist',
        memberlist: memberlist
    });
});

/* GET monthly list view (mounted at /entry/list) */
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

router.get("/delete", async (req, res, next) => {
    const url_parts = url.parse(req.url, true);
    const { date: dt } = url_parts.query;

    console.log(`date ${dt}`);
    const result = await wdb.deleterecord(dt);
    console.log(result);

    res.render('delete', {
        title: `削除 :${dt}`,
        dt: dt
    });
});

module.exports = router;
