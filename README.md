# Metro Bogotá

This is the final project for the course _Stochastic Models_ at Universidad de los Andes. It consists of a Dashboard that simulates the operation of the Bogotá Metro at a particular station through a Markov Chain model. It calculates statistics, steady state probabilities, times, costs and solves an SDP problem to optimize the operation of the station.

## Running the app

You can run the file `src/Dashboard.R` if you have R installed in your computer. An alternative is to run the following command in your terminal to use the Docker image:

```bash
docker build -t metro-r-image .
docker run --rm -p 3838:3838 metro-r-image
```

Then navigate to `http://localhost:3838/` in your browser to see the dashboard.
