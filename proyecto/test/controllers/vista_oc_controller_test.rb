require 'test_helper'

class VistaOcControllerTest < ActionController::TestCase
  test "should get generarVista" do
    get :generarVista
    assert_response :success
  end

end
