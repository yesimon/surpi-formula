{% set os = salt['grains.get']('os') %}

build-essential:
  pkg.installed

make:
  pkg.installed

autoconf:
  pkg.installed

csh:
  pkg.installed

python-dev:
  pkg.installed

python-pip:
  pkg.installed

gcc:
  pkg.installed

g++:
  pkg.installed

unzip:
  pkg.installed

curl:
  pkg.installed

wget:
  pkg.installed

cpanminus:
  pkg.installed

ghostscript:
  pkg.installed

blast2:
  pkg.installed

python-matplotlib:
  pkg.installed

git:
  pkg.installed

pigz:
  pkg.installed

moreutils:
  pkg.installed

ncbi-blast+:
  pkg.installed

genometools:
  pkg.installed

seqtk: # version 1.0-r31
  pkg.installed

stow:
  pkg.installed

cutadapt:
  pip.installed:
    - name: cutadapt == 1.8.3
    - require:
        - pkg: python-pip

DBI:
  cmd.run:
    - name: sudo cpanm DBI
    - require:
        - pkg: cpanminus
    - unless: test -d /usr/local/lib/*/perl/*/DBI

dbd-sqlite:
  cmd.run:
    - name: sudo cpanm DBD::SQLite
    - require:
        - pkg: cpanminus
    - unless: test -d /usr/local/lib/*/perl/*/DBD/SQLite

statistics-descriptive:
  cmd.run:
    - name: sudo cpanm Statistics::Descriptive
    - require:
        - pkg: cpanminus
    - unless: test -d /usr/local/lib/*/perl/*/Statistics/Descriptive

xml-parser:
  cmd.run:
    - name: sudo cpanm XML::Parser
    - require:
        - pkg: cpanminus
    - unless: test -d /usr/local/lib/*/perl/*/XML/Parser

fastq:
  cmd.run:
    - name: |
        mkdir fastq
        cd fastq
        wget "https://raw.github.com/brentp/bio-playground/master/reads-utils/fastq.cpp"
        g++ -O2 -o fastq fastq.cpp
        sudo mv fastq /usr/local/bin
        sudo chmod +x /usr/local/bin/fastq
    - cwd: /tmp
    - require:
        - pkg: g++
        - pkg: wget
    - unless: test -x /usr/local/bin/fastq

fqextract:
  cmd.run:
    - name: |
        mkdir fqextract
        cd fqextract
        wget https://raw.github.com/attractivechaos/klib/master/khash.h
        wget http://chiulab.ucsf.edu/SURPI/software/fqextract.c
        gcc fqextract.c -o fqextract
        sudo mv fqextract /usr/local/bin
        sudo chmod +x /usr/local/bin/fqextract
    - require:
        - pkg: gcc
        - pkg: wget
    - unless: test -x /usr/local/bin/fqextract

prinseq-lite:
  cmd.run:
    - name: |
        curl -O http://iweb.dl.sourceforge.net/project/prinseq/standalone/prinseq-lite-0.20.3.tar.gz
        tar xvfz prinseq-lite-0.20.3.tar.gz
        sudo cp prinseq-lite-0.20.3/prinseq-lite.pl /usr/local/bin
        sudo chmod +x /usr/local/bin/prinseq-lite.pl
    - require:
        - pkg: curl
    - unless: test -x /usr/local/bin/prinseq-lite.pl

/usr/local/bin/snap-aligner:
  file.managed:
    - source: https://github.com/amplab/snap/releases/download/v1.0beta.18/snap-aligner
    - source_hash: sha512=87d6a100e24eda308fffae9290a1b4a839b66aaf7b9db533c09c092065019f7f4a185e9c6fb1efb4e5be2aae09c9077b06faadf3d3e948721d2b6a1303bb78e2

libssl-dev:
  pkg.installed

libstatgen-git:
  git.latest:
    - name: https://github.com/statgen/libStatGen.git
    - rev: 49330332ac12ff870d621031bb8648a5bc09192a
    - target: /tmp/libStatGen
    - require:
        - pkg: git
    - unless: test -x /usr/local/bin/fastQValidator

fastqvalidator-git:
  git.latest:
    - name: https://github.com/statgen/fastQValidator.git
    - rev: 600907a9479890d20f419097075b0a1b2aabafa4
    - target: /tmp/fastQValidator
    - require:
        - pkg: git
    - unless: test -x /usr/local/bin/fastQValidator

fastqvalidator:
  cmd.run:
    - name: |
        cd /tmp/fastQValidator
        make
        cp bin/fastQValidator /usr/local/bin
    - require:
        - pkg: make
        - pkg: libssl-dev
        - pkg: zlib1g-dev
        - pkg: g++
        - git: libstatgen-git
        - git: fastqvalidator-git
    - unless: test -x /usr/local/bin/fastQValidator

rapsearch-git:
  git.latest:
    - name: https://github.com/zhaoyanswill/RAPSearch2.git
    - rev: 95c866e9b818b7b4b9648ef4e0810a33300c3432
    - target: /tmp/RAPSearch2
    - require:
        - pkg: git
    - unless: test -x /usr/local/bin/rapsearch

rapsearch:
  cmd.run:
    - name: |
        cd /tmp/RAPSearch2
        yes | ./install
        mv bin/rapsearch /usr/local
        mv bin/prerapsearch /usr/local
    - require:
        - pkg: make
        - pkg: g++
        - git: rapsearch-git
    - unless: test -x /usr/local/bin/rapsearch

{% if os == 'Ubuntu' %}
multiverse:
  cmd.run:
    - name: |
        sudo add-apt-repository multiverse
        sudo apt-get update
{% endif %}

abyss:
  pkg.installed:
    - name: abyss
{% if os == 'Ubuntu' %}
    - require:
        - cmd: multiverse
{% endif %}

openmpi-bin:
  pkg.installed

amos-git:
  git.latest:
    - name: https://github.com/nathanhaigh/amos.git
    - rev: a72381c1e8fe43ee96678dfe7bd3c8d329fb7655
    - target: /tmp/amos
    - require:
        - pkg: git
    - unless: test -x /usr/local/bin/AMOScmp

libexpat1-dev:
  pkg.installed

zlib1g-dev:
  pkg.installed

libboost-all-dev:
  pkg.installed

amos:
  cmd.run:
    - name: |
        cd /tmp/amos
        ./bootstrap
        ./configure --prefix=/opt/stow
        make
        sudo make install
        sudo stow -d /opt -t /usr/local stow
    - require:
        - pkg: autoconf
        - pkg: make
        - pkg: g++
        - pkg: libexpat1-dev
        - pkg: zlib1g-dev
        - pkg: libboost-all-dev
        - pkg: stow
        - git: amos-git
    - unless: test -x /usr/local/bin/AMOScmp

surpi:
  git.latest:
    - name: https://github.com/yesimon/surpi.git
    - target: /opt/surpi
    - require:
        - pkg: git


# For monitoring cpu/mem.
htop:
  pkg.installed

smem:
  pkg.installed
