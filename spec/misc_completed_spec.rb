require "spec_helper"
require 'pry'
require 'vcr'

describe Todoist::Misc::Completed do

  VCR.configure do |config|
    config.cassette_library_dir = "fixtures/vcr_cassettes"
    config.hook_into :webmock
  end
  
  before(:all) do
    Todoist::Util::Uuid.type = "misc_completed"
  end  

  before do
    @client = load_client  
  end
  
  it "is able to get productivity stats" do
    VCR.use_cassette("misc_completed_is_able_to_get_productivity_stats") do
      result = @client.misc_completed.get_productivity_stats
      expect(result).to be_truthy
    end
  end

  it "is able to get all completed items" do
    VCR.use_cassette("misc_completed_is_able_to_get_all_completed_items") do
      since = Date.today - 7
      result = @client.misc_completed.get_all_completed_items({"since" => since})
      expect(result["items"]).to be_truthy
    end
  end

end
