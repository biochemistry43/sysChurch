<xsl:stylesheet version = '1.0'
    xmlns:xsl='http://www.w3.org/1999/XSL/Transform'
    xmlns:cfdi='http://www.sat.gob.mx/cfd/3'>

<xsl:output method = "html" />
<xsl:template match="//cfdi:Comprobante">
   <html>
   <head>
   <link rel="stylesheet"  type="text/css" href="/home/daniel/Vídeos/sysChurch/lib/facturas de ventas.css"/>
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
        <tr><th colspan="3" style="color: {$color_titulos}; background-color: {$color_fondo}; font-size: 18px;">Factura de venta 3.3</th>
        </tr>
        <tr><th colspan="3" style="font-size:18px; text-align:center;"><xsl:value-of select="//cfdi:DatosEmisor/@NombreNegocio"/></th> </tr>

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
          <!--Estos datos  -->
          <td colspan="2" align="right" >
            <table id="negocio" style="text-align:center;">
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
              <tr><td><b>TELÉFONO: </b> <xsl:value-of select="//cfdi:DatosEmisor/@TelefonoNegocio"/><b> EMAIL: </b> <xsl:value-of select="//cfdi:DatosEmisor/@EmailNegocio"/></td></tr>
              <tr><td><b>PÁGINA WEB: </b> <xsl:value-of select="//cfdi:DatosEmisor/@PagWebNegocio"/></td></tr>
            </table>
          </td>
          <td align="right" >
            <table width="230px" style="border: solid 1px {$color_fondo}; text-align: center;" class="serieFolio">
              <tr><th style="color: {$color_titulos}; background-color: {$color_fondo}; font-size:18px;" >Datos internos</th></tr>
              <tr><td style="color: {$color_titulos}; background-color: {$color_fondo};"><b>SERIE: </b><xsl:value-of select="@Serie"/></td></tr>
              <tr><td style="color: {$color_titulos}; background-color: {$color_fondo};"><b>FOLIO: </b><xsl:value-of select="@Folio"/></td></tr>
              <tr><th style="color: {$color_titulos}; background-color: {$color_fondo};">Fecha y hora de expedición: </th></tr>
              <tr><td style="color: {$color_titulos}; background-color: {$color_fondo};"><xsl:value-of select="@Fecha"/></td></tr>

            </table>
          </td>
        </tr>
        <tr>
             <table style="border: solid 1px {$color_fondo}; text-align: justify;" width="100%" border="1">
                <thead>
                 <tr><th style="color: {$color_titulos}; background-color: {$color_fondo};" colspan="2">Lugar de expedición</th>
                 </tr>
                </thead>
                <tbody class="emisor">
                 <tr>
                   <td colspan="2"><b>DIRECCIÓN: </b>Calle:
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
                   <td style="width: 50%;"><b>TELÉFONO: </b><xsl:value-of select="//cfdi:DatosSucursal/@TelefonoSucursal"/> </td>
                   <td style="width: 50%;"><b>EMAIL: </b><xsl:value-of select="//cfdi:DatosSucursal/@EmailSucursal"/> </td></tr>
               </tbody>
            </table>
        </tr>
        <!--RECEPTOR-->
        <tr>
            <table style="border: solid 1px {$color_fondo}; text-align: justify;" width="100%" border="1">
               <thead>
               <tr><th style="color: {$color_titulos}; background-color: {$color_fondo};" colspan="2" >Receptor</th></tr>
               </thead>
               <tbody>
                    <tr>
                      <td style="width: 50%;"> <b>NOMBRE: </b> <xsl:value-of select="cfdi:Receptor/@Nombre"/></td>
                      <td style="width: 50%;"> <b>R.F.C.: </b> <xsl:value-of select="cfdi:Receptor/@Rfc"/></td>
                    </tr>
                    <tr>
                      <td colspan="2"><b>DIRECCIÓN: </b>
                        <xsl:value-of select="//cfdi:DomicilioReceptor/@calle"/>, No.
                        <xsl:value-of select="//cfdi:DomicilioReceptor/@noExterior"/>
                        <xsl:if test="//cfdi:DomicilioReceptor/@noInterior">, No. Int.
                          <xsl:value-of select="//cfdi:DomicilioReceptor/@noInterior"/>
                        </xsl:if>, Col.
                        <xsl:value-of select="//cfdi:DomicilioReceptor/@colonia"/>,
                        <xsl:if test="//cfdi:DomicilioReceptor/@referencia">
                          <xsl:value-of select="//cfdi:DomicilioReceptor/@referencia"/>,
                        </xsl:if>
                        <xsl:value-of select="//cfdi:DomicilioReceptor/@localidad"/>, C.P.
                        <xsl:value-of select="//cfdi:DomicilioReceptor/@codigoPostal"/>,
                        <xsl:value-of select="//cfdi:DomicilioReceptor/@municipio"/>,
                        <xsl:value-of select="//cfdi:DomicilioReceptor/@estado"/>.
                      </td>
                    </tr>
                    <tr>
                      <td  colspan="2"><b>USO DEL CFDI: </b><xsl:value-of select="cfdi:Receptor/@UsoCFDI"/> - <xsl:value-of select="cfdi:RepresentacionImpresa/@UsoCfdiDescripcion"/></td>
                    </tr>
                    <tr>
                      <td style="width: 50%;"><b>TELÉFONO: </b><xsl:value-of select="//cfdi:DatosReceptor/@Telefono1Receptor"/></td>
                      <td style="width: 50%;"><b>EMAIL: </b><xsl:value-of select="//cfdi:DatosReceptor/@EmailReceptor"/></td>
                    </tr>
             </tbody>
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
                     <th style="color: {$color_titulos}; background-color: {$color_fondo};">Desc</th>

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
          <xsl:if test="cfdi:Receptor/@Nombre"> <!--El atributo condicionesDePago no existe en las facturas globales -->
            <!--Que no lo cuentien jaja lea las letras chiquitas jajaja -->
            <p class="condicionesDePago"><xsl:value-of select="@CondicionesDePago"/></p>
            <br/>
            <div style="border-top: solid 1px {$color_fondo};" class="firma">(FIRMA DE CONFORMIDAD)</div>
          </xsl:if>
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
                  <td style="color: {$color_titulos}; background-color: {$color_fondo}"  align="left" class="folioFiscal"> <xsl:value-of select="//@UUID"/></td>
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
          <div style="color: {$color_titulos}; background-color: {$color_fondo}; line-height: 25px; font-size: 12px;">
            <center>
              ESTE DOCUMENTO ES UNA REPRESENTACIÓN IMPRESA DE UN CFDI.
            </center>
          </div>
                  <tr>
          <table style="border:none;">
            <tr>
              <td>
                Esta representación impresa de una factura de venta fue expedida por el sistema OMILOS (punto de venta) de KODIKAS. Pág web: kodikas.com.mx
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
          <td style="border-bottom: 1px solid {$color_fondo};"  align="center" class="conceptos"><xsl:value-of select="@Cantidad"/></td>
          <td style="border-bottom: 1px solid {$color_fondo};"  align="center" class="conceptos"><xsl:value-of select="@ClaveProdServ"/></td>
          <td style="border-bottom: 1px solid {$color_fondo};"  align="center" class="conceptos"><xsl:value-of select="@Unidad"/></td>
          <td style="border-bottom: 1px solid {$color_fondo};"  align="center" class="conceptos"><xsl:value-of select="@Descripcion"/></td>
          <td style="border-bottom: 1px solid {$color_fondo};"  align="right" class="conceptos">$ <xsl:value-of select="@ValorUnitario"/></td>
          <td style="border-bottom: 1px solid {$color_fondo};"  align="right" class="conceptos">$ 0.00<xsl:value-of select="@Descuento"/></td>
          <td style="border-bottom: 1px solid {$color_fondo};"  align="right" class="conceptos">$ <xsl:value-of select="@Importe"/></td>
        </tr>
    </tbody>
  </xsl:template>
</xsl:stylesheet>
