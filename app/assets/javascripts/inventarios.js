$(document).ready(function(){
   $("#search-product" ).keyup(function() {
   	  var criteria = $("#search-product").val();
   	  if(criteria == ""){
         $("#table_inv tbody tr").remove();
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
	           	  $("#table_inv tbody tr").remove();
	              var resLength = res.length;
	              for (i = 0; i < resLength; i++) {
	                 var element = res[i];
	                 $("#table_inv tbody").append("<tr class='row-inv even pointer'><td id='td_clave' class='td-inv'>"+element.clave+"</td>" +
	                 	"<td id='td_nombre' class='td-inv'>"+element.nombre+"</td><td id='td_precioCompra' class='td-inv'>"+element.precioCompra+"</td><td id='td_precioVenta' class='td-inv'>"+element.precioVenta+"</td>" +
	                 	"<td id='td_existencia' class='td-inv'>"+element.existencia+"</td><td id='td_fecha_actualizacion' class='td-inv'>"+element.updated_at+"</td></tr>");
	              }
	              
	           }else{
	           	  $("#list-search-products").empty();
	              //alert("fallo success")
	           }
	        }
	     })
   	  }
   });	

    $('#table_inv tbody').on( 'click', 'tr', function () {
	    $(this).find("td").each(function(){
		    if ( $(this).is("#td_clave") ) {
		    	var criteria = $(this).text();
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
			              var resLength = res.length;
			              for (i = 0; i < resLength; i++) {
			                 var element = res[i];
			                 $("#clave").val(element.clave);
			                 $("#descripcion").val(element.descripcion);
			                 $("#nombre").val(element.nombre);
			                 $("#precioCompra").val(element.precioCompra);
			                 $("#precioVenta").val(element.precioVenta);
			                 $("#existencia").val(element.existencia);
			                 $("#stock").val(element.stock);
			              }
			              
			           }else{

			           }
			        }
			    })
		    }
	    });
	} );
});
