<xsl:stylesheet version = '1.0'
    xmlns:xsl='http://www.w3.org/1999/XSL/Transform'
    xmlns:cfdi='http://www.sat.gob.mx/cfd/3'>

<xsl:output method = "html" />
<xsl:template match="//cfdi:Comprobante">
   <html>
   <head>
   <link rel="stylesheet"  type="text/css" href="/home/daniel/Vídeos/sysChurch/lib/notas de crédito.css"/>
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
     
          <tr><th colspan="3" style="color: {$color_titulos}; background-color: {$color_fondo}; font-size: 18px;">Nota de crédito 3.3</th>
          </tr>
          <tr>
            <th colspan="3" style="font-size:18px;" ><xsl:value-of select="//cfdi:DatosEmisor/@NombreNegocio"/></th>
          </tr>

          <tr>
            <table >
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
              <td>
                <table style="border: solid 1px {$color_fondo};">
                  <tr>
                    <thead>
                      <th style="color: {$color_titulos}; background-color: {$color_fondo};">Datos internos</th>
                      <th style="color: {$color_titulos}; background-color: {$color_fondo};">Datos del comprobante</th>
                      
                    </thead>
                    <tbody>
                      <td  style="color: {$color_titulos}; background-color: {$color_fondo};">
                        <table style="width: 230px; height: 100%;" class="serieFolio">
                          <tr><th style="color: {$color_titulos};">Serie: <xsl:value-of select="@Serie"/></th></tr>
                          <tr><th style="color: {$color_titulos};">Folio: <xsl:value-of select="@Folio"/></th></tr>
                          <tr><th style="color: {$color_titulos};">Fecha y hora de expedición: <xsl:value-of select="@Fecha"/></th></tr>
                        </table>
                      </td>
                      <td style="text-align: justify;">
                        <table style="height: 100%;">
                          <tr>
                            <td><b>FOLIO FISCAL: </b><xsl:value-of select="//@UUID"/>
                            </td>
                          </tr>
                          <tr>
                            <td><b>FECHA Y HORA DE CERTIFICACIÓN: </b>2018-08-13T18:21:14<xsl:value-of select="//@FechaTimbrado"/>
                            </td>
                          </tr>
                          <tr>
                            <td><b>NO. DE SERIE DEL CSD: </b>30001000000300023708<xsl:value-of select="@NoCertificado"/>
                            </td>
                          </tr>
                          <tr>
                            <td><b>NO. DE SERIE DEL CSD DEL SAT: </b>20001000000300022323<xsl:value-of select="//@NoCertificadoSAT"/>
                            </td>
                          </tr>
                        </table>
                      </td>
                    </tbody>
                  </tr>
                </table>
              </td>
            </table>
            
          </tr>
      

        <!--DIRECCIÓN FISCAL DEL NEGOCIO Y DE LA SUCURSSAL -->
        <tr>
          <table>
            <thead>
              <th style="color: {$color_titulos}; background-color: {$color_fondo};"></th>
              <th style="color: {$color_titulos}; background-color: {$color_fondo};">Negocio</th>
              <th style="color: {$color_titulos}; background-color: {$color_fondo};">Sucursal</th>
            </thead>
            <tbody>
              <tr style="border-bottom: solid 1px {$color_fondo};">
                <th style="text-align: left;">Dirección</th>
                <td style="border-left: solid 1px {$color_fondo};">Calle:
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
                  <xsl:value-of select="//cfdi:DomicilioEmisor/@estado"/>.
                </td>
                <td style="border-left: solid 1px {$color_fondo};">
                  Calle:
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
              <tr style="border-bottom: solid 1px {$color_fondo};">
                <th style="text-align: left;">Telefono</th>
                <td style="border-left: solid 1px {$color_fondo};"><xsl:value-of select="//cfdi:DatosEmisor/@TelefonoNegocio"/></td>
                <td style="border-left: solid 1px {$color_fondo};"><xsl:value-of select="//cfdi:DatosSucursal/@TelefonoSucursal"/></td>
              </tr>
              <tr style="border-bottom: solid 1px {$color_fondo};">
                <th style="text-align: left;">Email</th>
                <td style="border-left: solid 1px {$color_fondo};"><xsl:value-of select="//cfdi:DatosEmisor/@EmailNegocio"/></td>
                <td style="border-left: solid 1px {$color_fondo};"><xsl:value-of select="//cfdi:DatosSucursal/@EmailSucursal"/></td>
              </tr>
              <tr>
                <td colspan="3"> <b>R.F.C.: </b><xsl:value-of select="cfdi:Emisor/@Rfc"/><b> REGIMEN: </b><xsl:value-of select="//cfdi:DatosEmisor/@CveNombreRegimenFiscalSAT"/><b> PÁGINA WEB: </b> <xsl:value-of select="//cfdi:DatosEmisor/@PagWebNegocio"/></td>                
              </tr>
            </tbody>
          </table>
        </tr>

        <!--DATOS DEL RECEPTOR-->
        <tr>
            <table width="100%" border="1" class="texto_izquierda">
               <thead>
               <tr><th style="color: {$color_titulos}; background-color: {$color_fondo};" colspan="4" >Receptor</th></tr>
               </thead>
               <tbody>

                    <tr style="border-bottom: solid 1px {$color_fondo};">
                      <th >R.F.C.: </th><td><xsl:value-of select="cfdi:Receptor/@Rfc"/></td>
                      <th >Nombre:  </th><td><xsl:value-of select="cfdi:Receptor/@Nombre"/></td>
                    </tr>
                    <tr style="border-bottom: solid 1px {$color_fondo};">
                      <th >Dirección:  </th>
                      <td colspan="3">
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
                    <tr style="border-bottom: solid 1px {$color_fondo};"><th >Uso CFDI:  </th><td  colspan="3"><xsl:value-of select="cfdi:Receptor/@UsoCFDI"/> - <xsl:value-of select="cfdi:RepresentacionImpresa/@UsoCfdiDescripcion"/></td></tr>
                    <tr>
                      <th >Teléfono: </th> <td><xsl:value-of select="//cfdi:DatosReceptor/@Telefono1Receptor"/></td>
                      <th >Email: </th> <td><xsl:value-of select="//cfdi:DatosReceptor/@EmailReceptor"/></td>
                    </tr>
             </tbody>
             </table>
        </tr>
           <tr>
             <table width="100%" >
               <thead>
                 <tr>
                  <tr>
                    <th style="color: {$color_titulos}; background-color: {$color_fondo};">Cantidad</th>
                    <th style="color: {$color_titulos}; background-color: {$color_fondo};">Clave Prod</th>
                    <th style="color: {$color_titulos}; background-color: {$color_fondo};">Unidad</th>
                    <th style="color: {$color_titulos}; background-color: {$color_fondo};">Descripción</th>
                    <th style="color: {$color_titulos}; background-color: {$color_fondo};">Precio</th>    
                    <th style="color: {$color_titulos}; background-color: {$color_fondo};">Desc</th>
                    <th style="color: {$color_titulos}; background-color: {$color_fondo};">Importe</th>
                  </tr>
                 </tr>
               </thead>


               <xsl:apply-templates select="//cfdi:Concepto"/>
               <tr>
                   <td colspan="5" align="left"> <b>FORMA DE PAGO: </b><xsl:value-of select="cfdi:RepresentacionImpresa/@CveNombreFormaPago"/></td>
                   <!--td colspan="5"></td-->
                   <th align="right" style="border-bottom: solid 1px {$color_fondo};">SubTotal:</th><td align="right" style="border-bottom: solid 1px {$color_fondo};">$ <xsl:value-of select="@SubTotal"/></td>
               </tr>
               <tr>
                   <td colspan="5" align="left"><b>MÉTODO DE PAGO: </b><xsl:value-of select="cfdi:RepresentacionImpresa/@CveNombreMetodoPago"/></td>
                   <th align="right" style="border-bottom: solid 1px {$color_fondo};">Descuento:</th>
                   <td align="right" style="border-bottom: solid 1px {$color_fondo};">$ 0.00<xsl:value-of select="@Descuento"/></td>
               </tr>

               <tr>
               <td colspan="5" align="right">TRASLADOS: </td>

               <td ></td>
               <td ></td>
               </tr>

               <xsl:for-each select="./cfdi:Impuestos/cfdi:Traslados/cfdi:Traslado">
                    <tr>
                      <td colspan="5" ></td>
                      <th  align="right" style="border-bottom: solid 1px {$color_fondo};">
                        <xsl:if test="@Impuesto='002'">IVA </xsl:if>
                        <xsl:if test="@Impuesto='003'">IEPS </xsl:if>
                        <xsl:value-of select="@TasaOCuota * 100"/> %
                      </th>
                      <td align="right" style="border-bottom: solid 1px {$color_fondo};">$ <xsl:value-of select="@Importe"/></td>
                    </tr>
              </xsl:for-each>
               <tr id="total">
                 <!--td colspan="5"></td-->
                 <td colspan="5" align="center" style="font-size:12px;"><xsl:value-of select="cfdi:RepresentacionImpresa/@TotalLetras"/></td>
                   <th align="right"><b>Total:</b></th><td align="right" ><b>$ <xsl:value-of select="@Total"/></b></td>
               </tr>
              </table>
           </tr>
          <!--hr style="border:4px solid {$color_banda};" /-->
          <tr>
            <table>
              <thead>
                <th></th>
                <th style="color: {$color_titulos}; background-color: {$color_fondo};">SELLOS DIGITALES Y CADENA</th>
              </thead>
              <tbody>
                <tr>
                  <td>
                    <xsl:element name="img">
                      <xsl:attribute name="src"><xsl:value-of select="cfdi:RepresentacionImpresa/@CodigoQR"/></xsl:attribute>
                      <xsl:attribute name="height">120</xsl:attribute>
                      <xsl:attribute name="width">120</xsl:attribute>
                    </xsl:element>
                  </td>
                  <td>
                    <table>
                      <tr><td><b>SELLO DIGITAL DEL CFDI: </b><small><xsl:value-of select="@Sello"/>eXDsJQJbPAW6HBDKtCAyfdD9n61t75JwglLcMZo9zrFk7FbpGgl5PiztPJsVkhHRusaZsMorKhCUmAlD6Ni+9TH7rk7/J/dTrQvMLgIy3crFw0HwwuK1O/LibjJMBqzEAGLw+b7SIt
