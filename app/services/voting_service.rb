class VotingService
  def initialize(event_id:, user_id:)
    @event_id = event_id
    @user_id  = user_id
    @store    = Rails.configuration.event_store
  end

  def upvote
    publish(Events::Upvoted)
  end

  def downvote
    publish(Events::Downvoted)
  end

  def self.vote_counts(event_id)
    store  = Rails.configuration.event_store
    stream = "event-#{event_id}"

    all_events = store.read.stream(stream).to_a

    upvotes   = all_events.count { |e| e.is_a?(Events::Upvoted) }
    downvotes = all_events.count { |e| e.is_a?(Events::Downvoted) }

    { upvotes: upvotes, downvotes: downvotes }
  end

  def self.user_vote(event_id:, user_id:)
    store  = Rails.configuration.event_store
    stream = "event-#{event_id}"

    all_events = store.read.stream(stream).to_a
    last_vote  = all_events.select { |e|
      (e.is_a?(Events::Upvoted) || e.is_a?(Events::Downvoted)) &&
      e.data[:user_id] == user_id
    }.last

    return nil unless last_vote
    last_vote.is_a?(Events::Upvoted) ? :upvoted : :downvoted
  end

  private

  def publish(event_class)
    event = event_class.new(data: {
      event_id: @event_id,
      user_id:  @user_id,
      voted_at: Time.current
    })
    @store.publish(event, stream_name: "event-#{@event_id}")
  end
end
