require "spec_helper"
require 'pry'
require 'vcr'

describe Todoist::Sync::Items do
  VCR.configure do |config|
    config.cassette_library_dir = "fixtures/vcr_cassettes"
    config.hook_into :webmock
  end

  before(:all) do
    Todoist::Util::Uuid.type = "items"
  end

  before do
    @item_manager = Todoist::Sync::Items.new
  end

  it "is able to get items" do
    VCR.use_cassette("items_is_able_to_get_items") do         
      items = @item_manager.collection
      expect(items).to be_truthy
    end
  end

  it "is able to update a item" do  
    VCR.use_cassette("items_is_able_to_update_a_item") do   
      update_item = @item_manager.add({content: "Item3"})      
      expect(update_item).to be_truthy
      update_item.priority = 2
      result = @item_manager.update(update_item)
      expect(result).to be_truthy
      items_list =  @item_manager.collection
      queried_object = items_list[update_item.id]
      expect(queried_object.priority).to eq(2)
      @item_manager.delete([update_item])
      Todoist::Util::CommandSynchronizer.sync      
    end
  end

  it "is able to update multiple orders and indents" do
    VCR.use_cassette("items_is_able_to_update_multiple_orders_and_indents") do       
      item = @item_manager.add({content: "Item1"})
      expect(item).to be_truthy
      item2 = @item_manager.add({content: "Item2"})
  
      # Restore the items fully
  
      item_collection = @item_manager.collection
  
      item = item_collection[item.id]
      item2 = item_collection[item2.id]
  
  
      # Keep track of original values
      item_order = item.item_order
      item_order2 = item2.item_order
  
      # Swap orders
      item.item_order = item_order2
      item2.item_order = item_order
  
      # Indent @item
      item.indent = 2
  
      @item_manager.update_multiple_orders_and_indents([item, item2])
      item_collection = @item_manager.collection
  
      # Check to make sure newly retrieved object values match old ones
  
      expect(item_collection[item.id].item_order).to eq(item_order2)
      expect(item_collection[item2.id].item_order).to eq(item_order)
      expect(item_collection[item.id].indent).to eq(2)
  
      # Clean up extra item
  
      @item_manager.delete([item, item2])
      Todoist::Util::CommandSynchronizer.sync
    end
  
   end
   
   it "is able to move" do
    VCR.use_cassette("items_is_able_to_move") do
      project_manager = Todoist::Sync::Projects.new
      project = project_manager.add({name: "Item_Move_Test_To"})
      item = @item_manager.add({content: "ItemMove"})
      items_list =  @item_manager.collection
      queried_object = items_list[item.id]
      @item_manager.move(queried_object, project)
      items_list =  @item_manager.collection
      queried_object = items_list[item.id]
      expect(queried_object.project_id).to eq(project.id)

      project_manager.delete([project])
      @item_manager.delete([item])
      Todoist::Util::CommandSynchronizer.sync
    end
  end

  it "is able to complete" do
    VCR.use_cassette("items_is_able_to_complete") do
      item = @item_manager.add({content: "ItemComplete"})
      items_list =  @item_manager.collection

      queried_object = items_list[item.id]
      @item_manager.complete([queried_object])
      items_list =  @item_manager.collection
      queried_object = items_list[item.id]
      expect(queried_object.checked).to eq(1)
      @item_manager.delete([queried_object])
      Todoist::Util::CommandSynchronizer.sync
    end
  end
  
  it "is able to uncomplete" do
    VCR.use_cassette("items_is_able_to_uncomplete") do
      item = @item_manager.add({content: "ItemComplete"})
      items_list =  @item_manager.collection
      
      # Complete the item
      queried_object = items_list[item.id]
      @item_manager.complete([queried_object])
      items_list =  @item_manager.collection
      queried_object = items_list[item.id]
      expect(queried_object.checked).to eq(1)
      
      # Uncomplete the item
      @item_manager.uncomplete([queried_object])
      items_list =  @item_manager.collection
      queried_object = items_list[item.id]
      expect(queried_object.checked).to eq(0)
      
      @item_manager.delete([queried_object])
      Todoist::Util::CommandSynchronizer.sync
    end
  end
  
  it "is able to complete a recurring task" do
    VCR.use_cassette("items_is_able_to_complete_a_recurring_task") do
      item = @item_manager.add({content: "ItemCompleteRecurring", date_string: "every day @10" })
      items_list =  @item_manager.collection
      queried_object = items_list[item.id]
      
      due_date_original = queried_object.due_date_utc
      
      @item_manager.complete_recurring(queried_object)
      items_list =  @item_manager.collection
      queried_object = items_list[item.id]
      
      due_date_new = queried_object.due_date_utc
      
      expect(due_date_new).not_to eq(due_date_original)
      
      @item_manager.delete([queried_object])
      Todoist::Util::CommandSynchronizer.sync
    end
  end
  
  it "is able to close a task" do
    VCR.use_cassette("items_is_able_to_close_a_task") do
      item = @item_manager.add({content: "ItemClose"})
      items_list =  @item_manager.collection

      queried_object = items_list[item.id]
      @item_manager.close(queried_object)
      items_list =  @item_manager.collection
      queried_object = items_list[item.id]
      expect(queried_object.checked).to eq(1)
      @item_manager.delete([queried_object])
      Todoist::Util::CommandSynchronizer.sync
    end
  end

  it "is able to update day orders" do
    VCR.use_cassette("items_is_able_to_update_day_orders") do
      item = @item_manager.add({content: "ItemDayOrder"})
      items_list =  @item_manager.collection

      queried_object = items_list[item.id]
      queried_object.day_order = 1000
      @item_manager.update_day_orders([queried_object])
      items_list =  @item_manager.collection
      queried_object = items_list[item.id]
      expect(queried_object.day_order).to eq(1000)
      @item_manager.delete([queried_object])
      Todoist::Util::CommandSynchronizer.sync
    end
  end

end