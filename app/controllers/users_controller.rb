class UsersController < ApplicationController
  before_action :logged_in, only: :update #更新之前必须先登录
  before_action :correct_user, only: [:update, :destroy]  #为了重定向试图编辑其他用户资料的 用户，设置前置过滤调用这个方法

  def new
    @user=User.new  #创建注册页面form-for的用户对象，然后赋值给@user
  end

  def create
    @user = User.new(user_params)  #创建一个新用户
    if @user.save
      #处理注册成功情况
      redirect_to root_url, flash: {success: "新账号注册成功,请登陆"}
    else
      flash[:warning] = "账号信息填写有误,请重试"
      render 'new'
    end
  end

  def edit
    @user=User.find_by_id(params[:id])
  end

  def update
    @user = User.find_by_id(params[:id])
    if @user.update_attributes(user_params)
      flash={:info => "更新成功"}
    else
      flash={:warning => "更新失败"}
    end
    redirect_to root_path, flash: flash
  end

  def destroy
    @user = User.find_by_id(params[:id])
    @user.destroy
    redirect_to users_path(new: false), flash: {success: "用户删除"}
  end


#----------------------------------- students function--------------------



  private

  def user_params #只会在Users控制器内不使用，不需要开放给外部用户
    params.require(:user).permit(:name, :email, :major, :department, :password,
                                 :password_confirmation)
  end

  # Confirms a logged-in user.确保用户已登录
  def logged_in
    unless logged_in?
      redirect_to root_url, flash: {danger: '请登陆'}
    end
  end

  # Confirms the correct user.
  def correct_user
    @user = User.find(params[:id])
    unless current_user?(@user)
      redirect_to root_url, flash: {:warning => '此操作需要管理员身份'}
    end
  end

  # Confirms a logged-in user.
  def teacher_logged_in
    unless teacher_logged_in?
      redirect_to root_url, flash: {danger: '请登陆'}
    end
  end

end
