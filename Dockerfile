# Defines the tag for OBS and build script builds:
#!BuildTag: my_container

FROM opensuse/leap:15.3

#ARG ARCH=amd64
ARG ARCH=x86_64
ENV ARCH=${ARCH}

RUN zypper mr --disable repo-non-oss repo-update-non-oss
RUN zypper --no-gpg-checks ref
RUN zypper update -y

# Work around https://github.com/openSUSE/obs-build/issues/487
RUN zypper install -y openSUSE-release-appliance-docker

#USER wwwrun
#WORKDIR /srv/www

# Define your additional repositories here
#RUN zypper ar http://download.opensuse.org/repositories/openSUSE:Tools/openSUSE_Factory openSUSE:Tools

# Put additional files into container
#ADD . README.MY-APPLIANCE
#COPY MY.FILE /opt/my_space

# Install further packages using zypper
RUN zypper install -y htop

# This command will get executed on container start by default
#CMD /usr/sbin/httpd2-prefork

RUN zypper install -y kernel-default kernel-devel gcc make dkms


#RUN mkdir /var/lib/dkms
COPY var_lib_dkms /var/lib/dkms

ENV KERNELRELEASE=5.3.18-59.27-default

RUN rm /lib/modules/${KERNELRELEASE}/kernel/drivers/scsi/hpsa.ko.xz

RUN dkms uninstall -k $KERNELRELEASE --force hpsa-dkms/1.0 ;\
    dkms install -k $KERNELRELEASE --force hpsa-dkms/1.0 


COPY hpsahba /root/hpsahba
RUN cd /root/hpsahba/ && make && cp hpsahba /usr/local/bin/
RUN hpsahba -h

COPY unsupported-modules.conf /etc/modprobe.d/10-unsupported-modules.conf