+HlH9Y1VtPEB9hSdcyoEFXnzKJ0WnW3PWrpOpq7XX34rubJfCaod5QVDbUipj5ze3kyrh8yeCR5fHGwMUw0mMtW6xKu0bhNGfktUsiwhT/Jnklm1nDK9cWjinqpHFMgDscQGKE7PR9
VhBxbkAMOBSIF6x5x9Vweeb2hwy4LI526vEw12+QrjKqwQ0vItptbXhAowhbh2hh2Q==</small></td></tr>
                      <tr><td><b>SELLO DIGITAL DEL SAT: </b><small><xsl:value-of select="//@SelloSAT"/>mzvoBoMdpLUODingtlU7maQEBmXxeRMsCee/cJXIv0MBaSne7L9FHDoUP33q0cB0NSl/+apwp7dQ40VX35zgEZBFSRzpvJzLRLnNOv2faoCb0PWuplzpLqDtc02gcYGxpMmsNVhn5f
7oUw2q8RS1WH9/KgYUQcqg8tvC7+PBKKyvvAHoL/6Oj5cuDqNU/WwE5jWyfOf8TeZgL3GxcojXCq39kcI3AhCFfp6EdRrlzaMcRaY//wpBJthj3hI446IVVuxuoJ+NsyFRaTKSovLf
LS/daTHg+faVakYXFk7SPlYVVrwR2GUIYfzUuNhfGU5Nfi4vKvgq/2XLHMC+/l8z0A==</small></td></tr>
                      <tr><td><b>CADENA ORIGINAL DEL COMPLEMENTO DE CERTIFICACIÓN DIGITAL DEL SAT: </b><small><xsl:value-of select="cfdi:RepresentacionImpresa/@CadOrigComplemento"/>||1.1|82F74B84-9B4E-47DC-9BE2-4D259D2456E6|2018-08-22T03:37:05|IAD121214B34|eXDsJQJbPAW6HBDKtCAyfdD9n61t75JwglLcMZo9zrFk7FbpGgl5PiztPJsVkh
HRusaZsMorKhCUmAlD6Ni+9TH7rk7/J/dTrQvMLgIy3crFw0HwwuK1O/LibjJMBqzEAGLw+b7SIt+HlH9Y1VtPEB9hSdcyoEFXnzKJ0WnW3PWrpOpq7XX34rubJfCaod5QVDbUipj5
ze3kyrh8yeCR5fHGwMUw0mMtW6xKu0bhNGfktUsiwhT/Jnklm1nDK9cWjinqpHFMgDscQGKE7PR9VhBxbkAMOBSIF6x5x9Vweeb2hwy4LI526vEw12+QrjKqwQ0vItptbXhAowhbh2
hh2Q==|20001000000300022323||</small></td>
                      </tr>
                    </table>
                  </td>
                </tr>
              </tbody>
            </table>  
          </tr>

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
          </table>
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
