<xsl:stylesheet version = '1.0'
    xmlns:xsl='http://www.w3.org/1999/XSL/Transform'
    xmlns:cfdi='http://www.sat.gob.mx/cfd/3'>

<xsl:output method = "html" />
<xsl:template match="//cfdi:Comprobante">
   <html>
   <head>
   <link rel="stylesheet"  type="text/css" href="/home/daniel/Vídeos/sysChurch/lib/facturas globales.css"/>
   <title>Factura Electrónica <xsl:value-of select="@serie"/><xsl:value-of select="@folio"/></title>
   <!--link href="https://fonts.googleapis.com/css?family=Open+Sans" rel="stylesheet"/-->
      <script>
        function number_pages() {
          var vars={};
          var x=document.location.search.substring(1).split('&');
          for(var i in x) {var z=x[i].split('=',2);vars[z[0]] = unescape(z[1]);}
          var x=['frompage','topage','page','webpage','section','subsection','subsubsection'];
          for(var i in x) {
            var y = document.getElementsByClassName(x[i]);
            for(var j=0; j<y.length; ++j) y[j].textContent = vars[x[i]];
          }
        }
      </script>
   </head>
   <body onload="number_pages()">
   <!--Se obtienen los valores  -->
   <xsl:variable name="tipo_fuente"><xsl:value-of select="//cfdi:DatosPlantilla/@TipoFuente"/></xsl:variable>
   <xsl:variable name="tam_fuente"><xsl:value-of select="//cfdi:DatosPlantilla/@TamFuente"/></xsl:variable>
   <xsl:variable name="color_fondo"><xsl:value-of select="//cfdi:DatosPlantilla/@ColorFondo"/></xsl:variable>
   <xsl:variable name="color_banda"><xsl:value-of select="//cfdi:DatosPlantilla/@ColorBanda"/></xsl:variable>
   <xsl:variable name="color_titulos"><xsl:value-of select="//cfdi:DatosPlantilla/@ColorTitulos"/></xsl:variable>
   <div style="font-family: {$tipo_fuente}">
     <table width="100%" id="tablaRaiz">
       <tr>
          <table style="border:none; text-align: center; ">
            <thead></thead>
            <td style="border-top: 4px solid {$color_banda}; width: 30%;"><b>SERIE: </b><xsl:value-of select="@Serie"/><b> FOLIO: </b><xsl:value-of select="@Folio"/></td>
            <td style="text-align: center; font-size:18px; border-bottom: 4px solid {$color_banda};"><b>FACTURA GLOBAL 3.3</b></td>
            <td style="border-top: 4px solid {$color_banda}; width: 30%; text-align: center; "><b>FECHA Y HORA DE EXPEDICIÓN: </b><xsl:value-of select="@Fecha"/></td>
          </table>
        </tr>

        <tr>
          <table style="border:none; margin: 0px; padding: 0px;">
            <td>
              <table id="negocio" style="border: solid 1px {$color_fondo}; width: 100%; height: 100%; text-align:left;">
                <thead>
                  <tr><th style="color: {$color_titulos}; background-color: {$color_fondo}; font-size:18px; text-transform: uppercase;" colspan="2"><xsl:value-of select="//cfdi:DatosEmisor/@NombreNegocio"/></th></tr>
                </thead>
                <tbody>
                  <tr><th>R.F.C. </th><td><xsl:value-of select="cfdi:Emisor/@Rfc"/></td></tr>
                  <tr><th>REGIMEN: </th><td><xsl:value-of select="//cfdi:DatosEmisor/@CveNombreRegimenFiscalSAT"/> </td></tr>
                  <tr><th>DIRECCIÓN: </th><td>Calle:
                    <xsl:value-of select="//cfdi:DomicilioEmisor/@calle"/>, No.
                    <xsl:value-of select="//cfdi:DomicilioEmisor/@noExterior"/>
                    <xsl:if test="//cfdi:DomicilioEmisor/@noInterior">, No. Int.
                      <xsl:value-of select="//cfdi:DomicilioEmisor/@noInterior"/>
                    </xsl:if>, Col.
                    <xsl:value-of select="//cfdi:DomicilioEmisor/@colonia"/>,
                    <xsl:value-of select="//cfdi:DomicilioEmisor/@referencia"/>,
                    <xsl:value-of select="//cfdi:DomicilioEmisor/@localidad"/>, C.P.
                    <xsl:value-of select="//cfdi:DomicilioEmisor/@codigoPostal"/30
                    <xsl:value-of select="//cfdi:DomicilioEmisor/@municipio"/>,
                    <xsl:value-of select="//cfdi:DomicilioEmisor/@estado"/>.</td></tr>
                  <tr><th>TELÉFONO: </th><td><xsl:value-of select="//cfdi:DatosEmisor/@TelefonoNegocio"/></td></tr>
                  <tr><th>EMAIL: </th><td><xsl:value-of select="//cfdi:DatosEmisor/@EmailNegocio"/></td></tr>
                  <tr><th>PÁG. WEB: </th><td><xsl:value-of select="//cfdi:DatosEmisor/@PagWebNegocio"/></td></tr>
                </tbody>
              </table>
            </td>

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
          </table>
        </tr>

        <tr>
          <table style="border: none; width: 100%; margin: 0px; padding: 0px;">
            <td style="width: 50%; height: 70px;">
              <table style="border: solid 1px {$color_fondo}; width: 100%; height: 100%;" border="1">
                <thead>
                 <tr><th style="color: {$color_titulos}; background-color: {$color_fondo};" colspan="4">Lugar de expedición</th></tr>
                </thead>
                <tbody class="emisor">
                 <!--tr><th align="right">R.F.C.:  </th><td><xsl:value-of select="cfdi:Emisor/@Rfc"/></td></tr-->
                 <!--tr><th align="right">Nombre:  </th><td><xsl:value-of select="cfdi:Emisor/@Nombre"/></td></tr-->
                 <tr>
                   <th style="text-align: left;">Dirección:  </th>
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
                   <th style="text-align: left;">Teléfono: </th><td><xsl:value-of select="//cfdi:DatosSucursal/@TelefonoSucursal"/> </td>
                   <th style="text-align: left;">Email: </th><td><xsl:value-of select="//cfdi:DatosSucursal/@EmailSucursal"/> </td></tr>
                </tbody>
              </table>
              
            </td>
            <td style="width: 50%; height: 70px;">
              <!--Información del receptor -->

              <table style="border: solid 1px {$color_fondo}; width: 100%; height: 100%; text-align:left;" border="1">
                 <thead>
                 <tr><th style="color: {$color_titulos}; background-color: {$color_fondo};" colspan="2">Receptor</th></tr>
                 </thead>
                 <tbody>
                    <tr><th style="text-align: left;">R.F.C.: </th><td><xsl:value-of select="cfdi:Receptor/@Rfc"/></td></tr>
                    <tr><th style="text-align: left;">Nombre:  </th><td>Público en general</td></tr>
                    <tr><th style="text-align: left;">Uso CFDI:  </th><td><xsl:value-of select="cfdi:Receptor/@UsoCFDI"/> - <xsl:value-of select="cfdi:RepresentacionImpresa/@UsoCfdiDescripcion"/></td>
                    </tr>
             
                </tbody>
              </table>
            </td>
          </table> 
        </tr>
           <tr>
             <table style="border: solid 1px {$color_fondo};" width="100%" >
               <thead>
                 <tr>
                     <th style="color: {$color_titulos}; background-color: {$color_fondo};">Cantidad</th>
                     <th style="color: {$color_titulos}; background-color: {$color_fondo};">Clave Prod</th>
                     <th style="color: {$color_titulos}; background-color: {$color_fondo};">Unidad</th>
                     <th style="color: {$color_titulos}; background-color: {$color_fondo};">Descripción</th>
                     <th style="color: {$color_titulos}; background-color: {$color_fondo};">Precio</th>
                     <th style="color: {$color_titulos}; background-color: {$color_fondo};">Impuestos T.</th>
                     <th style="color: {$color_titulos}; background-color: {$color_fondo};">Importe</th>
                 </tr>
               </thead>

               <xsl:apply-templates select="//cfdi:Concepto"/>
               <tr>
                   <td colspan="5" align="left"> <b>FORMA DE PAGO: </b><xsl:value-of select="cfdi:RepresentacionImpresa/@CveNombreFormaPago"/></td>
                   <!--td colspan="5"></td-->
                   <th align="right">SubTotal:</th><td align="right">$ <xsl:value-of select="@SubTotal"/></td>
               </tr>
               <tr>
                   <td colspan="5" align="left"><b>MÉTODO DE PAGO: </b><xsl:value-of select="cfdi:RepresentacionImpresa/@CveNombreMetodoPago"/></td>
                   <th align="right">Descuento:</th>
                   <td align="right">$ 0.00<xsl:value-of select="@Descuento"/></td>
               </tr>

               <tr>
               <td colspan="5" align="right">TRASLADOS: </td>

               <td ></td>
               <td ></td>
               </tr>

               <xsl:for-each select="./cfdi:Impuestos/cfdi:Traslados/cfdi:Traslado">

                    <tr>
                      <td colspan="5" ></td>
                      <th  align="right">
                        <xsl:if test="@Impuesto='002'">IVA </xsl:if>
                        <xsl:if test="@Impuesto='003'">IEPS </xsl:if>
                        <xsl:value-of select="@TasaOCuota * 100"/> %
                      </th>
                      <td align="right">$ <xsl:value-of select="@Importe"/></td>
                    </tr>
              </xsl:for-each>
               <tr id="total">
                 <!--td colspan="5"></td-->
                 <td colspan="5" align="center" style="font-size:12px;"><xsl:value-of select="cfdi:RepresentacionImpresa/@TotalLetras"/></td>
                   <th align="right"><b>Total:</b></th><td align="right" ><b>$ <xsl:value-of select="@Total"/></b></td>
               </tr>
              </table>
           </tr>
          <hr style="border:4px solid {$color_banda};" />
    
          <table width="100%" style="border: solid 1px {$color_fondo}};" id="sellosDig">
            <td>
              <table width="100%" id="tablaInternaSellos">

                <tr>
                  <td rowspan="6">
                    <xsl:element name="img">
                      <xsl:attribute name="src"><xsl:value-of select="cfdi:RepresentacionImpresa/@CodigoQR"/></xsl:attribute>
                      <xsl:attribute name="height">120</xsl:attribute>
                      <xsl:attribute name="width">120</xsl:attribute>
                    </xsl:element>
                  </td>
                  <th align="right">Folio fiscal: </th>
                  <td style="color: {color_titulos}; background-color: {$color_fondo}"  align="left" class="folioFiscal"> <xsl:value-of select="//@UUID"/></td>
                </tr><!--1 -->
                <tr>
                  <th align="right" >Fecha y hora de certificación:  </th>
                  <!--d) Fecha y hora de emisión y de certificación de la Factura en adición a lo señalado en el artículo 29-A, fracción III del CFF.-->
                  <td align="left"> <small><xsl:value-of select="//@FechaTimbrado"/></small></td>
                </tr><!--3 -->
                <tr>
                  <!--b) Número de serie del CSD del emisor y del SAT. -->
                  <th align="right" >No. de serie del Certificado de Sello Digital: </th>
                  <td align="left"> <small><xsl:value-of select="@NoCertificado"/></small></td>
                </tr><!--4 -->
                <tr>
                  <!-- b) Número de serie del CSD del emisor y del SAT. -->
                  <th align="right" >No. de serie del Certificado de Sello Digital del SAT: </th>
                  <td align="left"> <small><xsl:value-of select="//@NoCertificadoSAT"/></small></td>
                </tr><!--5 -->


              </table>
            </td>

            <tr colspan="3" ><th >Sello Digital del CFDI:</th></tr> <!--V. Sello digital del contribuyente que lo expide. -->
            <tr colspan="3"><td class="paddingTablas" id="text-transform"><small><xsl:value-of select="@Sello"/></small></td></tr> <!--Debe de ser el mismo que SelloCFD -->

            <tr colspan="3"><th >Sello Digital del SAT:</th></tr> <!--IV. El sello digital del SAT.- -->
            <tr colspan="3"><td class="paddingTablas" id="text-transform"><small><xsl:value-of select="//@SelloSAT"/></small></td></tr>

            <tr colspan="3"><th >Cadena original del complemento de certificación digital del SAT:</th></tr> <!--IV. El sello digital del SAT.- -->
            <tr colspan="3"><td class="paddingTablas" id="text-transform"><small><xsl:value-of select="cfdi:RepresentacionImpresa/@CadOrigComplemento"/></small></td></tr>

          </table>
          </table>
          <div style="color: {$color_titulos}; background-color: {$color_fondo}" class="leyenda">
            <center>
              ESTE DOCUMENTO ES UNA REPRESENTACIÓN IMPRESA DE UN CFDI.
            </center>
          </div>
        <tr>
          <table style="border:none;">
            <tr>
              <td>
                Esta representación impresa de una factura global fue expedida por el sistema OMILOS (punto de venta) de KODIKAS. Pág web: kodikas.com.mx
              </td>
                <td>
                   <xsl:element name="img">
                    <xsl:attribute name="src">
                      http://kodikas.com.mx/wp-content/uploads/2016/05/logo-versi%C3%B3n-1.png
                    </xsl:attribute>
                    <xsl:attribute name="height">
                      50
                    </xsl:attribute>
                    <xsl:attribute name="width">
                      180
                    </xsl:attribute>
                  </xsl:element> 
                </td>
            </tr>
          </table>
        </tr>
          Page <span class="page"></span> of <span class="topage"></span>
      </body>
      </html>
   </div>

