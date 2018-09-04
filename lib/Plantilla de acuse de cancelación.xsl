<xsl:stylesheet version = '1.0'
      xmlns:xsl='http://www.w3.org/1999/XSL/Transform'
      xmlns:cfdi='http://www.sat.gob.mx/cfd/3'>
  <xsl:output method = "html" />
  <xsl:template match="//Acuse">
     <html>
     <head>
     <link rel="stylesheet"  type="text/css" href="/home/daniel/Documentos/sysChurch/lib/factura.css"/>
     <!--Para acuses de cancelación de facturas de ventas, globales, notas de crédito y todo lo habido y por haber-->
     <title>Acuse de cancelación de CFDI</title>
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
     <!--Se obtienen los valores de la configuuración para las representaciones impresas de los acuses de cancelación -->
     <xsl:variable name="tipo_fuente"><xsl:value-of select="//Plantilla/@TipoFuente"/></xsl:variable>
     <xsl:variable name="tam_fuente"><xsl:value-of select="//Plantilla/@TamFuente"/></xsl:variable>
     <xsl:variable name="color_fondo"><xsl:value-of select="//Plantilla/@ColorFondo"/></xsl:variable>
     <xsl:variable name="color_banda"><xsl:value-of select="//Plantilla/@ColorBanda"/></xsl:variable>
     <xsl:variable name="color_titulos"><xsl:value-of select="//Plantilla/@ColorTitulos"/></xsl:variable>
     
      <div style="font-family: {$tipo_fuente}">
       <table width="100%" id="tablaRaiz" style="border: solid 10px {$color_fondo};" >
          <tr style="margin-top: 10px;">
            <table style="border: solid 1px {$color_fondo}; width: 100%">
              <tr>
                <th style="background-color: {$color_fondo}; width: 10px;"></th>
                <th style="text-align:center; width: 60px;"><h2>ACUSE DE CANCELACIÓN DE UN CFDI</h2></th>
                <th style="background-color: {$color_fondo}; width: 10px;"></th>
              </tr>
            </table>
          </tr>
        
          <!--h2><xsl:value-of select="//DatosInternosSistema/@Comprobante"/></h2></th-->

          <tr style="margin-top: 10px;">
            <!--Encabezado de todos los comprobantes. Información del negocio-->
 
              <table width="230px" style="border: solid 1px {$color_fondo}; text-align:center;">
                <tr>
                  <th style="color: {$color_titulos}; background-color: {$color_fondo}; font-size:18px;">Datos internos</th>
                </tr>
                <tr>
                  <th style="color: {$color_titulos}; background-color: {$color_fondo};">Serie: <xsl:value-of select="//DatosInternosSistema/@Serie"/></th>
                </tr>
                <tr>
                  <th style="color: {$color_titulos}; background-color: {$color_fondo};">Folio: <xsl:value-of select="//DatosInternosSistema/@Folio"/></th>
                </tr>
                <tr>
                  <th style="color: {$color_titulos}; background-color: {$color_fondo};">Fecha y hora: <xsl:value-of select="//DatosInternosSistema/@FechaExpedicion"/></th>
                </tr>
              </table>
          </tr>

          <!--Información del acuse de cancelación-->
          <tr style="margin-top: 10px;">
            <table style="border:none;">
              <tr>
                <tr>
                   <th lign="left">FECHA DE CANCELACIÓN:  </th>
                   <td style="text-align: left;"><xsl:value-of select="//@Fecha"/></td>
                </tr>
                <tr>
                   <th align="left">R.F.C. DEL EMISOR:  </th>
                   <td style="text-align: left;"><xsl:value-of select="//@RfcEmisor"/></td>
                </tr>
              </tr>
            </table>
          </tr>

          <tr>
            <td >
               <table style="border: solid 1px {$color_fondo};" width="100%" border="1">
                <thead>
                 <tr>
                  <th style="color: {$color_titulos}; background-color: {$color_fondo};">Folio fiscal:</th>
                  <th style="color: {$color_titulos}; background-color: {$color_fondo}; border-left: solid 1px #fff;">Estatus del CFDI:</th>
                </tr>
                </thead>
                <tbody class="emisor">
                  <tr><td style="text-align:center;"><xsl:value-of select="//Folios/UUID"/></td>
                      <xsl:if test="//Folios/EstatusUUID = '201'">
                        <td style="border-left: solid 1px {$color_fondo}; text-align:center;">Cancelado</td>
                      </xsl:if>
                  </tr>
               </tbody>
            </table>
          </td>
          </tr>
          <tr style="margin-top: 10px;">
            <table style="border:none;">
              <tr><th align="left">SELLO DEL SAT: </th></tr>
              <tr><td><small><xsl:value-of select="///Signature/SignatureValue"/></small></td></tr>
            </table>
          </tr>
          <!--hr style="border:4px solid {$color_banda};" /-->
        </table>
        <tr style="margin-top: 10px;">
          <table style="border:none">
            <tr>
              <td>
                Esta representación impresa del acuse de cancelación fue expedido por el sistema OMILOS (punto de venta) de KODIKAS. Pág web: kodikas.com.mx
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
        </div>
         Page <span class="page"></span> of <span class="topage"></span>
      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>
