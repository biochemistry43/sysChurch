

  $(document).ready(function() {
    $('#btn_guardar_plantilla').click(function() {
      $('.flash').html("<div class='alert alert-success alert-dismissable notice'><button type='button' class='close' data-dismiss='alert'>&times;</button><span>Los cambios para la plantilla de email seleccionada se han guardado correctamente.</span></div>");
    });
    setTimeout(function() {
        $(".notice").fadeOut(1500);
    },10000);
  });
