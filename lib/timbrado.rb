#Todas las urls de timbox son del ambiiente de pruebas(se deben de canbiar al pasar a producción)

require 'base64'
#equire 'savon'
require 'nokogiri'
require 'byebug'

def timbrar_xml(usuario, contrasena, xml_base64, wsdl_url)
  # Generar el Envelope
  envelope = %Q^
    <soapenv:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:urn=\"urn:WashOut\">
      <soapenv:Header/>
      <soapenv:Body>
        <urn:timbrar_cfdi soapenv:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">
          <username xsi:type=\"xsd:string\">#{usuario}</username>
          <password xsi:type=\"xsd:string\">#{contrasena}</password>
          <sxml xsi:type=\"xsd:string\">##{xml_base64}</sxml>
      </urn:timbrar_cfdi>
      </soapenv:Body>
    </soapenv:Envelope>^

  # Crear un cliente de savon para hacer la petición al WS, en produccion quitar el "log: true"
  client = Savon.client(wsdl: wsdl_url, log: true)

  # Llamar el metodo timbrar
  response = client.call(:timbrar_cfdi, { "xml" => envelope })

  # Extraer el xml timbrado desde la respuesta del WS
  response = response.to_hash
  xml_timbrado = response[:timbrar_cfdi_response][:timbrar_cfdi_result][:xml]#xml sin alteraciones listo para entregar al cliente.

  return document = Nokogiri::XML(xml_timbrado)
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

    client = Savon.client(wsdl: "https://staging.ws.timbox.com.mx/cancelacion/wsdl", log: true)
    # Hacer el llamado al metodo 'consultar_status'
    response = client.call(:consultar_documento_relacionado, { "xml" => envelope })
    documento = Nokogiri::XML(response.to_xml) 
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
    response = client.call(:procesar_respuesta, { "xml" => envelope })
    documento = Nokogiri::XML(response.to_xml) 
=begin
incluir dentro del nodo "respuestas"
    <folios_respuestas>
      <uuid>#{uuid}</uuid>
      <rfc_emisor>#{rfc_emisor}</rfc_emisor>
      <total>#{total}</total>
      <respuesta>#{respuesta}</respuesta>
    </folios_respuestas>
=end
end

module Timbox

  class Servicios
    #Todos los servicios para timbrar y cancelar cfdis
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

    def mostrar_msj_error(servicio, codigo)

      case servicio
        when "cancelado" then ERRORES_CANCELADO[codigo]
        when "consulta_estatus" then ERRORES_CONSULTA_ESTATUS[codigo]
        when "consulta_documento_relacionado" then ERRORES_CONSULTA_DOCUMENTO_RELACIONADO[codigo]
        when "consulta_peticiones_pendientes" then ERRORES_CONSULTA_PETICIONES_PENDIENTES[codigo]
        when "procesado_respuesta" then ERRORES_PROCESADO_RESPUESTA[codigo]
      end

    end
  end
end