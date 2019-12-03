#登录和退出功能由Sessions控制器相应打rest动作处理
class SessionsController < ApplicationController
  include SessionsHelper

  def create
    user = User.find_by(email: login_params[:email].downcase) #使用提交打电子邮件地址从数据库中取出相应打用户
    if user && user.authenticate(login_params[:password]) #检测获取打用户是否有效
      #登入用户，然后重定向到用户资料页面
      log_in user #helpers
      params[:session][:remember_me] == '1' ? remember_user(user) : forget_user(user)#记住当前登录状态
      flash= {:info => "欢迎回来: #{user.name} :)"}
    else
      flash= {:danger => '账号或密码错误'}
    end
    redirect_to root_url, :flash => flash
  end

  def new

  end

  #销毁会话
  def destroy
    log_out if logged_in?
    redirect_to root_url
  end

  private
  def login_params
    params.require(:session).permit(:email, :password)
  end
end
