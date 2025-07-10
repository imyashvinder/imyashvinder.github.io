// Basic JavaScript for the blog
$(document).ready(function() {
  // Add smooth scrolling to all links
  $("a").on('click', function(event) {
    if (this.hash !== "") {
      event.preventDefault();
      var hash = this.hash;
      $('html, body').animate({
        scrollTop: $(hash).offset().top
      }, 800);
    }
  });

  // Add active class to current nav item
  $('.navbar-nav a').each(function() {
    if (this.href === window.location.href) {
      $(this).addClass('active');
    }
  });
}); 