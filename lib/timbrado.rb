module Timbox
  #Servicios web de Timbox
  class Servicios
    USERNAME = Rails.application.secrets.timbox_username
    PASSWORD = Rails.application.secrets.timbox_password

    WSDL_TIMBRADO = Rails.application.secrets.wsdl_timbrado
    WSDL_CANCELACION = Rails.application.secrets.wsdl_cancelacion
    #Todas las urls de timbox son del ambiiente de pruebas(se deben de canbiar al pasar a producción)
    require 'byebug'
    #Al 100%
    def timbrar_xml(xml_base64)
      # Generar el Envelope
      wsdl_url = Rails.application.secrets.wsdl_timbrar_xml

      envelope = %Q^
        <soapenv:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:urn=\"urn:WashOut\">
          <soapenv:Header/>
          <soapenv:Body>
            <urn:timbrar_cfdi soapenv:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">
              <username xsi:type=\"xsd:string\">#{USERNAME}</username>
              <password xsi:type=\"xsd:string\">#{PASSWORD}</password>
              <sxml xsi:type=\"xsd:string\">##{xml_base64}</sxml>
          </urn:timbrar_cfdi>
          </soapenv:Body>
        </soapenv:Envelope>^

      # Crear un cliente de savon para hacer la petición al WS, en produccion quitar el "log: true"
      client = Savon.client(wsdl: WSDL_TIMBRADO, log: true)

      # Llamar el metodo timbrar
      response = client.call(:timbrar_cfdi, { "xml" => envelope })

      # Extraer el xml timbrado desde la respuesta del WS
      response = response.to_hash
      xml_timbrado = response[:timbrar_cfdi_response][:timbrar_cfdi_result][:xml]#xml sin alteraciones listo para entregar al cliente.

      return document = Nokogiri::XML(xml_timbrado)
    end

    #El servicio “recuperar_comprobante” puede ser utilizado para recuperar uno o varios comprobantes completos (xml) usando los UUIDs. Se necesita de un usuario y contraseña para utilizar el servicio.
    def recuperar_cfdi(username, password, uuids)
      #username  Usuario del web service Sí
      #password  Contraseña del webservice Sí
      #uuids Similar al servicio de cancelación de comprobantes, se manda un arreglo de UUIDs para recuperar. Los UUIDs deben cumplir con la expresión regular para ser considerados en la búsqueda, si no, se regresa un error. Sí
      envelope = 
        %Q^<soapenv:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:WashOut">
           <soapenv:Header/>
           <soapenv:Body>
              <urn:recuperar_comprobante soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
                <username xsi:type="xsd:string">#{username}</username>
                <password xsi:type="xsd:string">#{password}</password>
                <uuids xsi:type="urn:uuid">
                   
                </uuids>
              </urn:recuperar_comprobante>
           </soapenv:Body>
        </soapenv:Envelope>^
      #<uuid xsi:type="xsd:string">{uuid}</uuid>
      client = Savon.client(wsdl: "https://staging.ws.timbox.com.mx/timbrado_cfdi33/wsdl", log: true)
      # Hacer el llamado al metodo cancelar_cfdi
      response = client.call(:recuperar_comprobante, { "xml" => envelope })
      documento = Nokogiri::XML(response.to_xml)

    end

    def buscar_acuses_recepcion(username, password,uuids)#*fecha_timbrado_inicio,*fecha_timbrado_fin)
      #username  Usuario del webservice    Sí
      #password  Contraseña del webservice   Sí
      #parametros_acuse
      #Es un parámetro definido para contener los diferentes filtros que desea usar. Si omite este parámetro el servicio regresará un error de estructura. Sí
      #uuids Se manda un arreglo de uno o más UUIDs que se desean cancelar. Los UUIDs deben cumplir con la expresión regular de UUIDs. El valor del UUID debe ser válido, si no ingresa valor en la etiqueta se validará contra la expresión regular de UUID. Si ingresa un valor en UUID no debe registrar los parámetros de fechas.  No
      #fecha_timbrado_inicio Fecha de timbrado inicial que desea consultar. La fecha debe cumplir con el formato YYYY-MM-DD o YYYY-MM-DDTHH:MM:SS  Si ingresa valor en este parámetro debe agregar fecha_timbrado_fin y no registrar UUID. No
      #fecha_timbrado_fin  Fecha de timbrado final que desea consultar. La fecha debe cumplir con el formato YYYY-MM-DD o YYYY-MM-DDTHH:MM:SS  Si ingresa valor en este parámetro debe agregar fecha_timbrado_inicio y no registrar UUID.  No
      envelope = 
        %Q^<soapenv:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:WashOut">
          <soapenv:Header/>
          <soapenv:Body>
              <urn:buscar_acuse_recepcion soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
                 <username xsi:type="xsd:string">#{username}</username>
                 <password xsi:type="xsd:string">#{password}</password>
                 <parametros_acuse xsi:type="urn:parametros_acuse">
                    #{uuids unless uuids.empty?}
                 </parametros_acuse>
              </urn:buscar_acuse_recepcion>
          </soapenv:Body>
        </soapenv:Envelope>^

        #<uuids xsi:type="urn:uuid">
          #<!--Zero or more repetitions:-->
          #<uuid>#{uuid}</uuid>
        #</uuids>
        #<fecha_timbrado_inicio xsi:type="xsd:string">#{fecha_timbrado_inicio}</f#echa_timbrado_inicio>
        #<fecha_timbrado_fin xsi:type="xsd:string">#{fecha_timbrado_fin}</fecha_timbrado_fin>

