require 'test_helper'

class ConfigComprobantesControllerTest < ActionController::TestCase
  setup do
    @config_comprobante = config_comprobantes(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:config_comprobantes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create config_comprobante" do
    assert_difference('ConfigComprobante.count') do
      post :create, config_comprobante: { asunto_email: @config_comprobante.asunto_email, color_banda: @config_comprobante.color_banda, color_fondo: @config_comprobante.color_fondo, color_titulos: @config_comprobante.color_titulos, msg_email: @config_comprobante.msg_email, negocio_id: @config_comprobante.negocio_id, tam_fuente: @config_comprobante.tam_fuente, tipo_comprobante: @config_comprobante.tipo_comprobante, tipo_fuente: @config_comprobante.tipo_fuente }
    end

    assert_redirected_to config_comprobante_path(assigns(:config_comprobante))
  end

  test "should show config_comprobante" do
    get :show, id: @config_comprobante
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @config_comprobante
    assert_response :success
  end

  test "should update config_comprobante" do
    patch :update, id: @config_comprobante, config_comprobante: { asunto_email: @config_comprobante.asunto_email, color_banda: @config_comprobante.color_banda, color_fondo: @config_comprobante.color_fondo, color_titulos: @config_comprobante.color_titulos, msg_email: @config_comprobante.msg_email, negocio_id: @config_comprobante.negocio_id, tam_fuente: @config_comprobante.tam_fuente, tipo_comprobante: @config_comprobante.tipo_comprobante, tipo_fuente: @config_comprobante.tipo_fuente }
    assert_redirected_to config_comprobante_path(assigns(:config_comprobante))
  end

  test "should destroy config_comprobante" do
    assert_difference('ConfigComprobante.count', -1) do
      delete :destroy, id: @config_comprobante
    end

    assert_redirected_to config_comprobantes_path
  end
end
