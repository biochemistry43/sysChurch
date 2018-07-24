module CFDI

  require 'base64'
  #equire 'savon'
  require 'nokogiri'
  require 'byebug'

  require 'openssl'

  # Una llave privada, en formato X509 no PKCS7
  #
  # Para convertirlos, nomás hacemos
  #     openssl pkcs8 -inform DER -in nombreGiganteDelSAT.key -passin pass:miFIELCreo >> certX509.pem
  class Key < OpenSSL::PKey::RSA
    # Crea una llave privada
    # @ param  file [IO, String] El `path` de esta llave o los bytes de la misma
    # @ param  password=nil [String, nil] El password de esta llave
    # @ return [CFDI::Key] La llave privada
    def initialize path_llave, password_llave=nil
      if path_llave.is_a? String
        path_llave = File.read(path_llave)
      end
      super path_llave, password_llave
    end

    #Por el momento no es utíl, pero más adelante servirá para los comprobantes en "borrador"
    def actualizar_fecha(comprobante)
      fecha = Time.now.strftime("%Y-%m-%dT%H:%M:%S")
      comprobante.fecha = fecha
      comprobante
    end

    def get_cadena_original(comprobante)
      comprobante = Nokogiri::XML(comprobante.comprobante_to_xml)
      xslt = Nokogiri::XSLT(File.read("/home/daniel/Documentos/sysChurch/lib/cadenaoriginal_3_3.xslt"))
      cadena = xslt.transform(comprobante)
      cadena.text.gsub("\n","")
    end

    def agregar_sello(comprobante, sello)
      comprobante.sello = sello
      comprobante = comprobante.comprobante_to_xml
    end

    # sella una factura
    # @ param factura [CFDI::Comprobante] El comprobante a sellar
    # @ return [CFDI::comprobante] El comprobante con el `sello`
    def sella comprobante
      #Actualiza la fecha del comprobante (NO es útil por ahora pero para comprobantes con estatus en borrador servirán porq se debe de actualizar fecha y sello)
      comprobante = actualizar_fecha(comprobante)

      cadena = get_cadena_original(comprobante)

      #Generar digestion y sello
      digester = OpenSSL::Digest::SHA256.new
      signature = self.sign(digester, cadena)
      sello = Base64.strict_encode64(signature)

      comprobante = agregar_sello(comprobante, sello)
    end
  end
end
