$(document).ready(function(){
   $("#search-product" ).keyup(function() {
   	  var criteria = $("#search-product").val();
   	  if(criteria == ""){
         $("#list-search-products").empty();
   	  }
   	  else{
   	  	 $.ajax({
	        url: "/articulos/showByCriteria/" + criteria,
	        dataType: "JSON",
	        timeout: 10000,
	        beforeSend: function(){
	           //$("#respuesta").html("Cargando...");
	        },
	        error: function(){
	        	//alert("error");
	           //$("#respuesta").html("Error al intentar buscar el empleado. Por favor intente más tarde.");
	           
	        },
	        success: function(res){
	           if(res){
	           	  $("#list-search-products").empty();
	              var resLength = res.length;
	              for (i = 0; i < resLength; i++) {
	              //text += "<li>" + fruits[i] + "</li>";
	                 var element = res[i];
	                 $("#list-search-products").append("<li class='list-group-item list-group-item-success'>"+element.nombre+"</li>");
	              }
	              
	           }else{
	           	  $("#list-search-products").empty();
	              //alert("fallo success")
	           }
	        }
	     })
   	  }
   });	
});


/*function buscarPorLegajo(){
   $("#boton_buscar").click(function(){
     var legajo = $("#legajo").val();
     $.ajax({
        url: "/empleados/buscar_por_legajo/" + legajo,
        dataType: "JSON",
        timeout: 10000,
        beforeSend: function(){
           $("#respuesta").html("Cargando...");
        },
        error: function(){
           $("#respuesta").html("Error al intentar buscar el empleado. Por favor intente más tarde.");
        },
        success: function(res){
           if(res){
              $("#respuesta").html('<a href="/empleados/'+res.id+'"> '+res.nombre+' ' + res.apellido + ' </a>');
           }else{
              $("#respuesta").html("El legajo no le pertenece a ningún empleado.");
           }
        }
     })
  });
};
$(document).ready(function(){
   buscarPorLegajo();
});*/

