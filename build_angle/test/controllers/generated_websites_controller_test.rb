require "test_helper"

class GeneratedWebsitesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get generated_websites_show_url
    assert_response :success
  end
end
