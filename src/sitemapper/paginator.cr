module Sitemapper
  class Paginator
    DEFAULT_LIMIT = 500
    property paths : Array(Tuple(String, Builder::Options))

    def initialize(@limit : Int32 = DEFAULT_LIMIT)
      @paths = [] of Tuple(String, Builder::Options)
    end

    def add(path : String, options : Builder::Options)
      @paths << {path, options}  
    end
 
    def items(current_page : Int32)
      offset = (current_page * @limit) - @limit
      @paths[offset, @limit]
    end

    # This is calculated each time since you could
    # get 1 the first time, then add to it and get 2 the second
    def total_pages
      (@paths.size / @limit.to_f).ceil.to_i
    end
  end
end
