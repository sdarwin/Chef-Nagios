maintainer        "Sam Darwin"
maintainer_email  "samuel.d.darwin@gmail.com"
license           "Apache 2.0"
description       "apache"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           "1.2.0"
recipe            "apache2", "Main Apache configuration"

%w{redhat centos scientific fedora debian ubuntu arch freebsd amazon}.each do |os|
  supports os
end

