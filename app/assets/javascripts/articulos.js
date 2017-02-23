$(document).ready(function(){

  $("#articulo_clave").keyup(function(event) {
    alert("hello");
  	code = event.keyCode;
  	if (code==13)
    {
    	alert("hello");
      event.preventDefault();
    }
  });
});