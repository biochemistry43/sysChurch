require 'test_helper'

class CatArticulosControllerTest < ActionController::TestCase
  setup do
    @cat_articulo = cat_articulos(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:cat_articulos)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create cat_articulo" do
    assert_difference('CatArticulo.count') do
      post :create, cat_articulo: { descripcionCatArticulo: @cat_articulo.descripcionCatArticulo, idCategoriaPadre: @cat_articulo.idCategoriaPadre, nombreCatArticulo: @cat_articulo.nombreCatArticulo }
    end

    assert_redirected_to cat_articulo_path(assigns(:cat_articulo))
  end

  test "should show cat_articulo" do
    get :show, id: @cat_articulo
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @cat_articulo
    assert_response :success
  end

  test "should update cat_articulo" do
    patch :update, id: @cat_articulo, cat_articulo: { descripcionCatArticulo: @cat_articulo.descripcionCatArticulo, idCategoriaPadre: @cat_articulo.idCategoriaPadre, nombreCatArticulo: @cat_articulo.nombreCatArticulo }
    assert_redirected_to cat_articulo_path(assigns(:cat_articulo))
  end

  test "should destroy cat_articulo" do
    assert_difference('CatArticulo.count', -1) do
      delete :destroy, id: @cat_articulo
    end

    assert_redirected_to cat_articulos_path
  end
end
