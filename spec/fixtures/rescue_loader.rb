begin
  require 'not_exists'
rescue LoadError
  :ok
end
