require 'ostruct'

# class ROpenStruct < OpenStruct
#   def method_missing(mid, *args)
#     mname = mid.id2name
#     len = args.length
#     if len == 0
#       @table[mname.intern] = ROpenStruct.new
#       self.new_ostruct_member(mname)
#       @table[mname.intern]
#     else
#       super
#     end
#   end
# end