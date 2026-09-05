# i suggest using a free program called "windirstat" to find and manually hit the "optimise" option. 
#   Theres probably other bloated vhdx files floating around

docker system prunt
wsl --shutdown
Optimize-VHD -Path "$env:LOCALAPPDATA\Docker\wsl\disk\docker_data.vhdx" -Mode Full
