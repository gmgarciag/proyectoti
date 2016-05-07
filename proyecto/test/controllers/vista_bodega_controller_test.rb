require 'test_helper'

class VistaBodegaControllerTest < ActionController::TestCase
  test "should get generarVista" do
    get :generarVista
    assert_response :success
  end

end
