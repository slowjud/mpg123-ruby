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
