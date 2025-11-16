require 'rails_helper'

RSpec.describe "Admin::UserImports", type: :request do
  describe "GET /create" do
    it "returns http success" do
      get "/admin/user_imports/create"
      expect(response).to have_http_status(:success)
    end
  end

end
