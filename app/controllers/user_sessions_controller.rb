class UserSessionsController < ApplicationController
  skip_before_filter :require_user, :check_role

  def new
    @user_session = UserSession.new
  end

  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      flash[:notice] = nil
      redirect_back_or_default users_url
    else
      flash[:notice] = "Login failed"
      #redirect_to :action => :new
      render :action => :new
    end
  end

  def destroy
    current_user_session.destroy
    redirect_back_or_default root_url
  end
end
