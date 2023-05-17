FROM postgres:13

RUN apt-get update && \
  apt-get install -y --no-install-recommends git ca-certificates build-essential postgresql-server-dev-13 && \
  git clone https://github.com/pgvector/pgvector.git /tmp/pgvector && \
  cd /tmp/pgvector && \
  make clean && \
  make OPTFLAGS="" && \
  make install && \
  mkdir /usr/share/doc/pgvector && \
  cp LICENSE README.md /usr/share/doc/pgvector && \
  rm -r /tmp/pgvector && \
  apt-get remove -y build-essential postgresql-server-dev-13 && \
  apt-get autoremove -y && \
  rm -rf /var/lib/apt/lists/*