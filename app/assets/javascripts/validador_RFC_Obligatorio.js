(function(){
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

        //Handler para el evento cuando cambia el input
        // -Lleva la RFC a mayúsculas para validarlo
        // -Elimina los espacios que pueda tener antes o después
      var validador_RFC_Obligatorio = function(e){
        var input = document.getElementById("rfc_input");
        var rfc = input.value.trim().toUpperCase()
        var rfcCorrecto = rfcValido(rfc);   // ⬅️ Acá se comprueba
        var colorearRojo=document.getElementById("errorRFC");

        if (!rfcCorrecto) {

          colorearRojo.className+=" has-error has-feedback";

          e.preventDefault();

        }

      };
        //Se pone a la escucha el sumit del formulario
        var facturarYCrearNueva=document.getElementById("RFC_Obligatorio");
        facturarYCrearNueva.addEventListener("click",validador_RFC_Obligatorio);

        var facturarAhora=document.getElementById("RFC_Obligatorio2");
        facturarAhora.addEventListener("click",validador_RFC_Obligatorio);

    }()
    )
