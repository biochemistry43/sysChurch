var numTarjetaCredito;
var numTarjetaDebito;
var plazoCredito;
var referenciaOxxo;
var referenciaPaypal
var copiaFormaPago = {};

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
    imprimirTicket();
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
 * Función que crea e imprime un ticket de compra
 */
function imprimirTicket(){
var div_print = document.createElement("div");
    div_print.setAttribute("id", "print-div")
    div_print.setAttribute("style", "font-size: 11px; width:200px;");
    var div_print_1 = document.createElement("div");
    div_print_1.className = "col-md-3";

    //logo del negocio
    var filalogo = document.createElement("div");
    filalogo.className = "row"
    var divlogo = document.createElement("div");
    divlogo.className = "col-md-12";
    divlogo.setAttribute("style","width: 100%;");
    div_print_1.appendChild(filalogo);
    filalogo.appendChild(divlogo);
    var logoNegocio = document.createElement("img")
    //logoNegocio.setAttribute("width", "70px");
    //logoNegocio.setAttribute("height", "45px");
    //rutaLogo = document.getElementById('logo_negocio').src;
    //logoNegocio.setAttribute("src", rutaLogo);
    //logoNegocio.setAttribute("style","horizontal-align:middle;");
    //divlogo.appendChild(logoNegocio);


    //Primer fila del ticket
    var div_print_1_1 = document.createElement("div");
    div_print_1_1.className = "row";

    var div_print_1_1_1 = document.createElement("div");
    div_print_1_1_1.className = "col-md-12";
    div_print_1_1_1.setAttribute("style", "text-align:center;");

    var nomNegocio = document.createElement("h5");
    nomNegocio.setAttribute("id", "nombre_negocio_ticket");
    var nomFiscalNegocio = document.createElement("h6");
    nomFiscalNegocio.setAttribute("id", "nombre_fiscal_negocio_ticket");
    var rfcNegocio = document.createElement("p");
    rfcNegocio.setAttribute("style", "font-size: 9px;");
    rfcNegocio.setAttribute("id", "rfc_negocio_ticket")
    var dirNegocio = document.createElement("p");
    dirNegocio.setAttribute("style", "font-size: 9px;");
    dirNegocio.setAttribute("id", "dir_negocio_ticket")
    var nomSucursal = document.createElement("h5");
    nomSucursal.setAttribute("id", "nombre_sucursal_ticket");
    //Termina primer fila del ticket

    //Segunda fila del ticket
    var div_print_1_2 = document.createElement("div");
    div_print_1_2.className = "row";
    div_print_1_2.setAttribute("style", "text-align:center;");
    var div_print_1_2_1 = document.createElement("p");
    div_print_1_2_1.className = "col-md-12";
    div_print_1_2_1.setAttribute("id", "direccion_sucursal_ticket");
    div_print_1_2_1.setAttribute("style", "font-size:9px;");
    //Termina segunda fila del ticket

    //Tercera fila del ticket
    var div_print_1_3 = document.createElement("div");
    div_print_1_3.className = "row";
    div_print_1_3.setAttribute("style", "text-align:center;");
    var div_print_1_3_1 = document.createElement("div");
    div_print_1_3_1.className = "col-md-12";
    div_print_1_3_1.setAttribute("id", "fecha_ticket");
    div_print_1_3_1.setAttribute("style", "font-size: 9px;");
    //Termina tercer fila del ticket

    //Cuarta fila del ticket
    var div_print_1_4 = document.createElement("div");
    div_print_1_4.className = "row";
    var div_print_1_4_1 = document.createElement("div");
    div_print_1_4_1.className = "col-md-12";
    div_print_1_4_1.setAttribute("id", "datos_cliente_ticket");
    div_print_1_4_1.setAttribute("style", "font-size: 9px;");
    //Termina la cuarta fila del ticket

    var filaCajero = document.createElement("div");
    filaCajero.className = "row";
    var divCajero = document.createElement("div");
    divCajero.className = "col-md-12";
    divCajero.setAttribute("id", "datos_cajero");
    divCajero.setAttribute("style", "font-size: 9px;");



    //Quinta fila del ticket
    var div_print_1_5 = document.createElement("div");
    div_print_1_5.className = "row";
    var div_print_1_5_1 = document.createElement("div");
    div_print_1_5_1.className = "col-md-12";
    div_print_1_5_1.setAttribute("id", "productos_ticket");
    div_print_1_5_1.setAttribute("style", "width: 100%;");
    var tablaProductos = document.createElement("table");
    tablaProductos.className = "col-md-12"
    tablaProductos.setAttribute("style","font-size: 9px;");
    tablaProductos.setAttribute("width", "95%");
    tablaProductos.setAttribute("id", "tabla_productos_ticket");
    tBodyProductos = document.createElement("tbody");
    //Termina quinta fila
    
    //Sexta fila del ticket
    var div_print_1_6 = document.createElement("div");
    div_print_1_6.className = "row";
    var div_print_1_6_1 = document.createElement("div");
    div_print_1_6_1.className = "col-md-12";
    var importeTotal = document.createElement("p");
    importeTotal.setAttribute("id", "importe_total_ticket");
    //Termina sexta fila del ticket

    //Septima fila del ticket
    var div_print_1_7 = document.createElement("div");
    div_print_1_7.className = "row";
    var div_print_1_7_1 = document.createElement("div");
    div_print_1_7_1.className = "col-md-12";
    var forma_Pago = document.createElement("p");
    forma_Pago.setAttribute("id", "forma_pago");
    forma_Pago.setAttribute("style", "font-size: 9px;")
    //Termina septima fila del ticket

    //Construccion del arbol dom del ticket
    div_print.appendChild(div_print_1);
    div_print_1.appendChild(div_print_1_1);
    div_print_1.appendChild(div_print_1_2);
    div_print_1.appendChild(div_print_1_3);
    div_print_1.appendChild(div_print_1_4);
    div_print_1.appendChild(filaCajero);
    div_print_1.appendChild(div_print_1_5);
    div_print_1.appendChild(div_print_1_6);
    div_print_1.appendChild(div_print_1_7);
    
    //Construccion de la primer fila
    div_print_1_1.appendChild(div_print_1_1_1);
    div_print_1_1_1.appendChild(nomNegocio);
    div_print_1_1_1.appendChild(nomFiscalNegocio);
    div_print_1_1_1.appendChild(dirNegocio);
    div_print_1_1_1.appendChild(rfcNegocio);
    div_print_1_1_1.appendChild(nomSucursal);
    //Termina construcción de la primer fila

    //Construcción de la segunda fila
    div_print_1_2.appendChild(div_print_1_2_1);
    //Termina construcción de la segunda fila

    //Construcción de la tercer fila
    div_print_1_3.appendChild(div_print_1_3_1);
    //Termina construcción de la tercer fila

    //Construcción de la cuarta fila
    div_print_1_4.appendChild(div_print_1_4_1);
    //Termina construcción de la cuarta fila

    filaCajero.appendChild(divCajero);

    //Construcción de la quinta fila
    div_print_1_5.appendChild(div_print_1_5_1);
    div_print_1_5_1.appendChild(tablaProductos);
    tablaProductos.appendChild(tBodyProductos);
    //Termina construcción de la quinta fila

    //Construcción de la sexta fila
    div_print_1_6.appendChild(div_print_1_6_1);
    div_print_1_6_1.appendChild(importeTotal);
    //Termina construcción de la sexta fila

    //Construcción de la septima fila
    div_print_1_7.appendChild(div_print_1_7_1);
    div_print_1_7_1.appendChild(forma_Pago);
    //Termina construcción de la septima fila

    //alert(JSON.stringify(copiaFormaPago));

    document.getElementById('print-div2').appendChild(div_print);



    $("#nombre_negocio_ticket").append($("#nombre_negocio").val() );
    $("#nombre_fiscal_negocio_ticket").append($("#nombre_negocio_fiscal").val() );

    $("#dir_negocio_ticket").append($("#direccion_negocio").val())
    $("#rfc_negocio_ticket").append($("#rfc_negocio").val())
    $("#nombre_sucursal_ticket").append("Sucursal: "+$("#nombre_sucursal").val());
    $("#direccion_sucursal_ticket").append($("#direccion_sucursal").val());
    $("#fecha_ticket").append("Fecha: " + fecha.getDate()+"/"+
                              (fecha.getMonth()+1)+"/"+fecha.getFullYear());

    $("#datos_cliente_ticket").html("Cliente: "+$("#nom_cliente_venta").text());
    $("#datos_cajero").html("Cajero: "+$("#nombre_cajero").val());

    $("#tabla_productos_ticket").html(""+
      
        "<thead>"+
          "<tr style='background-color: gray;'>"+
            "<th style='text-align:center; border-bottom: 1px solid #ddd;'>Cant</th>"+
            "<th style='text-align:center; border-bottom: 1px solid #ddd;'>Prod</th>"+
            "<th style='text-align:center; border-bottom: 1px solid #ddd;'>Imp</th>"+
          "</tr>"+ 
        "</thead>"

    );

    $('#table_sales tr').each(function (i, el) {
      //Se discrimina la primer fila (que corresponde al encabezado)
      
      if(i!=0){
      //El código del producto se encuentra en la primer columna de 
      //de la tabla de venta actual.
        var nombreProd = $(this).find("td").eq(1).text();
        //La cantidad vendida del producto se encuentra en la tercera
        //columna de la tabla de venta actual.
        var precio = $(this).find("td").eq(2).text();
        //El importe total del producto vendido se encuentra en la
        //quinta columna de la tabla de venta actual.
        var cantidad = $(this).find("td").eq(3).text();
        //itemVenta es el objeto JSON que guarda toda la fila de un articulo
        //vendido
        var importe = $(this).find("td").eq(4).text();
        itemVenta = {};
        
        $("#tabla_productos_ticket").append(""+
       
          "<tr style='border-bottom: 1px solid #ddd;'>"+
            "<td>"+cantidad+"</td>"+
            "<td style='text-align: justify;' >"+nombreProd+"</td>"+
            "<td style='text-align:right;'>"+importe+"</td>"+
          "</tr>"
    
        );

      }

    }); //Termina recorrido de la tabla de venta actual

    $("#importe_total_ticket").html("Total: <strong>$"+$("#importe").text()+"</strong>");

    
    if(formaPago.toLowerCase() == "efectivo"){
       $("#forma_pago").html("Forma de Pago: <strong>"+ formaPago + "</strong>");
    }

    else{

      for (x in copiaFormaPago) {
        if(x.includes("tarjeta")){
          nTarjeta = copiaFormaPago[x];
          terminacion = nTarjeta.substr(12, 4);
          document.getElementById("forma_pago").innerHTML += x + ": ************" +terminacion + "<br>"; 
        }
        else{
          document.getElementById("forma_pago").innerHTML += x + ": " +copiaFormaPago[x] + "<br>";  
        }
      }
    }


    $("#print-div2").print({

      globalStyles: true,
      mediaPrint: true,
      stylesheet: null,
      noPrintSelector: ".no-print",
      iframe: true,
      append: null,
      prepend: null,
      manuallyCopyFormValues: true,
      deferred: $.Deferred().done(function(){
        $("#print-div").empty();
        var form = $("#ventaForm");
        form.submit(); //Se submite el form con los datos de la venta.
      }),
      timeout: 750,
      title: null,
      doctype: '<!doctype html>'

    });   
}

/**
 * Establece el valor de la forma de pago que el cliente eligió
 */
function setFormaPago(forma){
  formaPago = forma;
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
                                    "<td><button class='btn btn-danger btn-xs borrar_item_venta'>"+
                                    "<i class='fa fa-trash-o'></i></button></td></tr>");
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

