#Build process for SIF images using Docker and WSL backend
#Look at the build process with:
# Get-Content ./build.log -Wait -Tail 50
#Start the process in the background with (problematic with reading the password):
# Start-Job -Name "Docker+Singularity build" -FilePath "./build.ps1"

#Ask for the admin password for WSL sudo and store it in variable
$secpass = Read-Host "Your WSL admin password" -AsSecureString

#Build the Docker base container
Get-Content ".\r-bioverse.Dockerfile" | docker build --progress=plain --tag "allumik/r-bioverse" - *>> ../build.log

#Push the container to DockerHub
docker image push allumik/r-bioverse:fat

#Run Singularity/Apptainer in WSL in su and build the SIF file (note: "`" is for escaping PS piping or newlines)
#Could also be done in vagrant
[Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($secpass)) | `
  wsl sudo -S singularity build --force r-bioverse-dev.sif r-bioverse-dev.def `| tee ../build.log


#Aaand go get a cup of coffee!


#Did anything go wrong?
# Select-String -Path "./build.log" -Pattern "error"