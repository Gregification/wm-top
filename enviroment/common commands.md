# handy command cheat sheet

## host: starting

1. start enviroment: `docker compose up -d --build`
    - there are build stages to the main docker file, select it by setting the "target" variable in the docker-compose file
        - base
        - pull-resources-only
        - full-build
1. terminal in enviroment container: `docker exec -it --user dev yocto_workspace bash`


## enviroment: yocto tools

1. list included layers `bitbake-layers show-layers`

