.. _docker_2-page:

Docker 2
========

OS commands in image building
-----------------------------

Depending on the underlying OS, there are different ways to build images.

Know your base system and their packages. Popular ones:

* `Debian <https://packages.debian.org>`__

* `CentOS <https://centos.pkgs.org/>`__

* `Alpine <https://pkgs.alpinelinux.org/packages>`__

* Conda. `Anaconda <https://anaconda.org/anaconda/repo>`__, `Conda-forge <https://conda-forge.org/feedstocks/>`__, `Bioconda <https://anaconda.org/bioconda/repo>`__, etc.


Update and upgrade packages
***************************

* On **Ubuntu**:

.. code-block::

  apt-get update && apt-get upgrade -y


On **CentOS**:

.. code-block::

  yum check-update && yum update -y


Search and install packages
***************************

* In **Ubuntu**:

.. code-block::

  apt search libxml2
  apt install -y libxml2-dev


* In **CentOS**:

.. code-block::

  yum search libxml2
  yum install -y libxml2-devel.x86_64


.. note::
    The **-y** option that we set for updating and for installing.

    It is an important option in the context of Docker: it means that you *answer yes to all questions* regarding installation.


Building recipes
----------------

All commands should be saved in a text file, named by default **Dockerfile**.

Basic instructions
******************

Each row in the recipe corresponds to a **layer** of the final image.

**FROM**: parent image. Typically, an operating system. The **base layer**.

.. code-block:: dockerfile 

  FROM ubuntu:22.04


**RUN**: the command to execute inside the image filesystem.

Think about it this way: every **RUN** line is essentially what you would run to install programs on a freshly installed Ubuntu OS.

.. code-block:: dockerfile

  RUN apt install wget


A basic recipe:

.. code-block:: dockerfile

  FROM ubuntu:22.04

  RUN apt update && apt -y upgrade
  RUN apt install -y wget


docker build
************

Implicitely looks for a **Dockerfile** file in the current directory:

.. code-block:: console

  docker build .

Same as:

.. code-block:: console

  docker build --file Dockerfile .


Syntax: **\--file / \-f**

**.** stands for the context (in this case, current directory) of the build process. This makes sense if copying files from filesystem, for instance. **IMPORTANT**: Avoid contexts (directories) overpopulated with files (even if not actually used in the recipe).

You can define a specific name for the image during the build process.

Syntax: **-t** *imagename:tag*. If not defined ```:tag``` default is latest.

.. code-block:: console

  docker build -t mytestimage .
  # Same as:
  docker build -t mytestimage:latest .


.. warning:: 
   Avoid contexts (directories) over-populated with files (even if not actually used in the recipe).
   In order to avoid that some directories or files are inspected or included (e.g, with COPY command in Dockerfile), you can use .dockerignore file to specify which paths should be avoided. More information at: https://codefresh.io/docker-tutorial/not-ignore-dockerignore-2/

The last line of installation should be **Successfully built ...**: then you are good to go.

Check with ``docker images`` that you see the newly built image in the list...

Then let's check the ID of the image and run it!

.. code-block:: console

  docker images

  docker run f9f41698e2f8
  docker run mytestimage


More instructions
*****************

**WORKDIR**: all subsequent actions will be executed in that working directory

.. code-block::

  WORKDIR ~

**ADD, COPY**: add files to the image filesystem

Difference between ADD and COPY explained `here <https://stackoverflow.com/questions/24958140/what-is-the-difference-between-the-copy-and-add-commands-in-a-dockerfile>`__ and `here <https://nickjanetakis.com/blog/docker-tip-2-the-difference-between-copy-and-add-in-a-dockerile>`__

**COPY**: lets you copy a local file or directory from your host (the machine from which you are building the image)

**ADD**: same, but ADD works also for URLs, and for .tar archives that will be automatically extracted upon being copied.

If we have a file, let's say ```example.jpg```, we can copy it.

.. code-block::

  # COPY source destination
  COPY example.jpg .

A more sophisticated case:

.. code-block::

  FROM ubuntu:22.04

  RUN apt update && apt -y upgrade
  RUN apt install -y wget

  RUN mkdir -p /data

  WORKDIR /data

  COPY example.jpg .


**CMD, ENTRYPOINT**: command to execute when generated container starts

