class Admin::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin!
  before_action :set_user, except: [ :index, :new, :create, :import ]

  def index
    # @users = User.all.order(admin: :desc)
    @users = User.all.order(:id)
  end

  def show
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to admin_users_path, notice: "User created."
    else
      puts @user.errors.full_messages
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to admin_users_path, notice: "User updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy
    redirect_to admin_users_path, notice: "User deleted."
  end

  def toggle_role
    @user.update(admin: !@user.admin)
    redirect_to admin_users_path, notice: "User role updated."
  end

  def import
    file = params[:file]
    return unless validate_import_file(file)

    CsvImportUsersService.new.call(file)
    redirect_to admin_users_path, notice: "File imported successfully."
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def authorize_admin!
    redirect_to root_path, alert: "Access denied" unless current_user.admin?
  end

  def user_params
    attributes = [ :full_name, :email, :password, :password_confirmation, :avatar ]
    user_params = params.expect(user: attributes)

    if action_name == "update"
      if user_params[:password].blank? && user_params[:password_confirmation].blank?
        user_params.delete(:password)
        user_params.delete(:password_confirmation)
      end
    end

    user_params
  end

  ALLOWED_CONTENT_TYPES = [ "text/csv" ].freeze

  def validate_import_file(file)
    if file.blank?
      redirect_to admin_users_path, alert: "Please choose a file to upload."
      return false
    end

    unless ALLOWED_CONTENT_TYPES.include?(file.content_type)
      redirect_to admin_users_path, alert: "Only CSV files are allowed."
      return false
    end

    true
  end
end
