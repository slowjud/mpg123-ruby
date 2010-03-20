require 'mpg123_api'

module MPG123
  VERSION = '0.0.1'
  
  class Tag
    @@klass_initialized = false

    def initialize(filename)
      @filename = filename
      unless @@klass_initialized
        MPG123::API.mpg123_init
        @@klass_initialized = true
      end
      
      @mpg123_handle = MPG123::API.mpg123_new(nil, nil)
      MPG123::API.mpg123_open @mpg123_handle, @filename
    end
    
    def read_id3
      MPG123::API.mpg123_scan @mpg123_handle
      if MPG123::API.mpg123_meta_check(@mpg123_handle) == 3 #should use the const
        @v2 = MPG123::API.get_id3_v2 @mpg123_handle
      end
    end
    
    def title
      @v2.title.p
    end
    
    def artist
      @v2.artist.p
    end
    
    def album
      @v2.album.p
    end
    
    def year
      @v2.year.p
    end
    
    def genre
      @v2.genre.p
    end
    
    def comment
      @v2.comment.p
    end
  end
end
