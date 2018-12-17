

  $(document).ready(function() {
    $('#btn_guardar_plantilla').click(function() {
      $('.flash').html("<div class='alert alert-success alert-dismissable notice'><button type='button' class='close' data-dismiss='alert'>&times;</button><span>Los cambios para la plantilla de email seleccionada se han guardado correctamente.</span></div>");
    });
    setTimeout(function() {
        $(".notice").fadeOut(1500);
    },10000);
  });


   var texto_variable = ['Nombre del cliente','Fecha','Número','Folio','Total','Nombre del negocio','Nombre de la sucursal','Email de contacto','Teléfono de contacto']
  
    /*Editor de texto para los asuntos de las plantillas de email solo permite poner texto variable sin aplicar formato al texto*/
    $('#summernote_asunto').summernote({
        tabsize: 2,
        minHeight: 40,
        maxHeight: 40,
        maxWidth: 200,
        disableResizeEditor: true,
        lang: 'es-ES', // default: 'en-US'
        toolbar: false,
        //Se aprovecha la funcionalidad de las sugerencias de summernote para brindarle al usuario la opcion de agregar texto variable.
        hint: {
          mentions: texto_variable,
          match: /\B@(\w*)$/,
          search: function (keyword, callback) {
            callback($.grep(this.mentions, function (item) {
              return item.indexOf(keyword) == 0;
            }));
          },
          content: function (item) {
            return '{{' + item + '}}';
          }
        },
    });

      $('#summernote').summernote({
        tabsize: 2,
        height: 170, 
        disableResizeEditor: true,
        //airMode: true,
        lang: 'es-ES', // default: 'en-US'
        //Se aprovecha la funcionalidad de las sugerencias de summernote para brindarle al usuario la opcion de agregar texto variable.
        hint: {
          mentions: texto_variable,
          match: /\B@(\w*)$/,
          search: function (keyword, callback) {
            callback($.grep(this.mentions, function (item) {
              return item.indexOf(keyword) == 0;
            }));
          },
          content: function (item) {
            return '{{' + item + '}}';
          }
        },

        toolbar: [
        // [groupName, [list of button]]
        ['fontname',['fontname']],
        ['fontsize', ['fontsize']],
        ['style', ['bold', 'italic', 'underline', 'clear']],
        ['font', ['strikethrough', 'superscript', 'subscript']],
        ['color', ['color']],
        ['para', ['ul', 'ol', 'paragraph']],
        ['height', ['height']],
        ['insert',['link','table','hr']],
        ['misc',['undo','redo']]

      ]
    });
