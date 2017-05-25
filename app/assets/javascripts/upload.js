window.onload = function() {
  var closeButton = document.getElementById('closeIcon');
  var imageDiv = document.getElementById('showImage');
  closeButton.addEventListener('click', function() {
    imageDiv.style.display = 'none';
    // alert('aaa');
  });
};
