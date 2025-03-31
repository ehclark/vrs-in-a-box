FROM ubuntu:24.04

ARG ASSEMBLY="grch38"

RUN apt-get update && apt-get upgrade -y && apt-get install -y \
    python3-pip \
    python3-venv \
    postgresql \
    libpq-dev \
    curl \
    unzip \
    ;

WORKDIR /vrs-python

RUN python3 -m venv /vrs-python/venv
ENV PATH=/vrs-python/venv/bin:$PATH

RUN /vrs-python/venv/bin/python3 -m pip install -U setuptools
RUN /vrs-python/venv/bin/python3 -m pip install 'ga4gh.vrs[extras]'

WORKDIR /
RUN curl -O -L https://github.com/ehclark/vrs-in-a-box/releases/download/seqrepofiles/seqrepo-${ASSEMBLY}.zip
RUN unzip seqrepo-${ASSEMBLY}.zip -d / && rm -f seqrepo-${ASSEMBLY}.zip
ENV GA4GH_VRS_DATAPROXY_URI="seqrepo+file:///seqrepo-${ASSEMBLY}/master"

ENV VIRTUAL_ENV=/vrs-python/venv
ENV PATH=/vrs-python/venv/bin:$PATH

WORKDIR /

ENTRYPOINT [ "/vrs-python/venv/bin/vrs-annotate", "vcf" ]
