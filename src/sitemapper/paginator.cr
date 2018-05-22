module Sitemapper
  class Paginator
    DEFAULT_LIMIT = 500
    property paths : Array(Tuple(String, Builder::Options))

    def initialize(@limit : Int32 = DEFAULT_LIMIT)
      @paths = [] of Array(Tuple(String, Builder::Options))
    end

    def add(path : String, options : Builder::Options)
      @paths << {path, options}  
    end

    # Takes a slice of `paths` from `@offset` to `@limit`
    def items(current_page : Int32)
      edge = current_page * @limit
      offset = edge - @limit
      @paths[offset...edge]
    end

    # This is calculated each time since you could
    # get 1 the first time, then add to it and get 2 the second
    def total_pages
      (@paths.size / @limit.to_f).ceil.to_i
    end
  end
end
