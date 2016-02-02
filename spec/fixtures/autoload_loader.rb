module Alpha
  module Beta
    autoload :Hoge, 'alpha/beta/hoge'
    autoload :Piyo, 'alpha/beta/piyo'
  end
end

Alpha::Beta::Hoge
