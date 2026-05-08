# spec/controllers/votes_controller_spec.rb
require 'rails_helper'

RSpec.describe VotesController, type: :controller do
  let(:event) { create(:event) }

  describe "POST #create" do
    context "as a guest" do
      before do
        clerk_double = double("Clerk", session: nil, user: nil, user_id: nil)
        allow_any_instance_of(ApplicationController).to receive(:clerk).and_return(clerk_double)
        allow_any_instance_of(ApplicationController).to receive(:set_clerk_user) do |controller|
          controller.instance_variable_set(:@clerk_user, nil)
        end
      end

      it "redirects to clerk sign in" do
        post :create, params: { event_id: event.id, vote_type: "upvote" }
        expect(response).to have_http_status(:redirect)
        expect(response.location).to include("sign-in")
      end

      it "does not call ProcessVoteJob" do
        expect(ProcessVoteJob).not_to receive(:perform_now)
        post :create, params: { event_id: event.id, vote_type: "upvote" }
      end
    end

    context "as a logged in user" do
      before do
        clerk_user    = double("ClerkUser", id: "user_123", username: "testuser", first_name: "Test", email_addresses: [])
        clerk_session = double("ClerkSession", user_id: "user_123")
        clerk_double  = double("Clerk", session: clerk_session, user: clerk_user, user_id: "user_123")
        allow_any_instance_of(ApplicationController).to receive(:clerk).and_return(clerk_double)
        allow_any_instance_of(ApplicationController).to receive(:set_clerk_user) do |controller|
          controller.instance_variable_set(:@clerk_user, clerk_user)
        end
      end

      context "with valid vote type" do
        it "calls ProcessVoteJob for upvote" do
          expect(ProcessVoteJob).to receive(:perform_now).with(
            event_id:  event.id.to_s,
            user_id:   "user_123",
            vote_type: "upvote"
          )
          post :create, params: { event_id: event.id, vote_type: "upvote" }
        end

        it "calls ProcessVoteJob for downvote" do
          expect(ProcessVoteJob).to receive(:perform_now).with(
            event_id:  event.id.to_s,
            user_id:   "user_123",
            vote_type: "downvote"
          )
          post :create, params: { event_id: event.id, vote_type: "downvote" }
        end

        it "redirects to root with notice" do
          allow(ProcessVoteJob).to receive(:perform_now)
          post :create, params: { event_id: event.id, vote_type: "upvote" }
          expect(response).to redirect_to(root_path)
          expect(flash[:notice]).to eq("Vote submitted!")
        end
      end

      context "with invalid vote type" do
        it "redirects to root with alert" do
          post :create, params: { event_id: event.id, vote_type: "invalid" }
          expect(response).to redirect_to(root_path)
          expect(flash[:alert]).to eq("Invalid vote type.")
        end

        it "does not call ProcessVoteJob" do
          expect(ProcessVoteJob).not_to receive(:perform_now)
          post :create, params: { event_id: event.id, vote_type: "invalid" }
        end
      end
    end
  end
end
