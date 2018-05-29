var numTarjetaCredito;
var numTarjetaDebito;
var plazoCredito;
var referenciaOxxo;
var referenciaPaypal
var copiaFormaPago = {};

var itemsEnTabla = new Set();

//este arreglo json guardará todos los datos correspondientes a la venta
var datosVenta = [];

//este arreglo guardará los datos de la forma de pago de esta venta en particular
var datosFormaPago = [];

//Este arreglo json guardará código y cFantidad de cada item de venta.
var itemsCompra = [];

//Esta variable cambia dependiendo de la forma de pago elegida por el usuario
var formaPago = "efectivo";

var fecha = new Date();


//jquery
$(document).ready(function(){
  
  function disableF5(e) { if ((e.which || e.keyCode) == 116) e.preventDefault(); };
  $(document).on("keydown", disableF5);

  $("#compra_tipo_pago").on("change", function(e){
    seleccion = this.value;
    if (seleccion == "Credito"){
      $("#opciones_compra_contado").css("display", "none");
      $("#opciones_compra_credito").slideDown();  
    }
    else if (seleccion == "Contado"){
      $("#opciones_compra_credito").css("display", "none");
      $("#opciones_compra_contado").slideDown(); 
      $('#compra_tipo_pago').prop('required',true);
    }
    
  });



  $('#compra_tipo_pago option:contains("Contado")').prop('selected',true);

  $("#filtros_avanzados").click(function(e){
    if( $("#opciones_filtros_avanzados").is(":visible") ){
      $(this).html('Filtros Avanzados <i class="fa fa-sort-down"></i>');
    }
    else{
      $(this).html('Filtros Avanzados <i class="fa fa-sort-up"></i>');
    }
      
    $("#opciones_filtros_avanzados").slideToggle("fast");

  });

  $("#filtros_por_fecha").click(function(e){
    if( $("#opciones_filtros_por_fecha").is(":visible") ){
      $(this).html('Filtros por fechas <i class="fa fa-sort-down"></i>');
    }
    else{
      $(this).html('Filtros por fechas <i class="fa fa-sort-up"></i>');
    }
      
    $("#opciones_filtros_por_fecha").slideToggle("fast");

  });

  $("#filtros_por_factura").click(function(e){
    if( $("#opciones_filtros_por_factura").is(":visible") ){
      $(this).html('Filtro por factura o ticket<i class="fa fa-sort-down"></i>');
    }
    else{
      $(this).html('Filtro por factura o ticket<i class="fa fa-sort-up"></i>');
    }
      
    $("#opciones_filtros_por_factura").slideToggle("fast");

  });

  

  /*El método autocomplete, asigna las funcionalidades de autocompletado a todos los campos con la clase
  autocomplete. Ver /assets/javascripts/autocomplete.jquery.js */
  $(".autocomplete").autocomplete();


  //Se aseguro que el campo de búsqueda esté vacío cada vez que se inicia el punto de venta.
  $("#search-product" ).val("");

  /**
   * En el caso de edición de compra, esta función copia el contenido del área de texto
   * razon_edicion en el campo oculto compra_razon_edicion
   */
  $("#razon_edicion" ).keyup(function(event) {

    $("#compra_razon_edicion").val($("#razon_edicion").val());
  });
  

  $("#search-product" ).keyup(function(event) {
    //Obtiene el código del evento
    var code=event.keyCode;

      // Si es Enter y el valor no está vacío, añade el producto a la compra.
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

    if (!$(this).hasClass("headings")) {
      cantidad = $(this).find("#cantidadProducto").html();
      precio = $(this).find("#precioProducto").html();
      cambiarCantidadProducto($(this).index(), cantidad, precio);
    }

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
    //Una vez recibida la respuesta del servidor, 
    //se construye una tabla con clientes dentro de un modal.
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
            "<td><button class='btn btn-success btn-xs' "+
                    "onclick='cambiarCliente(\""+element.id+"\", \""+element.nombre+"\", \""+element.telefono1+"\", \""+element.email+"\")' >"+
                      "<i class='fa fa-check-square'></i> Seleccionar </button></td></tr>");

      }


      /* Una vez que se han cargado los datos en la tabla, 
       * convertimos nuestra tabla en una tabla DataTable.
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

    $('#modalClientes').modal('show');

  });

    
  /**
   * Esta función cambia la cantidad de un producto que se a agregado previamente a la venta.
   * Cada vez que un producto se agrega a la venta, se agrega con una sola unidad. Mediante esta
   * función, se puede cambiar esa cantidad.7
   * param indice indica la fila de la tabla en donde se están intentando cambiar la cantidad.
   * param valor indica la cantidad actual de producto.
   */
  function cambiarCantidadProducto(indice, valor, precio){
    //Se actualiza el "body" del modal actualizar cantidad
    //Se asignan métodos para actualizar la cantidad dando click en el botón o con la tecla enter
    $('#modal-body-actualizar-cantidad').html('<div class="form">'+
        '<div class="form-group">'+
          '<label for="cantidad">Nueva Cantidad:</label>'+
          '<input type="text" class="form-control" id="nuevaCantidad'+indice+'" value="'+valor+'" onkeyup="enterActualizar(event, '+indice+')" >'+
        '</div>'+
        '<div class="form-group">'+
          '<label for="precio">Precio de Compra:</label>'+
          '<input type="text" class="form-control" id="precio'+indice+'" value="'+precio+'" onkeyup="enterActualizar(event, '+indice+')">'+
        '</div>'+
      '</div>');
    //Se añade un botón en el footer del modal que permite actualizar la cantidad.
    $('#modal-footer').html('<button type="button" class="btn btn-primary" data-dismiss="modal" onclick="actualizarCantidad('+indice+')">Aceptar</button>')
    
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

  $("#actualizar_compra_btn").on("click", function(evt){

    if (parseFloat($("#importe").text()) > 0){
      if($("#razon_edicion").val()!=''){
        $("#table_sales tbody").empty();
        $("#importe").text("0.0");
        $("#search-product").focus();
      }
    }
    else{
      alert("El importe de compra debe ser mayor que cero")
      return;
    }
    

  });


  $("#realizar_compra_btn").on("click", function(evt){

    if (parseFloat($("#importe").text()) > 0){
      $("#table_sales tbody").empty();
      $("#importe").text("0.0");
      $("#search-product").focus();
    }
    else{
      alert("El importe de compra debe ser mayor que cero")
      return;
    }
    

  });

  $("#search-product").select();


  
});//Fin de JQuery

/*window.onload = function() {

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
};*/


function enterActualizar(event, indice){
  if (event.keyCode == 13) {
    actualizarCantidad(indice);
    $('#actualizarCantidad').modal('hide');
  }
}


function actualizarCantidad(indice){
  cantidad = $("#nuevaCantidad"+indice).val();
  precio = $("#precio"+indice).val();

  $($('#table_sales').find('tbody > tr')[indice]).children('td')[3].innerHTML = cantidad;
  $($('#table_sales').find('tbody > tr')[indice]).children('td')[2].innerHTML = precio;

  precioVenta = $($('#table_sales').find('tbody > tr')[indice]).children('td')[2].innerHTML;
  

  importe = cantidad * precioVenta;
  $($('#table_sales').find('tbody > tr')[indice]).children('td')[4].innerHTML = importe;
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
        //var resLength = res.length;

        // En este for, se añaden los datos a cada una de las celdas 
        //de la fila de un producto.
      //  for(i=0; i < resLength; i++){
           var element = res;

           var esAgregado = guardarIdAgregado(element);

           if (esAgregado) {
             $("#table_sales").append("<tr id='tr-venta-"+element.id+"' class='even pointer'><td>"+element.clave+"</td>"+
                                    "<td>"+element.nombre+"</td>"+
                                    "<td id='precioProducto' >0</td><td id='cantidadProducto'>1</td>"+
                                    "<td>0</td>"+
                                    "<td><button class='btn btn-danger btn-xs borrar_item_venta'>"+
                                    "<i class='fa fa-trash-o'></i></button></td></tr>");
           }


      //  } //Terminan de añadirse los datos a la fila

        
        var nodoResultado = document.getElementById("search-product").parentNode.lastChild;
        document.getElementById("search-product").parentNode.removeChild(nodoResultado);
              
      }// Termina if(res)


    }// Termina la función success

  }); //Termina ajax

} //Termina la función addProduct


