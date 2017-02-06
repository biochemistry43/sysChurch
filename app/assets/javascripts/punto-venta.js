var numTarjetaCredito;
var numTarjetaDebito;
var plazoCredito;
var referenciaOxxo;
var referenciaPaypal;

$(document).ready(function(){
   
   $("#search-product" ).val("");
   $("#formasPago").val("Efectivo");

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

  
  //Codigo para cambiar cantidad de producto vendido.
  $(document).delegate("tr", "dblclick", function(e) {
    cantidad = $(this).find("#cantidadProducto").html();
    abrirModal($(this).index(), cantidad);

  });


  function abrirModal(indice, valor){
    $('#modal-body').html('<div class="form-inline">'+
        '<div class="form-group">'+
          '<label for="cantidad">Nueva Cantidad:</label>'+
          '<input type="text" class="form-control" id="nuevaCantidad'+indice+'" value="'+valor+'" onkeyup="enterActualizar(event, '+indice+')">'+
        '</div>'+
      '</div>');
      $('#modal-footer').html('<button type="button" class="btn btn-primary" data-dismiss="modal" onclick="actualizarCantidad('+indice+')">Aceptar</button>')
      
      $('#actualizarCantidad').modal('show');
      $('#nuevaCantidad'+indice).select();
      
  }

  //codigo para actualizar la etiqueta de sumatoria total. El código se va a ejecutar
  //cada que vez que haya un cambio en los valores de la tabla (lo cual sólo ocurre cuando se
  //agrega un producto o se cambia una cantidad de venta de producto).
  $("#table_sales").bind("DOMSubtreeModified", function() {

    var sumatoria = 0;
    $('#table_sales tr').each(function (i, el) {
      //Se discrimina la primer fila (que corresponde al encabezado)
      if(i!=0){
        var val = $(this).find("td").eq(4).html();
        var importe = parseFloat(val);
        sumatoria += importe;
      }
    });
    sumatoria.toFixed(2);

    $("#importe").text(sumatoria);
  });

  //este arreglo json guardará todos los datos correspondientes a la venta
  var datosVenta = [];

  var datosFormaPago = [];

  //Este arreglo json guardará código y cantidad de cada item de venta.
  var itemsVenta = [];
  var pago = "efectivo";
  
  $("#formasPago").on("change", function(){
    if($(this).val() == "Tarjeta de Crédito"){
      pago = "credito";
      $('#pagoTC').modal('show');
      $('#numTarjetaCredito').select();
    }
    if($(this).val() == "Tarjeta de débito"){
      pago = "debito";
      $('#pagoTD').modal('show');
      $('#numTarjetaDebito').select();
    }
    if($(this).val() == "Oxxo"){
      pago = "oxxo";
      $('#pagoOxxo').modal('show');
      $('#referenciaOxxo').select();
    }
    if($(this).val() == "Paypal"){
      pago = "paypal";
      $('#pagoPaypal').modal('show');
      $('#referenciaPaypal').select();
    }
  });


  //Acción para guardar la venta en un objeto JSON.
  $("#cobrarVenta").on("click", function() {
    
    caja = {};
    caja["caja"] = $("#Caja").val();
    datosVenta.push(caja);
    formaPago = {};
    if(pago == "efectivo"){
      formaPago["formaPago"]="efectivo";
    }
    if(pago == "credito"){
      formaPago["formaPago"]="credito";
      formaPago["ntCredito"] = numTarjetaCredito;
      formaPago["plazoTCredito"] = plazoCredito;

    }
    if(pago == "debito"){
      formaPago["formaPago"]="debito";
      formaPago["ntDebito"] = numTarjetaDebito;
    }
    if(pago == "oxxo"){
      formaPago["formaPago"]="oxxo";
      formaPago["refOxxo"] = referenciaOxxo;
    }
    if(pago == "paypal"){
      formaPago["formaPago"]="paypal";
      formaPago["refPaypal"] = referenciaPaypal;
    }

    datosFormaPago.push(formaPago);
    datosVenta.push(datosFormaPago);
    
    $('#table_sales tr').each(function (i, el) {
      //Se discrimina la primer fila (que corresponde al encabezado)
      if(i!=0){
        var codigoProd = $(this).find("td").eq(0).text();
        var cantidadProd = $(this).find("td").eq(3).text();
        var importeProd = $(this).find("td").eq(4).text();
        itemVenta = {};
        itemVenta["codigo"]=codigoProd;
        itemVenta["cantidad"]=cantidadProd;
        itemVenta["importe"]=importeProd;
        itemsVenta.push(itemVenta);
        
      }
    });
    datosVenta.push(itemsVenta);
    /*$.post("/punto_venta/realizarVenta", {data: datosVenta})
       .done(function(data){
          alert(data);
       })
       .fail(function() {
          alert( "error" );
       })
       .always(function() {
          
       });*/
       $("#dataVenta").val(JSON.stringify(datosVenta));
       var form = $("#ventaForm");
       form.submit();
       itemsVenta = [];
       datosVenta = [];
       datosFormaPago = [];
   });
  

});

