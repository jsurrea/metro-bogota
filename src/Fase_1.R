library(markovchain)
library(expm)

F1_CreateMarkovChain <- function(estados, lambda_pasajeros, lambda_trenes) {
    # Esta función crea la matriz Q de UNA sola estación.
    # 
    # Argumentos:
    # estados: Vector numérico de los estados de la variable.
    # lambda_pasajeros: Tasa con la que llegan pasajeros.
    # lambda_trenes: Tasa con la que llega un tren a la estación.
    
    # Se definen los posibles estados y se inicializa la matriz
    Q <- matrix(0, nrow = length(estados), ncol = length(estados))
    dimnames(Q) <- list(estados, estados)
    
    # Se define el número máximo de personas que pueden ir en el tren
    capacidad_tren <- 180  
    
    # La variable i representa el estado origen
    for(i in estados) {
        # La variable j representa el estado destino
        for(j in estados){
            
            # Llega una persona
            if(i+1 == j) {
                Q[i+1,j+1] = lambda_pasajeros
            }
            # Llega un tren
            if(j == max(0, i-capacidad_tren)) {
                Q[i+1,j+1] = lambda_trenes
            }
            # Diagonal
            if(i == j) {
                Q[i+1,j+1] = - (lambda_pasajeros + lambda_trenes)
                
                # Si no hay nadie, solo pueden llegar nuevos pasajeros
                if(i == 0) {
                    Q[i+1,j+1] = - lambda_pasajeros
                }
                # Si la estación está llena, solo pueden llegar trenes
                if (i == length(estados) - 1) {
                    Q[i+1,j+1] = - lambda_trenes
                }
            }
            # En cualquier otro caso se queda en 0
        }
    }
    
    # Verifica que la matriz haya sido definida correctamente
    stopifnot(all(rowSums(Q) - 0 < 1e5))
    
    # Devuelve la matriz como una cadena de Markov
    CMTC <- new(Class="ctmc", states = as.character(estados), byrow = TRUE, generator = Q)
    return(CMTC)
}

F1_CalculateStatistics <- function(Q) {
    # Calcula el valor esperado y la varianza durante la primera hora
    # 
    # Argumentos:
    # Q: Matriz de tasas de transición entre estados.
    
    # Se crea el vector de probabilidades iniciales.
    # Para esto, se asume que las estaciones inician vacías.
    alpha <- numeric(nrow(Q))
    alpha[1] <- 1
    
    # Se recuperan los valores numéricos de los estados
    estados <- seq(0, nrow(Q) - 1)
    
    # Se inicializan los vectores que contendrán los resultados
    valores_esperados <- rep(0, 60)
    varianzas <- rep(0, 60)
    
    # Para cada minuto durante la primera hora
    tiempo <- 1:60
    for(t in tiempo) {
        
        # Se calculan las probabilidades
        probs <- alpha %*% expm(Q*t)
        
        # Se calculan las estadísticas relevantes
        valor_esperado <- sum(estados*probs)
        varianza <- sum((estados^2)*probs) - sum(estados*probs)^2
        
        # Se guardan los resultados
        valores_esperados[t] <- valor_esperado
        varianzas[t] <- varianza
    }
    
    # Calcula los valores a 1 desv. est. del valor esperado.
    high <- pmin(valores_esperados + sqrt(varianzas), nrow(Q) - 1)
    low <- pmax(valores_esperados - sqrt(varianzas), 0)
    
    # Devuelve los datos como un data frame
    data <- data.frame(tiempo, valores_esperados, high, low)
    return(data)
}

F1_CalculateSteadyStates <- function(CMTC) {
    # Calcula los estados estables (toma solo la parte real)
    probabilidad <- Re(steadyStates(CMTC))[1,]
    # Devuelve el resultado como un data frame
    estado <- as.numeric(CMTC@states)
    data <- data.frame(estado, probabilidad)
    return(data)
}
