require 'test_helper'

class GastoGeneralsControllerTest < ActionController::TestCase
  setup do
    @gasto_general = gasto_generals(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:gasto_generals)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create gasto_general" do
    assert_difference('GastoGeneral.count') do
      post :create, gasto_general: { concepto: @gasto_general.concepto, folio_gasto: @gasto_general.folio_gasto, gasto_id: @gasto_general.gasto_id, monto: @gasto_general.monto, negocio_id: @gasto_general.negocio_id, sucursal_id: @gasto_general.sucursal_id, ticket_gasto: @gasto_general.ticket_gasto, user_id: @gasto_general.user_id }
    end

    assert_redirected_to gasto_general_path(assigns(:gasto_general))
  end

  test "should show gasto_general" do
    get :show, id: @gasto_general
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @gasto_general
    assert_response :success
  end

  test "should update gasto_general" do
    patch :update, id: @gasto_general, gasto_general: { concepto: @gasto_general.concepto, folio_gasto: @gasto_general.folio_gasto, gasto_id: @gasto_general.gasto_id, monto: @gasto_general.monto, negocio_id: @gasto_general.negocio_id, sucursal_id: @gasto_general.sucursal_id, ticket_gasto: @gasto_general.ticket_gasto, user_id: @gasto_general.user_id }
    assert_redirected_to gasto_general_path(assigns(:gasto_general))
  end

  test "should destroy gasto_general" do
    assert_difference('GastoGeneral.count', -1) do
      delete :destroy, id: @gasto_general
    end

    assert_redirected_to gasto_generals_path
  end
end
