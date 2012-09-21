Monthly::Application.configure do
  # Use Pry instead of IRB if available
  silence_warnings do
    begin
      require 'pry'
      IRB = Pry
    rescue LoadError
    end
  end
end