#
      #xml_timbrado = response[:buscar_acuse_recepcion][:timbrar_cfdi_result][:xml]#xml sin alteraciones listo para entregar al cliente.

      #return document = Nokogiri::XML(xml_timbrado)

      #documento = Nokogiri::XML(response.to_xml)
    end


    #Función para obtener el consumo de timbres e información del plan de Timbox
    def obtener_consumo(usuario, contrasena)
      envelope = %Q^
      <soapenv:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:WashOut">
         <soapenv:Header/>
         <soapenv:Body>
            <urn:obtener_consumo soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
               <username xsi:type="xsd:string">usuario</username>
               <password xsi:type="xsd:string">password</password>
            </urn:obtener_consumo>
         </soapenv:Body>
      </soapenv:Envelope>^
    end

    #El servicio de “consulta_rfc” puede ser utilizado para verificar si existe un RFC en la lista de RFCs inscritos no cancelados del SAT y si sí existe, se muestra información del mismo. Se necesita de un usuario y contraseña para utilizar el servicio.
    def consultar_rfc (username, password, rfc)
=begin
      Nombre  Descripción Requerido
      username  Usuario del web service Sí
      password  Contraseña del webservice Sí
      rfc RFC que se desea consultar, este debe cumplir con el regex:
      /[A-Z&Ñ]{3,4}[0-9]{2}(0[1-9]|1[012])(0[1-9]|[12][0-9]|3[01])[A-Z0-9]{2}[0-9A]/ Sí
=end
      envelope = %Q^
        <soapenv:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:WashOut">
           <soapenv:Header/>
           <soapenv:Body>
              <urn:consulta_rfc soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
                 <username xsi:type="xsd:string">#{username}</username>
                 <password xsi:type="xsd:string">#{password}</password>
                 <rfc xsi:type="xsd:string">#{rfc}</rfc>
              </urn:consulta_rfc>
           </soapenv:Body>
        </soapenv:Envelope>^

      # Crear un cliente de savon para hacer la conexión al WS, en produccion quital el "log: true"
      client = Savon.client(wsdl: "https://staging.ws.timbox.com.mx/timbrado_cfdi33/wsdl", log: true)
      # Hacer el llamado al metodo cancelar_cfdi
      response = client.call(:consulta_rfc, { "xml" => envelope })
      documento = Nokogiri::XML(response.to_xml)
    end

    #-------------------------------------------------------------------------------------------------------------------------
    #Al 100%
    #El servicio de “cancelar_cfdi” se utiliza para cancelar uno o varios comprobantes que ya fueron timbrados. Se requiere de usuario y contraseña para utilizar el servicio.
    def cancelar_CFDIs (username, password, rfc_emisor, folios, cert_pem, llave_pem, llave_password)
=begin
      username  Usuario del webservice. Sí
      password  Contraseña del webservice.  Sí
      rfc_emisor  El rfc que emitió el comprobante que desea cancelar.  Sí
      folios  Se manda un arreglo con uno o más objetos tipo folio, el cual debe contener los elementos UUID, rfcreceptor y total.  Sí
      cert_pem  El certificado, en formato pem, que corresponde al emisor del comprobante.  Sí
      llave_pem La llave, en formato pem, que corresponde al emisor del comprobante.  Sí
      llave_password  La contraseña de la llave_pem.  Sí
