$(document).ready(function(){
   $("#search-product" ).keyup(function() {
   	  var criteria = $("#search-product").val();
   	  if(criteria == ""){
         $("#table-inv tbody tr").remove();
   	  }
   	  else{
   	  	 $.ajax({
	        url: "/inventarios/showByCriteria/" + criteria,
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
	                 $("#list-search-products").append("<li id='found-product' class='list-group-item list-group-item-success'>"+element.clave+"&nbsp &nbsp &nbsp"+element.nombre+"<button id='"+element.clave+"' onclick='addProductToSale(this)'>agregar</button></li>");
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
