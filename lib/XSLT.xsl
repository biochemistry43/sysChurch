<xsl:stylesheet version = '1.0'
    xmlns:xsl='http://www.w3.org/1999/XSL/Transform'
    xmlns:cfdi='http://www.sat.gob.mx/cfd/3'>

<xsl:output method = "html" />

<xsl:template match="//cfdi:Comprobante">
   <html>
   <head>
   <link rel="stylesheet"  type="text/css" href="/home/daniel/Documentos/sysChurch/lib/factura.css"/>
   <title>Factura Electrónica <xsl:value-of select="@serie"/><xsl:value-of select="@folio"/></title>

   </head>
   <body>
   <table width="100%" id="tablaRaiz">
      <tr>
        <td colspan="2" align="right">
          <table class="serieFolio">
               <tr><th class="h1">Serie:</th><td class="h1"><xsl:value-of select="@Serie"/></td></tr>
               <tr><th class="h1">Folio:</th><td class="h1"><xsl:value-of select="@Folio"/></td></tr>
               <tr><th class="h1">Fecha y hora:</th><td class="h1"><xsl:value-of select="@Fecha"/></td></tr>
          </table>
        </td>
      </tr>
      <tr>
        <td width="50%">
           <table width="100%" border="1">
              <thead>
               <tr><th colspan="2" class="h1">Emisor</th></tr>
              </thead>
              <tbody class="emisor">
               <tr><th align="right">RFC:  </th><td><xsl:value-of select="cfdi:Emisor/@Rfc"/></td></tr>
               <tr><th align="right">Nombre:  </th><td><xsl:value-of select="cfdi:Emisor/@Nombre"/></td></tr>
               <tr><th align="right">Regimen:  </th><td><xsl:value-of select="cfdi:Emisor/@RegimenFiscal"/></td></tr>
             </tbody>
          </table>
        </td>

        <td width="50%">
          <table width="100%" border="1">
             <thead>
             <tr><th colspan="2" class="h1">Receptor</th></tr>
             </thead>
             <tbody>
             <tr><th align="right">RFC:  </th><td><xsl:value-of select="cfdi:Receptor/@Rfc"/></td></tr>
             <tr><th align="right">Nombre:  </th><td><xsl:value-of select="cfdi:Receptor/@Nombre"/></td></tr>
             <tr><th align="right">Uso CFDI:  </th><td><xsl:value-of select="cfdi:Receptor/@UsoCFDI"/></td></tr>
           </tbody>
           </table>
         </td>
      </tr>
         <tr>
           <table width="100%" >
             <thead>
               <tr>
                   <th>Cantidad</th>
                   <th>Clave Prod</th>
                   <th>Unidad</th>
                   <th>Cve Unidad</th>
                   <th>Descripción</th>
                   <th>Precio</th>
                   <th>Descuento</th>
                   <th>Importe</th>
               </tr>
             </thead>
             <xsl:apply-templates select="//cfdi:Concepto"/>

             <tr>

                 <td colspan="6"></td>
                 <th align="right">SubTotal:</th><td align="right">$ <xsl:value-of select="@SubTotal"/></td>
             </tr>
             <tr>
                 <td colspan="6"></td>
                 <th align="right">Desc.:</th>
                 <td align="right">$ <xsl:value-of select="@Descuento"/></td>
             </tr>
             <xsl:for-each select="./cfdi:Impuestos/cfdi:Traslados/cfdi:Traslado">
                 <tr>
                   <td colspan="5" align="right">Impuestos:</td>
                     <td><xsl:value-of select="@Impuesto"/></td>
                     <td><xsl:value-of select="@TasaOCuota"/> %</td>
                     <td align="right"><xsl:value-of select="@Importe"/></td>
                 </tr>
             </xsl:for-each>
             <tr id="total"><td colspan="6"></td>
                 <th align="right"><b>Total:</b></th><td align="right" ><b>$ <xsl:value-of select="@Total"/></b></td>
             </tr>
            </table>
         </tr>
        <hr/>
        <table id="sellosDig">
          <td>
            <table id="tablaInternaSellos">
              <tr>
                <!--IV. Contener el número de folio asignado por el SAT  -->
                <td ><b>Folio fiscal: </b> <small> <xsl:value-of select="//@UUID"/></small></td>
              </tr>
              <tr>
                <!--d) Fecha y hora de emisión y de certificación de la Factura en adición a lo señalado en el artículo 29-A, fracción III del CFF.-->
                <td ><b>Fecha y hora de certificación: </b> <small><xsl:value-of select="//@FechaTimbrado"/></small></td>
              </tr>
              <tr>
                <!--b) Número de serie del CSD del emisor y del SAT. -->
                <td ><b>Número de serie del Certificado de Sello Digital: </b> <small><xsl:value-of select="@NoCertificado"/></small></td>
              </tr>
              <tr>
                <!-- b) Número de serie del CSD del emisor y del SAT. -->
                <td><b>Número de serie del Certificado de Sello Digital del SAT: </b> <small><xsl:value-of select="//@NoCertificadoSAT"/></small></td>
              </tr>
            </table>
          </td>





          <tr><th>Sello Digital del CFDI:</th></tr> <!--V. Sello digital del contribuyente que lo expide. -->
          <tr><td id="text-transform"><small><xsl:value-of select="@Sello"/></small></td></tr> <!--Debe de ser el mismo que SelloCFD -->
<td>
          <tr><th>Sello Digital del SAT:</th></tr> <!--IV. El sello digital del SAT.- -->
          <tr><td id="text-transform"><small><xsl:value-of select="//@SelloSAT"/></small></td></tr>
</td>
        </table>
        </table>
        <div>

          <center>
            ESTE DOCUMENTO ES UNA REPRESENTACIÓN IMPRESA DE UN CFDI.
          </center>
        </div>
    </body>
    </html>
</xsl:template>

<xsl:template match="//cfdi:Concepto">
  <tbody>
    <tr>
        <td align="center"><xsl:value-of select="@Cantidad"/></td>
        <td align="center"><xsl:value-of select="@ClaveProdServ"/></td>
        <td align="center"><xsl:value-of select="@Unidad"/></td>
        <td align="center"><xsl:value-of select="@ClaveUnidad"/></td>
        <td align="center"><xsl:value-of select="@Descripcion"/></td>
        <td align="right">$ <xsl:value-of select="@ValorUnitario"/></td>
        <td align="right">$ <xsl:value-of select="@Descuento"/></td>
        <td align="right">$ <xsl:value-of select="@Importe"/></td>
    </tr>
  </tbody>
    <xsl:for-each select="./cfdi:Traslados/cfdi:Traslado">
        <tr>
            <td colspan="2" align="right"><xsl:value-of select="@Impuesto"/></td>
            <td align="right"><xsl:value-of select="@Importe"/></td>
            <td><xsl:value-of select="@TasaOCuota"/> %</td>
        </tr>
    </xsl:for-each>
</xsl:template>


</xsl:stylesheet>