function pagoTC(){
  numTarjetaCredito = document.getElementById("numTarjetaCredito").value;
  plazoCredito = document.getElementById("plazoCredito").value;
}

function pagoTD(){
  numTarjetaDebito = document.getElementById("numTarjetaDebito").value;
}

function pagoOxxo(){
  referenciaOxxo = document.getElementById("referenciaOxxo").value;
}

function pagoPaypal(){
  referenciaPaypal = document.getElementById("referenciaPaypal").value;
}

function enterActualizar(event, indice){
  if (event.keyCode == 13) {
    actualizarCantidad(indice);
    $('#actualizarCantidad').modal('hide');
  }
}

function actualizarCantidad(indice){
  cantidad = $("#nuevaCantidad"+indice).val();
  $($('#table_sales').find('tbody > tr')[indice]).children('td')[3].innerHTML = cantidad;
  precioVenta = $($('#table_sales').find('tbody > tr')[indice]).children('td')[2].innerHTML;
  importe = cantidad * precioVenta;
  $($('#table_sales').find('tbody > tr')[indice]).children('td')[4].innerHTML = importe;
}

function addProductToSale(elem){
  $.ajax({
    url: "/articulos/getById/" + elem.id,
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
/*<tr class="even pointer">
                  <!--<td class="a-center ">
                    <input type="checkbox" class="flat" name="table_records">
                  </td>-->
                   
                  <!--ejemplo de como agregar datos a esta tabla
                  <td class=" ">121000040</td>
                  <td class=" ">May 23, 2014 11:47:56 PM </td>
                  <td class=" ">121000210 <i class="success fa fa-long-arrow-up"></i></td>
                  <td class=" ">John Blank L</td>
                  <td class="a-right a-right ">$7.45</td>-->


                  <!--<td class=" last"><a href="#">View</a>
                  </td>-->
                </tr>*/
      if(res){
        var resLength = res.length;
        for(i=0; i < resLength; i++){
           var element = res[i];
           $("#table_sales").append("<tr class='even pointer'><td>"+element.clave+"</td>"+
                                    "<td>"+element.nombre+"</td>"+
                                    "<td>"+element.precioVenta+"</td><td id='cantidadProducto'>1</td>"+
                                    "<td>"+element.precioVenta+"</td></tr>");
        }

        
          /*var resLength = res.length;
          for (i = 0; i < resLength; i++) {*/
           //text += "<li>" + fruits[i] + "</li>";*/
           /* var element = res[i];
              $("#list-search-products").append("<li id='found-product' class='list-group-item list-group-item-success'>"+element.clave+"&nbsp &nbsp &nbsp"+element.nombre+"<button id='"+element.clave+"' onclick='addProductToSale(this)'>agregar</button></li>");
            }*/
              
      }else{
        //$("#list-search-products").empty();
      }
    }
  })
}




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

