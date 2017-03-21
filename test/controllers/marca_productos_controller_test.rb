require 'test_helper'

class MarcaProductosControllerTest < ActionController::TestCase
  setup do
    @marca_producto = marca_productos(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:marca_productos)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create marca_producto" do
    assert_difference('MarcaProducto.count') do
      post :create, marca_producto: { nombre: @marca_producto.nombre }
    end

    assert_redirected_to marca_producto_path(assigns(:marca_producto))
  end

  test "should show marca_producto" do
    get :show, id: @marca_producto
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @marca_producto
    assert_response :success
  end

  test "should update marca_producto" do
    patch :update, id: @marca_producto, marca_producto: { nombre: @marca_producto.nombre }
    assert_redirected_to marca_producto_path(assigns(:marca_producto))
  end

  test "should destroy marca_producto" do
    assert_difference('MarcaProducto.count', -1) do
      delete :destroy, id: @marca_producto
    end

    assert_redirected_to marca_productos_path
  end
end
