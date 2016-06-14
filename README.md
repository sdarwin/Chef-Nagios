Chef Nagios

This was a fork of the opscode Nagios recipe 1.2.6. Customized, streamlined and tested for RH5,6 and Ubuntu11,12.

No longer maintained, please refer to Chef Supermarket for latest nagios cookbook.

It looks like some of the bugs fixed here were also addressed in the mainline code which has recently been updated 
to 1.3.0 and 2.0.0.

- The apache module here is heavily reduced, to merely provide a basic web server for nagios.  There is no need for all
the added bells and whistles.
- Make sure webserver works out of the box 
- Added support for amazon
- Use packages whenever possible, not source
- Change RH folder to nagios, not nagios3
- more..

