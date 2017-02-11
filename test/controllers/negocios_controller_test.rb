require 'test_helper'

class NegociosControllerTest < ActionController::TestCase
  setup do
    @negocio = negocios(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:negocios)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create negocio" do
    assert_difference('Negocio.count') do
      post :create, negocio: { direccion: @negocio.direccion, logo: @negocio.logo, nombre: @negocio.nombre, representante: @negocio.representante, user_id: @negocio.user_id }
    end

    assert_redirected_to negocio_path(assigns(:negocio))
  end

  test "should show negocio" do
    get :show, id: @negocio
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @negocio
    assert_response :success
  end

  test "should update negocio" do
    patch :update, id: @negocio, negocio: { direccion: @negocio.direccion, logo: @negocio.logo, nombre: @negocio.nombre, representante: @negocio.representante, user_id: @negocio.user_id }
    assert_redirected_to negocio_path(assigns(:negocio))
  end

  test "should destroy negocio" do
    assert_difference('Negocio.count', -1) do
      delete :destroy, id: @negocio
    end

    assert_redirected_to negocios_path
  end
end
