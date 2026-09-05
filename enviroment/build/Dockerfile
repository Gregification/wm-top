FROM ubuntu:24.04 AS base

ARG USERNAME=dev

# enable if contianer has <~8gig memory, does what it can to reduce concurrent memory usage; slows build dramatically.
ARG LOW_MEMORY_BUILD=false

ARG BUILD_DIR=build-wm

# icecream distributed compiler. https://github.com/icecc/icecream
ARG ICECREAM_yippie=true
# must manually specify max jobs since yocto only checks local machine and will limit accordingly
ARG ICECREAM_maxThreads=50
# auto-discovery is a thing but it sometimes fails, uncomment to set scheduler server ip
#RUN export ICECC_SCHEDULER_HOST="192.168.1.100"


###################################################################################################
# tools and general enviroment setup
###################################################################################################

# Avoid interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# colorful terminal
ENV TERM=xterm-256color

# force clean build dir incase its a shared volume or something bonkers
RUN rm -rf /home/${USERNAME}/projects/yocto/${BUILD_DIR}

RUN apt-get update && apt-get install -y \
    git \
    tmux \
    file \
    fdisk \
    bsdextrautils \
    udev \
    curl \
    cmake \
    device-tree-compiler \
    build-essential \
    sudo \
    python3 \
    python-is-python3 \
    gawk \
    gdisk \
    wget \
    diffstat \
    unzip \
    texinfo \
    chrpath \
    socat \
    cpio \
    locales \
    lz4 \
    zstd \
    vim \
    icecc \
    icecream-sundae \
    net-tools \
    && locale-gen en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

# Create user, assign groups, and enable passwordless sudo
RUN useradd -m -s /bin/bash -G dialout,plugdev ${USERNAME} && \
    echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Create the ~/projects/yocto directory structure with proper permissions
RUN mkdir -p /home/${USERNAME}/projects/yocto && \
    chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}

# Switch to non-root user to perform git operations
USER ${USERNAME}
WORKDIR /home/${USERNAME}/projects/yocto


###################################################################################################
# pull repos
###################################################################################################


# Clone the required Yocto layers
# justifications and sourcing for these layers
#   some of these requiredments are foudn form the ocnf files, others just yell at u if u try to build w/o
#   A: stm32mp157d-dk1 bsp : https://github.com/STMicroelectronics/meta-st-stm32mp
RUN git clone -b scarthgap https://github.com/STMicroelectronics/meta-st-stm32mp
#          [OECORE]
#       B: URI: https://github.com/openembedded/openembedded-core.git
#           - ERROR: Layer 'stm-st-stm32mp' depends on layer 'openembedded-layer', but this layer is not enabled in your configuration
#           - ERROR: Layer 'meta-python' depends on layer 'openembedded-layer', but this layer is not enabled in your configuration
RUN git clone -b scarthgap https://github.com/openembedded/openembedded-core.git
#          layers: meta
#          branch: same dedicated branch as meta-st-stm32mp
#          revision: HEAD
#          [BITBAKE]
#       C: URI: https://github.com/openembedded/bitbake.git
RUN git clone -b yocto-6.0 https://github.com/openembedded/bitbake.git
#          branch: branch associated to oecore branch
#          revision: HEAD
#           - version compatiability is checked when running the oe-init-build-env script
#   D: bitbake detected as missing 'meta-python', 'openembedded-core'
RUN git clone -b scarthgap https://git.openembedded.org/meta-openembedded
#   E: distro
RUN git clone -b scarthgap https://github.com/STMicroelectronics/meta-st-openstlinux.git
#:  F: :)
RUN git clone -b scarthgap https://github.com/Gregification/meta-wm-bsp.git


# Symlink bitbake inside openembedded-core so oe-init-build-env finds it automatically
RUN ln -s /home/${USERNAME}/projects/yocto/bitbake /home/${USERNAME}/projects/yocto/openembedded-core/bitbake
# Set environment variables natively in Docker (persists across all steps and sessions)
ENV PATH="/home/${USERNAME}/projects/yocto/bitbake/bin:${PATH}"

#######

WORKDIR /home/${USERNAME}/projects/yocto/openembedded-core/

RUN ./oe-init-build-env ../${BUILD_DIR}
# Auto-source the Yocto environment whenever you attach or exec into the container
RUN echo "source /home/${USERNAME}/projects/yocto/openembedded-core/oe-init-build-env /home/${USERNAME}/projects/yocto/${BUILD_DIR}" >> /home/${USERNAME}/.bashrc

# Tells BitBake to spawn the terminal command in the active shell directly
RUN echo 'OE_TERMINAL = "tmux"' >> /home/${USERNAME}/projects/yocto/${BUILD_DIR}/conf/local.conf

FROM base AS pull-resources-only
CMD ["bash"]


###################################################################################################
# build
###################################################################################################

FROM pull-resources-only AS full-build

