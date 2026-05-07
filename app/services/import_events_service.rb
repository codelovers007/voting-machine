class ImportEventsService
  def call
    events = Billetto::Client.new.get_events

    records = (events["data"] || []).map do |event_data|
      {
        external_id: event_data["id"],
        title: event_data["title"],
        description: event_data["description"],
        image_url: event_data["image_link"],
        start_date: event_data["startdate"],
        end_date: event_data["enddate"],
        created_at: Time.current,
        updated_at: Time.current
      }
    end

    Event.upsert_all(
      records,
      unique_by: :external_id
    )
  end
end
