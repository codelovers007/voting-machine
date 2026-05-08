class ProcessVoteJob < ApplicationJob
  queue_as :default

  def perform(event_id:, user_id:, vote_type:)
    service = VotingService.new(event_id: event_id, user_id: user_id)

    case vote_type
    when "upvote"
      service.upvote
    when "downvote"
      service.downvote
    else
      Rails.logger.warn "ProcessVoteJob: Unknown vote_type '#{vote_type}'"
    end
  rescue => e
    Rails.logger.error "ProcessVoteJob: Error: #{e.message}"
    raise
  end
end
