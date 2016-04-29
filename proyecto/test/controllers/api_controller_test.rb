require 'test_helper'

class ApiControllerTest < ActionController::TestCase
  test "should get consultar" do
    get :consultar
    assert_response :success
  end

end
