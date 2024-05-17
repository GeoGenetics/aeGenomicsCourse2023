set -e
# install and start code-server
curl -fsSL https://code-server.dev/install.sh | sh -s -- --method=standalone --prefix=/tmp/code-server --version 4.8.3
/tmp/code-server/bin/code-server --auth none --port 13337 >/tmp/code-server.log 2>&1 &
sudo locale-gen en_US.UTF-8
# Install extensions for bash, python, and R
/tmp/code-server/bin/code-server --install-extension REditorSupport.r
/tmp/code-server/bin/code-server --install-extension ms-python.python
/tmp/code-server/bin/code-server --install-extension anwar.papyrus-pdf
/tmp/code-server/bin/code-server --install-extension mads-hartmann.bash-ide-vscode


# mkdir -p /home/kasm-user/Desktop

#coder dotfiles -y ${dotfiles_url} &

echo ". /home/${username}/.bashrc" >>/home/${username}/.bash_profile

wget -O /home/${username}/bashrc https://raw.githubusercontent.com/genomewalker/dotfiles/master/shell/bash/.bashrc

cat /home/${username}/bashrc >>/home/${username}/.bashrc
rm /home/${username}/bashrc
. /home/${username}/.bash_profile

if [ ! -d /home/${username}/opt ]; then

  mkdir /home/${username}/opt
  wget -O /tmp/Mambaforge.sh "https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-$(uname)-$(uname -m).sh"
  bash /tmp/Mambaforge.sh -b -p /home/${username}/opt/conda

  source /home/${username}/opt/conda/etc/profile.d/conda.sh

  conda init bash

  #/dockerstartup/kasm_default_profile.sh /dockerstartup/vnc_startup.sh /dockerstartup/kasm_startup.sh &
  # echo "source $${STARTUPDIR}/generate_container_user" >>/home/${username}/.bashrc

  . /home/${username}/.bash_profile

  conda config --set auto_activate_base false
  conda config --add channels defaults
  conda config --add channels bioconda
  conda config --add channels conda-forge
  conda config --set channel_priority strict

  cat <<EOF >/tmp/day1.yml
name: day1
channels:
  - conda-forge
  - bioconda
  - defaults
  - genomewalker
dependencies:
  - python=3.9
  - mapdamage2
  - fastp
  - htslib
  - samtools
  - bwa
  - bowtie2
  - bcftools
  - Adapterremoval
  - Picard
  - fastqc
  - seqkit
  - shellcheck
  - vsearch
EOF

  cat <<EOF >/tmp/day2.yml
name: day2
channels:
  - conda-forge
  - bioconda
  - defaults
  - genomewalker
dependencies:
  - python=3.9
  - snp-sites 
  - beast2
  - mafft
  - angsd
  - fastp
  - vsearch
  - raxML 
  - seqtk 
  - ngsLCA
  - r
  - r-optparse
  - r-phytools
  - r-scales
  - seqkit
  - openssl  # [not osx]
  - shellcheck
  - pip
  - pip:
      - bam-filter
EOF

  cat <<EOF >/tmp/day3.yml
name: day3
channels:
  - conda-forge
  - bioconda
  - defaults
dependencies:
  - python=3.9
  - shellcheck
  - bedtools
  - mapdamage2
  - plink
  - eigensoft
  - seqkit
EOF

  cat <<EOF >/tmp/day4.yml
name: day4
channels:
  - conda-forge
  - bioconda
  - defaults
  - genomewalker
dependencies:
  - python=3.9
  - shellcheck
  - seqkit
  - csvtk
  - taxonkit
  - mawk
  - cxx-compiler
  - mmseqs2
  - bbmap
  - pip
  - pip:
      - bam-filter
      - x-filter
      - dmg-reads
      - get-read-percid

EOF


  cat <<EOF >/tmp/metadDMG.yml
name: metaDMG
channels:
  - conda-forge
  - bioconda
  - defaults
  - genomewalker
dependencies:
  - python=3.9
  - shellcheck
  - pip
  - pip:
      - attrs
      - metaDMG[all]>=0.37.1
      - logger_tt==1.7.0
EOF

  cat <<EOF >/tmp/mapping.yml
name: mapping
channels:
  - conda-forge
  - bioconda
  - defaults
dependencies:
  - python=3.9
  - shellcheck
  - bowtie2
  - seqkit
  - csvtk
  - bowtie2
  - bwa
  - samtools
  - htslib
  - picard
  - seqkit
  - fastp
  - vsearch
  - mapdamage2
  - sambamba
  - pip
  - pip:
      - bam-filter
EOF

  cat <<EOF >/tmp/r.yml
name: r
channels:
  - conda-forge
  - bioconda
  - defaults
