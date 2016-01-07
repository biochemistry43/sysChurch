require 'test_helper'

class CategoriaGastosControllerTest < ActionController::TestCase
  setup do
    @categoria_gasto = categoria_gastos(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:categoria_gastos)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create categoria_gasto" do
    assert_difference('CategoriaGasto.count') do
      post :create, categoria_gasto: { descripcionCategoria: @categoria_gasto.descripcionCategoria, idCategoriaPadre: @categoria_gasto.idCategoriaPadre, nombreCategoria: @categoria_gasto.nombreCategoria }
    end

    assert_redirected_to categoria_gasto_path(assigns(:categoria_gasto))
  end

  test "should show categoria_gasto" do
    get :show, id: @categoria_gasto
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @categoria_gasto
    assert_response :success
  end

  test "should update categoria_gasto" do
    patch :update, id: @categoria_gasto, categoria_gasto: { descripcionCategoria: @categoria_gasto.descripcionCategoria, idCategoriaPadre: @categoria_gasto.idCategoriaPadre, nombreCategoria: @categoria_gasto.nombreCategoria }
    assert_redirected_to categoria_gasto_path(assigns(:categoria_gasto))
  end

  test "should destroy categoria_gasto" do
    assert_difference('CategoriaGasto.count', -1) do
      delete :destroy, id: @categoria_gasto
    end

    assert_redirected_to categoria_gastos_path
  end
end
