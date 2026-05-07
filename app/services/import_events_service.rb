class ImportEventsService
  EXCLUDED_COLUMNS = %w[ id created_at updated_at ].freeze

  UPSERT_COLUMNS = ( Event.column_names - EXCLUDED_COLUMNS ).map(&:to_sym).freeze

  def call
    records = valid_records

    return if records.empty?

    Event.upsert_all(
      records,
      unique_by: :external_id,
      update_only: UPSERT_COLUMNS
    )
  rescue StandardError => e
    Rails.logger.error(
      "ImportEventsService failed: #{e.message}"
    )
  end

  private

  def valid_records
    events.each_with_object([]) do |event_data, data|
      data << build_record(event_data) if event_valid?(event_data)
    end
  end

  def events
    response = Billetto::Client.new.get_events
    response["data"] || []
  end

  def build_record(data)
    {
      external_id: data["id"],
      title: data["title"],
      description: data["description"],
      image_url: data["image_link"],
      event_url: data["url"],
      start_date: data["startdate"],
      end_date: data["enddate"]
    }
  end

  def event_valid?(data)
    data["id"].present? &&
      data["title"].present? &&
      data["url"].present? &&
      data["startdate"].present? &&
      data["enddate"].present?
  end
end
