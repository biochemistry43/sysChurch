<xsl:stylesheet version = '1.0'
      xmlns:xsl='http://www.w3.org/1999/XSL/Transform'
      xmlns:cfdi='http://www.sat.gob.mx/cfd/3'>
  <xsl:output method = "html" />
  <xsl:template match="//cfdi:Comprobante">
     <html>
     <head>
     <link rel="stylesheet"  type="text/css" href="/home/daniel/Documentos/sysChurch/lib/factura.css"/>
     <!--Para acuses de cancelación de facturas de ventas, globales, notas de crédito y todo lo habido y por haber-->
     <title>Acuse de cancelación de CFDI<xsl:value-of select="@serie"/><xsl:value-of select="@folio"/></title>
     <!--link href="https://fonts.googleapis.com/css?family=Open+Sans" rel="stylesheet"/-->
     </head>
     <body>
     <!--Se obtienen los valores  -->
     <xsl:variable name="tipo_fuente"><xsl:value-of select="//cfdi:DatosPlantilla/@TipoFuente"/></xsl:variable>
     <xsl:variable name="tam_fuente"><xsl:value-of select="//cfdi:DatosPlantilla/@TamFuente"/></xsl:variable>
     <xsl:variable name="color_fondo"><xsl:value-of select="//cfdi:DatosPlantilla/@ColorFondo"/></xsl:variable>
     <xsl:variable name="color_banda"><xsl:value-of select="//cfdi:DatosPlantilla/@ColorBanda"/></xsl:variable>
     <xsl:variable name="color_titulos"><xsl:value-of select="//cfdi:DatosPlantilla/@ColorTitulos"/></xsl:variable>
     
     <div style="font-family: {$tipo_fuente}">
       <table width="100%" id="tablaRaiz">
          <!--Encabezado de todos los comprobantes. Información del negocio-->
          <tr>
            <td>
              <xsl:element name="img">
                <xsl:attribute name="src">
                  <xsl:value-of select="cfdi:RepresentacionImpresa/@Logo"/>
                </xsl:attribute>
                <xsl:attribute name="height">
                  120
                </xsl:attribute>
                <xsl:attribute name="width">
                  120
                </xsl:attribute>
              </xsl:element>
            </td>
            <td colspan="2" align="right" >
              <table id="negocio" style="text-align:center;">
                <tr><th   style="font-size:18px; text-align:center;"><xsl:value-of select="//cfdi:DatosEmisor/@NombreNegocio"/></th> </tr>
                <tr ><td> <b>R.F.C.</b><xsl:value-of select="cfdi:Emisor/@Rfc"/></td></tr>
                <tr ><td> <b>REGIMEN: </b><xsl:value-of select="//cfdi:DatosEmisor/@CveNombreRegimenFiscalSAT"/> </td></tr>
                <tr><td > <b>DIRECCIÓN: </b>Calle:
                  <xsl:value-of select="//cfdi:DomicilioEmisor/@calle"/>, No.
                  <xsl:value-of select="//cfdi:DomicilioEmisor/@noExterior"/>
                  <xsl:if test="//cfdi:DomicilioEmisor/@noInterior">, No. Int.
                    <xsl:value-of select="//cfdi:DomicilioEmisor/@noInterior"/>
                  </xsl:if>, Col.
                  <xsl:value-of select="//cfdi:DomicilioEmisor/@colonia"/>,
                  <xsl:value-of select="//cfdi:DomicilioEmisor/@referencia"/>,
                  <xsl:value-of select="//cfdi:DomicilioEmisor/@localidad"/>, C.P.
                  <xsl:value-of select="//cfdi:DomicilioEmisor/@codigoPostal"/>,
                  <xsl:value-of select="//cfdi:DomicilioEmisor/@municipio"/>,
                  <xsl:value-of select="//cfdi:DomicilioEmisor/@estado"/>.</td></tr>
                <tr>
                  <td>
                    <b>TELÉFONO: </b> <xsl:value-of select="//cfdi:DatosEmisor/@TelefonoNegocio"/>
                    <b>Email: </b> <xsl:value-of select="//cfdi:DatosEmisor/@EmailNegocio"/>
                  </td>
                </tr>
                <tr><td><b>PÁGINA WEB: </b> <xsl:value-of select="//cfdi:DatosEmisor/@PagWebNegocio"/></td></tr>
              </table>
            </td>
            <td align="right" >
              <table width="230px" style="border: solid 1px {$color_fondo};" class="serieFolio">
                <xsl:choose>
                   <xsl:when test="cfdi:Receptor/@Nombre">
                     <xsl:choose>
                       <xsl:when test="@TipoDeComprobante = 'E'">
                         <tr><th  style="color: {$color_titulos}; background-color: {$color_fondo}; font-size:18px;"  class="fondos_titulos">Nota de crédito 3.3</th></tr>
                       </xsl:when>
                       <xsl:otherwise test="@TipoDeComprobante = 'I'">
                         <tr><th style="color: {$color_titulos}; background-color: {$color_fondo}; font-size:18px;" >Factura 3.3</th></tr>
                       </xsl:otherwise>
                     </xsl:choose>
                   </xsl:when>
                   <xsl:otherwise>
                     <tr><th style="color: {$color_titulos}; background-color: {$color_fondo}; font-size:18px;">Factura global 3.3</th></tr>
                   </xsl:otherwise>
                </xsl:choose>
                <tr><th style="color: {$color_titulos}; background-color: {$color_fondo};">Serie: <xsl:value-of select="@Serie"/></th></tr>
                <tr><th style="color: {$color_titulos}; background-color: {$color_fondo};">Folio: <xsl:value-of select="@Folio"/></th></tr>
                <tr><th style="color: {$color_titulos}; background-color: {$color_fondo};">Fecha y hora: <xsl:value-of select="@Fecha"/></th></tr>
              </table>
            </td>
          </tr>
          <xsl:if test="//cfdi:DatosSucursal">
          <!--Información de la sucursal el lugar donde fue expedido el acuse -->
          <tr>
               <table style="border: solid 1px {$color_fondo};" width="100%" border="1">
                  <thead>
                   <tr><th style="color: {$color_titulos}; background-color: {$color_fondo};" colspan="4">Lugar de expedición:</th></tr>
                  </thead>
                  <tbody class="emisor">
                   <!--tr><th align="right">R.F.C.:  </th><td><xsl:value-of select="cfdi:Emisor/@Rfc"/></td></tr-->
                   <!--tr><th align="right">Nombre:  </th><td><xsl:value-of select="cfdi:Emisor/@Nombre"/></td></tr-->
                   <tr>
                     <th align="right">Dirección:  </th>
                     <td colspan="3">Calle:
                       <xsl:value-of select="//cfdi:ExpedidoEn/@calle"/>, No.
                       <xsl:value-of select="//cfdi:ExpedidoEn/@noExterior"/>
                       <xsl:if test="//cfdi:ExpedidoEn/@noInterior">, No. Int.
                         <xsl:value-of select="//cfdi:ExpedidoEn/@noInterior"/>
                       </xsl:if>, Col.
                       <xsl:value-of select="//cfdi:ExpedidoEn/@colonia"/>,
                       <xsl:value-of select="//cfdi:ExpedidoEn/@referencia"/>,
                       <xsl:value-of select="//cfdi:ExpedidoEn/@localidad"/>, C.P.
                       <xsl:value-of select="//cfdi:ExpedidoEn/@codigoPostal"/>,
                       <xsl:value-of select="//cfdi:ExpedidoEn/@municipio"/>,
                       <xsl:value-of select="//cfdi:ExpedidoEn/@estado"/>.
                     </td>
                   </tr>
                   <tr>
                     <th align="right">Teléfono: </th><td><xsl:value-of select="//cfdi:DatosSucursal/@TelefonoSucursal"/> </td>
                     <th align="right">Email: </th><td><xsl:value-of select="//cfdi:DatosSucursal/@EmailSucursal"/> </td></tr>
                 </tbody>
              </table>
          </tr>
          </xsl:if>
          <!--Información del acuse de cancelación-->
          <tr>
             <table style="border: solid 1px {$color_fondo};" width="100%" border="1">
                <thead>
                 <tr><th style="color: {$color_titulos}; background-color: {$color_fondo};">Información del acuse de cancelación:</th></tr>
                </thead>
                <tbody class="emisor">
                  <tr><th align="right">Folio fiscal: </th><td><big><xsl:value-of select="cfdi:Acuse/@UUID"/></big></td></tr>
                  <tr><th align="right">Estatus: </th><td><xsl:value-of select="cfdi:Acuse/@EstatusCFDI"/> (<xsl:value-of select="cfdi:Emisor/@DetallesEstatusCFDI"/>)</td></tr>
                 <tr><th align="right">R.F.C. del emisor: </th><td><xsl:value-of select="cfdi:Emisor/@Rfc"/></td></tr>
                 <tr><th align="right">Fecha y hora de cancelación:  </th><td><xsl:value-of select="cfdi:Emisor/@FechaCancelacion"/></td></tr>
                 <tr><th align="right">Sello digital del SAT: </th><td ><xsl:value-of select="/cfdi:Acuse/@SelloSAT"/>
                   </td>
                 </tr>
               </tbody>
            </table>
          </tr>
          <!--hr style="border:4px solid {$color_banda};" /-->
          <p class="condicionesDePago">Representación impresa de un acuse de cancelación expedido por el sistema OMILOS (punto de venta) de KODIKAS.</p>
        </table>
            <!--div style="color: {color_titulos}; background-color: {$color_fondo}" class="leyenda">
              <center>
                ESTE DOCUMENTO ES UNA REPRESENTACIÓN IMPRESA DE UN CFDI.
              </center>
            </div-->
        </div>
      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>
