### docker build --pull -t jdob/python-web:2.0

FROM registry.access.redhat.com/rhel7
MAINTAINER Jason Dobies <jdobies@redhat.com>

### Atomic/OpenShift Labels - https://github.com/projectatomic/ContainerApplicationGenericLabels
LABEL name="jdob/python-web" \
      vendor="Dobtech" \
      version="2.0" \
      release="1" \
### Required labels above - recommended below
      url="https://dobtech.io" \
      summary="Certified dumb python web application" \
      description="Says Hello World over HTTP" \
      run='docker run -tdi --name ${NAME} ${IMAGE}' \
      io.k8s.description="Serves Hello World over HTTP" \
      io.k8s.display-name="python-web" \
      io.openshift.expose-services="" \
      io.openshift.tags="jdob,starter-epel,starter,epel"

### Atomic Help File - Write in Markdown, it will be converted to man format at build time.
### https://github.com/projectatomic/container-best-practices/blob/master/creating/help.adoc
COPY help.md user_setup /tmp/

### Add necessary Red Hat repos here
[]RUN REPOLIST=rhel-7-server-rpms,rhel-7-server-optional-rpms,epel \
### Add your package needs here
    INSTALL_PKGS="golang-github-cpuguy83-go-md2man \
    python34 \
    jq" && \
    yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && \
    yum -y update-minimal --disablerepo "*" --enablerepo rhel-7-server-rpms --setopt=tsflags=nodocs \
      --security --sec-severity=Important --sec-severity=Critical && \
    yum -y install --disablerepo "*" --enablerepo ${REPOLIST} --setopt=tsflags=nodocs ${INSTALL_PKGS} && \
### help file markdown to man conversion
    go-md2man -in /tmp/help.md -out /help.1 && \
    yum clean all

### Setup user for build execution and application runtime
ENV APP_ROOT=/opt/app-root \
    USER_NAME=default \
    USER_UID=10001
ENV APP_HOME=${APP_ROOT}/src  PATH=$PATH:${APP_ROOT}/bin
RUN mkdir -p ${APP_HOME}
RUN chmod -R ug+x /tmp/user_setup && /tmp/user_setup

####### Add app-specific needs below. #######
### Containers should NOT run as root as a good practice
USER ${USER_UID}
WORKDIR ${APP_ROOT}

COPY web.py ${APP_ROOT}

CMD /bin/bash -c 'python3 -u ${APP_ROOT}/web.py'
