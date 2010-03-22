require 'mpg123_api'

module MPG123
  VERSION = '0.0.1'
  
  class Tag

    def initialize(filename)
      mpg123_handle = MPG123::API.mpg123_new(nil, nil)
      MPG123::API.mpg123_open mpg123_handle, filename
      MPG123::API.mpg123_scan mpg123_handle

      if MPG123::API.mpg123_meta_check(mpg123_handle) & MPG123::API::MPG123_ID3
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
  
  class Decoder
    @@mpg123_handle
    
    def initialize(filename)
      @@mpg123_handle = MPG123::API.mpg123_new(nil, nil)
      MPG123::API.mpg123_param(@@mpg123_handle, MPG123::API::MPG123_VERBOSE, 2, 0)
      MPG123::API.mpg123_open @@mpg123_handle, filename
      format = MPG123::API.getformat(@@mpg123_handle)
    end
    
    def read
      MPG123::API.read_frame(@@mpg123_handle)
    end
  end
end
