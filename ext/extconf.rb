require 'mkmf'

extname = 'libcrystal'

$CFLAGS << '-Wall -O3 -fPIC'

dir_config(extname)
create_makefile(extname)
