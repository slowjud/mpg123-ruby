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
        // Make sure we deal with the correct ecoding
		// Currently we're only dealling with signed 16bit
        int i;
		int val;
        size_t done = 0;
        unsigned char *buffer;
        VALUE array = rb_ary_new();
        
        mpg123_framebyframe_next( mh );
        mpg123_framebyframe_decode( mh, NULL, &buffer, &done );
        
        for (i = 0; i < done/sizeof(char); i+=2){
            val = buffer[i] << 8 | buffer[i+1];
            if ( val & 0x8000 ) {
                val ^= 0xffffff8000;
            }
            rb_ary_push( array, INT2FIX( val ) );
        }

        if( done > 0 )
            return array;
        else
            return Qnil;
    }
%}


%inline %{
    VALUE bmp1(mpg123_handle *mh)
    {
        int sample_rate = 0;
        size_t done = 0;
        unsigned char *buffer;
        int song_length = 0;
        
        // get the sample rate
        // rewind to the start of the song.
        // read a frame
        do {
            mpg123_framebyframe_next( mh );
            mpg123_framebyframe_decode( mh, NULL, &buffer, &done );
        } while( done );
        
        // start calculating the instant energies
        // start calculating the average energies
        
        // we need to hold the last second of instant energies.
        
        // start calculating the variance
        // calculate the beats
        // devide the number of beats by the song length
        song_length = mpg123_length(mh) / sample_rate;
        return INT2FIX(1);
    }
%}
