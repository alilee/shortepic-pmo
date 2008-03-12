class ProjectStatusReportInterval < ActiveRecord::Migration
  def self.up
    add_column :project_details, :status_report_interval, :integer
  end

  def self.down
    remove_column :project_detail, :status_report_interval
  end
end
