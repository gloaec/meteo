require 'test_helper'

class FtpsControllerTest < ActionController::TestCase
  setup do
    @ftp = ftps(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:ftps)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create ftp" do
    assert_difference('Ftp.count') do
      post :create, ftp: { channel: @ftp.channel, host: @ftp.host, password_digest: @ftp.password_digest, post: @ftp.post, root_path: @ftp.root_path, user: @ftp.user }
    end

    assert_redirected_to ftp_path(assigns(:ftp))
  end

  test "should show ftp" do
    get :show, id: @ftp
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @ftp
    assert_response :success
  end

  test "should update ftp" do
    patch :update, id: @ftp, ftp: { channel: @ftp.channel, host: @ftp.host, password_digest: @ftp.password_digest, post: @ftp.post, root_path: @ftp.root_path, user: @ftp.user }
    assert_redirected_to ftp_path(assigns(:ftp))
  end

  test "should destroy ftp" do
    assert_difference('Ftp.count', -1) do
      delete :destroy, id: @ftp
    end

    assert_redirected_to ftps_path
  end
end
