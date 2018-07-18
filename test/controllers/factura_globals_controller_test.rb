require 'test_helper'

class FacturaGlobalsControllerTest < ActionController::TestCase
  setup do
    @factura_global = factura_globals(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:factura_globals)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create factura_global" do
    assert_difference('FacturaGlobal.count') do
      post :create, factura_global: { consecutivo: @factura_global.consecutivo, estado_factura: @factura_global.estado_factura, factura_forma_pago_id: @factura_global.factura_forma_pago_id, fecha_expedicion: @factura_global.fecha_expedicion, folio: @factura_global.folio, folio_fiscal: @factura_global.folio_fiscal, monto: @factura_global.monto, negocio_id: @factura_global.negocio_id, ruta_storage: @factura_global.ruta_storage, sucursal_id: @factura_global.sucursal_id, user_id: @factura_global.user_id }
    end

    assert_redirected_to factura_global_path(assigns(:factura_global))
  end

  test "should show factura_global" do
    get :show, id: @factura_global
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @factura_global
    assert_response :success
  end

  test "should update factura_global" do
    patch :update, id: @factura_global, factura_global: { consecutivo: @factura_global.consecutivo, estado_factura: @factura_global.estado_factura, factura_forma_pago_id: @factura_global.factura_forma_pago_id, fecha_expedicion: @factura_global.fecha_expedicion, folio: @factura_global.folio, folio_fiscal: @factura_global.folio_fiscal, monto: @factura_global.monto, negocio_id: @factura_global.negocio_id, ruta_storage: @factura_global.ruta_storage, sucursal_id: @factura_global.sucursal_id, user_id: @factura_global.user_id }
    assert_redirected_to factura_global_path(assigns(:factura_global))
  end

  test "should destroy factura_global" do
    assert_difference('FacturaGlobal.count', -1) do
      delete :destroy, id: @factura_global
    end

    assert_redirected_to factura_globals_path
  end
end
