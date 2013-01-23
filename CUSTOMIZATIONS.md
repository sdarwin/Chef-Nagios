
======================
UBUNTU
======================

in sites-enabled/nagios3.conf (and thus for chef apache2.conf.erb)

  #DocumentRoot    /usr/share/nagios3/htdocs
  DocumentRoot    /var/www

add this in /var/www/index.html

<html><body>
<a href="/nagios3">nagios</a><br>
<a href="/munin">munin</a><br>
<a href="http://example.com:4040">chef</a><br>
</body></html>

==========================
REDHAT?
==========================

