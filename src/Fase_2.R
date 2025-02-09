library(plotly)
library(markovchain)
library(readxl)

F2_CreateMarkovChain <- function(df) {
    # Esta función devuelve la cadena de Markov discreta del sistema a analizar.
    # Utiliza como entrada un dataframe con los estados de varios trenes en el tiempo
    
    # 1. Se calculan las probabilidades de cambiar de estado "Status" 
    # Se asume que los datos para cada tren vienen en orden cronológico
    # También se espera que terminen en el estado "Fallas Irreparables"
    status <- c("Condiciones Óptimas", "Condiciones Regulares", "Fallas Irreparables")
    counts <- matrix(0, nrow = length(status), ncol = length(status))
    dimnames(counts) <- list(status, status)
    for(index in 1:(nrow(df) - 1)) {
        status_actual <- df[index, "Status"]
        status_post <- df[index+1, "Status"]
        # Cuando se llega al estado "Fallas Irreparables", se pasa al siguiente tren
        if(status_actual == "Fallas Irreparables")
            next
        # Se cuenta cuántas veces se pasa entre los distintos estados transitorios
        counts[status_actual, status_post] <- counts[status_actual, status_post] + 1 
    }
    # Se añade la propiedad absorbente del estado "Fallas Irreparables"
    counts["Fallas Irreparables", "Fallas Irreparables"] <- 1
    # Se normaliza por filas para obtener probabilidades
    counts <- counts / rowSums(counts)
    
    # 2. Se calculan las probabilidades teniendo en cuenta las distancias recorridas
    # Se asume independiencia entre las dos variables ("Status" y "distancia")
    distancias <- format(seq(0, 690000, 10000), scientific = FALSE)
    estados <- as.vector(outer(distancias, status, paste))
    P <- matrix(0, nrow = length(estados), ncol = length(estados))
    dimnames(P) <- list(estados, estados)
    # Se usa el sufijo "o" para orígen y "d" para destino
    for(status_o in status) {
        for(status_d in status) {
            # Se recupera la probabilidad de cambio de Status
            prob_status <- counts[status_o, status_d]
            # Se recorren todos los posibles cambios de distancias:
            # i -> i | i + 10k | i + 20k | i + 30k
            for(i in 1:length(distancias)) {
                distancia_o <- distancias[i]
                # Se añaden probs uniformes a los 3 elementos siguientes.
                for(j in 0:3) {
                    # Si se llega al borde, se acumulan las probs sobre la mayor distancia
                    distancia_d <- distancias[min(i+j, length(distancias))]
                    # Se calcula la probabilidad (uniforme) para distancias
                    prob_distancia <- 1/4
                    # Se obtienen los estados de orígen y destino
                    origen <- paste(distancia_o, status_o)
                    destino <- paste(distancia_d, status_d)
                    # Se acumula la probabilidad como 2 eventos independientes
                    P[origen, destino] <- P[origen, destino] + prob_distancia * prob_status
                }
            }
        }
    }
    # Se arreglan las probabilidades para los estados absorbentes y se reordena la matriz
    for(distancia in distancias) {
        estado <- paste(distancia, "Fallas Irreparables")
        P[estado, ] <- 0
        P[estado, estado] <- 1
    }
    for(s in status) {
        estado <- paste("690000", s)
        P[estado, ] <- 0
        P[estado, estado] <- 1
    }
    
    # Verificar que las filas suman 1
    stopifnot(all(rowSums(P) == 1))
    
    # 3. Se crea el objeto markovchain
    CMTD <- new(Class="markovchain", states=estados, transitionMatrix=P)
    return(CMTD)
}

F2_TiempoOperacion <- function(CMTD) {
    # Obtiene los estados absorbentes
    abs_states <- grepl("690000", CMTD@states, fixed=TRUE) | 
        grepl("Fallas Irreparables", CMTD@states, fixed=TRUE)
    # Selecciona solo aquellos que NO son absorbentes
    Q <- CMTD[!abs_states, !abs_states]
    I <- diag(nrow(Q)) 
    # Calcula los tiempos
    tiempos <- solve(I - Q)
    target <- "     0 Condiciones Óptimas"
    tiempo_meses <- rowSums(tiempos)[target]
    return(tiempo_meses / 12)
}

F2_PagoChatarrizacion <- function(CMTD) {
    # Obtiene los estados absorbentes
    abs_states <- grepl("690000", CMTD@states, fixed=TRUE) | 
        grepl("Fallas Irreparables", CMTD@states, fixed=TRUE)
    # Selecciona las submatrices
    Q <- CMTD[!abs_states, !abs_states]  # T -> T
    R <- CMTD[!abs_states, abs_states]  # T -> A
    I <- diag(nrow(Q)) 
    # Calcula las probabilidades de ser absorbido por cada estado
    probs <- solve(I - Q) %*% R
    target <- "     0 Condiciones Óptimas"
    probs <- probs[target, ]
    # Acumula estas probabilidades en fallas y/o kilometraje
    both <- sum(probs["690000 Fallas Irreparables"])
    km <- sum(probs[ grepl("690000", CMTD@states[abs_states], fixed=TRUE) ]) - both
    fail <- sum(probs[ grepl("Fallas Irreparables", CMTD@states[abs_states], fixed=TRUE) ]) - both
    probs <- c(fail, km, both) # se verifica que sum(probs) == 1
    # Halla el valor esperado
    costos <- c(76500000, 85000000, 80750000)
    VE <- sum(probs * costos)
    return(VE)
}

F2_CostoOperacion <- function(CMTD, costo_optimas, costo_regulares) {
    # Obtiene los estados absorbentes
    abs_states <- grepl("690000", CMTD@states, fixed=TRUE) | 
        grepl("Fallas Irreparables", CMTD@states, fixed=TRUE)
    # Selecciona solo aquellos que NO son absorbentes
    Q <- CMTD[!abs_states, !abs_states]
    I <- diag(nrow(Q)) 
    # Calcula los tiempos para el caso de interés
    target <- "     0 Condiciones Óptimas"
    tiempos <- solve(I - Q)[target, ]
    tiempo_optimas <- sum(tiempos[ grepl("Condiciones Óptimas", names(tiempos), fixed=TRUE) ])
    tiempo_regulares <- sum(tiempos[ grepl("Condiciones Regulares", names(tiempos), fixed=TRUE) ])
    return(costo_optimas * tiempo_optimas + costo_regulares * tiempo_regulares)
}

F2_PlotData <- function(CMTD) {
    
    # Obtiene los estados absorbentes
    abs_states <- grepl("690000", CMTD@states, fixed=TRUE) | 
        grepl("Fallas Irreparables", CMTD@states, fixed=TRUE)
    # Selecciona las submatrices
    Q <- CMTD[!abs_states, !abs_states]  # T -> T
    R <- CMTD[!abs_states, abs_states]  # T -> A
    I <- diag(nrow(Q)) 
    # Calcula las probabilidades de ser absorbido por cada estado (solo fallas irreparables)
    probs <- solve(I - Q) %*% R
    target <- "     0 Condiciones Óptimas"
    probs <- probs[target, grepl("Fallas Irreparables", CMTD@states[abs_states], fixed=TRUE)]
    # Extrae la probabilidad de cada kilometraje (ya vienen ordenados)
    names(probs) <- substr(names(probs), 1, 6)
    distancias <- names(probs)
    names(probs) <- NULL
    # Se crea el data frame con los datos a devolver
    data <- data.frame(distancias, probs)
    return(data)
}
