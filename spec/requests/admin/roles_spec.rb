require 'rails_helper'

RSpec.describe "Admin::Roles", type: :request do
  describe "GET /update" do
    it "returns http success" do
      get "/admin/roles/update"
      expect(response).to have_http_status(:success)
    end
  end

end
