var numTarjetaCredito;
var numTarjetaDebito;
var plazoCredito;
var referenciaOxxo;
var referenciaPaypal;

//este arreglo json guardará todos los datos correspondientes a la venta
var datosVenta = [];

//este arreglo guardará los datos de la forma de pago de esta venta en particular
var datosFormaPago = [];

//Este arreglo json guardará código y cantidad de cada item de venta.
var itemsVenta = [];

//Esta variable cambia dependiendo de la forma de pago elegida por el usuario
var formaPago = "efectivo";

//jquery
$(document).ready(function(){

  /**
   * Aquí se añadirán todas las funcionalidades mediante teclas que el módulo de punto
   * de venta va a tener.
   */
  $('#div_pos').bind('keydown', function(event) {
    

    switch(event.keyCode){

      case 115: //Tecla f4 abre el modal de pago.
       //primero verifica que la tabla de ventas tenga al menos un artículo agregado
        if ($('#table_sales >tbody >tr').length == 0){
          alert ( "No hay productos añadidos a la venta" );
        }
        else{
          $('#modalPago').modal('show');
          $('#campo-paga-con').select();
        }
        event.stopPropagation();
        break;
    }

  });//Terminan los eventos de teclado dentro de el módulo punto de venta.


  /*El método autocomplete, asigna las funcionalidades de autocompletado a todos los campos con la clase
  autocomplete. Ver /assets/javascripts/autocomplete.jquery.js */
  $('.autocomplete').autocomplete();

  //Se aseguro que el campo de búsqueda esté vacío cada vez que se inicia el punto de venta.
  $("#search-product" ).val("");



  /**
   * Esta porción de código identifica si se ha presionado enter en el campo de búsqueda de un
   * producto. Si es así, añade el producto encontrado a la lista de venta actual
   */
  $("#search-product" ).keyup(function(event) {
    //Obtiene el código del evento
    var code=event.keyCode;

      // Si es Enter y el valor no está vacío, añade el producto a la venta.
      if (code==13 && $("#search-product").val()!="")
      {
        //añade el producto a la venta actual.
        addProductToSale($("#search-product").val());
        $("#search-product").val("");
      }
  });

  
  /**
   * Codigo para cambiar cantidad de producto vendido.
   * Al dar doble clic sobre algún producto de la lista de ventas, se abre un modal
   * que permite cambiar la cantidad de producto.
   */
  $(document).delegate("tr", "dblclick", function(e) {

    cantidad = $(this).find("#cantidadProducto").html();
    cambiarCantidadProducto($(this).index(), cantidad);

  });

  //Con esta petición ajax, se llena el modal de clientes.
  $.ajax({
    //Los datos se obtienen en json
    url: "/clientes.json",
    dataType: "JSON",
    timeout: 10000,
    beforeSend: function(){
    
    },
    error: function(){
      alert("Error al cargar la lista de clientes.");
    },
    //Una vez recibida la respuesta del servidor, se construye una tabla con clientes dentro de un modal.
    success: function(res){

      var resLength = res.length;

      for(i=0; i < resLength; i++){
        var element = res[i];

        /* lista_clientes es la tabla que está dentro del modal con la lista de los clientes.
         * por cada cliente que se agrega a la tabla, se añade un botón con el método onclick 
         * para cambiar los datos
         * del cliente dentro de la pantalla de venta**/
        $("#lista_clientes").append(""+

            "<tr class='even pointer'><td>"+element.nombre+"</td>"+
            "<td>"+element.telefono1+"</td>"+
            "<td>"+element.email+"</td>"+
            "<td><button class='btn btn-primary btn-xs' "+
                    "onclick='cambiarCliente(\""+element.id+"\", \""+element.nombre+"\", \""+element.telefono1+"\", \""+element.email+"\")' >"+
                      "<i class='fa fa-folder'></i> Seleccionar </button></td></tr>");

      }

      /* Una vez que se han cargado los datos en la tabla, convertimos nuestra tabla en una tabla DataTable.
       * El plugin Datatable fue instalado mediante la gema 'jquery-datatables-rails'. 
       * Para más información:  https://github.com/rweng/jquery-datatables-rails
       * La funcionalidad de ser responsiva fue añadida a la tabla.
       */
      $('#lista_clientes').DataTable({
        responsive: true
      });
         
    }//Termina success de la petición ajax

  }); //Termina petición ajax de la lista de clientes.

  //Esta acción abre el modal que permite cambiar el cliente de una venta
  $("#cambiarClienteBtn").on("click", function(e){

    $('#modalClientes').modal('show');

  });

    
  /**
   * Esta función cambia la cantidad de un producto que se a agregado previamente a la venta.
   * Cada vez que un producto se agrega a la venta, se agrega con una sola unidad. Mediante esta
   * función, se puede cambiar esa cantidad.7
   * param indice indica la fila de la tabla en donde se están intentando cambiar la cantidad.
   * param valor indica la cantidad actual de producto.
   */
  function cambiarCantidadProducto(indice, valor){
    //Se actualiza el "body" del modal actualizar cantidad
    //Se asignan métodos para actualizar la cantidad dando click en el botón o con la tecla enter
    $('#modal-body-actualizar-cantidad').html('<div class="form-inline">'+
        '<div class="form-group">'+
          '<label for="cantidad">Nueva Cantidad:</label>'+
          '<input type="text" class="form-control" id="nuevaCantidad'+indice+'" value="'+valor+'" onkeyup="enterActualizar(event, '+indice+')">'+
        '</div>'+
      '</div>');
    //Se añade un botón en el footer del modal que permite actualizar la cantidad.
    $('#modal-footer').html('<button type="button" class="btn btn-primary" data-dismiss="modal" onclick="actualizarCantidad('+indice+')">Aceptar</button>')
    
    //Se muestra el modal.  
    $('#actualizarCantidad').modal('show');
    
    //Se selecciona el texto que está en el textfield para facilitar la edición de la cantidad.    
    $('#nuevaCantidad'+indice).select();
      
  }//Termina el método cambiarCantidadProducto

  /* Código para actualizar la etiqueta de sumatoria total. El código se va a ejecutar
   * cada que vez que haya un cambio en los valores de la tabla (lo cual sólo ocurre cuando se
   * agrega un producto o se cambia una cantidad de venta de producto). */
  $("#table_sales").bind("DOMSubtreeModified", function() {

    var sumatoria = 0;

    //recorre cada fila de la tabla de venta actual
    $('#table_sales tr').each(function (i, el) {

      //Se discrimina la primer fila (que corresponde al encabezado)
      if(i!=0){
        //el td 4 equivale al campo con la cantidad.
        var val = $(this).find("td").eq(4).html();
        
        //Convierto el valor del importe en un valor float
        var importe = parseFloat(val);

        //añado el importe a la sumatoria total de la venta
        sumatoria += importe;
      }
    });
    
    //una vez obtenido el valor de la venta, se limita a dos decimales.
    sumatoria.toFixed(2);
    
    //el valor de la sumatoria se asigna a la etiqueta importe que muestra la sumatoria total.
    $("#importe").text(sumatoria);
  });

  

  $("#formasPago").on("change", function(){
    if($(this).val() == "Tarjeta de Crédito"){
      formaPago = "credito";
      $('#pagoTC').modal('show');
      $('#numTarjetaCredito').select();
    }
    if($(this).val() == "Tarjeta de débito"){
      formaPago = "debito";
      $('#pagoTD').modal('show');
      $('#numTarjetaDebito').select();
    }
    if($(this).val() == "Oxxo"){
      formaPago = "oxxo";
      $('#pagoOxxo').modal('show');
      $('#referenciaOxxo').select();
    }
    if($(this).val() == "Paypal"){
      formaPago = "paypal";
      $('#pagoPaypal').modal('show');
      $('#referenciaPaypal').select();
    }
  });

  //Acción para abrir el modal de cobro de la venta.
  $("#pagarBtn").on("click", function(){
    $('#modalPago').modal('show');
    $('#campo-paga-con').select();
  });


  //Acción para guardar la venta en un objeto JSON.
  $("#cobrarVenta").on("click", function() {
    
    //Se añade la caja a la que pertenece esta venta.
    caja = { };
    caja["caja"] = $("#caja").val();
    datosVenta.push(caja);

    formaPagoJSON = {};
    formaPagoJSON["formaPago"] = formaPago;

    $.ajax({
      //Los datos se obtienen en json
      url: "/punto_venta/obtenerCamposFormaPago/"+formaPago,
      dataType: "JSON",
      method: "POST",
      timeout: 10000,
      beforeSend: function(){
      
      },
      error: function(){
        alert("Error al cargar los campos de formas de pago.");
      },
      
      success: function(res){
        for(i= 0; i < res.length; i++){
          resultado = res[i];
          nom = resultado.nombrecampo;
          campo = nom.toString();
          camNoSpc = campo.replace(' ', '-');
          
          formaPagoJSON[String(camNoSpc)] = $("#campo-"+camNoSpc).val();
        }
        
        
           
      }//Termina success de la petición ajax

    }); //Termina petición ajax de campos de la forma de pago elegida

    if(formaPago == "efectivo"){
      formaPagoJSON["formaPago"]="efectivo";
    }
    if(formaPago == "credito"){
      formaPagoJSON["formaPago"]="credito";
      formaPagoJSON["ntCredito"] = numTarjetaCredito;
      formaPagoJSON["plazoTCredito"] = plazoCredito;

    }
    if(formaPago == "debito"){
      formaPagoJSON["formaPago"]="debito";
      formaPagoJSON["ntDebito"] = numTarjetaDebito;
    }
    if(formaPago == "oxxo"){
      formaPagoJSON["formaPago"]="oxxo";
      formaPagoJSON["refOxxo"] = referenciaOxxo;
    }
    if(formaPago == "paypal"){
      formaPagoJSON["formaPago"]="paypal";
      formaPagoJSON["refPaypal"] = referenciaPaypal;
    }

    datosFormaPago.push(formaPagoJSON);
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

       /*$("#dataVenta").val(JSON.stringify(datosVenta));
       var form = $("#ventaForm");
       form.submit();
       itemsVenta = [];
       datosVenta = [];
       datosFormaPago = [];*/
   });

});

