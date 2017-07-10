$(document).ajaxSend(function() {
  $('.loading').css('display','block');
  $('.image_div').html('');
  $('.confidence_div').html('');
}).ajaxComplete(function() {
  $('.loading').css('display','none');
}).ajaxError(function() {
  $('.image_div').css('display', 'none');
})
