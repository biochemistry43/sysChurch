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
