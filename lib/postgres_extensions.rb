module ActiveRecord
  module ConnectionAdapters
    class PostgreSQLAdapter < AbstractAdapter
      alias old_native_database_types native_database_types
      def native_database_types
        old_native_database_types.merge({ :tsvector => { :name => "tsvector"} })
      end
    end

    class Column
      private
      alias old_simplified_type simplified_type
      def simplified_type(field_type)
        if field_type =~ /tsvector/i
          :tsvector
        else
          old_simplified_type(field_type)
        end
      end
    end
  end
end