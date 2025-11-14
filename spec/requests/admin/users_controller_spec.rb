require 'rails_helper'

RSpec.describe "Admin::UsersController", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:user)  { create(:user) }

  describe "authentication and authorization" do
    it "redirects unauthenticated users" do
      get admin_users_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it "denies access to non-admins" do
      sign_in user
      get admin_users_path
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("Access denied.")
    end
  end

  describe "GET /admin/users" do
    it "shows list for admin" do
      sign_in admin
      get admin_users_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /admin/users/:id" do
    it "shows a user" do
      sign_in admin
      get admin_user_path(user)
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /admin/users/new" do
    it "renders new form" do
      sign_in admin
      get new_admin_user_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /admin/users" do
    it "creates user with valid params" do
      sign_in admin

      expect {
        post admin_users_path, params: {
          user: {
            full_name: "John Doe",
            email: "john@example.com",
            password: "password123",
            password_confirmation: "password123"
          }
        }
      }.to change(User, :count).by(1)
      expect(response).to redirect_to(admin_users_path)
    end

    it "renders new on validation errors" do
      sign_in admin

      post admin_users_path, params: {
        user: {
          full_name: "",
          email: "",
          password: ""
        }
      }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "GET /admin/users/:id/edit" do
    it "renders edit page" do
      sign_in admin
      get edit_admin_user_path(user)
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /admin/users/:id" do
    it "updates a user" do
      sign_in admin

      patch admin_user_path(user), params: {
        user: { full_name: "Updated" }
      }
      expect(response).to redirect_to(admin_users_path)
      expect(user.reload.full_name).to eq("Updated")
    end

    it "fails validation" do
      sign_in admin

      patch admin_user_path(user), params: {
        user: { email: "" }
      }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "DELETE /admin/users/:id" do
    it "deletes user" do
      sign_in admin
      user_to_delete = create(:user)

      expect {
        delete admin_user_path(user_to_delete)
      }.to change(User, :count).by(-1)
      expect(response).to redirect_to(admin_users_path)
    end
  end

  describe "PATCH /admin/users/:id/toggle_role" do
    it "toggles admin role" do
      sign_in admin

      patch toggle_role_admin_user_path(user)
      expect(user.reload.admin).to eq(true)
      expect(response).to redirect_to(admin_users_path)
    end
  end

  describe "POST /admin/users/import" do
    it "accepts CSV file" do
      sign_in admin
      file = fixture_file_upload("users.csv", "text/csv")
      post import_admin_users_path, params: { file: file }

      expect(response).to redirect_to(admin_users_path)
      expect(flash[:notice]).to eq("File imported successfully.")
    end

    it "rejects blank file" do
      sign_in admin

      post import_admin_users_path, params: { file: nil }

      expect(response).to redirect_to(admin_users_path)
      expect(flash[:alert]).to eq("Please choose a file to upload.")
    end

    it "rejects wrong file type" do
      sign_in admin
      file = fixture_file_upload("not_csv.txt", "text/plain")
      post import_admin_users_path, params: { file: file }

      expect(response).to redirect_to(admin_users_path)
      expect(flash[:alert]).to eq("Only CSV files are allowed.")
    end
  end
end
