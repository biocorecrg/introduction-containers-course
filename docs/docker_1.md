# Docker 1

## What is Docker?

- Platform for developing, shipping and running applications.
- Infrastructure as application / code.
- First version: 2013.
- Company: originally dotCloud (2010), later named Docker.
- Established [Open Container Initiative](https://www.opencontainers.org/).

As a software:

- [Docker Community Edition](https://www.docker.com/products/container-runtime).
- Docker Enterprise Edition.

There is an increasing number of alternative container technologies and providers. Many of them are actually based on software components originally from the Docker stack, and they normally try to address some specific use cases or weak points. As an example, **Singularity**, that we introduce later in this course, is focused on HPC environments. Another case, **Podman**, keeps a high functional compatibility with Docker but with a different focus on technology (not keeping a daemon) and permissions.

## Docker components

```{image} http://apachebooster.com/kb/wp-content/uploads/2017/09/docker-architecture.png
:width: 700
```

- Read-only templates.
- Containers are run from them.
- Images are not run.
- Images have several layers.

## Images versus containers

- **Image**: A set of layers, read-only templates, inert.
- An instance of an image is called a **container**.

When you start an image, you have a running container of this image. You can have many running containers of the same image.

*"The image is the recipe, the container is the cake; you can make as many cakes as you like with a given recipe."*

<https://stackoverflow.com/questions/23735149/what-is-the-difference-between-a-docker-image-and-a-container>

## Docker vocabulary

```console
docker
```

```{image} images/docker_vocab.png
:width: 550
```

Get help:

```console
docker run --help
```

```{image} images/docker_run_help.png
:width: 550
```

## Using existing images

### Explore Docker hub

Images can be stored locally or shared in a registry.

[Docker hub](https://hub.docker.com/) is the main public registry for Docker images.

Let's search the keyword **ubuntu**:

```{image} images/dockerhub_ubuntu.png
:width: 900
```

### docker pull: import image

- get latest image / latest release

```console
docker pull ubuntu
```

```{image} images/docker_pull.png
:width: 650
```

- choose the version of Ubuntu you are fetching: check the different tags

```{image} images/dockerhub_ubuntu_1804.png
:width: 850
```

```console
docker pull ubuntu:22.04
```

## docker images: list images

```console
docker images
```

```{image} images/docker_images_list.png
:width: 650
```

Each image has a unique **IMAGE ID**.

## docker run: run image, i.e. start a container

Now we want to use what is **inside** the image.

**docker run** creates a fresh container (active instance of the image) from a **Docker (static) image**, and runs it.

The format is:

docker run image:tag **command**

```console
docker run ubuntu:22.04 /bin/ls
```

```{image} images/docker_run_ls.png
:width: 200
```

Now execute **ls** in your current working directory: is the result the same?

You can execute any program/command that is stored inside the image:

```console
docker run ubuntu:22.04 /bin/whoami
docker run ubuntu:22.04 cat /etc/issue
```

You can either execute programs in the image from the command line (see above) or **execute a container interactively**, i.e. **"enter"** the container.

With **--name** you can provide a name to the container.

```console
docker run -it ubuntu:22.04 /bin/bash

docker run --name myubuntu -it ubuntu:22.04 /bin/bash
```

You can run containers in detached mode (kept in the background):

```console
docker run -it --detach ubuntu:22.04 /bin/bash

docker run --name myubuntu2 -it --detach ubuntu:22.04 /bin/bash
```

## docker ps: check containers status

List running containers:

```console
docker ps
```

List all containers (whether they are running or not):

```console
docker ps -a
```

## docker exec: execute process in running container

```console
docker exec myubuntu2 uname -a
```

- Interactively

```console
docker exec -it myubuntu2 /bin/bash
```

## docker stop, start, restart: actions on container

Stop a running container:

```console
docker stop myubuntu2

docker ps -a
```

Start a stopped container (does NOT create a new one):

```console
docker start myubuntu2

docker ps -a
```

Restart a running container:

```console
docker restart myubuntu2

docker ps -a
```

## docker rm, docker rmi: clean up!

```console
docker rm myubuntu
docker rm -f myubuntu
```

```console
docker rmi ubuntu:22.04
```

## Volumes

Docker containers are fully isolated. It is necessary to mount volumes in order to handle input/output files.

Syntax: **--volume/-v** *host:container*

```console
mkdir data
# We can also copy the FASTQ we used in data
docker run --volume $(pwd)/data:/scratch --name fastqc_container biocontainers/fastqc:v0.11.9_cv7 fastqc /scratch/B7_input_s_chr19.fastq.gz
```

## Volume exercises

1. Copy the 2 fastq files from available datasets in Github repository and place them in mounted directory
2. Run fastqc interactively (inside container): `` `fastqc  /scratch/*.gz` ``
3. Run fastqc non-interactively (outside the container)

## docker run --user

It is possible to run certain containers with a specific user, appending `` `run --user` ``.

A convenient command would be:

```console
docker run --user $(id -u):$(id -g) --volume $(pwd)/data:/scratch --name user_test biocontainers/fastqc:v0.11.9_cv7 touch /scratch/userfile
```

## Ports

The same as with volumes, but with ports, to access Internet services.

Syntax: **--publish/-p** *host:container*

```console
docker run --detach --name webserver nginx
curl localhost:80
docker exec webserver curl localhost:80
docker rm -f webserver
```

```console
docker run --detach --name webserver --publish 80:80 nginx
curl localhost:80
docker rm -f webserver
```

```console
docker run --detach --name webserver -p 8080:80 nginx
curl localhost:80
curl localhost:8080
docker exec webserver curl localhost:80
docker exec webserver curl localhost:8080
docker rm -f webserver
```
