FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TERM=xterm-256color

# 1. Install icecc (daemon), icecream (client), and ncurses-term (fixes terminal colors)
RUN apt-get update && apt-get install -y \
    icecc \
    icecream \
    icecream-sundae \ 
    net-tools \
    build-essential \
    ncurses-term \
    && rm -rf /var/lib/apt/lists/*

ENV ICECC_SCHEDULER_HOST="192.168.1.100" \
    ICECC_NETNAME="icecream" \
    ICECC_MAX_JOBS=""

EXPOSE 10245/tcp

# Run iceccd daemon directly as the main process
#CMD ["sh", "-c", "exec iceccd -d -s \"${ICECC_SCHEDULER_HOST}\" -n \"${ICECC_NETNAME}\" ${ICECC_MAX_JOBS:+-m \"${ICECC_MAX_JOBS}\"} -v"]
CMD ["bash"]