=end
     envelope = %Q^
      <soapenv:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:WashOut">
        <soapenv:Header/>
        <soapenv:Body>
          <urn:cancelar_cfdi soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
            <username xsi:type="xsd:string">#{username}</username>
            <password xsi:type="xsd:string">#{password}</password>
            <rfc_emisor xsi:type="xsd:string">#{rfc_emisor}</rfc_emisor>
            <folios xsi:type="urn:folios">#{folios}</folios>
            <cert_pem xsi:type="xsd:string">#{cert_pem}</cert_pem>
            <llave_pem xsi:type="xsd:string">#{llave_pem}</llave_pem>
            <llave_password xsi:type="xsd:string">#{llave_password}</llave_password>
          </urn:cancelar_cfdi>
        </soapenv:Body>
      </soapenv:Envelope>^   

      client = Savon.client(wsdl: "https://staging.ws.timbox.com.mx/cancelacion/wsdl", log: true)
      # Hacer el llamado al metodo cancelar_cfdi
      response = client.call(:cancelar_cfdi, { "xml" => envelope })
      documento = Nokogiri::XML(response.to_xml)
      # Obenter el acuse de cancelación
      #acuse = documento.xpath("//acuse_cancelacion").text
      #puts acuse

      # Obtener los estatus de los comprobantes cancelados
      #uuids_cancelados = documento.xpath("//comprobantes_cancelados").text
      #puts uuids_cancelados   
    end

    #El servicio de “consultar_estatus” se utiliza para la consulta del estatus del CFDI, este servicio pretende proveer una forma alternativa de consulta que requiera verificar el estado de un comprobante en bases de datos del SAT. Los parámetros que se requieren en la consulta se describen en la siguiente tabla.
    def consultar_estatus (username, password, rfc_emisor, rfc_receptor, uuid, total)
=begin
    Parametros para la consulta de status
      username  Usuario del webservice. Sí
      password  Contraseña del webservice.  Sí
      rfc_emisor  El RFC que emitió el comprobante que desea consultar. Sí
      rfc_receptor  El RFC del receptor del comprobante que desea consultar.  Sí
      uuid  Se manda el UUID del comprobante que se desea consultar. El UUID debe cumplir con la expresión regular de UUIDs.  Sí
      total Total del comprobante Sí
=end
       envelope = %Q^
        <soapenv:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:WashOut">
         <soapenv:Header/>
         <soapenv:Body>
            <urn:consultar_estatus soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
               <username xsi:type="xsd:string">#{username}</username>
               <password xsi:type="xsd:string">#{password}</password>
               <uuid xsi:type="xsd:string">#{uuid}</uuid>
               <rfc_emisor xsi:type="xsd:string">#{rfc_emisor}</rfc_emisor>
               <rfc_receptor xsi:type="xsd:string">#{rfc_receptor}</rfc_receptor>
               <total xsi:type="xsd:string">#{total}</total>
            </urn:consultar_estatus>
         </soapenv:Body>
      </soapenv:Envelope>^

      client = Savon.client(wsdl: "https://staging.ws.timbox.com.mx/cancelacion/wsdl", log: true)
      # Hacer el llamado al metodo 'consultar_status'
      response = client.call(:consultar_estatus, { "xml" => envelope })
      documento = Nokogiri::XML(response.to_xml)   
    end

    #El servicio de “consultar_documento_relacionado” se utiliza para realizar la consulta al servicio del SAT para revisar si el documento a consultar tiene documentos relacionados.
    def consultar_documento_relacionado(username, password, rfc_receptor, uuid, cert_pem, llave_pem, llave_password)
=begin
      username  Usuario del webservice  Sí
      password  Contraseña del webservice Sí
      rfc_receptor  El rfc que emitió el comprobante que desea cancelar.  Sí
      uuid  Se manda el UUID del comprobante que se desea consultar. El UUID debe cumplir con la expresión regular de UUIDs.  Sí
      cert_pem  El certificado, en formato pem, que corresponde al emisor del comprobante.  Sí
      llave_pem La llave, en formato pem, que corresponde al emisor del comprobante.  Sí
      llave_password  La contraseña de la llave_pem.  Sí
