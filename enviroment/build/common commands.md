# handy command cheat sheet

## host: starting

1. start enviroment: `docker compose up -d --build`
    - there are build stages to the main docker file, select it by setting the "target" variable in the docker-compose file
        - base
        - pull-resources-only
        - full-build
1. terminal in enviroment container: `docker exec -it --user dev yocto_workspace bash`
1. sharing windows host usb with wsl/docker-contianer. useful for using USB<->SDCard readers
    1. show attached usbs `usbipd list`
    1. bind usb in question `usbipd bind --busid 10-1 --force`
    1. share for wsl access `usbipd attach --wsl --busid 10-1`
        - set `/dev/` as a shared volume between wsl and the container

## enviroment: yocto tools

1. list included layers `bitbake-layers show-layers`
1. piddle iwth the BB_PRESSURE_MAX_MEM variable for bitbake to avoid disk thrashing
    ```bash
    export BB_PRESSURE_MAX_MEM="250"
    bitbake core-image-minimal
    ```
1. flashing sdcard after build, something like this command 
    ```bash
    DEVICE=sdg scripts/create_sdcard_from_flashlayout.sh flashlayout_core-image-minimal/opteemin/FlashLayout_sdcard_stm32mp157d-dk1-opteemin.tsv
    ```