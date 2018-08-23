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

=begin
Parametros de respuesta
  folios  Información de los comprobantes cancelados, consiste en UUID, código y mensaje.
  acuse_cancelacion El acuse de cancelación que regresa el SAT.
=end
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
end

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