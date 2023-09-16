FROM rocker/tidyverse:latest

RUN install2.r --error \
    --deps TRUE \
    renv

# Install Jupyter
RUN apt-get update && apt-get install -y python3-pip
RUN pip3 install jupyter

# Install IRkernel
RUN R -e "install.packages('IRkernel', repos='https://cloud.r-project.org/')"

# Ensure the IRkernel is available to Jupyter
RUN R -e "IRkernel::installspec(user = FALSE)"

COPY src ./opt/src

COPY ./entry_point.sh /opt/
RUN chmod +x /opt/entry_point.sh

COPY ./requirements.txt /opt/

# Install R packages with specific versions from requirements.txt
RUN while read p; do \
      PKG=$(echo $p | cut -d'@' -f1); \
      VER=$(echo $p | cut -d'@' -f2); \
      R -e "devtools::install_version('$PKG', version='$VER', repos='https://cloud.r-project.org/')"; \
    done <opt/requirements.txt

WORKDIR /opt/src
RUN chown -R 1000:1000 /opt/src

USER 1000

ENTRYPOINT ["/opt/entry_point.sh"]