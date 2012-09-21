class MiniTest::Spec
  class << self
    alias_method :context, :describe
  end
end
