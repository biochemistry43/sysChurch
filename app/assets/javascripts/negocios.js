
    function validarcertificado() {
     var archivo = document.getElementById("certificado").value;
     //mierror = ""
     if (archivo) {
       //Para detectar algun cambio
       var cambioVal = document.getElementById("certificado").onchange;
       extension_permitida = ".cer"
       extension = (archivo.substring(archivo.lastIndexOf("."))).toLowerCase();

       if (cambioVal) {
         if (extension_permitida != extension){
           mierror = "Sólo se pueden subir archivos con extensiones: " + extension_permitida;
           archivo.value = "";
           alert(mierror);
         }
       }
     }
   }
   //Valida llave
   function validarllave() {
    var archivo = document.getElementById("llave").value;
    //mierror = ""
    if (archivo) {
      //Para detectar algun cambio
      var cambioVal = document.getElementById("llave").onchange;
      extension_permitida = ".key"
      extension = (archivo.substring(archivo.lastIndexOf("."))).toLowerCase();

      if (cambioVal) {
        if (extension_permitida != extension){
          mierror = "Sólo se pueden subir archivos con extensiones: " + extension_permitida;
          archivo.value = "";
          alert(mierror);
        }
      }
    }
  }
