$(function() {
  $("#deletedialog").dialog({
    autoOpen: false,
    title: 'データ削除',
    closeOnEscape: false,
    modal: true,
    buttons: {
      "キャンセル": function(){
        $(this).dialog('close');
    },
      "削除": function(){
        $(this).dialog('close');
        var d = $("#datepicker").val();
        window.location.href = '/entry/delete?date='+d ;
      }
    }
  });

$("#datedialognothing").dialog({
  autoOpen: false,
  title: '測定記録なし',
  closeOnEscape: false,
  modal: true,
  buttons: {
    "別の日付にする": function(){
      $(this).dialog('close');
      $("#datepicker").focus();

      $("#mode").val("update");

    },
    "新規入力する": function(){
      var d = $("#datepicker").val();
      $("#newentrydate").val(d);
      $("#newentry").val(d);
      $(this).dialog('close');

      window.location.href = '/entry?date='+d+'&nofetch=1&dialog=1' ;

    }
  }
});

$("#clearentry").dialog({
  autoOpen: false,
  title: '新規入力',
  closeOnEscape: false,
  modal: true,
  buttons: {
    "今見えてるデータをクリアして入力": function(){
      var d = $("#datepicker").val();
      $("#newentrydate").val(d);
      $("#newentry").val(d);
      $(this).dialog('close');

      window.location.href = '/entry?date='+d+'&nofetch=1&noclear=1' ;

    },
    "今見えているデータを残す": function(){
      var d = $("#datepicker").val();
      $("#newentrydate").val(d);
      $("#newentry").val(d);
      $(this).dialog('close');

      window.location.href = '/entry?date='+d+'&nofetch=1' ;

    }
  }
});
});
