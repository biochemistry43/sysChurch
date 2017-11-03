require 'test_helper'

class FacturasControllerTest < ActionController::TestCase
  setup do
    @factura = facturas(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:facturas)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create factura" do
    assert_difference('Factura.count') do
      post :create, factura: { cliente_id: @factura.cliente_id, estado_factura: @factura.estado_factura, fecha_expedicion: @factura.fecha_expedicion, folio: @factura.folio, forma_pago_id: @factura.forma_pago_id, negocio_id: @factura.negocio_id, sucursal_id: @factura.sucursal_id, user_id: @factura.user_id, venta_id: @factura.venta_id }
    end

    assert_redirected_to factura_path(assigns(:factura))
  end

  test "should show factura" do
    get :show, id: @factura
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @factura
    assert_response :success
  end

  test "should update factura" do
    patch :update, id: @factura, factura: { cliente_id: @factura.cliente_id, estado_factura: @factura.estado_factura, fecha_expedicion: @factura.fecha_expedicion, folio: @factura.folio, forma_pago_id: @factura.forma_pago_id, negocio_id: @factura.negocio_id, sucursal_id: @factura.sucursal_id, user_id: @factura.user_id, venta_id: @factura.venta_id }
    assert_redirected_to factura_path(assigns(:factura))
  end

  test "should destroy factura" do
    assert_difference('Factura.count', -1) do
      delete :destroy, id: @factura
    end

    assert_redirected_to facturas_path
  end
end
