require 'test_helper'

class TipoUsuariosControllerTest < ActionController::TestCase
  setup do
    @tipo_usuario = tipo_usuarios(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:tipo_usuarios)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create tipo_usuario" do
    assert_difference('TipoUsuario.count') do
      post :create, tipo_usuario: { descripcionTipo: @tipo_usuario.descripcionTipo, isGastos: @tipo_usuario.isGastos, isInventarios: @tipo_usuario.isInventarios, isPerdidas: @tipo_usuario.isPerdidas, isPersonas: @tipo_usuario.isPersonas, isVentas: @tipo_usuario.isVentas, nombreTipo: @tipo_usuario.nombreTipo }
    end

    assert_redirected_to tipo_usuario_path(assigns(:tipo_usuario))
  end

  test "should show tipo_usuario" do
    get :show, id: @tipo_usuario
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @tipo_usuario
    assert_response :success
  end

  test "should update tipo_usuario" do
    patch :update, id: @tipo_usuario, tipo_usuario: { descripcionTipo: @tipo_usuario.descripcionTipo, isGastos: @tipo_usuario.isGastos, isInventarios: @tipo_usuario.isInventarios, isPerdidas: @tipo_usuario.isPerdidas, isPersonas: @tipo_usuario.isPersonas, isVentas: @tipo_usuario.isVentas, nombreTipo: @tipo_usuario.nombreTipo }
    assert_redirected_to tipo_usuario_path(assigns(:tipo_usuario))
  end

  test "should destroy tipo_usuario" do
    assert_difference('TipoUsuario.count', -1) do
      delete :destroy, id: @tipo_usuario
    end

    assert_redirected_to tipo_usuarios_path
  end
end
