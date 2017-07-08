require 'test_helper'

class ReporteGastosControllerTest < ActionController::TestCase
  test "should get reporte_gastos" do
    get :reporte_gastos
    assert_response :success
  end

end
