class Event < ApplicationRecord
  validates :external_id, presence: true, uniqueness: true
  validates :title, :start_date, :end_date, :event_url, presence: true

  scope :apply_order, -> { order(start_date: :asc) }
end
