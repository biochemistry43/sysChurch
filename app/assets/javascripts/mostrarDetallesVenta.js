
//Con esta petición ajax, se llena el modal de clientes.
$.ajax({
  //Los datos se obtienen en json
  url: "/clientes.json",
  dataType: "JSON",
  timeout: 10000,
  beforeSend: function(){

  },
  error: function(){
    alert("Error al cargar la lista de clientes.");
  },
  //Una vez recibida la respuesta del servidor, se construye una tabla con clientes dentro de un modal.
  success: function(res){

    var resLength = res.length;

    for(i=0; i < resLength; i++){
      var element = res[i];

      /* lista_clientes es la tabla que está dentro del modal con la lista de los clientes.
       * por cada cliente que se agrega a la tabla, se añade un botón con el método onclick
       * para cambiar los datos
       * del cliente dentro de la pantalla de venta**/
      $("#lista_clientes").append(""+

          "<tr class='even pointer'><td>"+element.nombre+" "+element.ape_pat+" "+element.ape_mat+"</td>"+
          "<td>"+element.telefono1+"</td>"+
          "<td>"+element.email+"</td>"+
          "<td><button class='btn btn-success btn-xs' "+
                  "onclick='cambiarCliente(\""+element.id+"\", \""+element.nombre+" "+element.ape_pat+" "+element.ape_mat+"\", \""+element.telefono1+"\", \""+element.email+"\")' >"+
                    "<i class='fa fa-check-square'></i> Seleccionar </button></td></tr>");

    }

    /* Una vez que se han cargado los datos en la tabla, convertimos nuestra tabla en una tabla DataTable.
     * El plugin Datatable fue instalado mediante la gema 'jquery-datatables-rails'.
     * Para más información:  https://github.com/rweng/jquery-datatables-rails
     * La funcionalidad de ser responsiva fue añadida a la tabla.
     */
    $('#lista_clientes').DataTable({
      responsive: true,
      "language":{
        "info": "Mostrar pag _PAGE_ de _PAGES_",
        "lengthMenu": "Mostrar _MENU_ registros",
        "zeroRecords": "No hay coincidencias",
        "search": "Buscar: _INPUT_",
        "infoFiltered": " - encontrados en _MAX_ registros",
        "paginate": {
          "previous": "Anterior",
          "next" : "siguiente",
          "last" : "último",
          "first" : "primero"
        }
      }
    });



  }//Termina success de la petición ajax

}); //Termina petición ajax de la lista de clientes.

//Esta acción abre el modal que permite cambiar el cliente de una venta
$("#cambiarClienteBtn").on("click", function(e){

  $('#modalClie').modal('show');

});
/*
* Esta función permite cambiar los valores del cuadro de clientes en base al cliente elegido
* En el modal de clientes
*/
function cambiarCliente(id, nombre, telefono, email){
 //Se guarda el id del cliente elegido en un input hidden
 $("#id_cliente").val(id);

 //Se llenan los campos de acuerdo al cliente seleccionado por el usuario.
 $("#nombre_fiscal_receptor_vf").val("Pedro");
 $("#email_cliente").html("Email: <strong>"+email+"</strong>");
 $("#telefono_cliente").html("Teléfono: <strong>"+telefono+"</strong>");
 $("#modalClie").modal("hide");
}
