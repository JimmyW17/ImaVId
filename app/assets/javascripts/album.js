// window.onload = function() {
//   var elem = document.querySelector('.grid');
//   var gridsizer = document.querySelector('.grid-sizer');
//   var msnry = new Masonry( '.grid', {
//     // options
//     itemSelector: '.grid-item',
//     columnWidth: gridsizer,
//     percentPosition: true
//   });
//
//   // element argument can be a selector string
//   //   for an individual element
//
// };

$(document).ready(function() {
  var $grid = $('.grid').masonry({
    // set itemSelector so .grid-sizer is not used in layout
    itemSelector: '.grid-item',
    // use element for option
    columnWidth: '.grid-sizer',
    percentPosition: true
  });
  // layout Masonry after each image loads
  $grid.imagesLoaded().progress(function() {
    $grid.masonry('layout');
  });
});
