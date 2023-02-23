#Build process for SIF images using Docker and WSL backend
#Look at the build process with:
# Get-Content ./build.log -Wait -Tail 50
#Start the process in the background with (problematic with reading the password):
# Start-Job -Name "Docker+Singularity build" -FilePath "./build.ps1"

#Ask for the admin password for WSL sudo and store it in variable
# $secpass = Read-Host "Your WSL admin password" -AsSecureString
$projdir = $PWD.Path

#Build the Docker base container
Get-Content "$projdir\dockerfiles\r-bioverse.Dockerfile" | docker build --progress=plain --tag "allumik/r-bioverse" - *>> "$projdir/build.log"

#Push the container to DockerHub
docker image push allumik/r-bioverse

# #Run Singularity/Apptainer in WSL in su and build the SIF file (note: "`" is for escaping PS piping or newlines)
# [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($secpass)) | `
#   wsl sudo -S apptainer build --force r-bioverse-dev.sif r-bioverse-dev.def `| tee ../build.log


#Or run it in a Docker container instead of WSL
Get-Content "$projdir/dockerfiles/sif-build.Dockerfile" | docker build --progress=plain --tag "allumik/sif-builder" - *>> "$projdir/build.log"
docker run --privileged -v $projdir\:/app allumik/sif-builder build --force /app/r-bioverse-dev.sif /app/def_files/r-bioverse-dev.def *>> "$projdir/build.log"


## Aaand go get a cup of coffee ☕️!


#Did anything go wrong?
# Select-String -Path "./build.log" -Pattern "error"