/**
 * Establece el valor de la forma de pago que el cliente eligió
 */
function setFormaPago(forma){
  formaPago = forma;
}

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
    url: "/articulos/getById/" + elem,
    dataType: "JSON",
    timeout: 10000,
    beforeSend: function(){
    //$("#respuesta").html("Cargando...");
    },
    error: function(){
      alert("error");
      //$("#respuesta").html("Error al intentar buscar el empleado. Por favor intente más tarde.");
             
    },
    success: function(res){
      if(res){
        var resLength = res.length;
        for(i=0; i < resLength; i++){
           var element = res[i];
           $("#table_sales").append("<tr class='even pointer'><td>"+element.clave+"</td>"+
                                    "<td>"+element.nombre+"</td>"+
                                    "<td>"+element.precioVenta+"</td><td id='cantidadProducto'>1</td>"+
                                    "<td>"+element.precioVenta+"</td></tr>");
        }
        var nodoResultado = document.getElementById("search-product").parentNode.lastChild;
        document.getElementById("search-product").parentNode.removeChild(nodoResultado);
              
      }else{
        
      }
    }
  })
}

/**
 * Esta función permite cambiar los valores del cuadro de clientes en base al cliente elegido
 * En el modal de clientes
 */
function cambiarCliente(id, nombre, telefono, email){
  //Se guarda el id del cliente elegido en un input hidden
  $("#id_cliente").val(id);

  //Aquí se llenan los datos básicos del cliente.
  $("#nom_cliente_venta").html("<strong>"+nombre+"</strong>");
  $("#email_cliente").html("Email: <strong>"+email+"</strong>");
  $("#telefono_cliente").html("Teléfono: <strong>"+telefono+"</strong>");
  $("#modalClientes").modal("hide");
}

