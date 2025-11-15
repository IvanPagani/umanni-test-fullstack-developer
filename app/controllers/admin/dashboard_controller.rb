class Admin::DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin!

  def index
    @total_users = User.count
    @total_admins = User.where(admin: true).count
    @total_regulars = User.where(admin: false).count
  end

  private

  def authorize_admin!
    redirect_to root_path, alert: "Access denied." unless current_user.admin?
  end
end