</xsl:template>

<xsl:template match="//cfdi:Concepto">
  <tbody>
    <xsl:variable name="color_fondo"><xsl:value-of select="//cfdi:DatosPlantilla/@ColorFondo"/></xsl:variable>
         <tr>
             <td align="center" class="conceptos" style="border-bottom: 1px solid {$color_fondo};"><xsl:value-of select="@Cantidad"/></td>
             <td align="center" class="conceptos" style="border-bottom: 1px solid {$color_fondo};"><xsl:value-of select="@ClaveProdServ"/></td>
             <td align="center" class="conceptos" style="border-bottom: 1px solid {$color_fondo};"><xsl:value-of select="@ClaveUnidad"/></td>
             <td align="center" class="conceptos" style="border-bottom: 1px solid {$color_fondo};"><xsl:value-of select="@Descripcion"/> - <xsl:value-of select="@NoIdentificacion"/></td>
             <td align="right" class="conceptos" style="border-bottom: 1px solid {$color_fondo};">$ <xsl:value-of select="@ValorUnitario"/></td>
             <!--La columna que era para los descuentos, será para desglosar los impuestos de cada movimiento-->
             <!--td align="right" class="conceptos">$ <xsl:value-of select="@Descuento"/></td-->

             <!--Que locura! se desglosan los impuestos de cada movimiento(los impuestos que pudieran tener los conceptos de cada venta, pueden ser de 1...)-->
             <td align="center" class="conceptos" style="border-bottom: 1px solid {$color_fondo};">
               <xsl:for-each select="./cfdi:Impuestos/cfdi:Traslados/cfdi:Traslado"> <!--Selecciona el nodo actual-->
                 B=$<xsl:value-of select="@Base"/> -
                 <xsl:if test="@Impuesto='002'">IVA </xsl:if>
                 <xsl:if test="@Impuesto='003'">IEPS </xsl:if>
                 <xsl:value-of select="@TasaOCuota * 100"/>% - T=$
                 <xsl:value-of select="@Importe"/>
                 <br/>
                  <!--Un saltito de ranita para que se muetren dentro de la misma fila de cada movimiento-->
                </xsl:for-each>
             </td>
             <td align="right" class="conceptos" style="border-bottom: 1px solid {$color_fondo};">$ <xsl:value-of select="@Importe"/></td>
         </tr>
  </tbody>
</xsl:template>


</xsl:stylesheet>
