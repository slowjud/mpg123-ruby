require 'mpg123_api'

module MPG123
  VERSION = '0.0.1'
  
  class Tag
    @@klass_initialized = false

    def initialize(filename)
      unless @@klass_initialized
        MPG123::API.mpg123_init
        @@klass_initialized = true
      end
      
      mpg123_handle = MPG123::API.mpg123_new(nil, nil)
      MPG123::API.mpg123_open mpg123_handle, filename
      MPG123::API.mpg123_scan mpg123_handle

      if MPG123::API.mpg123_meta_check(mpg123_handle) & 0x3
        @v2 = MPG123::API.get_id3_v2 mpg123_handle
        @v1 = MPG123::API.get_id3_v1 mpg123_handle
      end
      MPG123::API.mpg123_close mpg123_handle
    end
    
    
    def method_missing(sym, *args, &block)
      if %w{title artist album year genre comment}.include? sym.to_s
        if !@v2.send(sym).nil?
          return @v2.send(sym).p
        elsif !@v1.send(sym).nil?
          return @v1.send(sym).strip
        end
      end
    end
  end
end
