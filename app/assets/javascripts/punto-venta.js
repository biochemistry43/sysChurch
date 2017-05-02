var numTarjetaCredito;
var numTarjetaDebito;
var plazoCredito;
var referenciaOxxo;
var referenciaPaypal
var copiaFormaPago = {};
var ultimoFolio = "";

//este arreglo json guardará todos los datos correspondientes a la venta
var datosVenta = [];

//este arreglo guardará los datos de la forma de pago de esta venta en particular
var datosFormaPago = [];

//Este arreglo json guardará código y cFantidad de cada item de venta.
var itemsVenta = [];

//Esta variable cambia dependiendo de la forma de pago elegida por el usuario
var formaPago = "efectivo";

var fecha = new Date();


//jquery
$(document).ready(function(){

  $(".autocomplete").autocomplete();

  /**
   * Aquí se añadirán todas las funcionalidades mediante los botones de teclado
   * que el módulo de punto de venta va a tener.
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
          $("#importePagar").text($("#importe").text());
          $('#campo-paga-con').select();
        }
        event.stopPropagation();
        break;
    }

  });//Terminan los eventos de teclado dentro de el módulo punto de venta.

  $('#campo-paga-con').bind('keyup', function(event) {
    
    if(($("#importe").text().length >= 1) && ($("#campo-paga-con").val().length >= 1))  {
      
      value = parseFloat($("#importe").text());
      pagoCli = parseFloat($("#campo-paga-con").val());

      
      var cambio = pagoCli - value;
      cambio = cambio.toFixed(2);

      if (cambio > 0){
        $("#cambio_cliente").text(cambio);  
      }
      
    }
    

  });//Terminan los eventos de teclado dentro de el módulo punto de venta.


  /*El método autocomplete, asigna las funcionalidades de autocompletado a todos los campos con la clase
  autocomplete. Ver /assets/javascripts/autocomplete.jquery.js */
  //$('.autocomplete').autocomplete();

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
        addProduct($("#search-product").val());
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
    existencia = $(this).find("#existenciaProducto").html();
    cambiarCantidadProducto($(this).index(), cantidad, existencia);

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

            "<tr class='even pointer'><td>"+element.nombre+" "+element.ape_pat+" "+element.ape_mat+"</td>"+
            "<td>"+element.telefono1+"</td>"+
            "<td>"+element.email+"</td>"+
            "<td><button class='btn btn-success btn-xs' "+
                    "onclick='cambiarCliente(\""+element.id+"\", \""+element.nombre+" "+element.ape_pat+" "+element.ape_mat+"\", \""+element.telefono1+"\", \""+element.email+"\")' >"+
                      "<i class='fa fa-check-square'></i> Seleccionar </button></td></tr>");

      }

      /* Una vez que se han cargado los datos en la tabla, convertimos nuestra tabla en una tabla DataTable.
       * El plugin Datatable fue instalado mediante la gema 'jquery-datatables-rails'. 
       * Para más información:  https://github.com/rweng/jquery-datatables-rails
       * La funcionalidad de ser responsiva fue añadida a la tabla.
       */
      $('#lista_clientes').DataTable({
        responsive: true,
        "language":{
          "info": "Mostrar pag _PAGE_ de _PAGES_",
          "lengthMenu": "Mostrar _MENU_ registros",
          "zeroRecords": "No hay coincidencias",
          "search": "Buscar: _INPUT_",
          "infoFiltered": " - encontrados en _MAX_ registros",
          "paginate": {
            "previous": "Anterior",
            "next" : "siguiente",
            "last" : "último",
            "first" : "primero"
          }
        }
      });


         
    }//Termina success de la petición ajax

  }); //Termina petición ajax de la lista de clientes.

  //Esta acción abre el modal que permite cambiar el cliente de una venta
  $("#cambiarClienteBtn").on("click", function(e){

    $('#modalClie').modal('show');

  });

    
  /**
   * Esta función cambia la cantidad de un producto que se a agregado previamente a la venta.
   * Cada vez que un producto se agrega a la venta, se agrega con una sola unidad. Mediante esta
   * función, se puede cambiar esa cantidad.7
   * param indice indica la fila de la tabla en donde se están intentando cambiar la cantidad.
   * param valor indica la cantidad actual de producto.
   */
  function cambiarCantidadProducto(indice, valor, existencia){
    //Se actualiza el "body" del modal actualizar cantidad
    //Se asignan métodos para actualizar la cantidad dando click en el botón o con la tecla enter
    $('#modal-body-actualizar-cantidad').html('<div class="form-inline">'+
        '<div class="form-group">'+
          '<label for="cantidad">Nueva Cantidad:</label>'+
          '<input type="text" class="form-control" id="nuevaCantidad'+indice+'" value="'+valor+'" onkeyup="enterActualizar(event, '+indice+', '+existencia+')">'+
        '</div>'+
      '</div>');
    //Se añade un botón en el footer del modal que permite actualizar la cantidad.
    $('#modal-footer').html('<button type="button" class="btn btn-primary" data-dismiss="modal" onclick="actualizarCantidad('+indice+', '+existencia+')">Aceptar</button>')
    
    //Se muestra el modal.  
    $('#actualizarCantidad').modal('show');
    
    //Se selecciona el texto que está en el textfield para facilitar la edición de la cantidad.    
    $('#nuevaCantidad'+indice).select();
      
  }//Termina el método cambiarCantidadProducto


  //Acción para abrir el modal de cobro de la venta.
  $("#pagarBtn").on("click", function(){
    if ($('#table_sales >tbody >tr').length == 0){
      alert ( "No hay productos añadidos a la venta" );
    }
    else{
      $('#modalPago').modal('show');
      $('#campo-paga-con').select();
      $("#importePagar").text($("#importe").text());
    }
  });

  $("#fecha_ticket").html("Fecha: " + fecha.getDate()+"/"+
       (fecha.getMonth()+1)+"/"+fecha.getFullYear());


  //Acción para guardar la venta en un objeto JSON.
  $("#cobrarVenta").on("click", function() {
    
    //Se añade la caja a la que pertenece esta venta.
    caja = { };
    caja["caja"] = $("#caja").val();
    datosVenta.push(caja);

    //Este objeto guarda el id del cliente a quien se vendió
    datosCliente = {};
    datosCliente["id_cliente"] = $("#id_cliente").val();

    datosVenta.push(datosCliente);

    formaPagoJSON = {};
    formaPagoJSON["formaPago"] = formaPago;

    if(formaPago != "efectivo"){


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

          /*El resultado de esta petición, será una estructura ajax con los datos
            de los campos dados de alta en la forma de pago elegida.
            la forma de pago se solicita mediante la variable "formaPago"
            cuando se hace la solicitud ajax*/

          //Se recorre cada campo de la Forma de Pago elegida
          for(i= 0; i < res.length; i++){

            resultado = res[i]; //Se obtiene el campo.

            nom = resultado.nombrecampo; //obtenemos el nombre del campo

            campo = nom.toString(); //Se transforma el dato en un String.

            camNoSpc = campo.replace(' ', '-');//Se reemplazan los espacios por un "-"

            //Se crea un campo JSON con el mismo nombre del campo en base de datos
            //Salvo que lleva un "-" en lugar de un espacio en los casos de nombres
            //de campo compuestos. Ejemplo: Tarjeta credito cambia a Tarjeta-credito

            // Dado que el campo html tiene el mismo nombre de id (con la palabra
            // "campo-" antecediendole), se obtiene el valor del campo en base a ese
            // mismo nombre encontrado en bd, a excepción de que lleva un guión medio
            // en lugar de los espacios.
            // Sin embargo, para asignar la "llave" al JSON, se utiliza el nombre con
            // Espacios incluidos.
            formaPagoJSON[String(campo)] = $("#campo-"+camNoSpc).val();            

          }

          //Se guardan los datos de la forma de pago en el arreglo JSON
          
             
        },//Termina success de la petición ajax

        complete: function(jqXHR, settings){
          
          if(jqXHR.status == 200){
            completarVenta();

            
          }

        }

      }); //Termina petición ajax de campos de la forma de pago elegida
    }

    else{
      completarVenta();
    }

  });//Fin de la acción de cobrar venta.


  $("#cancelarVentaBtn").on("click", function(evt){

    confirmacion = confirm("¿Está seguro de cancelar esta venta?");
    if (confirmacion){
      $("#table_sales tbody").empty();
      $("#importe").text("0.0")
      $("#search-product").focus();
    }
    else{
      return;
    }
    

  });

  $("#search-product").select();
  
});//Fin de JQuery

