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
    @@format
    @@instant_energies
    @@avg_energies
    @@beats
    
    def initialize(filename)
      @@mpg123_handle = MPG123::API.mpg123_new(nil, nil)
      MPG123::API.mpg123_param @@mpg123_handle, MPG123::API::MPG123_VERBOSE, 2, 0
      MPG123::API.mpg123_format_none @@mpg123_handle
      MPG123::API.mpg123_format @@mpg123_handle, 44100, MPG123::API::MPG123_MONO, MPG123::API::MPG123_ENC_SIGNED_8
      MPG123::API.mpg123_open @@mpg123_handle, filename
      MPG123::API.mpg123_scan @@mpg123_handle
      @@format = MPG123::API.getformat @@mpg123_handle
    end
    
    def read
      MPG123::API.read_frame @@mpg123_handle
    end

    def sample_rate
      @@format['rate']
    end
    
    def channels
      @@format['channels']
    end    

    def encoding
      @@format['encoding']
    end
    
    def mpg123_handle
      @@mpg123_handle
    end
    
    
    ###########################################################
    ## TODO: push all the energy caculations into the C code ##
    ## TODO: push all the beat caculations into the C code   ##
    ## TODO: when moving to the C code base 1024 samples and ##
    ##       seconds not frames and groups of frames         ##
    ###########################################################
    
    def instant_energy_list
      @@instant_energies = Array.new
      while buffer = MPG123::API.read_frame(@@mpg123_handle)
        instant_energy = 0
        buf_size = buffer.size
        buffer.each{ |e| instant_energy += e*e }
        @@instant_energies << instant_energy / buf_size
      end
      @@instant_energies
    end
    
    def avg_energy_list
      @@avg_energies = Array.new
      @@instant_energies.each_with_index do |e, i|
        avg = 0
        if i > 37
          (i-37..i).each do |k|
            avg += (@@instant_energies[k] / 38)
          end
        else
          (0..i).each do |k|
            avg += (@@instant_energies[k] / (i+1))
          end
        end
        @@avg_energies << avg
      end
      @@avg_energies
    end

    def constants_list
      @@c_list = Array.new
      @@instant_energies.each_with_index do |e, i|
        avg = 0
        if i > 37
          (i-37..i).each do |k|
            avg += ((@@instant_energies[k] - @@avg_energies[k]) / 38)
          end
        else
          (0..i).each do |k|
            avg += ((@@instant_energies[k] - @@avg_energies[k]) / (i+1))
          end
        end
        @@c_list << ((avg * -0.0025714) + 1.5142857)
      end
      @@c_list
    end

    def beats_list(const = 1.3)
      @@beats = Array.new
      @@instant_energies.each_with_index do |e, i|
        if e > (@@avg_energies[i] * @@c_list[i])
          @@beats[i] = true
        else
          @@beats[i] = false
        end
      end
      @@beats
    end

    def beat_count1
      @@beat_count = 0
      @@beats.each_with_index do |e,i|
        @@beat_count += 1 if (e && !@@beats[i-1])
      end
      @@beat_count
    end

  end
end
