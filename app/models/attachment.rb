# == Schema Information
# Schema version: 16
#
# Table name: attachments
#
#  id         :integer       not null, primary key
#  item_id    :integer       not null
#  filename   :string(255)   not null
#  version    :string(255)   not null
#  size       :integer       not null
#  created_at :datetime      not null
#  person_id  :integer       not null
#  mime_type  :string(255)   not null
#

# == Schema Information
# Schema version: 1
#
# Table name: attachments
#
#  id         :integer       not null, primary key
#  item_id    :integer       not null
#  filename   :string(255)   not null
#  version    :string(255)   not null
#  size       :integer       not null
#  created_at :datetime      not null
#  person_id  :integer       not null
#  mime_type  :string(255)   not null
#

class Attachment < ActiveRecord::Base
    belongs_to :item
    belongs_to :person
    has_one :attachment_content, :dependent => :destroy
    
    validates_presence_of :item_id, :person_id
    validates_presence_of :size, :filename, :mime_type
    validates_length_of :version, :minimum => 1
    validates_exclusion_of :size, :in => -10..0
    
    validates_uniqueness_of :version, :scope => [:item_id, :filename], :message => "already available. Please upload a new version of the file."
    
    def uploaded_file=(incoming_file)
        self.filename = incoming_file.original_filename
        if !self.filename.empty?
            self.mime_type = incoming_file.content_type
            self.size = incoming_file.size
            self.attachment_content = AttachmentContent.new(:data => incoming_file.read)
        end
    end
    
    def file_size
        size_in_bytes = size
        if size_in_bytes < 1024
            ret = size_in_bytes.to_s + " B"
        else
            size_in_kb = (size_in_bytes.to_f / 1024)
            if size_in_kb < 1024
                ret = sprintf("%.2f KB", size_in_kb)
            else
                size_in_mb = (size_in_kb / 1024)
                ret = sprintf("%.2f MB", size_in_mb)
            end
        end
        ret
    end
    
    def <=>(other)
      if self.filename == other.filename
        then self.version <=> other.version
      else
        self.filename <=> other.filename
      end
    end
    
end
