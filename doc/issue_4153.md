paver setup
# This command downloads and extract the correct GeoServer version
=> IOError: [Errno 13] Permission denied: '/usr/local/share/GeoIP'

# JD: added this hack:
sudo chmod 777 /usr/local/share

and reran paver setup
=> IOError:
  Requesting http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz
  1KB [00:00, 970.01KB/s]
   total_size [0] / wrote [162]
  Writing to /usr/local/share/GeoIP
  Cannot extract <open file 'output.bin', mode 'r' at 0x7feb76c20d20> and write to /usr/local/share/GeoIP: Not a gzipped file

File is missing. 2 choices:
1. MaxMind DB binary, gzipped
https://geolite.maxmind.com/download/geoip/database/GeoLite2-City.tar.gz
2. CSV format, zipped
https://geolite.maxmind.com/download/geoip/database/GeoLite2-City-CSV.zip

Try #1 coz it's most similar to GeoLiteCity.dat.gz

BUt where to put that URL?

I'll try the manage.py command referenced in the paver setup output:
python -W ignore manage.py updategeoip -o

=> same error:
  Requesting http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz
  1KB [00:00, 975.65KB/s]
   total_size [0] / wrote [162]
  Writing to /usr/local/share/GeoIP
  Cannot extract <open file 'output.bin', mode 'r' at 0x7fef7a5c0d20> and write to /usr/local/share/GeoIP: Not a gzipped file
  Traceback (most recent call last):
    File "/home/ubuntu/Envs/geonode/src/geonode/geonode/base/management/commands/updategeoip.py", line 126, in handle_old_format
      tofile.write(zfile.read())
    File "/usr/lib/python2.7/gzip.py", line 261, in read
      self._read(readsize)
    File "/usr/lib/python2.7/gzip.py", line 303, in _read
      self._read_gzip_header()
    File "/usr/lib/python2.7/gzip.py", line 197, in _read_gzip_header
      raise IOError, 'Not a gzipped file'
  IOError: Not a gzipped file

Try the lines manually in python:

try from python manage.py shell:
    from django.contrib.gis.geoip2 import GeoIP2 as GeoIP
    URL = 'http://geolite.maxmind.com/download/geoip/database/GeoLite2-City.tar.gz'
    OLD_FORMAT = False

from django.contrib.gis import geoip
=> OK

from django.contrib.gis import geoip2
=> ERROR:
  ---------------------------------------------------------------------------
  ImportError                               Traceback (most recent call last)
  <ipython-input-6-383cd228a818> in <module>()
  ----> 1 from django.contrib.gis import geoip2

  ImportError: cannot import name geoip2

#JD: OK
1. Old GeoLite-City database is discontinued
2. New GeoLite2-City database works with geoip2
3. geoip2 requires Django>=1.9
4. Geonode 2.8 runs on Django 1.8

Raised issue 4153 with Geonode-dev
