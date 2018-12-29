  //Con esta petición ajax, se llena el modal de clientes.
  $.ajax({
    //Los datos se obtienen en json
    url: "/datos_fiscales_clientes/obtener_datos_fiscales",
    dataType: "JSON",
    method: "GET",
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

            "<tr class='even pointer'><td>"+element.nombreFiscal+"</td>"+
            "<td>"+element.rfc+"</td>"+
            "<td>"+element.email+"</td>"+
            "<td><button class='btn btn-success btn-xs' "+
                    "onclick='cambiarCliente(\""+element.id+"\", \""+element.nombreFiscal+ "\", \""+element.rfc+"\", \""+element.email+"\", \""+element.calle+"\", \""+element.numExterior+"\", \""+element.numInterior+"\", \""+element.colonia+"\", \""+element.codigo_postal+"\", \""+element.municipio+"\", \""+element.estado+"\", \""+element.localidad+"\", \""+element.pais+"\", \""+element.referencia+"\")' >"+
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
  /*
  * Esta función permite cambiar los valores del cuadro de clientes en base al cliente elegido
  * En el modal de clientes
  */
  function cambiarCliente(id, nombre_fiscal, rfc, email, calle, no_ext, no_int, colonia, cp, municipio, estado, localidad, pais, referencia){
    //Se guarda el id del cliente elegido en un input hidden
    //$("#id_cliente").val(id);

    //Se cambian los valores de las cajas de texto
    $('#nombre_fiscal_receptor_vf').val(nombre_fiscal);
    $('#rfc_receptor_vf').val(rfc);
    $('#destinatario').val(email);
    //Las siguientes cajas de texto corresponden a la dirección de facturación y solo se actualizan si está seleccionado el check. 
    if( $('#check_agregar_direccion').prop('checked')){
      $('#calle_receptor_vf').val(calle);
      $('#no_exterior_receptor_vf').val(no_ext);
      $('#no_interior_receptor_vf').val(no_int);
      $('#colonia_receptor_vf').val(colonia);
      $('#cp_receptor_vf').val(cp);
      $('#municipio_receptor_vf').val(municipio);
      $('#estado_receptor_vf').val(estado);
      $('#localidad_receptor_vf').val(localidad);
      $('#pais_receptor_vf').val(pais);
      $('#referencia_receptor_vf').val(referencia);
    }
    $('.remove-attr').attr('readonly');

    $("#modalClie").modal("hide");
  }

  $('#check_activar_campos').on('click', function(){
    if( $(this).is(':checked') ){
      $('.remove-attr').removeAttr('readonly');
    }else{
      $('.remove-attr').attr('readonly', 'true'); //atributo, valor
    }
  });


  $(document).ready(function() {

    setTimeout(function() {
        $(".content").fadeOut(1500);
    },10000);

    $('#check_agregar_direccion' ).on('click', function() {
    if( $(this).is(':checked') ){
      $('#direccion_facturacion').show();      
    } else {
      $('#direccion_facturacion').hide();
    }
    });

    $('#btn_editar_datos_fiscales_cliente').on('click', function(){

    });
  });

