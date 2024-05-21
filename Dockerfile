from ubuntu:22.04

ARG CLAMAV_VERSION=1.0.6
ARG CLAMAV_ARTIFACT=clamav-$CLAMAV_VERSION.tar.gz
ARG CLAMAV_ARTIFACT_URL=https://www.clamav.net/downloads/production/$CLAMAV_ARTIFACT

# https://docs.clamav.net/manual/Installing/Installing-from-source-Unix.html#ubuntu--debian
RUN apt-get update && apt-get install -y \
  `# install tools` \
  gcc make pkg-config python3 python3-pip python3-pytest valgrind cmake \
  `# install clamav dependencies` \
  check libbz2-dev libcurl4-openssl-dev libjson-c-dev libmilter-dev \
  libncurses5-dev libpcre2-dev libssl-dev libxml2-dev zlib1g-dev

RUN python3 -m pip install --user cmake

RUN apt-get install -y cargo rustc curl

# https://docs.clamav.net/manual/Installing/Installing-from-source-Unix.html#download-the-source-code
RUN curl -L --fail -o $CLAMAV_ARTIFACT $CLAMAV_ARTIFACT_URL
RUN tar xzf $CLAMAV_ARTIFACT
RUN cd clamav-$CLAMAV_VERSION &&  mkdir build && cd build && \
 cmake .. \
  -D CMAKE_INSTALL_PREFIX=/usr \
  -D CMAKE_INSTALL_LIBDIR=lib \
  -D APP_CONFIG_DIRECTORY=/etc/clamav \
  -D DATABASE_DIRECTORY=/var/lib/clamav \
  -D ENABLE_JSON_SHARED=OFF && \
 cmake --build . && \
 ctest && \
 cmake --build . --target install


# Add service user account https://docs.clamav.net/manual/Installing/Add-clamav-user.html
RUN groupadd clamav && \
    useradd -g clamav -s /bin/false -c "Clam Antivirus" clamav && \
    chown -R clamav:clamav /var/lib/clamav/

# Configuration of clamav
 
