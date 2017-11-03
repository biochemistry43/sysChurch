require 'test_helper'

class FacturaElectronicasControllerTest < ActionController::TestCase
  setup do
    @factura_electronica = factura_electronicas(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:factura_electronicas)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create factura_electronica" do
    assert_difference('FacturaElectronica.count') do
      post :create, factura_electronica: { cliente_id_id: @factura_electronica.cliente_id_id, estado_factura: @factura_electronica.estado_factura, fecha_expedicion: @factura_electronica.fecha_expedicion, folio: @factura_electronica.folio, forma_pago_id_id: @factura_electronica.forma_pago_id_id, negocio_id_id: @factura_electronica.negocio_id_id, sucursal_id: @factura_electronica.sucursal_id, user_id_id: @factura_electronica.user_id_id, venta_id_id: @factura_electronica.venta_id_id }
    end

    assert_redirected_to factura_electronica_path(assigns(:factura_electronica))
  end

  test "should show factura_electronica" do
    get :show, id: @factura_electronica
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @factura_electronica
    assert_response :success
  end

  test "should update factura_electronica" do
    patch :update, id: @factura_electronica, factura_electronica: { cliente_id_id: @factura_electronica.cliente_id_id, estado_factura: @factura_electronica.estado_factura, fecha_expedicion: @factura_electronica.fecha_expedicion, folio: @factura_electronica.folio, forma_pago_id_id: @factura_electronica.forma_pago_id_id, negocio_id_id: @factura_electronica.negocio_id_id, sucursal_id: @factura_electronica.sucursal_id, user_id_id: @factura_electronica.user_id_id, venta_id_id: @factura_electronica.venta_id_id }
    assert_redirected_to factura_electronica_path(assigns(:factura_electronica))
  end

  test "should destroy factura_electronica" do
    assert_difference('FacturaElectronica.count', -1) do
      delete :destroy, id: @factura_electronica
    end

    assert_redirected_to factura_electronicas_path
  end
end
