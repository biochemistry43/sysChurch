$(document).ready(function(){


    $("#filtro_por_fecha").click(function(e){
      if( $("#opciones_filtros_por_fecha").is(":visible") ){
         $(this).html('Filtros por fecha <i class="fa fa-sort-down"></i>');
      }
      else{
      	$(this).html('Filtros por fecha <i class="fa fa-sort-up"></i>');
      }

      $("#opciones_filtros_por_fecha").slideToggle("fast");

    });
});
