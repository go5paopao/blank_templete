# Base Python Image
FROM python:3.8

# Install dependencies
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    wget \
    curl \
    bzip2 \
    file \
    make \
    cmake \
    sudo \
    libbz2-dev \
    zlib1g-dev \
    libffi-dev \
    libatlas-base-dev \
    libboost-dev \
    libboost-system-dev \
    libboost-filesystem-dev \
    libsqlite3-dev \
    libreadline6-dev \
    libssl-dev \
    libncursesw5-dev \
    libdb-dev \
    libexpat1-dev \
    liblzma-dev \
    libgdbm-dev \
    libmpdec-dev \
    gcc \
    g++ \
    git \
    xz-utils \
    liblzma-dev \
    cmake --fix-missing \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

############################
# mecab
############################
# # install mecab from github
# WORKDIR /opt
# RUN git clone https://github.com/taku910/mecab.git
# WORKDIR /opt/mecab/mecab
# RUN ./configure  --enable-utf8-only \
#   && make \
#   && make check \
#   && make install \
#   && ldconfig

# WORKDIR /opt/mecab/mecab-ipadic
# RUN ./configure --with-charset=utf8 \
#  && make \
#  && make install

# # neologd
# WORKDIR /opt
# RUN git clone --depth 1 https://github.com/neologd/mecab-ipadic-neologd.git
# WORKDIR /opt/mecab-ipadic-neologd
# RUN ./bin/install-mecab-ipadic-neologd -n -y
# WORKDIR /

############################
# python packages
############################

COPY requirements.txt requirements.txt
RUN pip install -U pip && pip install -r requirements.txt

# for jupyter 
RUN jupyter contrib nbextension install --user

# Set up Jupyter Notebook config
ENV CONFIG_NOTEBOOK /root/.jupyter/jupyter_notebook_config.py
ENV CONFIG_IPYTHON /root/.ipython/profile_default/ipython_config.py

RUN jupyter notebook --generate-config --allow-root && \
    ipython profile create

RUN echo "c.NotebookApp.ip = '0.0.0.0'" >>${CONFIG_NOTEBOOK} && \
    echo "c.NotebookApp.port = 8888" >>${CONFIG_NOTEBOOK} && \
    echo "c.NotebookApp.allow_root = True" >>${CONFIG_NOTEBOOK} && \
    echo "c.NotebookApp.open_browser = False" >>${CONFIG_NOTEBOOK} && \
    echo "c.MultiKernelManager.default_kernel_name = 'python3'" >>${CONFIG_NOTEBOOK}

# vim key bind
# Create required directory in case (optional)
RUN mkdir -p $(jupyter --data-dir)/nbextensions && \
    cd $(jupyter --data-dir)/nbextensions && \
    rm -rf vim_binding/ && \
    git clone https://github.com/lambdalisue/jupyter-vim-binding vim_binding && \
    jupyter nbextension enable vim_binding/vim_binding

# install nodejs for jupyter lab extentions
# nodejsの導入
RUN curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash - \
    && sudo apt-get install -y nodejs

RUN jupyter labextension install @jupyter-widgets/jupyterlab-manager && \
    jupyter labextension install @jupyterlab/toc && \
    jupyter labextension install @axlair/jupyterlab_vim

# jupyter-kite
RUN cd && \
    echo $PWD && \
    wget https://linux.kite.com/dls/linux/current && \
    chmod 777 current && \
    sed -i 's/"--no-launch"//g' current > /dev/null && \
    ./current --install ./kite-installer && \
    jupyter labextension install @kiteco/jupyterlab-kite --minimize=False && \
    jupyter lab build --minimize=False && \
    pip install jupyter-kite

# jupyter notebook theme
RUN jt -vim -T -N -t monokai

# 8888:jupyter, 5000:mlflow-ui
EXPOSE 8888 5000
