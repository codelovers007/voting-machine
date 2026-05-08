class EventsController < ApplicationController
  def index
    @events = Event.apply_order.paginate(page: params[:page])

    # Load vote counts for all events
    @vote_counts = {}
    @user_votes  = {}

    @events.each do |event|
      @vote_counts[event.id] = VotingService.vote_counts(event.id)
      if clerk.user_id
        @user_votes[event.id] = VotingService.user_vote(
          event_id: event.id,
          user_id:  clerk.user_id
        )
      end
    end
  end
end
