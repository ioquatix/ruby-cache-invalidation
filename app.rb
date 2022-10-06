module App
  CONST_NUM = Integer(ENV.fetch("NUM", 100_000))

  CONST_NUM.times do |i|
    class_eval(<<~RUBY, __FILE__, __LINE__ + 1)
      Const#{i} = Module.new

      def self.lookup_#{i}
        Const#{i}
      end
    RUBY
  end

  class_eval(<<~RUBY, __FILE__, __LINE__ + 1)
    def self.warmup
      #{CONST_NUM.times.map { |i| "lookup_#{i}"}.join("\n")}
    end
  RUBY
end
