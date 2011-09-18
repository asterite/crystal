module Crystal
  class Def
    def instantiate(resolver, scope, node)
      return self if resolved_type

      args_types = node.args.map &:resolved_type
      args_types_signature = args_types.join ', '
      args_values = []
      args_values_signature = ""
      args.each_with_index do |arg, i|
        if arg.constant?
          raise "Argument #{arg} must be known at compile time" unless node.args[i].can_be_evaluated_at_compile_time?
          arg_value = scope.eval_anon node.args[i]
          args_values_signature << ", " unless args_values_signature.empty?
          args_values_signature << arg_value.to_s
          args_values << arg_value
        else
          args_values << nil
        end
      end
      instance_name = instance_name name, args_types_signature, args_values_signature

      instance = scope.find_expression instance_name
      if !instance || node.block
        instance_args = args.map(&:clone)
        instance_args.each_with_index { |arg, index| arg.compile_time_value = args_values[index] }
        args_types.each_with_index { |arg_type, i| instance_args[i].resolved_type = arg_type }
        instance = Def.new instance_name, instance_args, body.clone
        instance.obj = node.obj
      end

      if node.block
        args_count = instance.count_yield_args
        while node.block.args.length < args_count
          node.block.args << Var.new('%missing')
        end

        block = scope.define_block node.block
        instance.replace_yield node, block
        instance.accept resolver

        scope.remove_expression instance

        instance.name = instance_name name, args_types_signature, args_values_signature, block.resolved_type

        existing_instance = scope.find_expression instance.name
        instance = existing_instance if existing_instance

        instance.block = block

        scope.add_expression instance
      else
        #begin
          instance.accept resolver
        #rescue => ex
          #raise_error "#{node.name} #{ex.message}"
        #end
      end
      instance
    end

    def instance_name(name, args_types, args_values, block_type = nil)
      i = "#{name}"
      i << "<#{args_types}>"
      i << "(#{args_values})" if args_values.length > 0
      i << "&#{block_type}" if block_type
      i
    end
  end
end
