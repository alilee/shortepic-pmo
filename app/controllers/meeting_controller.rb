class MeetingController < ItemController

  protected
  
  # Loads the required item (initially for security checking) using params[:id] and caches it for other methods.
  # This method is called by the authorisation Application before_filter.
  def load_item(id)
    @meeting = Meeting.find(id, :include => [:detail, :attendees])
  end
  
  def child_collections
    [ { :table => 'attendees', :collection => @meeting.attendees, :class => MeetingAttendee, :show => true, :edit => true }
    ]
  end
  
end
