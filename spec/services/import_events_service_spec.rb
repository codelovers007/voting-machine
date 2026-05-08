require 'rails_helper'

RSpec.describe ImportEventsService, type: :service do
  let(:service) { described_class.new }

  let(:valid_event_data) do
    {
      "id"          => "ext_001",
      "title"       => "Test Concert",
      "description" => "A great concert",
      "image_link"  => "https://example.com/image.jpg",
      "url"         => "https://example.com/event",
      "startdate"   => "2026-06-01",
      "enddate"     => "2026-06-02"
    }
  end

  let(:invalid_event_data) do
    {
      "id"        => nil,
      "title"     => nil,
      "url"       => nil,
      "startdate" => nil,
      "enddate"   => nil
    }
  end

  let(:api_response) { { "data" => [valid_event_data] } }

  before do
    billetto_client = instance_double(Billetto::Client)
    allow(Billetto::Client).to receive(:new).and_return(billetto_client)
    allow(billetto_client).to receive(:get_events).and_return(api_response)
  end

  describe "#call" do
    context "with valid records" do
      it "imports events into the database" do
        expect { service.call }.to change(Event, :count).by(1)
      end

      it "saves correct title" do
        service.call
        expect(Event.last.title).to eq("Test Concert")
      end

      it "saves correct external_id" do
        service.call
        expect(Event.last.external_id).to eq("ext_001")
      end

      it "saves correct event_url" do
        service.call
        expect(Event.last.event_url).to eq("https://example.com/event")
      end

      it "upserts existing event instead of creating duplicate" do
        service.call
        expect { service.call }.not_to change(Event, :count)
      end

      it "updates existing event on upsert" do
        service.call
        updated_response = { "data" => [valid_event_data.merge("title" => "Updated Concert")] }
        allow(Billetto::Client).to receive(:new).and_return(
          instance_double(Billetto::Client, get_events: updated_response)
        )
        service.call
        expect(Event.find_by(external_id: "ext_001").title).to eq("Updated Concert")
      end
    end

    context "with multiple events" do
      let(:second_event_data) do
        valid_event_data.merge("id" => "ext_002", "title" => "Second Concert")
      end

      before do
        billetto_client = instance_double(Billetto::Client)
        allow(Billetto::Client).to receive(:new).and_return(billetto_client)
        allow(billetto_client).to receive(:get_events).and_return(
          { "data" => [valid_event_data, second_event_data] }
        )
      end

      it "imports all valid events" do
        expect { service.call }.to change(Event, :count).by(2)
      end
    end

    context "with invalid records" do
      before do
        billetto_client = instance_double(Billetto::Client)
        allow(Billetto::Client).to receive(:new).and_return(billetto_client)
        allow(billetto_client).to receive(:get_events).and_return(
          { "data" => [invalid_event_data] }
        )
      end

      it "does not import invalid events" do
        expect { service.call }.not_to change(Event, :count)
      end
    end

    context "with mixed valid and invalid records" do
      let(:second_invalid) { { "id" => nil, "title" => "No ID Event", "url" => nil, "startdate" => nil, "enddate" => nil } }

      before do
        billetto_client = instance_double(Billetto::Client)
        allow(Billetto::Client).to receive(:new).and_return(billetto_client)
        allow(billetto_client).to receive(:get_events).and_return(
          { "data" => [valid_event_data, invalid_event_data] }
        )
      end

      it "only imports valid events" do
        expect { service.call }.to change(Event, :count).by(1)
      end
    end

    context "when API returns empty data" do
      before do
        billetto_client = instance_double(Billetto::Client)
        allow(Billetto::Client).to receive(:new).and_return(billetto_client)
        allow(billetto_client).to receive(:get_events).and_return({ "data" => [] })
      end

      it "does not import anything" do
        expect { service.call }.not_to change(Event, :count)
      end
    end

    context "when API returns no data key" do
      before do
        billetto_client = instance_double(Billetto::Client)
        allow(Billetto::Client).to receive(:new).and_return(billetto_client)
        allow(billetto_client).to receive(:get_events).and_return({})
      end

      it "does not import anything" do
        expect { service.call }.not_to change(Event, :count)
      end
    end

    context "when API raises an error" do
      before do
        billetto_client = instance_double(Billetto::Client)
        allow(Billetto::Client).to receive(:new).and_return(billetto_client)
        allow(billetto_client).to receive(:get_events).and_raise(StandardError, "API timeout")
      end

      it "does not raise an error" do
        expect { service.call }.not_to raise_error
      end

      it "logs the error" do
        expect(Rails.logger).to receive(:error).with(
          "ImportEventsService failed: API timeout"
        )
        service.call
      end
    end
  end

  describe "#event_valid?" do
    it "returns true for valid event data" do
      expect(service.send(:event_valid?, valid_event_data)).to be true
    end

    it "returns false when id is missing" do
      expect(service.send(:event_valid?, valid_event_data.merge("id" => nil))).to be false
    end

    it "returns false when title is missing" do
      expect(service.send(:event_valid?, valid_event_data.merge("title" => nil))).to be false
    end

    it "returns false when url is missing" do
      expect(service.send(:event_valid?, valid_event_data.merge("url" => nil))).to be false
    end

    it "returns false when startdate is missing" do
      expect(service.send(:event_valid?, valid_event_data.merge("startdate" => nil))).to be false
    end

    it "returns false when enddate is missing" do
      expect(service.send(:event_valid?, valid_event_data.merge("enddate" => nil))).to be false
    end
  end

  describe "#build_record" do
    it "maps API fields to model attributes correctly" do
      record = service.send(:build_record, valid_event_data)
      expect(record).to eq({
        external_id: "ext_001",
        title:       "Test Concert",
        description: "A great concert",
        image_url:   "https://example.com/image.jpg",
        event_url:   "https://example.com/event",
        start_date:  "2026-06-01",
        end_date:    "2026-06-02"
      })
    end
  end
end
