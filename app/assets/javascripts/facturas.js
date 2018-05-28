$(document).ready(function(){
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



});