window.onload = function() {

  if ($BODY.hasClass('nav-md')) {
    $BODY.removeClass('nav-md').addClass('nav-sm');
    $LEFT_COL.removeClass('scroll-view').removeAttr('style');

    if ($SIDEBAR_MENU.find('li').hasClass('active')) {
      $SIDEBAR_MENU.find('li.active').addClass('active-sm').removeClass('active');
    }
  } else {
    $BODY.removeClass('nav-sm').addClass('nav-md');

    if ($SIDEBAR_MENU.find('li').hasClass('active-sm')) {
      $SIDEBAR_MENU.find('li.active-sm').addClass('active').removeClass('active-sm');
    }
  }
};



/**
 * 
 */
function completarVenta(){

  datosFormaPago.push(formaPagoJSON);
  //alert(JSON.stringify(datosFormaPago));

  //Se guardan los datos de forma de pago en el arreglo de datos de la venta
  datosVenta.push(datosFormaPago);
  copiaFormaPago = JSON.parse(JSON.stringify(formaPagoJSON));        
  
  /**
   * Ahora se recorren cada uno de los items de la venta y llena el arreglo
   * con los datos respectivos.
   */
  $('#table_sales tr').each(function (i, el) {
    //Se discrimina la primer fila (que corresponde al encabezado)
    if(i!=0){
    //El código del producto se encuentra en la primer columna de 
    //de la tabla de venta actual.
      var codigoProd = $(this).find("td").eq(0).text();
      //La cantidad vendida del producto se encuentra en la tercera
      //columna de la tabla de venta actual.
      var cantidadProd = $(this).find("td").eq(3).text();
      //El importe total del producto vendido se encuentra en la
      //quinta columna de la tabla de venta actual.
      var importeProd = $(this).find("td").eq(4).text();
      //itemVenta es el objeto JSON que guarda toda la fila de un articulo
      //vendido
      itemVenta = {};
      //Se crean los campos correspondientes y se guardan los datos obtenidos
      //del producto
      itemVenta["codigo"]=codigoProd;
      itemVenta["cantidad"]=cantidadProd;
      itemVenta["importe"]=importeProd;
      //itemsVenta guarda la totalidad de los items de la venta.
      //itemVenta es el item en particular.
      itemsVenta.push(itemVenta);
      
    }
  }); //Termina recorrido de la tabla de venta actual
  //Ahora se guardan los items de la venta en el objeto datosVenta
  datosVenta.push(itemsVenta);
  
  //dataVenta es un campo oculto dentro del form ventaForm
  //este forma es el encargado de mandar toda la información relativa a la venta
  //en un objeto JSON.
  $("#dataVenta").val(JSON.stringify(datosVenta));
  
  

  if($("#isPrintTicket").attr("checked")){
    var form = $("#ventaForm");
    form.submit(); //Se submite el form con los datos de la venta.
    //imprimirTicket();
  }
  else{
    var form = $("#ventaForm");
    form.submit(); //Se submite el form con los datos de la venta.
  }

     
  //Se vacían los arreglos previamente creados para evitar posibles datos 
  //incorrectos.
  itemsVenta = [];
  datosVenta = [];
  datosFormaPago = [];
  datosCliente = {};

}//Termina función completar venta


