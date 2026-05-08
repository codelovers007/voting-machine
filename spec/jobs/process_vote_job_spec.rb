require 'rails_helper'

RSpec.describe ProcessVoteJob, type: :job do
  let(:event)   { create(:event) }
  let(:user_id) { "user_123" }

  describe "#perform" do
    context "with upvote" do
      it "calls upvote on VotingService" do
        service_double = instance_double(VotingService)
        allow(VotingService).to receive(:new).with(
          event_id: event.id.to_s,
          user_id:  user_id
        ).and_return(service_double)
        expect(service_double).to receive(:upvote)

        described_class.new.perform(
          event_id:  event.id.to_s,
          user_id:   user_id,
          vote_type: "upvote"
        )
      end
    end

    context "with downvote" do
      it "calls downvote on VotingService" do
        service_double = instance_double(VotingService)
        allow(VotingService).to receive(:new).with(
          event_id: event.id.to_s,
          user_id:  user_id
        ).and_return(service_double)
        expect(service_double).to receive(:downvote)

        described_class.new.perform(
          event_id:  event.id.to_s,
          user_id:   user_id,
          vote_type: "downvote"
        )
      end
    end

    context "with unknown vote type" do
      it "logs a warning" do
        expect(Rails.logger).to receive(:warn).with(
          "ProcessVoteJob: Unknown vote_type 'invalid'"
        )
        described_class.new.perform(
          event_id:  event.id.to_s,
          user_id:   user_id,
          vote_type: "invalid"
        )
      end

      it "does not raise an error" do
        allow(Rails.logger).to receive(:warn)
        expect {
          described_class.new.perform(
            event_id:  event.id.to_s,
            user_id:   user_id,
            vote_type: "invalid"
          )
        }.not_to raise_error
      end
    end

    context "when VotingService raises an error" do
      it "logs the error and re-raises" do
        service_double = instance_double(VotingService)
        allow(VotingService).to receive(:new).and_return(service_double)
        allow(service_double).to receive(:upvote).and_raise(StandardError, "something went wrong")

        expect(Rails.logger).to receive(:error).with(
          "ProcessVoteJob: Error: something went wrong"
        )

        expect {
          described_class.new.perform(
            event_id:  event.id.to_s,
            user_id:   user_id,
            vote_type: "upvote"
          )
        }.to raise_error(StandardError, "something went wrong")
      end
    end
  end

  describe "queue" do
    it "is on the default queue" do
      expect(described_class.new.queue_name).to eq("default")
    end
  end
end