=end
      envelope = %Q^
        <soapenv:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:WashOut">
         <soapenv:Header/>
         <soapenv:Body>
           <urn:consultar_documento_relacionado soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
             <username xsi:type="xsd:string">#{username}</username>
             <password xsi:type="xsd:string">#{password}</password> 
             <uuid xsi:type="xsd:string">#{uuid}</uuid>
             <rfc_receptor xsi:type="xsd:string">#{rfc_receptor}</rfc_receptor>
             <cert_pem xsi:type="xsd:string">#{cert_pem}</cert_pem>
             <llave_pem xsi:type="xsd:string">#{llave_pem}</llave_pem>
             <llave_password xsi:type="xsd:string">#{llave_password}</llave_password>
           </urn:consultar_documento_relacionado>
         </soapenv:Body>
        </soapenv:Envelope>^

        #client = Savon.client(wsdl: "https://staging.ws.timbox.com.mx/cancelacion/wsdl", log: true)
        # Hacer el llamado al metodo 'consultar_status'
        #response = client.call(:consultar_documento_relacionado, { "xml" => envelope })
        #documento = Nokogiri::XML(response.to_xml) 
        client = Savon.client(wsdl: "https://staging.ws.timbox.com.mx/cancelacion/wsdl", log: true)
        response = client.call(:consultar_documento_relacionado, { "xml" => envelope })
        response = response.to_hash
    end

    #El servicio de “consultar_peticiones_pendientes” se utiliza para realizar la consulta al servicio del SAT para revisar las peticiones que se encuentran en espera de una respuesta por parte del Receptor. Los parámetros requeridos para realizar la petición se describen en la siguiente tabla.
    def consultar_peticiones_pendientes (username, password, rfc_receptor, cert_pem, llave_pem, llave_password)
=begin
      Parámetros de la petición:
      Nombre  Descripción Requerido
      username  Usuario del webservice. Sí
      password  Contraseña del webservice.  Sí
      rfc_receptor  El RFC que recibió el comprobante que desea cancelar. Sí
      cert_pem  El certificado, en formato pem, que corresponde al emisor del comprobante.  Sí
      llave_pem La llave, en formato pem, que corresponde al emisor del comprobante.  Sí
      llave_password  La contraseña de la llave_pem.  Sí
=end
      envelope = %Q^
        <soapenv:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:WashOut">
           <soapenv:Header/>
           <soapenv:Body>
              <urn:consultar_peticiones_pendientes soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
                <username xsi:type="xsd:string">#{username}</username>
                <password xsi:type="xsd:string">#{password}</password>
                <rfc_receptor xsi:type="xsd:string">#{rfc_receptor}</rfc_receptor>
                <cert_pem xsi:type="xsd:string">#{cert_pem}</cert_pem>
                <llave_pem xsi:type="xsd:string">#{llave_pem}</llave_pem>
                <llave_password xsi:type="xsd:string">#{llave_password}</llave_password>
              </urn:consultar_peticiones_pendientes>
           </soapenv:Body>
        </soapenv:Envelope>^

        client = Savon.client(wsdl: "https://staging.ws.timbox.com.mx/cancelacion/wsdl", log: true)
        # Hacer el llamado al metodo 'consultar_status'
        response = client.call(:consultar_peticiones_pendientes, { "xml" => envelope })
        documento = Nokogiri::XML(response.to_xml) 
    end


    def procesar_respuesta (username, password, rfc_receptor, respuestas, cert_pem, llave_pem, llave_password)
=begin
      Petición al servicio
      El servicio de “procesar_respuesta” se utiliza para realizar la petición de aceptación/rechazo de la solicitud de cancelación que se encuentra en espera de dicha resolución por parte del receptor del documento al servicio del SAT. Los parámetros requeridos para realizar la petición se describen en la siguiente tabla.

      Parámetros de la petición:
      Nombre  Descripción Requerido
      username  Usuario del webservice. Sí
      password  Contraseña del webservice.  Sí
      rfc_receptor  El rfc que recibió el comprobante que desea cancelar. Sí
      respuestas  Se manda el arreglo con uno o más objetos del tipo folios_respuestas que se compone del UUID, el RFC Emisor, el Total y la Respuesta (Aceptación o Rechazo). El UUID debe cumplir con la expresión regular de UUIDs.  Sí
      cert_pem  El certificado, en formato pem, que corresponde al emisor del comprobante.  Sí

      Parámetros del nodo respuestas:
      Nombre  Descripción Requerido
      uuid  Folio del comprobante que se va aceptar o rechazar para su cancelación  Sí
      rfc_emisor  RFC del emisor del comprobante a cancelar Sí
      total Total del comprobante a cancelar  Sí
      respuesta Parámetro a enviar para aceptar la solicitud de cancelación. Deberá agregar:
        A – Aceptar la solicitud
        R – Rechazar la solicitud
