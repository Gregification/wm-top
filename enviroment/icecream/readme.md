icecream is non-functional.
ST's bsp dosent seem to support it. im sure theres a workaround but I couldnt get it going.

This compose project is a worker node, the scheduler is part of the yocto-build compose file.

To enable: 
- update `ICECC_SCHEDULER_HOST` to the host machine that runs the scheduler container. 
- enable the scheduler container in the yocto-build compose file
- set `ICECREAM_yippie=true` in the yocto-build Dockerfile
- start both, icecream clietns will automatically connect
- good luck getting the vendor bsp happy :thumbs_up:, do update this if you do.

