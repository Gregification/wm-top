yocto beginner notes

there are at least 4 seprate git repos you must piddle with,
all 4 repos must be matching versions, its written somewhere
on their sites... somewhere... hard to find >:( .
1. BitBake (BB) : this is a build tool, just like 'make'. (is written in python, make sure thats installed)
1. Board Support Package (BSP) : provided by the board vendor
1. OpenEmbedded-Core (OE-Core) : 'core metadata'. huh? idk either.
1. Meta-OpenEmbedded (Meta-OE) : colleciton of supplimental layers to OE

the strat (read ALL before starting, to avoid getting locked into unsupported hardware!!):
- install (git pull) from the same root dir. this is not required but untl you know more about these tools
	    just follow along.
- make sure all these repos exist before starting anything!
- it seems every repo except BB uses branch names, so try matching the names
    1. find the BSP, install latest
    2. find the supported OE branch, install it
    3. find the BB branch that supports the branch of OE, install it
    4. find the Meta-OE branch that matches OE, install it

- the "poky" distribution you may see referenced in documents, is a single git repo that 
	contains a set of known-good repos - BB, OE-Core, and some refernce settings ; for 
	reasons(?) the yocto people decided they wont support poky anymore since its 
	bad practice or something along those lines, so we gotta do it our selves :(
	(see above for steps to do it). Poky is like trainnig wheeles, we ride or die; and brother we aint riding

at this poitn all the 'layers' are installed, need to tell OE to set up the enviroment,

&nbsp; go to the OE-Core dir and run the init script. its probably going to throw errors but just install what ever it yells at you for. it was en_US.UTF-8 locales and some lx4x things for me.

*run bitbake form within the geneerated build dir inside the OE dir.
     """ bitbake-layers show-layers """ , u gotta for like ../../<bitbase-layers>... unless u put it on PATH

use """ bitbake-layers add-layer ../apth/to/meta-oe """ (replace path as needed) to add in all the layers 

&nbsp;   we installed, until "" show-layers "" (see previous paragraph) shows all hte layers

after all the layers you need/want (idk man) are added, go find the BB config, usually called something

&nbsp; like 'machine' or what not; in the BSP. (.conf). if u read the file it also tells you what layers are 
    requried, s ogo abck and add them using bitbake.

inside the OE-Core/build/conf/local.con , set hte "MACHINE" variable to the file name of the conf u just found.

&nbsp; in my case the config file was "stm32mp15-disco.conf" so i did """ MACHINE = "stm32mp15-disco" """

&nbsp;this would also be the palce to tell XZ to limt ram and what not, inorder to build on low resource systems.

&nbsp; then see yocot proejct iamges refrence manual section. yaps about what commands nad args to use for 

&nbsp; what ever your looking for. sometimes the vendor also provides some recepies.

- before running the recipie, you can edit kernel config using """ bitbake -c menuconfig virtual/kernel """

could also use venfors BSP thign to have OE generate the build?
	TEMPLATECONF=../meta-st-stm32mp/conf/template/default BITBAKEDIR=../bitbake source openembedded-core/oe-init-build-env

## yocto image build options
> https://docs.yoctoproject.org/ref-manual/images.html

---
### useful things

- start container `docker compose up -d --build`
- open terminal in running container: `docker exec -it --user dev bash yocto_build_container`
- container side usb access to host
    1. install `winget install --interactive --exact dorssel.usbipd-win`
    1. bind and attach usb
        1. `usbipd list`
        1. `usbipd bind --busid <BUSID>`
        1. `usbipd attach --wsl --busid <BUSID>`
        1. see [here](https://youtu.be/KU8_HMfpv0s?t=712) for video about steps to preform.
    1. pass to docker `docker run -it --device=/dev/ttyUSB0 my-image`
        > or in compose 
        ```docker
        privileged: true 
        devices:
            - "/dev/ttyUSB0:/dev/ttyUSB0"  # [Host WSL Path] : [Container Path]
        ```
- short hand cmd to check partitions without fdisk, `sgdisk /dev/sde -p`

- upon sucessfully runnign the flash script it prints out some useful commands
    ```bash
    ###########################################################################

    RAW IMAGE generated: './flashlayout_core-image-minimal/opteemin/../../FlashLayout_sdcard_stm32mp157f-dk2-opteemin.raw'

    WARNING: before to use the command dd, please umount all the partitions
            associated to SDCARD.
        sudo umount `lsblk --list | grep mmcblk0 | grep part | gawk '{ print $7 }' | tr '\n' ' '`

    To put this raw image on sdcard:
        sudo dd if='./flashlayout_core-image-minimal/opteemin/../../FlashLayout_sdcard_stm32mp157f-dk2-opteemin.raw' of=/dev/mmcblk0 bs=8M conv=fdatasync status=progress

    mmcblk0 can be replaced by:
        sdX if it's a device dedicated to receive the raw image 
            (where X can be a, b, , d, e)

    To mount bootfs partition:
        udisksctl mount -b /dev/disk/by-partlabel/bootfs

    After the dd command you can verify if copy are correctly done and partitions take into account
        sgdisk /dev/mmcblk0 -p
        sgdisk /dev/mmcblk0 -v
    if '-v' command indicate a problem, please execute the following command:
        sgdisk /dev/mmcblk0 -e

    ###########################################################################
    ```
1. there are some possible intermittent steps to the docker file as well, set the `target` variable in the compose file
    1. base
    1. pull-resources-only
    1. full-build

1. something like this to flash, 32gb sdcard at /dev/sdg
    ```bash
    DEVICE=sdg scripts/create_sdcard_from_flashlayout.sh flashlayout_core-image-minimal/opteemin/FlashLayout_sdcard_stm32mp157d-dk1-opteemin.tsv
    ```
    - other args, skim the stop of the script for them
        - `SDCARD_SIZE=29800`

1. IMPORTANT!!! the vendor script to creat sdcard images may silently fail!
    - SOLUTION: use the script anyways so it sets up the partitions. BUT you have to manually dd over the binaries for each partition

1. #### [STM32MP1 bring-up troubleshooting guide](https://community.st.com/stm32-mpus-61/stm32mp1-bring-up-troubleshooting-guide-12)

1. inspect partition layout of raw image file 
    ```bash 
        fdisk -l image.raw
    ```

