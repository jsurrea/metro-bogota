FROM r-base

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev

# Install R packages
RUN R -e "install.packages(c('plotly', 'markovchain', 'readxl', 'expm', 'shiny', 'shinydashboard', 'shinyWidgets'), repos='http://cran.rstudio.com')"

WORKDIR /app
COPY src/app.R /app/
COPY src/Fase_1.R /app/
COPY src/Fase_2.R /app/
COPY src/Fase_3.R /app/
COPY src/www /app/www

EXPOSE 3838

CMD ["R", "-e", "shiny::runApp('/app', host='0.0.0.0', port=3838)"]

