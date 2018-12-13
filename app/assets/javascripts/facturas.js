$(document).ready(function(){

  //TABLA INDEX

  $('.data-table').DataTable({
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

    //FILTROS 

    $("#filtros_avanzados").click(function(e){
      if( $("#opciones_filtros_avanzados").is(":visible") ){
        $('#errorRFC2').removeClass(" has-error has-feedback");

        $(this).html('Filtros Avanzados <i class="fa fa-sort-down"></i>');
      }
      else{
        $("#formFiltrosAvanzados")[0].reset();
        $(this).html('Filtros Avanzados <i class="fa fa-sort-up"></i>');
      }
      $("#opciones_filtros_avanzados").slideToggle("fast");
    });


    $("#filtro_por_cliente").click(function(e){
      if ($("#rbtn_rbtn_nombreFiscal").is(":checked")) {
        $('#errorRFC').removeClass(" has-error has-feedback");
        $('.rfc_input').hide().val("");
        $('#nombreFiscalCliente').show();
        $('#leyenda_filtro_cliente').html("Nombre:");
      }
      else if ($("#rbtn_rbtn_rfc").is(":checked")) {
        $('#errorRFC').removeClass(" has-error has-feedback");
        $('.rfc_input').hide().val("");

        $('#nombreFiscalCliente').hide().val("");
        $('.rfc_input').show();
        $('#leyenda_filtro_cliente').html("R.F.C.:");
      }
      if( $("#opciones_filtros_por_cliente").is(":visible") ){
         $(this).html('Filtros por cliente <i class="fa fa-sort-down"></i>');
      }
      else{
        $(this).html('Filtros por cliente <i class="fa fa-sort-up"></i>');
      }
      $("#opciones_filtros_por_cliente").slideToggle("fast");
    });


    $("#filtro_por_folio").click(function(e){
      if( $("#opciones_filtros_por_folio").is(":visible") ){
         $(this).html('Filtros por folio <i class="fa fa-sort-down"></i>');
      }
      else{
        $(this).html('Filtros por folio <i class="fa fa-sort-up"></i>');
      }

      $("#opciones_filtros_por_folio").slideToggle("fast");

    });


    $("#filtro_por_fecha").click(function(e){
      if( $("#opciones_filtros_por_fecha").is(":visible") ){
         $(this).html('Filtros por fecha <i class="fa fa-sort-down"></i>');
      }
      else{
        $(this).html('Filtros por fecha <i class="fa fa-sort-up"></i>');
      }
      $("#opciones_filtros_por_fecha").slideToggle("fast");
    });

    //VALIDACIONES

      //Función para validar un RFC
      // Devuelve el RFC sin espacios ni guiones si es correcto
      // Devuelve false si es inválido
      // (debe estar en mayúsculas, guiones y espacios intermedios opcionales)
      function rfcValido(rfc, aceptarGenerico = true) {
        const re       = /^([A-ZÑ&]{3,4}) ?(?:- ?)?(\d{2}(?:0[1-9]|1[0-2])(?:0[1-9]|[12]\d|3[01])) ?(?:- ?)?([A-Z\d]{2})([A\d])$/;
        var   validado = rfc.match(re);

        if (!validado)  //Coincide con el formato general del regex?
            return false;

        //Separar el dígito verificador del resto del RFC
        const digitoVerificador = validado.pop(),
              rfcSinDigito = validado.slice(1).join(''),
              len = rfcSinDigito.length,

          //Obtener el digito esperado
              diccionario = "0123456789ABCDEFGHIJKLMN&OPQRSTUVWXYZ Ñ",
              indice = len + 1;
        var   suma,
              digitoEsperado;

        if (len == 12) suma = 0
        else suma = 481; //Ajuste para persona moral

        for(var i=0; i<len; i++)
            suma += diccionario.indexOf(rfcSinDigito.charAt(i)) * (indice - i);
        digitoEsperado = 11 - suma % 11;
        if (digitoEsperado == 11) digitoEsperado = 0;
        else if (digitoEsperado == 10) digitoEsperado = "A";

        //El dígito verificador coincide con el esperado?
        // o es un RFC Genérico (ventas a público general)?
        if ((digitoVerificador != digitoEsperado)
         && (!aceptarGenerico || rfcSinDigito + digitoVerificador != "XAXX010101000"))
            return false;
        else if (!aceptarGenerico && rfcSinDigito + digitoVerificador == "XEXX010101000")
            return false;
        return rfcSinDigito + digitoVerificador;
      }

      //Para el filtro por cliente.. permite elegir la busqueda por nombre fisca o por RFC
     $("#rbtn_rbtn_nombreFiscal, #rbtn_rbtn_rfc").change(function () {
            if ($("#rbtn_rbtn_nombreFiscal").is(":checked")) {
              //$('#errorRFC').removeClass(" has-error has-feedback");
              $('.rfc_input').hide().val("");
              $('#nombreFiscalCliente').show();
              $('#leyenda_filtro_cliente').html("Nombre:");

              var buu = function(e){

                var nombre_cliente = "noo";
 

                if (nombre_cliente == "noo") {
                  //colorearRojo.className+=" has-error has-feedback";
                  e.preventDefault();
                }

              };
              //Se pone a la escucha el sumit del formulario
              var facturarYCrearNueva=document.getElementById("RFC_Obligatorio");
              facturarYCrearNueva.addEventListener("click",buu);


            }else if ($("#rbtn_rbtn_rfc").is(":checked")) {
              //Handler para el evento cuando cambia el input
              // -Lleva la RFC a mayúsculas para validarlo
              // -Elimina los espacios que pueda tener antes o después
              /*
              var validador_RFC = function(e){
                var input = document.getElementById("rfc_input");
                var rfc = input.value.trim().toUpperCase()
                var rfcCorrecto = rfcValido(rfc);   // ⬅️ Acá se comprueba
                var colorearRojo=document.getElementById("errorRFC");

                if (!rfcCorrecto) {
                  colorearRojo.className+=" has-error has-feedback";
                  e.preventDefault();
                }

              };*/
              //Se pone a la escucha el sumit del formulario
              //var facturarYCrearNueva=document.getElementById("RFC_Obligatorio");
              //facturarYCrearNueva.addEventListener("click",validador_RFC);

              $('#nombreFiscalCliente').hide().val("");
              $('.rfc_input').show();
              $('#leyenda_filtro_cliente').html("R.F.C.:");
            }
      });

      //Consulta por cliente
      $('select#opcion_busqueda_cliente').on('change',function(){
          var valor = $(this).val();
          if (valor == "Buscar por R.F.C."){
            //Handler para el evento cuando cambia el input
            // -Lleva la RFC a mayúsculas para validarlo
            // -Elimina los espacios que pueda tener antes o después
          var validador_RFC_Obligatorio2 = function(e){
            var input = document.getElementById("rfc_input2");
            var rfc = input.value.trim().toUpperCase()
            var rfcCorrecto = rfcValido(rfc);   // ⬅️ Acá se comprueba
            var colorearRojo=document.getElementById("errorRFC2");
            if (!rfcCorrecto) {
              colorearRojo.className+=" has-error has-feedback";
              e.preventDefault();
            }
          };
            //Se pone a la escucha el sumit del formulario
            var facturarYCrearNueva=document.getElementById("RFC_Obligatorio2");
            facturarYCrearNueva.addEventListener("click",validador_RFC_Obligatorio2);

            $('.nombre_collection_select').hide().val("");
            $('.rfc_text_field').show().val("");

          }else if (valor == "Buscar por nombre fiscal") {
            $('#errorRFC2').removeClass(" has-error has-feedback");
            $('.nombre_collection_select').show().val("");
            $('.rfc_text_field').hide().val("");
          }

          //Ocultar cuando no este seleccionado ninguno
      });


      $('select#opcion_busqueda_cliente').on('change',function(){
            var valor = $(this).val();

            if (valor == "Buscar por R.F.C."){
              //Handler para el evento cuando cambia el input
              // -Lleva la RFC a mayúsculas para validarlo
              // -Elimina los espacios que pueda tener antes o después
            var validador_RFC_Obligatorio2 = function(e){
              var input = document.getElementById("rfc_input2");
              var rfc = input.value.trim().toUpperCase()
              var rfcCorrecto = rfcValido(rfc);   // ⬅️ Acá se comprueba
              var colorearRojo=document.getElementById("errorRFC2");

              if (!rfcCorrecto) {

                colorearRojo.className+=" has-error has-feedback";

                e.preventDefault();

              }

            };
            //Se pone a la escucha el sumit del formulario
            var facturarYCrearNueva=document.getElementById("RFC_Obligatorio2");
            facturarYCrearNueva.addEventListener("click",validador_RFC_Obligatorio2);

            $('.nombre_collection_select').hide().val("");
            $('.rfc_text_field').show().val("");

            }else if (valor == "Buscar por nombre fiscal") {
              $('#errorRFC2').removeClass(" has-error has-feedback");
              $('.nombre_collection_select').show().val("");
              $('.rfc_text_field').hide().val("");
            }
        //Ocultar cuando no este seleccionado ninguno
      });


      //Consulta avanzada
      $('select#condicion_monto_factura').on('change',function(){
          var valor = $(this).val();
          if (valor == "rango desde"){
            $('#monto_factura').show().val("");
            $('#monto_factura2').show().val("");
          }else{
            $('#monto_factura').show().val("");
            $('#monto_factura2').hide().val("");
          }
          //Ocultar cuando no este seleccionado ninguno
      });


      //Para la búsqueda por monto de
      $("#formFiltrosAvanzados").submit(function(e){

          if (condicion == "rango desde"){
            var monto_factura =  $("#monto_factura").val();
            var monto_factura2 = $("#monto_factura2").val();
            if (monto_factura2.length == 0 || monto_factura.length == 0){
            alert("valor"+ monto_factura+ "valor 2"+ monto_factura2);
              e.preventDefault();
            }

          }else{
            var monto_factura =  $("#monto_factura").val();

            if (monto_factura.length == 0){
            alert("valor"+ monto_factura);
              e.preventDefault();
            }
          }
      });

});
