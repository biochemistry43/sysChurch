require 'test_helper'

class PlantillasEmailsControllerTest < ActionController::TestCase
  setup do
    @plantillas_email = plantillas_emails(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:plantillas_emails)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create plantillas_email" do
    assert_difference('PlantillasEmail.count') do
      post :create, plantillas_email: { asunto_email: @plantillas_email.asunto_email, comprobante: @plantillas_email.comprobante, msg_email: @plantillas_email.msg_email, negocio_id: @plantillas_email.negocio_id }
    end

    assert_redirected_to plantillas_email_path(assigns(:plantillas_email))
  end

  test "should show plantillas_email" do
    get :show, id: @plantillas_email
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @plantillas_email
    assert_response :success
  end

  test "should update plantillas_email" do
    patch :update, id: @plantillas_email, plantillas_email: { asunto_email: @plantillas_email.asunto_email, comprobante: @plantillas_email.comprobante, msg_email: @plantillas_email.msg_email, negocio_id: @plantillas_email.negocio_id }
    assert_redirected_to plantillas_email_path(assigns(:plantillas_email))
  end

  test "should destroy plantillas_email" do
    assert_difference('PlantillasEmail.count', -1) do
      delete :destroy, id: @plantillas_email
    end

    assert_redirected_to plantillas_emails_path
  end
end
