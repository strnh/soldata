$(function() {
  $( "#datepicker" ).datepicker({
    dateFormat: "yy/mm/dd",
    dayNamesShort:   [ "日", "月", "火", "水", "木", "金", "土" ],
    dayNamesMin: [ "日", "月", "火", "水", "木", "金", "土" ],
    monthNames: [ "1月", "2月", "3月", "4月", "5月", "6月", "7月", "8月", "9月", "10月", "11月", "12月" ],
    monthNamesShort: [ "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12" ],
    yearRange: "2005:2025",
    onSelect: function (dateText,inst) {
      $.get('/entry/checkdate', { date: dateText },
      function (data){
//        alert(data);
      if (data>0) {
        var d = $("#datepicker").datepicker("getDate");
        var dd = $.datepicker.formatDate("yy/mm/dd",d);
//        console.log(dd);


        window.location.href = '/entry?date='+dd+'&dp=1';

      } else {
        $("#datedialognothing").dialog('open');
      }

      });
    }
  });

 $( "#datepicker").change(function(event){

   var d = $("#datepicker").datepicker("getDate");
   var dd = $.datepicker.formatDate("yy/mm/dd",d);
   console.log("datapicker chenge :"+dd);


   window.location.href = '/entry?date='+dd+'&dp=1';

 });

});
$(function() {
　
  $("#newentry").on("click", function(event){
    console.log("new entry date clicked.");
    $("#mode").val("insert");
    var d = $("#newentrydate").attr("value");
    $("#datepicker").datepicker("setDate",d);

    var sel = $("#clearentry").dialog('open');
      return false;

    //window.location.href = '/entry?date='+d+'&nofetch=1' ;
 //  console.log($("#datepicker").attr("value"));

  });
　
  $("#lastentry").on("click", function(event){
    console.log("clicked.");
    var d = $("#lastentrydate").attr("value");
    $( "#datepicker").datepicker("setDate",d);
    window.location.href = '/entry?date='+d;
 //  console.log($("#datepicker").attr("value"));

  });

  $("#delentry").on("click",function (e) {
    console.log('delete clicked.');
    $("#deletedialog").dialog('open');
    return false;
  });
});
