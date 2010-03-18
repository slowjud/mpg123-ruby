require 'mkmf'

def error msg
  message msg + "\n"
  abort
end

unless have_header('mpg123.h') and have_library('mpg123')
  error "You must have mpg123 installed in order to use mpg123-ruby."
end

create_makefile('mpg123_api')