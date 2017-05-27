document.addEventListener("turbolinks:load", function() {
  var gif_icon = document.getElementById('gif_icon');
  var gif_render = document.getElementById('gif_render');
  var youtube_icon = document.getElementById('youtube_icon');
  var youtube_render = document.getElementById('youtube_render');
  gif_icon.addEventListener('click', function() {
    gif_render.innerHTML = '<%= render "gif", :pictures =>@link %>';
  });
  youtube_icon.addEventListener('click', function() {
    youtube_render.innerHTML = '<%= render "youtube", :pictures =>@link %>';
  });
});
