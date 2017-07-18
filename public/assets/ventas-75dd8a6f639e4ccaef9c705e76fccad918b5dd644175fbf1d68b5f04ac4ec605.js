$(document).ready(function(){
    $("#filtros_avanzados").click(function(e){
      if( $("#opciones_filtros_avanzados").is(":visible") ){
         $(this).html('Filtros Avanzados <i class="fa fa-sort-down"></i>');
      }
      else{
      	$(this).html('Filtros Avanzados <i class="fa fa-sort-up"></i>');
      }
      
      $("#opciones_filtros_avanzados").slideToggle("fast");

    });

    $("#filtro_por_clave").click(function(e){
      if( $("#opciones_filtros_por_clave").is(":visible") ){
         $(this).html('Filtros por clave <i class="fa fa-sort-down"></i>');
      }
      else{
      	$(this).html('Filtros por clave <i class="fa fa-sort-up"></i>');
      }
      
      $("#opciones_filtros_por_clave").slideToggle("fast");

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
});
