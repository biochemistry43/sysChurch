require 'test_helper'

class UsoCfdisControllerTest < ActionController::TestCase
  setup do
    @uso_cfdi = uso_cfdis(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:uso_cfdis)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create uso_cfdi" do
    assert_difference('UsoCfdi.count') do
      post :create, uso_cfdi: { clave: @uso_cfdi.clave, descripcion: @uso_cfdi.descripcion }
    end

    assert_redirected_to uso_cfdi_path(assigns(:uso_cfdi))
  end

  test "should show uso_cfdi" do
    get :show, id: @uso_cfdi
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @uso_cfdi
    assert_response :success
  end

  test "should update uso_cfdi" do
    patch :update, id: @uso_cfdi, uso_cfdi: { clave: @uso_cfdi.clave, descripcion: @uso_cfdi.descripcion }
    assert_redirected_to uso_cfdi_path(assigns(:uso_cfdi))
  end

  test "should destroy uso_cfdi" do
    assert_difference('UsoCfdi.count', -1) do
      delete :destroy, id: @uso_cfdi
    end

    assert_redirected_to uso_cfdis_path
  end
end
