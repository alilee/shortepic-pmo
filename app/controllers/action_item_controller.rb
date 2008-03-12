class ActionItemController < ItemController

  protected
  
  # Loads the required item (initially for security checking) using params[:id] and caches it for other methods.
  # This method is called by the authorisation Application before_filter.
  def load_item(id)
    @action_item = ActionItem.find(id, :include => :detail)
  end
  
end
