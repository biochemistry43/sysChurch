<xsl:stylesheet version = '1.0'
    xmlns:xsl='http://www.w3.org/1999/XSL/Transform'
    xmlns:cfdi='http://www.sat.gob.mx/cfd/3'>

<xsl:output method = "html" />

<xsl:template match="//cfdi:Comprobante">
   <html>
   <head>
   <link rel="stylesheet"  type="text/css" href="/home/daniel/Documentos/sysChurch/lib/factura.css"/>

   <title>Factura Electrónica <xsl:value-of select="@serie"/><xsl:value-of select="@folio"/></title>
   <link href="https://fonts.googleapis.com/css?family=Open+Sans" rel="stylesheet"/>

   </head>
   <body>
   <table width="100%" id="tablaRaiz">
      <tr>
        <td >
          <xsl:element name="img">
            <xsl:attribute name="src">
              <xsl:value-of select="cfdi:RepresentacionImpresa/@Logo"/>
            </xsl:attribute>
            <xsl:attribute name="height">
              120
            </xsl:attribute>
            <xsl:attribute name="width">
              200
            </xsl:attribute>
          </xsl:element>
        </td>
        <!--Estos datos  -->
        <td colspan="2" align="right" >
          <table id="negocio">
               <tr><th class="h1" colspan="2"><b>Pacifica coaching</b></th><td></td></tr>
               <tr><th class="h1"  colspan="2">  <xsl:value-of select="//cfdi:DomicilioEmisor/@calle"/> #
                 <xsl:value-of select="//cfdi:DomicilioEmisor/@noExterior"/> Int.
                 <xsl:value-of select="//cfdi:DomicilioEmisor/@noInterior"/>
               </th><td class="h1"></td></tr>

               <tr><th class="h1"  colspan="2"><xsl:value-of select="//cfdi:DomicilioEmisor/@colonia"/></th><td class="h1"></td></tr>
               <tr><th class="h1"  colspan="2">
                 <xsl:value-of select="//cfdi:DomicilioEmisor/@municipio"/>,
                 <xsl:value-of select="//cfdi:DomicilioEmisor/@estado"/>. C.P.:
                 <xsl:value-of select="//cfdi:DomicilioEmisor/@codigoPostal"/>
               </th><td class="h1"></td></tr>
               <tr><th class="h1"  colspan="2">R.F.C.:
                 <xsl:value-of select="cfdi:Emisor/@Rfc"/>
               </th><td class="h1"></td></tr>
               <tr><th class="h1"  colspan="2">Régimen fiscal:
                 <xsl:value-of select="cfdi:Emisor/@RegimenFiscal"/>
               </th><td class="h1"></td></tr>
          </table>
        </td>

        <td colspan="2" align="right" >
          <table class="serieFolio">
               <tr><th class="h1" colspan="2"><big><big><b>C.F.D.I. de Ingreso 3.3</b></big></big></th><td></td></tr>
               <tr><th class="h1">Serie:</th><td class="h1"><xsl:value-of select="@Serie"/></td></tr>
               <tr><th class="h1">Folio:</th><td class="h1"><xsl:value-of select="@Folio"/></td></tr>
               <tr><th class="h1">Fecha y hora:</th><td class="h1"><xsl:value-of select="@Fecha"/></td></tr>
          </table>
        </td>
      </tr>

      <tr>

           <table width="100%" border="1">
              <thead>
               <tr><th colspan="2" class="h1">Lugar de expedición:</th></tr>
              </thead>
              <tbody class="emisor">
               <!--tr><th align="right">R.F.C.:  </th><td><xsl:value-of select="cfdi:Emisor/@Rfc"/></td></tr-->
               <!--tr><th align="right">Nombre:  </th><td><xsl:value-of select="cfdi:Emisor/@Nombre"/></td></tr-->
               <tr>
                 <th align="right">Dirección:  </th>
                 <td>calle: <xsl:value-of select="//cfdi:ExpedidoEn/@calle"/> #
                            <xsl:value-of select="//cfdi:ExpedidoEn/@noExterior"/> colonia:
                            <xsl:value-of select="//cfdi:ExpedidoEn/@colonia"/>,
                            <xsl:value-of select="//cfdi:ExpedidoEn/@municipio"/>,
                            <xsl:value-of select="//cfdi:ExpedidoEn/@estado"/>.
                 </td>
               </tr>
               <tr>
                 <th align="right">Teléfono:</th>
                 <td></td></tr>

             </tbody>
          </table>

      </tr>
      <tr>
          <table width="100%" border="1">
             <thead>
             <tr><th colspan="4" class="h1">Receptor</th></tr>
             </thead>
             <tbody>

             <!--El atributo Nombre servirá para mostrar o no mostrar información en la Representación impresa cuando se trate de factura de venta o  factura global.
                 El xml de las facturas globales(simplificadas) no continen el atributo Nombre por reglas del SAT, porque no son expedidas a un cliente en específico-->
             <xsl:choose>
                <xsl:when test="cfdi:Receptor/@Nombre">
                  <tr>
                    <th align="right">R.F.C.: </th><td><xsl:value-of select="cfdi:Receptor/@Rfc"/></td>
                    <th align="right">Nombre:  </th><td><xsl:value-of select="cfdi:Receptor/@Rfc"/></td>
                  </tr>
                  <tr>
                    <th align="right">Dirección: </th>
                    <td colspan="3">Calle: <xsl:value-of select="//cfdi:DomicilioReceptor/@calle"/> #
                       <xsl:value-of select="//cfdi:DomicilioReceptor/@noExterior"/> Col.
                       <xsl:value-of select="//cfdi:DomicilioReceptor/@colonia"/>,
                       <xsl:value-of select="//cfdi:DomicilioReceptor/@municipio"/>,
                       <xsl:value-of select="//cfdi:DomicilioReceptor/@estado"/>.
                    </td>
                  </tr>
                  <tr><th align="right">Uso CFDI:  </th><td  colspan="3"><xsl:value-of select="cfdi:Receptor/@UsoCFDI"/> - <xsl:value-of select="cfdi:RepresentacionImpresa/@UsoCfdiDescripcion"/></td></tr>
                  <tr>
                    <th align="right">Teléfono:</th> <td><xsl:value-of select="//cfdi:DatosReceptor/@Telefono1Receptor"/></td>
                    <th align="right">Email:</th> <td><xsl:value-of select="//cfdi:DatosReceptor/@EmailReceptor"/></td>
                  </tr>
                </xsl:when>
                <xsl:otherwise>
                  <tr>
                    <th align="right">R.F.C.: </th><td><xsl:value-of select="cfdi:Receptor/@Rfc"/></td>
                    <th align="right">Nombre:  </th><td>Público en general.</td>
                  </tr>
                  <tr><th align="right">Uso CFDI:  </th><td  colspan="3"><xsl:value-of select="cfdi:Receptor/@UsoCFDI"/> - <xsl:value-of select="cfdi:RepresentacionImpresa/@UsoCfdiDescripcion"/></td></tr>
                </xsl:otherwise>
             </xsl:choose>
           </tbody>
           </table>
      </tr>

         <tr>
           <table width="100%" >
             <thead>
               <tr>
                   <th>Cantidad</th>
                   <th>Clave Prod</th>
                   <th>Unidad</th>

                   <th>Descripción</th>
                   <th>Precio</th>
                   <th>Desc</th>
                   <th>Importe</th>
               </tr>
             </thead>

             <xsl:apply-templates select="//cfdi:Concepto"/>
             <tr>
                 <td colspan="5"></td>
                 <th align="right">SubTotal:</th><td align="right">$ <xsl:value-of select="@SubTotal"/></td>
             </tr>
             <tr>
                 <td colspan="5" align="center"> <xsl:value-of select="cfdi:RepresentacionImpresa/@TotalLetras"/> </td>
                 <th align="right">Descuento:</th>
                 <td align="right">$ <xsl:value-of select="@Descuento"/></td>
             </tr>

             <tr>
             <td colspan="5" align="right">TRASLADOS: </td>
             <th ></th>
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
             <tr id="total"><td colspan="5"></td>
                 <th align="right"><b>Total:</b></th><td align="right" ><b>$ <xsl:value-of select="@Total"/></b></td>
             </tr>
            </table>
         </tr>
        <hr/>
        <!--Que no lo cuentien jaja lea las letras chiquitas jajaja -->
        <p class="condicionesDePago"><xsl:value-of select="@CondicionesDePago"/></p>
        <br/>


        <div class="firma">(FIRMA DE CONFORMIDAD)</div>


        <table id="sellosDig">
          <td>
            <table id="tablaInternaSellos">

              <tr>
                <td rowspan="6">
                  <xsl:element name="img">
                    <xsl:attribute name="src"><xsl:value-of select="cfdi:RepresentacionImpresa/@CodigoQR"/></xsl:attribute>
                    <xsl:attribute name="height">120</xsl:attribute>
                    <xsl:attribute name="width">120</xsl:attribute>
                  </xsl:element>
                </td>
                <th align="right">Folio fiscal: </th>
                <td align="left" class="folioFiscal"> <xsl:value-of select="//@UUID"/></td>
              </tr><!--1 -->
              <tr>
                <th align="right" >Fecha y hora de certificación:  </th>
                <!--d) Fecha y hora de emisión y de certificación de la Factura en adición a lo señalado en el artículo 29-A, fracción III del CFF.-->
                <td align="left"> <small><xsl:value-of select="//@FechaTimbrado"/></small></td>
              </tr><!--3 -->
              <tr>
                <!--b) Número de serie del CSD del emisor y del SAT. -->
                <th align="right" >Número de serie del Certificado de Sello Digital: </th>
                <td align="left"> <small><xsl:value-of select="@NoCertificado"/></small></td>
              </tr><!--4 -->
              <tr>
                <!-- b) Número de serie del CSD del emisor y del SAT. -->
                <th align="right" >Número de serie del Certificado de Sello Digital del SAT: </th>
                <td align="left"> <small><xsl:value-of select="//@NoCertificadoSAT"/></small></td>
              </tr><!--5 -->


            </table>
          </td>

          <tr colspan="3"><th >Sello Digital del CFDI:</th></tr> <!--V. Sello digital del contribuyente que lo expide. -->
          <tr colspan="3"><td class="paddingTablas" id="text-transform"><small><xsl:value-of select="@Sello"/></small></td></tr> <!--Debe de ser el mismo que SelloCFD -->

          <tr colspan="3"><th >Sello Digital del SAT:</th></tr> <!--IV. El sello digital del SAT.- -->
          <tr colspan="3"><td class="paddingTablas" id="text-transform"><small><xsl:value-of select="//@SelloSAT"/></small></td></tr>

          <tr colspan="3"><th >Cadena original del complemento de certificación digital del SAT:</th></tr> <!--IV. El sello digital del SAT.- -->
          <tr colspan="3"><td class="paddingTablas" id="text-transform"><small><xsl:value-of select="cfdi:RepresentacionImpresa/@CadOrigComplemento"/></small></td></tr>

        </table>
        </table>
        <div class="leyenda">
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
        <td align="center" class="conceptos"><xsl:value-of select="@Cantidad"/></td>
        <td align="center" class="conceptos"><xsl:value-of select="@ClaveProdServ"/></td>
        <td align="center" class="conceptos"><xsl:value-of select="@Unidad"/></td>

        <td align="center" class="conceptos"><xsl:value-of select="@Descripcion"/></td>
        <td align="right" class="conceptos">$ <xsl:value-of select="@ValorUnitario"/></td>
        <td align="right" class="conceptos">$ <xsl:value-of select="@Descuento"/></td>
        <td align="right" class="conceptos">$ <xsl:value-of select="@Importe"/></td>
    </tr>
  </tbody>

  <xsl:for-each select="./cfdi:Traslados/cfdi:Traslado">
  <tr><td colspan="2" align="right"><xsl:value-of select="@Impuesto"/></td>
      <td align="right"><xsl:value-of select="@Importe"/></td>
      <td><xsl:value-of select="@TasaOCuota"/> %</td>
  </tr>
</xsl:for-each>
</xsl:template>


</xsl:stylesheet>