$(document).on('click', '.borrar_item_venta', function (event) {
    event.preventDefault();
    var fila = $(this).closest('tr');
    var id_fila = fila.attr('id');
    var id_producto = id_fila.substr(9);
    itemsEnTabla.delete(parseInt(id_producto));
    fila.remove();
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


        //Los datos de interés son la clave, el precio, la cantidad comprada y el importe
        //Estos datos se encuentran en las columnas cero, dos, tres y cuatro respectivamente.
   
        var codigoProd = $(this).find("td").eq(0).text();
        var precio = $(this).find("td").eq(2).text();
        var cantidad = $(this).find("td").eq(3).text();
        var importeProducto = $(this).find("td").eq(4).text();
        
        //itemVenta es el objeto JSON que guarda toda la fila de un articulo
        //comprado
        itemCompra = {};

        //Se crean los campos correspondientes y se guardan los datos obtenidos
        //del producto
        itemCompra["codigo"]=codigoProd;
        itemCompra["precio"]=precio;
        itemCompra["cantidad"]=cantidad;
        itemCompra["importe"]=importeProducto;
        
        //itemsCompra guarda la totalidad de los items de la compra.
        //itemCompra es el item en particular.
        itemsCompra.push(itemCompra);

        
        //Convierto el valor del importe en un valor float
        var importe = parseFloat(importeProducto);

        //añado el importe a la sumatoria total de la venta
        sumatoria += importe;
      }
    });
    
    //una vez obtenido el valor de la venta, se limita a dos decimales.
    sumatoria.toFixed(2);
    
    //el valor de la sumatoria se asigna a la etiqueta importe que muestra la sumatoria total.
    $("#importe").text(sumatoria);

    //el valor de la sumatoria se pone en el campo hidden monto_compra
    $("#compra_monto_compra").val(sumatoria);

    //Se anade los valores de la compra en el textfield hidden #compra_articulos
    //Llamado simplemente "articulos" en la vista rails
    $("#compra_articulos").val(JSON.stringify(itemsCompra));
    
    //Se reinicia el arreglo de items de la compra
    itemsCompra = [];

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
  $("#modalClientes").modal("hide");
}

function guardarIdAgregado(producto){

  if (itemsEnTabla.has(producto.id)) { 
    var cantidad = $("#tr-venta-"+producto.id).children('td')[3].innerHTML;
    var nuevaCantidad = parseFloat(cantidad) + 1;
    $("#tr-venta-"+producto.id).children('td')[3].innerHTML = nuevaCantidad;

    precioVenta = $("#tr-venta-"+producto.id).children('td')[2].innerHTML;

    nuevoImporte = nuevaCantidad * parseFloat(precioVenta);

    $("#tr-venta-"+producto.id).children('td')[4].innerHTML = nuevoImporte;

    return false;
  }
  else{
     itemsEnTabla.add(producto.id);  
     return true;
  }
}
