FROM r-base:4.3.2

RUN apt-get update && apt-get install -y \
    libcurl4-gnutls-dev \
    libssl-dev \
    libxml2-dev \
    && rm -rf /var/lib/apt/lists/*

RUN R -e "install.packages(c('shiny', 'rsconnect'), repos='https://cran.rstudio.com/')"

COPY deploy.R /deploy.R
COPY server.R /server.R
COPY ui.R /ui.R

CMD ["Rscript", "/deploy.R"]