/**
 * Establece el valor de la forma de pago que el cliente eligió
 */
function setFormaPago(forma){
  formaPago = forma;
}

function enterActualizar(event, indice, existencia){
  if (event.keyCode == 13) {
    
    cantidad = $("#nuevaCantidad"+indice).val();
    
    if(cantidad <= existencia){
      actualizarCantidad(indice, existencia);
      $('#actualizarCantidad').modal('hide');  
    }
    else{
      alert("No hay suficiente existencia para vender esta cantidad de producto.\n La existencia del producto es: "+existencia);
      return;
    }
    
    
  }
}

function actualizarCantidad(indice, existencia){

  cantidad = $("#nuevaCantidad"+indice).val();
  
  //Si la cantidad no sobrepasa la existencia
  if(cantidad <= existencia){

    //Se cambia el valor encontrado en la celda que tiene la cantidad de producto a vender
    $($('#table_sales').find('tbody > tr')[indice]).children('td')[3].innerHTML = cantidad;

    //Se obtiene el precio de venta encontrado en la tabla
    precioVenta = $($('#table_sales').find('tbody > tr')[indice]).children('td')[2].innerHTML;

    //Se obtiene el importe a raíz del precio de venta y la cantidad introducida por el usuario
    importe = cantidad * precioVenta;

    //Se actualiza la celda que contiene el importe de venta de este producto en particular
    //con el calculado a partir del precio de venta y la nueva cantidad.
    $($('#table_sales').find('tbody > tr')[indice]).children('td')[4].innerHTML = importe;

  }
  else{
    alert("No hay suficiente existencia para vender esta cantidad de producto.\n La existencia del producto es: "+existencia);
  }

  

}