The ENTRYPOINT specifies a command that will always be executed when the container starts. The CMD specifies arguments that will be fed to the ENTRYPOINT

In the example below, when the container is run without an argument, it will execute `echo "hello world"`.
If it is run with the argument **hello moon** it will execute `echo "hello moon"`

.. code-block::

  FROM ubuntu:22.04
  ENTRYPOINT ["/bin/echo"]
  CMD ["hello world"]


A more complex recipe (save it in a text file named **Dockerfile**):

.. code-block::

  FROM ubuntu:22.04

  RUN mkdir -p /downloads
  WORKDIR /downloads

  RUN apt-get update && apt-get -y upgrade
  RUN apt-get install -y wget

  ENTRYPOINT ["/usr/bin/wget"]
  CMD ["https://cdn.wp.nginx.com/wp-content/uploads/2016/07/docker-swarm-hero2.png"]



.. code-block:: console

  docker run f9f41698e2f8 https://cdn-images-1.medium.com/max/1600/1*_NQN6_YnxS29m8vFzWYlEg.png


Docker build exercise
---------------------

* Random numbers

* Copy the following short bash script in a file called random_numbers.bash.

.. code-block:: console

  #!/usr/bin/bash
  seq 1 1000 | shuf | head -$1


This script outputs random intergers from 1 to 1000: the number of integers selected is given as the first argument.

* Write a recipe for an image:

  * Based on `centos:8`

  * That will execute this script (with bash) when it is run, giving it 2 as a default argument (i.e. outputs 2 random integers): the default can be changed as the image is run.

  * Build the image.

  * Start a container with the default argument, then try it with another argument.

.. raw:: html

  <details>
  <summary><a>Suggested solution</a></summary>

.. code-block::

  FROM centos:8

  # Copy script from host to image
  COPY random_numbers.bash .

  # Make script executable
  RUN chmod +x random_numbers.bash

  # As the container starts, "random_numbers.bash" is run
  ENTRYPOINT ["/usr/bin/bash", "random_numbers.bash"]

  # default argument (that can be changed on the command line)
  CMD ["2"]

Build and run:

.. code-block:: console

  docker build -f Dockerfile_RN -t random_numbers .
  docker run random_numbers
  docker run random_numbers 10

.. raw:: html

  </details>

docker tag
-----------

To tag a local image with ID "e23aaea5dff1" into the "ubuntu_wget" image name repository with version "1.0":

.. code-block:: console

  docker tag e23aaea5dff1 ubuntu_wget:1.0

docker push
-----------

We upload our built container image into a registry. This way we can share among different users. Default is `Docker Hub <https://hub.docker.com>`_, but we can use other ones as well.

As an example, we are going to use Gitlab Registry. We can use for sharing images to be used with the cluster.

.. image:: /images/gitlab-deploy-container-registry.png
  :width: 700


.. image:: /images/gitlab-deploy-container-registry-detail.png
  :width: 700


We create a project on Gitlab, and then we can use the Gitlab Registry.

.. code-block:: console

  docker login gitlab.linux.crg.es:5005

  docker build -t gitlab.linux.crg.es:5005/myusername/myproject -f Dockerfile .

  docker push gitlab.linux.crg.es:5005/myusername/myproject


Additional docker commands
--------------------------

* `docker (image) inspect`: Provide details of the running container or metadata about the image
  * Open Container Specs labels: https://specs.opencontainers.org/image-spec/annotations/
  * LABEL tag: https://docs.docker.com/engine/reference/builder/#label
* `docker commit`: Turn a container into an image
* `docker save`: Save an image to a tar archive
* `docker load`: Load an image from a tar archive
* `docker export`: Export a container's filesystem as a tar archive (little used)
* `docker import`: Import the contents from a tarball to create a filesystem image (little used)

Recommend workflow: If necessary, commit a Docker container into an image and then save it into a tar archive that can be shared and loaded in another machine.

* Reference: https://www.baeldung.com/ops/docker-save-export

Major clean
-----------

Check used space

.. code-block:: console

  docker system df


Remove unused containers (and others) - **DO WITH CARE**

.. code-block:: console

  docker system prune


Remove ALL non-running containers, images, etc. - **DO WITH MUCH MORE CARE!!!**

.. code-block:: console

  docker system prune -a

* Reference: https://www.digitalocean.com/community/tutorials/how-to-remove-docker-images-containers-and-volumes