=end

    #Creo q a los señores de Timbox se les olvidaron agregar dos parametros(llave_pem y llave_password)
      envelope = %Q^
        <soapenv:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:WashOut">
           <soapenv:Header/>
           <soapenv:Body>
              <urn:procesar_respuesta soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
                 <username xsi:type="xsd:string">#{username}</username>
                 <password xsi:type="xsd:string">#{password}</password>
                 <rfc_receptor xsi:type="xsd:string">#{rfc_receptor}</rfc_receptor>
                 <respuestas xsi:type="urn:respuestas">#{respuestas}</respuestas>
                 <cert_pem xsi:type="xsd:string">#{cert_pem}</cert_pem>
                 <llave_pem xsi:type="xsd:string">#{llave_pem}</llave_pem>
                 <llave_password xsi:type="xsd:string">#{llave_password}</llave_password>
              </urn:procesar_respuesta>
           </soapenv:Body>
        </soapenv:Envelope>^

        client = Savon.client(wsdl: "https://staging.ws.timbox.com.mx/cancelacion/wsdl", log: true)
        # Hacer el llamado al metodo 'consultar_status'
        #response = client.call(:procesar_respuesta, { "xml" => envelope })
        #documento = Nokogiri::XML(response.to_xml) 

        response = client.call(:procesar_respuesta, { "xml" => envelope })
        response = response.to_hash
      end
    end

  class Errores

    # =>  Errores de validación (Timbrado)s

    # =>  Errores de validación (Servicio de cancelación)
    ERRORES_CANCELADO = {
      'CANC101' => 'El CFDI no se puede cancelar porque contiene relacionado el complemento de pagos.',
      'CANC102' => 'El CFDI no se puede cancelar porque contiene comprobantes relacionados vigentes, para cancelarlo deberá cancelar previamente todos los comprobantes relacionados.',
      'CANC103' => 'El CFDI ha sido cancelado previamente por aceptación del receptor.',
      'CANC104' => 'El CFDI no se puede cancelar, porque fue rechazado previamente.',
      'CANC105' => 'El CFDI no se puede cancelar porque tiene estatus de “En espera de aceptación”.',
      'CANC106' => 'El CFDI no se puede cancelar porque tiene estatus de “En proceso”.',
      'CANC107' => 'El CFDI ha sido cancelado previamente por plazo vencido',
    }

    ERRORES_CONSULTA_ESTATUS = {
      'N 601' => 'La expresión impresa proporcionada no es válida', #Este código de respuesta se presentará cuando la petición de validación no se haya respetado en el formato definido.
      'N 602' => 'Comprobante no encontrado', #Este código de respuesta se presentará cuando el UUID del comprobante no se encuentre en la Base de Datos del SAT.
      'S' => 'Comprobante obtenido satisfactoriamente' #Este código se presentará cuando el UUID del comprobante se encuentre en la Base de Datos del SAT
    }

    ERRORES_CONSULTA_DOCUMENTO_RELACIONADO = {
      '2000' => 'Existen cfdi relacionados al folio fiscal.',  #Este código de respuesta se presentará cuando la petición de consulta encuentre documentos relacionados al UUID consultado.
      '2001' => 'No existen cfdi relacionados al folio fiscal.', #Este código de respuesta se presentará cuando el UUID consultado no contenga documentos relacionados a el.
      '2002' => 'El folio fiscal no pertenece al receptor.', #Este código de respuesta se presentará cuando el RFC del receptor no corresponda al UUID consultado.
      '1101' => 'No existen peticiones para el RFC Receptor.' #Este código se regresa cuando la consulta se realizó de manera exitosa, pero no se encontraron solicitudes de cancelación para el rfc receptor.
    }

    ERRORES_CONSULTA_PETICIONES_PENDIENTES = {
      '300' => 'Usuario No Válido.',  
      '301' => 'XML Mal Formado.',  #Este código de error se regresa cuando el request contiene información inválida, por ejemplo: un RFC de receptor no válido.
      '1100' => 'Se obtuvieron las peticiones del RFC Receptor de forma exitosa.', 
      '1101' => 'No existen peticiones para el RFC Receptor.', #Este código se regresa cuando la consulta se realizó de manera exitosa, pero no se encontraron solicitudes de cancelación para el rfc receptor.
    }

    ERRORES_PROCESADO_RESPUESTA = {
      #Mensajes recibidos
      '300' => 'Usuario No Válido.',  
      '301' => 'XML Mal Formado.',  #Este código de error se regresa cuando el request posee información inválida, ejemplo: un RFC de receptor no válido.
      '302' => 'Sello Mal Formado.',  
      '304' => 'Certificado Revocado o Caduco.',  #El certificado puede ser inválido por múltiples razones como son el tipo, la vigencia, etc.
      '305' => 'Certificado Inválido.', #El certificado puede ser inválido por múltiples razones como son el tipo, la vigencia, etc.
      '309' => 'Padrón de Folio Inválido.', #El padrón de folios para registro fiscal no coincide. Aplicable únicamente a cancelaciones de CFDI de RIF.
      '310' => 'CSD Inválido.', 
      '1000' => 'Se recibió la respuesta de la petición de forma exitosa.',  
      '1001' => 'No existen peticiones de cancelación en espera de respuesta para el uuid.', #Se recibió la respuesta de forma exitosa, sin embargo, no se encontró ninguna solicitud de cancelación pendiente.
      '1002' => 'Ya se recibió una respuesta para la petición de cancelación del uuid.', 
      '1003' => 'Sello No Corresponde al RFC Receptor.', 
      '1004' => 'Existen más de una petición de cancelación para el mismo uuid.', 
      '1005' => 'El uuid es nulo no posee el formato correcto.',
      '1006' => 'Se rebaso el número máximo de solicitudes permitidas.', #Se cuenta con un límite de 500 solicitudes pendientes por petición. Estas 500 solicitudes deben pertenecer al mismo Receptor
      #Errores de validación
      'CANC108' => 'El CFDI ha sido cancelado previamente por plazo vencido, no puede ser aceptado.',
      'CANC109' => 'El CFDI ha sido cancelado previamente, no puede ser aceptado.',
      'CANC110' => 'El CFDI ha sido cancelado previamente por plazo vencido, no puede ser rechazado.',
      'CANC111' => 'El CFDI ha sido cancelado previamente, no puede ser rechazado'
    }


    ERRORES_VARIOS = {
      '404' => 'Los datos de autentificación enviados son incorrectos', # El campo Username y Password no coinciden Todos
      '405' => 'El parametro xml debe contener un valor válido', #  El parametro xml que envio tiene estructura invalida o viene vacio  servicios de timbrado
      '405' => 'La codificación del XML no esta en UTF-8',    #servicios de timbrado
      '408' => 'Su plan a caducado, favor de contratar uno nuevo',  #El plan contratado caducó timbrado y cancelación
      '408' => 'Se han agotado la cantidad de timbres, favor de contratar un nuevo plan', #Se agotaron los timbres de su plan  timbrado y cancelación
      '406' => 'Parámetro x inválido', # Uno de los parametros que envío tiene estructura inválida o viene vacío servicios de cancelación
      '410' => 'Problema con el PFX', #   No se pudo abrir el archivo PFX, posiblemente está corrupto o no se generó bien el PFX  cancelar_cfdi
      '410' => 'No se ha podido obtener el la clave privada del usuario para firmar la cancelación', #  No se incluyó la llave privada en el archivo PFX  cancelar_cfdi
      '410' => 'Password Invalido para este PFX', # La contraseña utilizada no corresponde con la del PFX cancelar_cfdi
      '410' => 'Al decodificar el PFX se encontro que este no es archivo PFX válido', # El PFX en base64 no corresponde a un PFX válido cancelar_cfdi
      '701' => 'La llave_pem es una llave invalida', # La llave_pem está corrupta  
      '702' => 'Error en el certificado, el certificado es inválido', #El pem del certificado no corresponde a uno válido  cancelar_cfdi_certs
      '703' => 'Hay 500 o más UUIDS en una sola petición', # Se incluyeron más de 500 uuids para cancelar  cancelar_cfdi_certs
      '407' => 'Error de comunicación con el servicio de x',  #Hubo un error de timeout, interno o de comunicación con el SAT, intente denuevo (aplica para todos los servicios) Todos
      '2000' => 'Por el momento solo se acepta 1 comprobante en el zip', # Se mandó más de un archivo en el zip  timbrar_zip
      '2001' => 'Archivo zip corrupto, no se pudieron recuperar los comprobantes',# El zip en base64 no corresponde a un zip válido timbrar_zip
      '2002' => 'No se debe omitir el campo fecha_timbrado_inicio si el campo fecha_timbrado_fin existe', #  Se omitio el campo fecha_timbrado_inicio  buscar_cfdis
      '2003' => 'No se debe omitir el campo fecha_timbrado_fin si el campo fecha_timbrado_inicio existe', #  Se omitio el campo fecha_timbrado_fin buscar_cfdis
      '2004' => 'El campo fecha_timbrado_inicio no cumple con el formato YYYY-MM-DD', #  La fecha no cumple con el formato YYYY-MM-DD  buscar_cfdis
      '2005' => 'El campo fecha_timbrado_fin no cumple con el formato YYYY-MM-DD', # La fecha no cumple con el formato YYYY-MM-DD  buscar_cfdis
      '2006' => 'No se debe omitir el campo fecha_emision_inicio si el campo fecha_emision_fin existe', #  Se omitió el campo fecha_emision_inicio buscar_cfdis
      '2007' => 'No se debe omitir el campo fecha_emision_fin si el campo fecha_emision_inicio existe', #  Se omitió el campo fecha_emision_fin  buscar_cfdis
      '2008' => 'El campo fecha_emision_inicio no cumple con el formato YYYY-MM-DD', # La fecha no cumple con el formato YYYY-MM-DD  buscar_cfdis
      '2009' => 'El campo fecha_emision_fin no cumple con el formato YYYY-MM-DD', #  La fecha no cumple con el formato YYYY-MM-DD  buscar_cfdis
      '2010' => 'El UUID no cumple con el formato de UUIDs', # El UUID no cumple con el formato de UUIDs buscar_cfdis
      '2011' => 'El valor de external_id no es un valor valido, debe ser un entero', #El valor de external_id no es un entero (int) buscar_cfdis
      '2012' => 'La estructura del RFCEmisor es incorrecta', # El rfc_emisor no cumple con el formato de rfcs  buscar_cfdis
      '2013' => 'La estructura del RFCreceptor es incorrecta', # El rfc_receptor no cumple con el formato de rfcs  buscar_cfdis
      '2014' => 'El parametro "cancelado" solo puede tener valor de "true", "false" y nulo', # El valor debe ser un string buscar_cfdis
      '2015' => 'El campo uuids está vacio', # No se deben omitir los uuids  recuperar_comprobante
      '2016' => 'No se pueden recuperar mas de 200 comprobantes en una sola peticion', # La petición contiene más de 200 uuids recuperar_comprobante
      '2017' => 'El uuid no tiene una estructura válida', #  El UUID no cumple con el formato de UUIDs recuperar_comprobante
      '2018' => 'No se pueden recuperar mas de 200 comprobantes en una sola peticion', # La petición contiene más de 200 external_ids  recuperar_comprobante_external_id
      '2019' => 'El valor de external_id no es un valor valido', # external_id debe ser un entero (int)  recuperar_comprobante_external_id
      '2020' => 'No se encontro actividad para este usuario', # No existe actividad para el usuario, vuelva a intentar  obtener_consumo
      '2021' => 'El rfc no tiene una estructura válida', # El rfc no cumple con el formato de rfcs consulta_rfc
      '301' => 'El xml recibido no contiene una estructura válida', #   servicios de timbrado
      '303' => 'Sello no corresponde a emisor', # El certificado no corresponde con el rfc  servicios de cancelación
      '304' => 'El Certificado revocado o caduco', #  El certificado está vencido servicios de cancelación
      '305' => 'La fecha de cancelación no esta dentro de la vigencia del CSD del Emisor', #  El certificado se vence antes de que pueda ser cancelado el comprobante servicios de cancelación
      '306' => 'El certificado ultizado es de tipo FIEL. No es un CSD', # El certificado no corresponde a un CSD  servicios de cancelación
      '308' => 'El Certificado no fue expedido por el SAT' # El certificado no lo emitió el SAT  servicios de cancelación

    }

  end
end