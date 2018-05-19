module CFDI

  # Un complemento fiscal, o Timbre
  class Complemento < ElementoComprobante

    # los datos del timbre
    @cadenaOriginal = [:Version, :uuid, :FechaTimbrado, :RfcProvCertif, :SelloCFD, :NoCertificadoSAT]
    attr_accessor *@cadenaOriginal

    # Regresa la cadena Original del Timbre Fiscal Digital del SAT
    #
    # @return [String] la cadena formada
    def cadena_TimbreFiscalDigital
      return "||#{@Version}|#{@uuid}|#{@FechaTimbrado}|#{@RfcProvCertif}|#{@SelloCFD}|#{@NoCertificadoSAT}||"
    end

  end

end
