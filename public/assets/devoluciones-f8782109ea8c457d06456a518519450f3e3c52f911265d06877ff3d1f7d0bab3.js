$(document).ready(function(){

   $("#cantidad_devuelta").keyup(function(event) {
   	  cd = $("#cantidad_devuelta").val();
   	  cantidad = Number(cd);
	  if(typeof cantidad == "number"){
	  	precio_venta = Number($("#precio_venta").val());
        importe = cantidad * precio_venta;
        $("#importe_devolucion").val(importe);
	  }
	  else{
         alert("La cantidad debe ser un valor numérico");
         $("#cantidad_devuelta").val("");
	  }

	});

});
