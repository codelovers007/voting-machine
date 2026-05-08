require 'rails_helper'

RSpec.describe Event, type: :model do
  describe "validations" do
    it "is valid with all required attributes" do
      event = build(:event)
      expect(event).to be_valid
    end

    it "is invalid without a title" do
      event = build(:event, title: nil)
      expect(event).not_to be_valid
      expect(event.errors[:title]).to include("can't be blank")
    end

    it "is invalid without a start_date" do
      event = build(:event, start_date: nil)
      expect(event).not_to be_valid
      expect(event.errors[:start_date]).to include("can't be blank")
    end

    it "is invalid without an end_date" do
      event = build(:event, end_date: nil)
      expect(event).not_to be_valid
      expect(event.errors[:end_date]).to include("can't be blank")
    end

    it "is invalid without an event_url" do
      event = build(:event, event_url: nil)
      expect(event).not_to be_valid
      expect(event.errors[:event_url]).to include("can't be blank")
    end

    it "is invalid without an external_id" do
      event = build(:event, external_id: nil)
      expect(event).not_to be_valid
      expect(event.errors[:external_id]).to include("can't be blank")
    end

    it "is invalid with a duplicate external_id" do
      create(:event, external_id: "ext_123")
      event = build(:event, external_id: "ext_123")
      expect(event).not_to be_valid
      expect(event.errors[:external_id]).to include("has already been taken")
    end
  end

  describe "scopes" do
    it "apply_order returns events ordered by start_date asc" do
      event1 = create(:event, start_date: Date.today + 10, end_date: Date.today + 15)
      event2 = create(:event, start_date: Date.today + 2,  end_date: Date.today + 5)
      event3 = create(:event, start_date: Date.today + 5,  end_date: Date.today + 8)

      expect(Event.apply_order.to_a).to eq([ event2, event3, event1 ])
    end
  end
end
