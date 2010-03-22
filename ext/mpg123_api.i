%module "MPG123::API"
%{
#include <mpg123.h>
%}

%include </usr/local/include/mpg123.h>

%inline %{
    mpg123_id3v1 *get_id3_v1(mpg123_handle *mh)
    {
        mpg123_id3v1 *v1;
        mpg123_id3(mh, &v1, NULL);
        return v1;
    }
%}

%inline %{
    mpg123_id3v2 *get_id3_v2(mpg123_handle *mh)
    {
        mpg123_id3v2 *v2;
        mpg123_id3(mh, NULL, &v2);
        return v2;
    }
%}

%inline %{
    VALUE getformat(mpg123_handle *mh)
    {
        long r = 0;
        int  c = 0;
        int  e = 0;
        VALUE hash = rb_hash_new();
        mpg123_getformat( mh, &r, &c, &e );
        rb_hash_aset( hash, rb_str_new2("rate"), LONG2NUM(r) );
        rb_hash_aset( hash, rb_str_new2("channels"), INT2NUM(c) );
        rb_hash_aset( hash, rb_str_new2("encoding"), INT2NUM(e) );
        
        return hash;
    }
%}

%inline %{
    VALUE read_frame(mpg123_handle *mh)
    {
	      // Make sure we deal with the correct bitrate
        int i;
        size_t done = 0;
        size_t buffer_size = mpg123_outblock( mh );
        unsigned char *buffer = malloc( buffer_size );
        VALUE array = rb_ary_new();
        
        mpg123_read( mh, buffer, buffer_size, &done );
        
				for (i = 0; i < done/sizeof(char); i++){
						rb_ary_push( array, INT2FIX( buffer[i] ) );
				}

        free ( buffer );
        
        if( done > 0 )
            return array;
        else
            return Qnil;
    }
%}


