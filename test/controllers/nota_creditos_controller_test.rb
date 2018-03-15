require 'test_helper'

class NotaCreditosControllerTest < ActionController::TestCase
  setup do
    @nota_credito = nota_creditos(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:nota_creditos)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create nota_credito" do
    assert_difference('NotaCredito.count') do
      post :create, nota_credito: { cliente_id: @nota_credito.cliente_id, fecha_expedicion: @nota_credito.fecha_expedicion, folio: @nota_credito.folio, monto_devolucion: @nota_credito.monto_devolucion, motivo: @nota_credito.motivo, negocio_id: @nota_credito.negocio_id, sucursal_id: @nota_credito.sucursal_id, user_id: @nota_credito.user_id }
    end

    assert_redirected_to nota_credito_path(assigns(:nota_credito))
  end

  test "should show nota_credito" do
    get :show, id: @nota_credito
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @nota_credito
    assert_response :success
  end

  test "should update nota_credito" do
    patch :update, id: @nota_credito, nota_credito: { cliente_id: @nota_credito.cliente_id, fecha_expedicion: @nota_credito.fecha_expedicion, folio: @nota_credito.folio, monto_devolucion: @nota_credito.monto_devolucion, motivo: @nota_credito.motivo, negocio_id: @nota_credito.negocio_id, sucursal_id: @nota_credito.sucursal_id, user_id: @nota_credito.user_id }
    assert_redirected_to nota_credito_path(assigns(:nota_credito))
  end

  test "should destroy nota_credito" do
    assert_difference('NotaCredito.count', -1) do
      delete :destroy, id: @nota_credito
    end

    assert_redirected_to nota_creditos_path
  end
end
