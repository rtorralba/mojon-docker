FROM z88dk/z88dk

RUN wget https://github.com/mojontwins/MK1/raw/master/lib/splib2/splib2_mk2.lib -O /opt/z88dk/lib/clibs/splib2_mk2.lib
RUN wget https://raw.githubusercontent.com/mojontwins/MK1/master/lib/splib2/spritepack.h -O /opt/z88dk/include/spritepack.h

RUN export Z88DK="/opt/z88dk"
RUN export PATH="$PATH:$Z88DK/bin"
RUN export Z80_OZFILES="$Z88DK/lib/"
RUN export ZCCCFG="$Z88DK/lib/config/"