function addProduct(elem){
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
          if(element.existencia == 0){
            alert("Este producto no tiene existencias");
          }
          else{

            $("#table_sales").append("<tr class='even pointer'><td>"+element.clave+"</td>"+
                                    "<td>"+element.nombre+"</td>"+
                                    "<td>"+element.precioVenta+"</td><td id='cantidadProducto'>1</td>"+
                                    "<td>"+element.precioVenta+"</td>"+
                                    "<td id='existenciaProducto' style='visibility:hidden;'>"+element.existencia+"</td>"+
                                    "<td><button class='btn btn-danger btn-xs borrar_item_venta'>"+
                                    "<i class='fa fa-trash-o'></i></button></td>"+
                                    "</tr>");
          }

        }


        var nodoResultado = document.getElementById("search-product").parentNode.lastChild;
        document.getElementById("search-product").parentNode.removeChild(nodoResultado);
              
      }else{
        
      }
    }
  })
}

$(document).on('click', '.borrar_item_venta', function (event) {
    event.preventDefault();
    $(this).closest('tr').remove();
});

jQuery.fn.contentChange = function(callback){
    var elms = jQuery(this);
    elms.each(
      function(i){
        var elm = jQuery(this);
        elm.data("lastContents", elm.html());
        window.watchContentChange = window.watchContentChange ? window.watchContentChange : [];
        window.watchContentChange.push({"element": elm, "callback": callback});
      }
    )
    return elms;
  }
  setInterval(function(){
    if(window.watchContentChange){
      for( i in window.watchContentChange){
        if(window.watchContentChange[i].element.data("lastContents") != window.watchContentChange[i].element.html()){
          window.watchContentChange[i].callback.apply(window.watchContentChange[i].element);
          window.watchContentChange[i].element.data("lastContents", window.watchContentChange[i].element.html())
        };
      }
    }
  },500);

  /* Código para actualizar la etiqueta de sumatoria total. El código se va a ejecutar
   * cada que vez que haya un cambio en los valores de la tabla (lo cual sólo ocurre cuando se
   * agrega un producto o se cambia una cantidad de venta de producto). */
  
  /* Código para actualizar la etiqueta de sumatoria total. El código se va a ejecutar
   * cada que vez que haya un cambio en los valores de la tabla (lo cual sólo ocurre cuando se
   * agrega un producto o se cambia una cantidad de venta de producto). */
  $("#table_sales").contentChange(function(){
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
  $("#modalClie").modal("hide");
}

