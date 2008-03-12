class AddTSearch2 < ActiveRecord::Migration
  def self.up
    ts_filename = `locate contrib/tsearch2.sql | head -n 1`.strip
    contents = File.read(ts_filename)
    execute(contents)
    
    execute('ALTER TABLE items ADD COLUMN res_idx_fti tsvector')
    execute("UPDATE items SET res_idx_fti=to_tsvector(coalesce(title,'') ||' '|| coalesce(description,''))")
    execute('CREATE TRIGGER tsvectorupdate BEFORE UPDATE OR INSERT ON items
                FOR EACH ROW EXECUTE PROCEDURE
                    tsearch2(res_idx_fti, title, description)')
    execute('CREATE INDEX index_fti ON items USING gist(res_idx_fti)')
  end

  def self.down
    execute('DROP INDEX index_fti')
    execute('DROP TRIGGER tsvectorupdate')
    execute('ALTER TABLE items DROP COLUMN res_idx_fti')

    ts_filename = `locate contrib/untsearch2.sql | head -n 1`.strip
    contents = File.read(ts_filename)
    execute(contents)
  end
end
