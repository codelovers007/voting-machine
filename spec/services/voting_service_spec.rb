require 'rails_helper'

RSpec.describe VotingService, type: :service do
  let(:event)   { create(:event) }
  let(:user_id) { "user_abc123" }
  let(:service) { VotingService.new(event_id: event.id, user_id: user_id) }
  let(:store)   { Rails.configuration.event_store }

  before do
    store.delete_stream("event-#{event.id}") rescue nil
  end

  describe "#upvote" do
    it "publishes an Upvoted event to the stream" do
      expect { service.upvote }.to change {
        store.read.stream("event-#{event.id}").to_a.count
      }.by(1)
    end

    it "publishes an Events::Upvoted type" do
      service.upvote
      published = store.read.stream("event-#{event.id}").to_a.last
      expect(published).to be_a(Events::Upvoted)
    end

    it "stores correct event_id in data" do
      service.upvote
      published = store.read.stream("event-#{event.id}").to_a.last
      expect(published.data[:event_id]).to eq(event.id)
    end

    it "stores correct user_id in data" do
      service.upvote
      published = store.read.stream("event-#{event.id}").to_a.last
      expect(published.data[:user_id]).to eq(user_id)
    end
  end

  describe "#downvote" do
    it "publishes a Downvoted event to the stream" do
      expect { service.downvote }.to change {
        store.read.stream("event-#{event.id}").to_a.count
      }.by(1)
    end

    it "publishes an Events::Downvoted type" do
      service.downvote
      published = store.read.stream("event-#{event.id}").to_a.last
      expect(published).to be_a(Events::Downvoted)
    end

    it "stores correct event_id in data" do
      service.downvote
      published = store.read.stream("event-#{event.id}").to_a.last
      expect(published.data[:event_id]).to eq(event.id)
    end

    it "stores correct user_id in data" do
      service.downvote
      published = store.read.stream("event-#{event.id}").to_a.last
      expect(published.data[:user_id]).to eq(user_id)
    end
  end

  describe ".vote_counts" do
    it "returns zero counts when no votes" do
      counts = VotingService.vote_counts(event.id)
      expect(counts).to eq({ upvotes: 0, downvotes: 0 })
    end

    it "counts upvotes correctly" do
      service.upvote
      service.upvote
      expect(VotingService.vote_counts(event.id)[:upvotes]).to eq(2)
      expect(VotingService.vote_counts(event.id)[:downvotes]).to eq(0)
    end

    it "counts downvotes correctly" do
      service.downvote
      service.downvote
      expect(VotingService.vote_counts(event.id)[:downvotes]).to eq(2)
      expect(VotingService.vote_counts(event.id)[:upvotes]).to eq(0)
    end

    it "counts mixed votes correctly" do
      service.upvote
      service.downvote
      VotingService.new(event_id: event.id, user_id: "other_user").upvote
      counts = VotingService.vote_counts(event.id)
      expect(counts[:upvotes]).to eq(2)
      expect(counts[:downvotes]).to eq(1)
    end

    it "only counts votes for the given event" do
      other_event = create(:event)
      VotingService.new(event_id: other_event.id, user_id: user_id).upvote
      expect(VotingService.vote_counts(event.id)).to eq({ upvotes: 0, downvotes: 0 })
    end
  end

  describe ".user_vote" do
    it "returns nil when user has not voted" do
      expect(VotingService.user_vote(event_id: event.id, user_id: user_id)).to be_nil
    end

    it "returns :upvoted after upvote" do
      service.upvote
      expect(VotingService.user_vote(event_id: event.id, user_id: user_id)).to eq(:upvoted)
    end

    it "returns :downvoted after downvote" do
      service.downvote
      expect(VotingService.user_vote(event_id: event.id, user_id: user_id)).to eq(:downvoted)
    end

    it "returns the last vote type when voted multiple times" do
      service.upvote
      service.downvote
      expect(VotingService.user_vote(event_id: event.id, user_id: user_id)).to eq(:downvoted)
    end

    it "does not return another user's vote" do
      VotingService.new(event_id: event.id, user_id: "other_user").upvote
      expect(VotingService.user_vote(event_id: event.id, user_id: user_id)).to be_nil
    end

    it "returns nil for a different event" do
      other_event = create(:event)
      VotingService.new(event_id: other_event.id, user_id: user_id).upvote
      expect(VotingService.user_vote(event_id: event.id, user_id: user_id)).to be_nil
    end
  end
end
