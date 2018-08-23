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

#Función para la cancelación de los CFDIs.
def cancelar_cfdis usuario, contrasena, rfc, uuid, pfx_base64, pfx_password, wsdl_url
  # Generar el Envelope para el metodo cancelar
  envelope = %Q^
  <soapenv:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:urn=\"urn:WashOut\">
     <soapenv:Header/>
     <soapenv:Body>
      <urn:cancelar_cfdi soapenv:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">
         <username xsi:type=\"xsd:string\">#{usuario}</username>
         <password xsi:type=\"xsd:string\">#{contrasena}</password>
         <rfcemisor xsi:type=\"xsd:string\">#{rfc}</rfcemisor>
         <uuids xsi:type=\"urn:uuids\">
            <uuid xsi:type=\"xsd:string\">#{uuid}</uuid>
         </uuids>
         <pfxbase64 xsi:type=\"xsd:string\">#{pfx_base64}</pfxbase64>
         <pfxpassword xsi:type=\"xsd:string\">#{pfx_password}</pfxpassword>
      </urn:cancelar_cfdi>
   </soapenv:Body>
  </soapenv:Envelope>^

  # Crear un cliente de savon para hacer la conexión al WS, en produccion quital el "log: true"
  client = Savon.client(wsdl: wsdl_url, log: true)

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