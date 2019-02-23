/**
 * Plugin  : Autocompletar con jQuery
 *   Autor : Lucas Forchino
 * WebSite : http://www.tutorialjquery.com
 * version : 1.0
 * Licencia: Pueden usar libremenete este código siempre y cuando no sea para 
 *           publicarlo como ejemplo de autocompletar en otro sitio.
 */


(function($){
    // Creo la funcion en el prototype de jQuery de manera de integrarla
    $.fn.autocomplete= function ()
    {
        //puede haber mas de un autocomplete que cargar por eso esto los levanta a todos
        $(this).each(function(){
            
            
            // aplico los estilos a los elementos elegidos
            $(this).addClass('autocomplete-jquery-aBox');
            
            
            // guardo en una variable una nueva funcion que asigna el texto del 
            // link que paso en that al input donde escribimos.
            // esto seleccionaria el link del cuadro autocompletar
            var selectItem = function(that)
            {

                //console.log(that);
                //console.log($(that));
                // partiendo del link busco el input y le asigno el valor del link
                $(that).parent().parent().find('input').val("");
                addProduct($(that).attr("id"));
                 $(that).parent().parent().find('input').focus();
                // remuevo el cuadro de autocompletar, se supone si ya seleccionaste
                // un valor no se necesita mas
                $(that).parent().remove();
                                    
            }
            // busco el input y le asigno un evento al presionar una tecla
            $(this).find('input').bind('keyup',function(event){
                var input = $(this);

                //6514645

                //Si se borra todo el contenido del cuadro de búsqueda, se remueve
                //el cuadro de resultados.
                /*if(input.val()==""){
                   input.parent().find('.autocomplete-jquery-results').remove();
                }*/
                
                // codigo de la tecla persionada
                var code=event.keyCode;
                // si es Enter => seleccionar el link marcado 
                if ((code==13) )//&& $('.autocomplete-jquery-mark').length > 0)
                {

                    var criteria = $("#search-product").val();

                    if(window.location.pathname == "/punto_venta"){
                       urlCorrecta = "/articulos/showByCriteriaForPos/" + criteria;
                    }
                    else{
                       urlCorrecta = "/articulos/showByCriteria/" + criteria;   
                    }


                    if(criteria == ""){
                        $("#list-search-products").empty();
                    }
                    else{
                        $.ajax({
                            url: urlCorrecta,
                            dataType: "JSON",
                            timeout: 10000,
                            beforeSend: function(){
                               //$("#respuesta").html("Cargando...");
                            },
                            error: function(){
                                //alert("error");
                               //$("#respuesta").html("Error al intentar buscar el empleado. Por favor intente más tarde.");
                               
                            },
                            
                            success: function(data){

                                if (data.length > 0) {
                                    
                                    for(index in data)
                                    {


                                        console.log("el id del producto es: " + data[index].id);

                                        addProduct(data[index].id);
                                        //agrego un link por resultado
                                        /*if(data.hasOwnProperty(index))
                                            {
                                                var a = $('<a>');
                                                a.html(data[index].nombre);
                                                a.addClass('autocomplete-jquery-item');
                                                var widthFixed=width - 3;
                                                a.css({'width':widthFixed});
                                                a.attr("id",  data[index].id);
                                                if(data[index].existencia == 0){
                                                    a.addClass('autocomplete-jquery-item-inexistence');
                                                }
                                                a.click(function(){
                                                  // funcion que pone el texto en input
                                                  selectItem(this);
                                                })
                                                
                                                a.attr('data-id',index);
                                                $(result).append(a);
                                            }*/
                                    }
                                    /*if (data.length>0)
                                    {
                                        input.parent().append(result);
                                        result.fadeIn('fast');
                                    }*/
                                }
                                
                            }
                         });
                      }

                    /*console.log("código: " + code);
                    var element = input.parent().find('.autocomplete-jquery-results').find("a");
                    console.log("element" + element);
                    setTimeout(
                      function() 
                      {
                        console.log("cargando")
                      }, 500);
                    selectItem(element);*/
                }
                // si son las flechas => moverse por los links
                /*else if(code==40 || code ==38)
                {
                    elements =$('.autocomplete-jquery-results').find('a');
                    var mark =0;
                    if ($('.autocomplete-jquery-mark').size()>0){
                        mark=$('.autocomplete-jquery-mark').attr('data-id');
                        $('.autocomplete-jquery-mark').removeClass('autocomplete-jquery-mark');
                             
                        if (code==38){
                            mark --;
                        }else{
                            mark ++;
                        }
                             
                        if (mark > elements.size()){
                            mark=0;
                        }else if (mark < 0){
                            mark=elements.size();
                        }
                             
                             
                    }
                    elements.each(function(){
                        if ($(this).attr('data-id')==mark)
                        {
                            $(this).addClass('autocomplete-jquery-mark');
                        }
                    });                             
                           
                }*/
                
                // si es una letra o caracter, ejecutar el autocompletar
                // con este filtro solo toma caracteres para la busqueda
                /*else if((code>47 && code<91)||(code>96 && code<123) || code ==8 )
                {
                    // si presiono me fijo si hay resultados para lo que tengo 
                    // tomo la url
                    var url = input.attr('data-source');
                    // tomo el valor del combo actualmente
                    var value = input.val();
                    url+=value;
                    //busco en el server la info 

                    var urlCorrecta = ""
                    
                    

                    var criteria = $("#search-product").val();

                    if(window.location.pathname == "/punto_venta"){
                       urlCorrecta = "/articulos/showByCriteriaForPos/" + criteria;
                    }
                    else{
                       urlCorrecta = "/articulos/showByCriteria/" + criteria;   
                    }


                      if(criteria == ""){
                         $("#list-search-products").empty();
                      }
                      else{
                         $.ajax({
                            url: urlCorrecta,
                            dataType: "JSON",
                            timeout: 10000,
                            beforeSend: function(){
                               //$("#respuesta").html("Cargando...");
                            },
                            error: function(){
                                //alert("error");
                               //$("#respuesta").html("Error al intentar buscar el empleado. Por favor intente más tarde.");
                               
                            },
                            
                            success: function(data){

                                if (data.length > 0) {
                                    //
                                    // si encontro algo 
                                    // creo un cuadro debajo del input con los resultados
                                    input.parent().find('.autocomplete-jquery-results').remove();
                                    var left = input.position().left;
                                    var width= input.width();
                                    var result=$('<div>');
                                    // le damos algunos estilos al combo 
                                    result.css({'width':width});
                                    result.css({'left':left});
                                    
                                    
                                    result.addClass('autocomplete-jquery-results');
                                    for(index in data)
                                    {
                                        //agrego un link por resultado
                                        if(data.hasOwnProperty(index))
                                            {
                                                var a = $('<a>');
                                                a.html(data[index].nombre);
                                                a.addClass('autocomplete-jquery-item');
                                                var widthFixed=width - 3;
                                                a.css({'width':widthFixed});
                                                a.attr("id",  data[index].id);
                                                if(data[index].existencia == 0){
                                                    a.addClass('autocomplete-jquery-item-inexistence');
                                                }
                                                a.click(function(){
                                                  // funcion que pone el texto en input
                                                  selectItem(this);
                                                })
                                                
                                                a.attr('data-id',index);
                                                $(result).append(a);
                                            }
                                    }
                                    if (data.length>0)
                                    {
                                        input.parent().append(result);
                                        result.fadeIn('fast');
                                    }
                                }
                                
                            }
                         });
                      }*/


                    //$.getJSON(url,{}, function(data){
                        // si encontro algo 
                        // creo un cuadro debajo del input con los resultados
                       /*/ input.parent().find('.autocomplete-jquery-results').remove();
                        var left = input.position().left;
                        var width= input.width();
                        var result=$('<div>');*/
                        // le damos algunos estilos al combo 
                       /* result.css({'width':width});
                        result.css({'left':left});
                        
                        
                        result.addClass('autocomplete-jquery-results');
                        for(index in data)
                        {*/
                            //agrego un link por resultado
                            /*if(data.hasOwnProperty(index))
                                {
                                    var a = $('<a>');
                                    a.html(data[index]);
                                    a.addClass('autocomplete-jquery-item');
                                    var widthFixed=width - 3;
                                    a.css({'width':widthFixed});
                                    a.attr('href',"#");

                                    a.click(function(){*/
                                        // funcion que pone el texto en input
                                       /* selectItem(this);
                                    })
                                    a.attr('data-id',index);
                                    $(result).append(a);
                                }*/
                        /*}
                        if (data.length>0)
                        {
                            input.parent().append(result);
                            result.fadeIn('slow');
                        }*/
                   /* });*/
                //}
            });
        });
    }
})(jQuery);
