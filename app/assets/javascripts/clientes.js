(function(){

  var usarMismaDireccion =function(){
    //Variables para los valores de la diracción de residencia del cliente
    //var nombre = document.getElementById("nombre");
    var direccionCalle = document.getElementById("direccionCalle");
    var direccionNumeroExt = document.getElementById("direccionNumeroExt");
    var direccionNumeroInt = document.getElementById("direccionNumeroInt");
    var direccionColonia = document.getElementById("direccionColonia");
    var direccionMunicipio = document.getElementById("direccionMunicipio");
        //direccionDelegacion
    var direccionEstado = document.getElementById("direccionEstado");
    var direccionCp = document.getElementById("direccionCp");

  //Variables para los asignar la misma dirección para la dirección fiscal
    //var nombre = document.getElementById("nombre"); Chance y si se trata de persona física... y no de un fantasma :V jajaja
    var calle_f = document.getElementById("calle_f");
    var numExterior_f = document.getElementById( "numExterior_f");
    var numInterior_f = document.getElementById("numInterior_f");
    var colonia_f = document.getElementById("colonia_f");
    var municipio_f = document.getElementById("municipio_f");
        //direccionDelegacion
    var estado_f = document.getElementById("estado_f");
    var codigo_postal_f = document.getElementById("codigo_postal_f");

    calle_f.value = direccionCalle.value
    numExterior_f.value = direccionNumeroExt.value
    numInterior_f.value = direccionNumeroInt.value
    colonia_f.value = direccionColonia.value
    municipio_f.value = direccionMunicipio.value
    estado_f.value = direccionEstado.value
    codigo_postal_f.value = direccionCp.value

  };

  var btn_usarDireccion = document.getElementById("btn_usarDireccion");
  btn_usarDireccion.addEventListener("click",usarMismaDireccion);

}())
