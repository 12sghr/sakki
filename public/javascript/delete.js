$(function() {
  var $delBtn = $("#del");
  var $yesBtn = $("#yes");
  var $delForm = $("#delForm");

  $delBtn.click(function() {
    $('.small.modal')
    .modal('show');
  });

  $yesBtn.click(function() {
    $delForm.submit();
  });
});
