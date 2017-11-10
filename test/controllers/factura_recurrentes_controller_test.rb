require 'test_helper'

class FacturaRecurrentesControllerTest < ActionController::TestCase
  setup do
    @factura_recurrente = factura_recurrentes(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:factura_recurrentes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create factura_recurrente" do
    assert_difference('FacturaRecurrente.count') do
      post :create, factura_recurrente: { cliente_id: @factura_recurrente.cliente_id, estado_factura: @factura_recurrente.estado_factura, fecha_expedicion: @factura_recurrente.fecha_expedicion, folio: @factura_recurrente.folio, forma_pago_id: @factura_recurrente.forma_pago_id, negocio_id: @factura_recurrente.negocio_id, sucursal_id: @factura_recurrente.sucursal_id, tiempo_recurrente: @factura_recurrente.tiempo_recurrente, user_id: @factura_recurrente.user_id }
    end

    assert_redirected_to factura_recurrente_path(assigns(:factura_recurrente))
  end

  test "should show factura_recurrente" do
    get :show, id: @factura_recurrente
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @factura_recurrente
    assert_response :success
  end

  test "should update factura_recurrente" do
    patch :update, id: @factura_recurrente, factura_recurrente: { cliente_id: @factura_recurrente.cliente_id, estado_factura: @factura_recurrente.estado_factura, fecha_expedicion: @factura_recurrente.fecha_expedicion, folio: @factura_recurrente.folio, forma_pago_id: @factura_recurrente.forma_pago_id, negocio_id: @factura_recurrente.negocio_id, sucursal_id: @factura_recurrente.sucursal_id, tiempo_recurrente: @factura_recurrente.tiempo_recurrente, user_id: @factura_recurrente.user_id }
    assert_redirected_to factura_recurrente_path(assigns(:factura_recurrente))
  end

  test "should destroy factura_recurrente" do
    assert_difference('FacturaRecurrente.count', -1) do
      delete :destroy, id: @factura_recurrente
    end

    assert_redirected_to factura_recurrentes_path
  end
end