dependencies:
  - python=3.9
  - shellcheck
  - r
  - radian
  - r-languageserver
  - r-httpgd
  - r-showtext
  - r-rcpp
  - r-tidyverse
  - r-igraph
  - r-plotly
  - r-ggrepel
  - r-viridis
  - r-ggpubr
  - r-cubelyr
  - r-doparallel
  - r-furrr
  - r-lobstr
  - r-quadprog
  - r-data.tree
  - r-reshape2
  - r-vegan
  - r-rioja
  - r-readxl
  - r-gghighlight
  - r-dplyr
  - bioconductor-rsamtools
  - bioconductor-complexheatmap
EOF

  mamba create -y -n course python=3.9
  mamba env create -f /tmp/r.yml
  rm /tmp/r.yml
  mamba env create -f /tmp/day1.yml
  rm /tmp/day1.yml
  mamba env create -f /tmp/day2.yml
  rm /tmp/day2.yml
  mamba env create -f /tmp/metadDMG.yml
  rm /tmp/metadDMG.yml
  mamba env create -f /tmp/day3.yml
  rm /tmp/day3.yml
  mamba env create -f /tmp/day4.yml
  rm /tmp/day4.yml
  mamba env create -f /tmp/mapping.yml
  rm /tmp/mapping.yml

  echo "conda activate course" >>/home/${username}/.bashrc

  cat <<EOF >/home/${username}/.Rprofile
Sys.setenv(TERM_PROGRAM="vscode")
if (interactive() && Sys.getenv("RSTUDIO") == "") {
  source(file.path(Sys.getenv("HOME"), ".vscode-R", "init.R"))
}

if (interactive() && Sys.getenv("TERM_PROGRAM") == "vscode") {
  showtext::showtext_auto()
  if ("httpgd" %in% .packages(all.available = TRUE)) {
    options(vsc.plot = FALSE)
    options(device = function(...) {
      httpgd::hgd(silent = TRUE)
      .vsc.browser(httpgd::hgd_url(history = FALSE), viewer = "Beside")
    })
  }
}

EOF

  mkdir -p /home/${username}/.local/share/code-server/User
  cat <<EOF >/home/${username}/.local/share/code-server/User/settings.json
{
    "files.dialog.defaultPath": "/home/${username}/course",
    "r.plot.useHttpgd": true,
    "r.rpath.linux": "/home/${username}/opt/conda/envs/r/bin/R",
    "r.rterm.linux": "/home/${username}/opt/conda/envs/r/bin/radian",
    "r.bracketedPaste": true,
    "r.rterm.option": [
        "--no-save",
        "--no-restore",
        "--r-binary=/home/${username}/opt/conda/envs/r/bin/R"
    ],
    "r.alwaysUseActiveTerminal": true,
}
EOF

  # Compile different tools
  conda activate day2
  cd /home/${username}/opt
  mkdir src
  cd src
  git clone https://github.com/samtools/htslib.git
  cd htslib
  git submodule update --init --recursive
  make -j 5 CPPFLAGS="-L$${CONDA_PREFIX}/lib -I$${CONDA_PREFIX}/include" lib-static htslib_static.mk
  cd ..
  git clone https://github.com/richarddurbin/phynder.git
  cd phynder
  make -j 5
  mv phynder /home/${username}/opt/conda/envs/day2/bin/
  cd ..
  git clone https://github.com/ruidlpm/pathPhynder.git
  cd pathPhynder
  mv pathPhynder.R /home/${username}/opt/conda/envs/day2/bin/
  cat <<EOF >/home/${username}/opt/conda/envs/day2/bin/pathPhynder
#!/bin/bash
Rscript /home/${username}/opt/conda/envs/day2/bin/pathPhynder.R "\$@"
EOF
  chmod +x /home/${username}/opt/conda/envs/day2/bin/pathPhynder
  cd ..
  git clone --recurse-submodules https://github.com/fbreitwieser/bamcov
  cd bamcov
  make -j 5 CPPFLAGS="-L$${CONDA_PREFIX}/lib -I$${CONDA_PREFIX}/include"
  mv bamcov /home/${username}/opt/conda/envs/day2/bin/
  cd ..

  git clone https://github.com/metaDMG-dev/metaDMG-cpp.git
  cd metaDMG-cpp
  git checkout abd303e808c7d74166f305ac88ef538af9b1d44d
  make -j 5 CPPFLAGS="-L$${CONDA_PREFIX}/lib -I$${CONDA_PREFIX}/inclu^C" HTSSRC=../htslib/
  sudo mv metaDMG-cpp /usr/local/bin/
  rm -rf pathPhynder phynder bamcov htslib

  conda deactivate

  conda activate r

  Rscript -e 'remotes::install_github("uqrmaie1/admixtools")'
  Rscript -e 'remotes::install_github("wyc661217/ngsLCA")'

  conda deactivate

  sudo cp /home/${username}/course/data/vgan/bin/vgan /usr/local/bin/

  sudo chown ${username}:${username} /home/${username}/course
  sudo chown ${username}:${username} /home/${username}/course/wdir

  ln -s /home/${username}/course/data/vgan/ /home/${username}/opt/vgan

fi
. /home/${username}/.bash_profile
