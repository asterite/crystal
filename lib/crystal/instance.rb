module Crystal
  class Module
    def add_def_instance(instance)
      @def_instances[instance.name] = instance
    end

    def remove_def_instance(name)
      @def_instances.delete name
    end

    def find_def_instance(name)
      @def_instances[name]
    end
  end

  class Def
    def instantiate(resolver, scope, node)
      args_types = node.args.map &:resolved_type
      args_types.insert 0, node.obj.resolved_type if node.obj
      args_types_signature = args_types.join ', '
      args_values = []
      args_values_signature = ""
      args.each_with_index do |arg, i|
        if arg.constant?
          node.raise_error "Argument #{arg} must be known at compile time" unless node.args[i].can_be_evaluated_at_compile_time?
          arg_value = scope.eval_anon node.args[i]
          args_values_signature << ", " unless args_values_signature.empty?
          args_values_signature << arg_value.to_s
          args_values << arg_value
        else
          args_values << nil
        end
      end
      instance_name = instance_name name, args_types_signature, args_values_signature

      instance = scope.find_def_instance instance_name
      if !instance || node.block
        instance_args = args.map(&:clone)

        if node.obj
          node_obj_clone = node.obj.clone
          self_var = Var.new('self', node.obj.clone)
          instance_args.insert 0, self_var
        end
        instance_args.each_with_index { |arg, index| arg.compile_time_value = args_values[index] }
        if node.obj && node.obj.resolved.is_a?(Class)
          self_var.compile_time_value = node.obj.resolved.compile_time_value
        end
        args_types.each_with_index { |arg_type, i| instance_args[i].resolved_type = arg_type }
        instance = Def.new instance_name, instance_args, body.clone
        instance.obj = obj
      end

      if node.block
        args_count = instance.count_yield_args
        while node.block.args.length < args_count
          node.block.args << Var.new('%missing')
        end

        block = scope.define_block node.block
        instance.block = block
        instance.replace_yield node, block
        instance.accept resolver

        scope.remove_def_instance instance

        instance.name = instance_name name, args_types_signature, args_values_signature, block.resolved_type

        existing_instance = scope.find_def_instance instance.name
        if existing_instance
          instance = existing_instance
          instance.block = block
        end

        scope.add_def_instance instance
      else
        scope.add_def_instance instance

        instance.accept resolver
      end
      instance
    end

    def instance_name(name, args_types, args_values, block_type = nil)
      i = ""
      if obj
        i << obj.to_s
        i << (obj.is_a?(Metaclass) ? '::' : '#')
      end
      i << name.to_s
      i << "<#{args_types}>"
      i << "(#{args_values})" if args_values.length > 0
      i << "&#{block_type}" if block_type
      i
    end
  end
end
