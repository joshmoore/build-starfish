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

# Install the scc tool for merging PRs
RUN conda create -n scc python=2.7 pip && /home/starfish/.conda/envs/scc/bin/pip install scc
ENV SCC /home/starfish/.conda/envs/scc/bin/scc

ARG SCC_BASE="master"
ARG SCC_MISC="--no-ask --reset -S none"
ARG SCC_ARGS="-Dnone -Iuser:joshmoore"

# Merge various PRs together
RUN echo TODO: MERGE BASE REPOSITORY && \
    echo e.g. $SCC merge --shallow $SCC_ARGS $SCC_BASE && \
    echo then "git submodule sync" to update the URLs

RUN git submodule update --init --remote --recursive
RUN git submodule foreach git config user.email $(git config user.email)
RUN git submodule foreach git config user.name $(git config user.name)
RUN git submodule foreach git config github.user $(git config github.user)
RUN git submodule foreach git config github.token $(git config github.token)

ARG TIMESTAMP=Default
RUN echo $TIMESTAMP
RUN echo MERGE SUBMODULES && $SCC merge -vvv $SCC_MISC $SCC_ARGS \
	--update-gitmodules \
	--repository-config="$PWD/repositories.yml" \
        $SCC_BASE && \
        echo TODO: this branch can be pushed for further testing

# Update the requirements files (and similar) as necessary to point to
# the newly created commit checksums. Optionally push the versions somewhere.
RUN find . -iname requirements* -exec sed -i 's/slicedimage.*/slicedimage/' {} \;

# Iterate over all the projects to build a consistent image
RUN git submodule foreach $PWD/build.sh

ENTRYPOINT ["pytest"]
