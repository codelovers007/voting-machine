class VotesController < ApplicationController
  before_action :require_clerk_session!

  VOTE_TYPES = %w[upvote downvote].freeze

  def create
    vote_type = params[:vote_type]

    unless VOTE_TYPES.include?(vote_type)
      return redirect_to root_path, alert: "Invalid vote type."
    end

    ProcessVoteJob.perform_now(event_id: params[:event_id],
                                  user_id:  clerk.user_id,
                                  vote_type: vote_type
                                )

    redirect_to root_path, notice: "Vote submitted!"
  end
end
