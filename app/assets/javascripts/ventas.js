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
});
