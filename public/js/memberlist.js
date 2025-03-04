$(function () {
  $("#memberlist").ready(function(){
    $.getJSON("/entry/memberlist",function(data) {
      var $select = $('.member');
      $select.empty();
      var $option,options,isSelected;
      var options = $.map(data,function (id,name){
        console.log("id == "+id["bid"]);
        if (id["bid"] === 10002 ) {
          isSelected = true;
        } else {
            isSelected = false;
        }
        $option=$('<option>', { value: id["bid"], text: id["name"], selected: isSelected});
        return $option;
      });
      $select.append(options);
//         console.log(data[0]["name"]);
    });
  });
});
