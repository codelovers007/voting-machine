class EventsController < ApplicationController
  def index
    @events = Event.apply_order
  end
end
