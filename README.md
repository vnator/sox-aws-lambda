# Base
Build [sox project](http://sox.sourceforge.net/) with docker, to use the sox binary in aws-lambda

# How?
```bash
git clone https://github.com/vnator/sox-aws-lambda.git
cd sox-aws-lambda

#the default is to use amazonlinux:latest image:
./run.sh

#if you need to use amazonlinux:1 image, run as follow:
./run.sh amazonlinux-1
```

after the end of the script execution, in case of success you can see the follow message in you terminal:
> Binary available in bin directory

have fun with sox-aws-lambda in your aws-lambda!

I case of something go wrong, feel free to edit [Dockerfile](./amazonlinux-latest/Dockerfile) or [scripts/build.sh](./scripts/build.sh). In this case you can use aditional options of `run.sh` script:
```bash
# In case of change the scripts/build.sh you need only to rerun it in your container without update the docker image:
./run.sh

# If you change the Dockerfile you need to update the docker image and rerun the script in a new container
./run.sh amazonlinux-latest update

# If you aready runned the docker image / docker container, and only need to copy the sox-aws-lambda again from your container, run:
./run.sh amazonlinux-latest install

# You can also delete all the docker things
./run.sh amazonlinux-latest clean
```