#You can now run 'bitbake <target>'
#Common targets are:
#    core-image-minimal
#    core-image-full-cmdline
#    core-image-sato
#    core-image-weston
#    meta-toolchain
#    meta-ide-support

# from within the build folder run this command to show the layers
# bitbake-layers show-layers

WORKDIR /home/${USERNAME}/projects/yocto/${BUILD_DIR}

# update the file pats to match the username, cant figure out how to get docker to evaluate instead of as a literal
RUN [ "${USERNAME}" = "dev" ] || { exit 1; }
# add layers to build, doing it using bitbake-layers add-layer dosent add everything
RUN cat << 'EOF' > /home/${USERNAME}/projects/yocto/${BUILD_DIR}/conf/bblayers.conf
LCONF_VERSION = "7"
BBPATH = "${TOPDIR}"
BBFILES ?= ""

BBLAYERS ?= " \
  /home/dev/projects/yocto/openembedded-core/meta \
  /home/dev/projects/yocto/meta-openembedded/meta-oe \
  /home/dev/projects/yocto/meta-openembedded/meta-python \
  /home/dev/projects/yocto/meta-st-stm32mp \
  /home/dev/projects/yocto/meta-wm-bsp \
  /home/dev/projects/yocto/meta-st-openstlinux \
  "
EOF

# snab the config from the vendor BSP repo
#   note: this is for stm32mp15-disco (discovery), the config file also shows some needed layers at the top
#       found the bsp configs here: 'meta-st-stm32mp/conf/machine'
#       !!! check the file supports the exact bord model !!!
#   Update MACHINE in local.conf using sed (in-place replacement)
RUN sed -i 's/^MACHINE ??=.*/MACHINE = "stm32mp1"/' /home/dev/projects/yocto/${BUILD_DIR}/conf/local.conf

# to save space when using WSL
#   Automatically delete build intermediate files after packaging
RUN echo 'INHERIT += "rm_work"' >> /home/dev/projects/yocto/${BUILD_DIR}/conf/local.conf
#   Exclude specific heavy targets from rm_work if you need to debug them
RUN echo 'RM_WORK_EXCLUDE += "virtual/kernel"' >> /home/dev/projects/yocto/${BUILD_DIR}/conf/local.conf

RUN if [ "$ICECREAM_yippie" = "true" ]; then \
        echo "sudo service iceccd start" >> /home/${USERNAME}/.bashrc \
        echo 'INHERIT += "icecc"' >> /home/dev/projects/yocto/${BUILD_DIR}/conf/local.conf \
        echo 'ICECC_DISABLED = "0"' >> /home/dev/projects/yocto/${BUILD_DIR}/conf/local.conf \
        echo 'PARALLEL_MAKE = "-j ${ICECREAM_maxThreads}"' >> /home/dev/projects/yocto/${BUILD_DIR}/conf/local.conf \
        echo 'ICECC_PARALLEL_MAKE = "-j ${ICECREAM_maxThreads}"' >> /home/dev/projects/yocto/${BUILD_DIR}/conf/local.conf \
        echo 'ICECC_SCHEDULER_HOST="localhost"' >> /etc/icecc/icecc.conf \
    else \
        echo 'ICECC_DISABLED = "1"' >> /home/dev/projects/yocto/${BUILD_DIR}/conf/local.conf \
    fi

# to reduce max memory required,
#   page sizes used by xz. will silentely fail even if swap is available sometimes. only needed on very dinky systems.
RUN if [ "$LOW_MEMORY_BUILD" = "true" ]; then \
        echo 'XZ_DEFAULTS = "--memlimit=1024M"' >> /home/dev/projects/yocto/${BUILD_DIR}/conf/local.conf; \
    fi

# build
#   you can also just run make menuconfig directly, no need for bitbake
RUN echo "bitbake -c menuconfig virtual/kernel" >> build_simple.sh
#   actually build the image 
RUN echo "bitbake core-image-minimal" >> build_simple.sh
RUN chmod 777 build_simple.sh

# build output in resulting path something like: tmp/deploy/images
# can copy to host using as admin: docker cp yocto_build_container:/home/dev/projects/yocto/build-test/tmp-glibc/deploy/images/stm32mp15-disco ./
# the rest cna be done though WSL using the copied files
# theres a scropt to greate the build output inside the image dir, under a folder called scripts. make sure to edit the script values to use 
#   the correct storage device!

# IMPORTANT, THE **** VENDOR SCRIPT IS funky. will silentely fail to make a working .raw image for the sdcard >:( . 
#   SOLUTION: use the script anyways so it sets up the partitions. BUT you have to manually dd over the binaries for each partition

# start icecream service conditionaly
ENV ICECREAM_yippie=${ICECREAM_yippie}
ENTRYPOINT ["sh", "-c", "if [ \"$ICECREAM_yippie\" = \"true\" ]; then echo \"Starting iceccd service...\"; sudo service iceccd start; fi && exec \"$@\"", "--"]

CMD ["bash"]
