class EventsController < ApplicationController
  def index
    @events = Event.apply_order.paginate(page: params[:page])
  end
end
