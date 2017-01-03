$(document).ready(function(){
   

   $("#search-product" ).keyup(function() {
   	  var criteria = $("#search-product").val();
   	  if(criteria == ""){
         $("#list-search-products").empty();
   	  }
   	  else{
   	  	 $.ajax({
	        url: "/articulos/showByCriteria/" + criteria,
	        dataType: "JSON",
	        timeout: 10000,
	        beforeSend: function(){
	           //$("#respuesta").html("Cargando...");
	        },
	        error: function(){
	        	//alert("error");
	           //$("#respuesta").html("Error al intentar buscar el empleado. Por favor intente más tarde.");
	           
	        },
	        success: function(res){
	           if(res){
	           	  $("#list-search-products").empty();
	              var resLength = res.length;
	              for (i = 0; i < resLength; i++) {
	              //text += "<li>" + fruits[i] + "</li>";
	                 var element = res[i];
	                 $("#list-search-products").append("<li id='found-product' class='list-group-item list-group-item-success'>"+element.clave+"&nbsp &nbsp &nbsp"+element.nombre+"<button id='"+element.clave+"' onclick='addProductToSale(this)'>agregar</button></li>");
	              }
	              
	           }else{
	           	  $("#list-search-products").empty();
	              //alert("fallo success")
	           }
	        }
	     })
   	  }
   });	
});

function addProductToSale(elem){
  $.ajax({
    url: "/articulos/showByCriteria/" + elem.id,
    dataType: "JSON",
    timeout: 10000,
    beforeSend: function(){
    //$("#respuesta").html("Cargando...");
    },
    error: function(){
      //alert("error");
      //$("#respuesta").html("Error al intentar buscar el empleado. Por favor intente más tarde.");
             
    },
    success: function(res){
/*<tr class="even pointer">
                  <!--<td class="a-center ">
                    <input type="checkbox" class="flat" name="table_records">
                  </td>-->
                   
                  <!--ejemplo de como agregar datos a esta tabla
                  <td class=" ">121000040</td>
                  <td class=" ">May 23, 2014 11:47:56 PM </td>
                  <td class=" ">121000210 <i class="success fa fa-long-arrow-up"></i></td>
                  <td class=" ">John Blank L</td>
                  <td class="a-right a-right ">$7.45</td>-->


                  <!--<td class=" last"><a href="#">View</a>
                  </td>-->
                </tr>*/
      if(res){
        var resLength = res.length;
        for(i=0; i < resLength; i++){
           var element = res[i];
           $("#table-sales").append("<tr class='even pointer'><td>"+element.clave+"</td></tr>");
        }

        
          /*var resLength = res.length;
          for (i = 0; i < resLength; i++) {*/
           //text += "<li>" + fruits[i] + "</li>";*/
           /* var element = res[i];
              $("#list-search-products").append("<li id='found-product' class='list-group-item list-group-item-success'>"+element.clave+"&nbsp &nbsp &nbsp"+element.nombre+"<button id='"+element.clave+"' onclick='addProductToSale(this)'>agregar</button></li>");
            }*/
              
      }else{
        //$("#list-search-products").empty();
      }
    }
  })

  alert(elem.id);
}


/*function buscarPorLegajo(){
   $("#boton_buscar").click(function(){
     var legajo = $("#legajo").val();
     $.ajax({
        url: "/empleados/buscar_por_legajo/" + legajo,
        dataType: "JSON",
        timeout: 10000,
        beforeSend: function(){
           $("#respuesta").html("Cargando...");
        },
        error: function(){
           $("#respuesta").html("Error al intentar buscar el empleado. Por favor intente más tarde.");
        },
        success: function(res){
           if(res){
              $("#respuesta").html('<a href="/empleados/'+res.id+'"> '+res.nombre+' ' + res.apellido + ' </a>');
           }else{
              $("#respuesta").html("El legajo no le pertenece a ningún empleado.");
           }
        }
     })
  });
};
$(document).ready(function(){
   buscarPorLegajo();
});*/

