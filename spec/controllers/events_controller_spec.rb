require 'rails_helper'

RSpec.describe EventsController, type: :controller do
  describe "GET #index" do
    before do
      create_list(:event, 3)
      clerk_double = double("Clerk", session: nil, user: nil, user_id: nil)
      allow_any_instance_of(ApplicationController).to receive(:clerk).and_return(clerk_double)
      allow_any_instance_of(ApplicationController).to receive(:set_clerk_user) do |controller|
        controller.instance_variable_set(:@clerk_user, nil)
      end
    end

    it "returns 200" do
      get :index
      expect(response).to have_http_status(:ok)
    end

    it "renders the index template" do
      get :index
      expect(response).to render_template(:index)
    end

    it "assigns @events" do
      get :index
      expect(assigns(:events).count).to eq(3)
    end

    it "assigns @vote_counts as a hash" do
      get :index
      expect(assigns(:vote_counts)).to be_a(Hash)
    end

    it "assigns @user_votes as empty hash for guest" do
      get :index
      expect(assigns(:user_votes)).to eq({})
    end
  end
end
