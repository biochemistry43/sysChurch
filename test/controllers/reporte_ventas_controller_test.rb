require 'test_helper'

class ReporteVentasControllerTest < ActionController::TestCase
  test "should get reporte_ventas" do
    get :reporte_ventas
    assert_response :success
  end

end
