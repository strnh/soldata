//
// require jquery
//
// function nextcell(current) {
//
//}
function kojiyacalc (x) {
  var p = Number($("#"+x).val());
  var v = 0.0;
  var v2 = 0.0;
  var v3 = 0.0;

  switch (x) {

    case "etcrox" :
      var source = "#"+x;
      var f = Number($("#fna2s2o3").val());
      var v = 0.0;
      v = 16.67*p*f;
      $(source).attr("data-a",v);
//      alert (  $(source).attr("data-a"));
    break;
//
    case "etcr3x":
      var r = Number($("#etcrox").val());
      var f = Number($("#fna2s2o3").val());
      v = 8.67*f*(p-r);
    break;

    case "etso4x":

      var a = Number( $("#etcrox").data("a"));
      if (a===NaN) {
        alert("クロム酸の測定値が入力されていません。");
        break;
      }
      var f = Number($("#fnaoh1").val());
      v = 28.03 * (f * p - 0.01 *a);
    break;
   case "predip1":
     var f = Number($("#fnaoh2").val());
//      v = 8.84*p*f;a
        v = p;
     break;

   case "etparadx":
      v = 100*p;

    break;
//
   case "crpmpdx":
   case "crclpdx":
   case "crpc85x":
      var unit = $("#"+x).attr("data-unit");
      v = p * 50;
      v2 = p * 82.5;
      v3 = p * 9.8;
      $("#crpclpdv").val(v2.toFixed(3));
      $("#crpclpdv").css({"background-color": "#FFFFCC" });
      $("#crpc85v").val(v3.toFixed(3));
      $("#crpc85v").css({"background-color": "#FFFFCC" });

      break;
    case "crphclx":
       var f = $("#fnaoh2").val();
       v = 17.22 * f * p;
      break;

   case "crpsnclx":
       var f = $("#fi").val();
       v = 11.28 * p * f;

      break;

   case "selcux":
       v = p*0.5;
	   $("#selakx").val(v);	
       break;
   case "selakx":
       v = p*150;
       break;
    case "selbx":
       var f = $("#fhcl").val();
       v = 14.7 * f * p;
      break;
    case "cuscusx":
       var f = $("#fedta").val();
       v = 12.5 * f * p;
       break;
    case "cusso4x":
       var f = $("#fnaoh2").val();
       v = 4.9 * f * p;
       break;
    case "cusclox":
       v = 151.2 * p;
       break;
    case "snitotnix": //光沢ニッケル　全ニッケル量
        var f = $("#fedta").val();
        v = 2.985 * f * p;
        $("#"+x).attr("data-c",v);
        break;
    case "sninisox": //光沢ニッケル　硫酸ニッケル
        v = (c - (d * 0.2469) ) *4.48;
      break;

    case "sniniclx":
     // 塩化ニッケル
      var f = $("#fagno3").val();
      v = 2.39*f*p;
    // 硫酸ニッケル
      var c = $("#snitotnix").attr("data-c");
      if (c === undefined) {
        $("#snitotnix").focus();
        break;
      }
      var d = v;
      var vv = (c - v * 0.2469) *4.48;
      var unit = $("#sninisov").attr("data-unit");
      $("#sninisov").val(vv.toFixed(3));
      $("#sninisov").css({"background-color": "#FFFFCC" });

      break;
     case "snibx":
       var f = $("#fnaoh1").val();
       v = 3.092 * f * p;
     break;
    case "crcro3x":
        var f = $("#fna2s2o3").val();
        v = 16.667*f*p;
     break;
     case "crtcx":
        v = p * 6.6;
     break;
     case "crso4x":
        v = p;
     break;
     case "craccr":
         f = $("#fna2s2o3").val();
         v = 1.6667 * f * p;
         break;
     case "cracso":
        v = p;
        break;
    default:
    v = 0.0;
  }

  return(v);

}



$(function (){

  $('.num').on("focus",function(){
    $(this).css({"background-color": "lime"});
    //    console.log($(this).attr('id'));
  });
  $('.num').on("blur",function(e){
    $(this).css({"background-color": "#FFFFFF"});
  });

  $('.fnum').on("focus",function(){
    $(this).css({"background-color": "lime"});
    //    console.log($(this).attr('id'));
  });
  $('.fnum').on("blur",function(e){
    $(this).css({"background-color": "#FFFFFF"});
  });



  $('.num').on("keypress",function(e){
    if (e.which==13) {
      var currentinput = $(this).attr("id");
      var target = "#"+$(this).attr("data-target");
      var next = "#"+$(this).attr("data-vector");
      var unit = $(this).attr("data-unit");
      var v = 0.0;
      v = kojiyacalc(currentinput);
      vstr = v.toFixed(4)
      $(target).val(vstr);
//      $(target+"-bg").text(unit);
      $(target).css({"background-color": "#FFFFCC" });
      $("#"+currentinput).attr('changed',1);
      $(next).focus();
      return false;
    }
  });
  $('.fnum').on("keypress",function(e){
    if (e.which==13) {
      var currentinput = $(this).val();
      var next = "#"+$(this).attr("data-vector");
      var v = 0.0;
      v = Number(currentinput);
        if (v>0) {
          vstr = v.toFixed(4);
//          console.log("val = " + vstr);
          $("#"+currentinput).attr('changed',1);
          $(next).focus();
        }
      return false;
    }
  });
});
