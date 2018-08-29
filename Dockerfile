FROM continuumio/miniconda3
RUN useradd -m starfish
USER starfish

# Set up the initial conda environment
RUN conda create -n env python=3.6 pip
RUN echo "source activate env" >> ~/.bashrc
ENV PATH /home/starfish/.conda/envs/env/bin:$PATH
env MPLBACKEND Agg
COPY --chown=starfish:starfish . /src
WORKDIR /src

# FIXME: remove
USER root
RUN apt-get update && apt-get install -y vim
USER starfish

# Install the scc tool for merging PRs
RUN conda create -n scc python=2.7 pip && /home/starfish/.conda/envs/scc/bin/pip install scc
ENV SCC /home/starfish/.conda/envs/scc/bin/scc
ENV SCC_ARGS="--no-ask --reset -S none"
ENV SCC_BASE="master"

# Merge various PRs together
RUN echo TODO: MERGE BASE REPOSITORY && \
    echo e.g. $SCC merge --shallow $SCC_ARGS $SCC_BASE

RUN git submodule sync
RUN git submodule update --init --remote --recursive
RUN git submodule foreach git config user.email $(git config user.email)
RUN git submodule foreach git config user.name $(git config user.name)
RUN git submodule foreach git config github.user $(git config github.user)
RUN git submodule foreach git config github.token $(git config github.token)
RUN echo MERGE SUBMODULES && $SCC merge -vvv $SCC_ARGS -D all \
	--update-gitmodules \
	--repository-config="$PWD/repositories.yml" \
        $SCC_BASE && \
        echo TODO: this branch can be pushed for further testing

# Iterate over all the projects
RUN find . -iname requirements* -exec sed -i 's/slicedimage.*/slicedimage/' {} \;
RUN git submodule foreach $PWD/build.sh
RUN echo TODO: bumped versions can be pushed as well

ENTRYPOINT ["/src/test.sh"]
