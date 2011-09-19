module DefineConstant
  def define_constant(path, base = Object, &block)
    namespace, class_name = *constant_path(path)
    klass = Class.new(base)
    namespace.const_set(class_name, klass)
    klass.class_eval(&block) if block_given?
    @defined_constants << path
    klass
  end

  def clear_generated_constants
    @defined_constants.reverse.each do |path|
      namespace, class_name = *constant_path(path)
      if namespace.const_defined?(class_name)
        namespace.send(:remove_const, class_name)
      end
    end

    @defined_constants.clear
  end

  private

  def constant_path(constant_name)
    names = constant_name.split('::')
    class_name = names.pop
    namespace = names.inject(Object) { |result, name| result.const_get(name) }
    [namespace, class_name]
  end
end

RSpec.configure do |config|
  config.include DefineConstant
  config.before do
    @defined_constants = []
  end

  config.after do
    clear_generated_constants
  end
end
