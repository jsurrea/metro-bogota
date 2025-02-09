# Metro Bogotá

This is the final project for the course _Stochastic Models_ at Universidad de los Andes. It consists of a Dashboard that simulates the operation of the Bogotá Metro at a particular station through a Markov Chain model. It calculates statistics, steady state probabilities, times, costs and solves an SDP problem to optimize the operation of the station.

## Running the app

You can run the file `src/Dashboard.R` if you have R installed in your computer. An alternative is to run the following command in your terminal to use the Docker image:

```bash
docker build -t metro-r-image .
docker run --rm -p 3838:3838 metro-r-image
```

Then navigate to `http://localhost:3838/` in your browser to see the dashboard.

## Demo

<img width="1600" alt="P0" src="https://github.com/user-attachments/assets/f0c40eb0-fd0c-4bfe-a516-26794940d98a" />

<img width="1600" alt="P1" src="https://github.com/user-attachments/assets/e265d697-c2a4-4c75-9e03-dfd96ff63228" />

<img width="1600" alt="P2" src="https://github.com/user-attachments/assets/2ee00692-e878-4836-818e-113f5ab5f1d2" />

<img width="1600" alt="P3" src="https://github.com/user-attachments/assets/12ed4d65-9d0c-4bee-85aa-9ee535a6ff45" />




