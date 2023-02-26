#FROM centos:centos8
FROM registry.redhat.io/ubi8/ubi

USER root 

COPY import_repo.sh /

RUN chmod +x /import_repo.sh 

RUN yum install -y \
    git \
    python3 

RUN python3 -m pip install --upgrade pip wheel && \
    python3 -m pip install httpie
 
ENTRYPOINT ["cmd", "import_repo.sh"]