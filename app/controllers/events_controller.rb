class EventsController < ApplicationController
  before_action :require_clerk_session!

  def index
    @events = Event.apply_order.paginate(page: params[:page])
  end
end
