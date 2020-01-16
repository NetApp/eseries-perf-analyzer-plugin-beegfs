FROM ubuntu:18.04
ARG DEBIAN_FRONTEND=noninteractive
COPY beegfs-deb9.list ./
COPY DEB-GPG-KEY-beegfs ./
COPY repomirror_sources.list ./
COPY repomirror_beegfs-deb9.list ./
COPY repo_check.sh /repo_check.sh
RUN chmod +x repo_check.sh
RUN ./repo_check.sh
RUN apt-get install gnupg2 ca-certificates -y && rm -rf /var/lib/apt/lists/*
RUN apt-key add DEB-GPG-KEY-beegfs
RUN apt-get update && apt-get install beegfs-mon -y && rm -rf /var/lib/apt/lists/*
COPY docker-entrypoint.sh ./
RUN chmod +x *.sh
ENTRYPOINT ["./docker-entrypoint.sh"]