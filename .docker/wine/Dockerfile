FROM i386/alpine:3.10.2

# Wine 32Bit for running EXE
RUN apk add --no-cache wine freetype ncurses

# Configure Wine
RUN winecfg

# Install wget
RUN apk add --no-cache wget=1.20.3-r0

# Download Mono
RUN wget -P /mono http://dl.winehq.org/wine/wine-mono/4.9.3/wine-mono-4.9.3.msi

# Install Mono Runtime for .NET Applications
RUN wine msiexec /i /mono/wine-mono-4.9.3.msi
RUN rm -rf /mono/wine-mono-4.9.3.msi

# Fake X11 display for headless execution
RUN apk add --no-cache xvfb-run=1.20.4-r0