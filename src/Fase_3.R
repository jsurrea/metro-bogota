# Parámetros del modelo
F3_CapacidadEstacion <- 150
F3_CapacidadVagon <- 30
F3_Franjas <- c("Mañana", "Mediodía", "Tarde", "Noche") 
F3_Tasas <- 15 * c(9, 2, 7, 0.5)
names(F3_Tasas) <- F3_Franjas

# Componentes del SDP
F3_Estados <- 0:F3_CapacidadEstacion
F3_Decisiones <- 0:(F3_CapacidadEstacion/F3_CapacidadVagon)
F3_Epocas <- c(t(outer(5:22, formatC(seq(0, 45, 15), width = 2, format = "d", flag = "0"), paste, sep = ":")), "23:00")

# Matriz de probabilidades de transición
P <- array(0, dim = c(length(F3_Franjas), length(F3_Decisiones), length(F3_Estados), length(F3_Estados)))
dimnames(P) <- list(F3_Franjas, as.character(F3_Decisiones), as.character(F3_Estados), as.character(F3_Estados))
for(franja in F3_Franjas) {
    tasa_llegada <- F3_Tasas[franja]
    for(num_vagones in F3_Decisiones) {
        capacidad_tren <- F3_CapacidadVagon * num_vagones
        # Definir los objetos como matrices
        P[franja, as.character(num_vagones), , ] <- matrix(0, nrow = length(F3_Estados), ncol = length(F3_Estados))
        for(origen in F3_Estados) {
            for(destino in F3_Estados) {
                # Personas que quedaron en la estación después de que se fue el tren
                restantes <- max(origen - capacidad_tren, 0)
                # Personas que llegaron a la estación después de que se fue el tren
                llegadas <- destino - restantes
                # Las personas que llegan de más se acumulan sobre la capacidad
                if(destino == F3_CapacidadEstacion)
                    prob <- ppois(llegadas - 1, tasa_llegada, lower.tail = FALSE)
                else
                    prob <- dpois(llegadas, lambda = tasa_llegada)
                # Probabilidad de tener esta cantidad de llegadas
                P[franja, as.character(num_vagones), as.character(origen), as.character(destino)] <- prob
            }
        }
        # Verificar que estén bien construidas
        stopifnot(all(rowSums(P[franja, as.character(num_vagones), , ]) - 1 < 1e-5))
    }
}


F3_CreateReturnsMatrix <- function(costo_vagon, costo_confianza) {
    # Definir la matriz
    C <- array(0, dim = c(length(F3_Franjas), length(F3_Estados), length(F3_Decisiones)))
    dimnames(C) <- list(F3_Franjas, as.character(F3_Estados), as.character(F3_Decisiones))
    for(franja in F3_Franjas) {
        for(estado in F3_Estados) {
            for(num_vagones in F3_Decisiones) {
                # Se tiene un costo por cada vagón enviado
                costo_vagones <- costo_vagon * num_vagones
                # Y otro costo por cada persona que no alcanzó a subirse con esa cantidad de vagones
                num_faltantes <- max(estado - F3_CapacidadVagon * num_vagones, 0)
                costo_faltantes <- costo_confianza * num_faltantes
                C[franja, as.character(estado), as.character(num_vagones)] = costo_vagones + costo_faltantes
            }
        }
    }
    return(C)
}

F3_SolveSDP <- function(C) {
    # Matriz de ecuaciones de Bellman
    f <- matrix(0, nrow = length(F3_Estados), ncol = length(F3_epocas))
    dimnames(f) <- list(as.character(F3_Estados), F3_epocas)
    
    # Matriz de decisiones
    decisiones <- matrix(0, nrow = length(F3_Estados), ncol = length(F3_epocas))
    dimnames(decisiones) <- list(as.character(F3_Estados), F3_epocas)
    
    # Caso base: última época. Se consideran solo los retornos inmediatos
    # En la última época se tiene la última franja
    ultima_franja <- F3_Franjas[length(F3_Franjas)]
    ultima_epoca <- F3_epocas[length(F3_epocas)]
    for(estado in F3_Estados) {
        # Se toma el mínimo costo entre todas las decisiones para la última franja y estado actual
        f[as.character(estado), ultima_epoca] <- min(C[ultima_franja, as.character(estado), ])
        decisiones[as.character(estado), ultima_epoca] <- which.min(C[ultima_franja, as.character(estado), ]) - 1
    }
    
    # Caso inductivo: de atrás para adelante, excepto la última
    for(epoca in rev(F3_epocas[-length(F3_epocas)])){
        for(estado in F3_Estados) {
            # Identificar en qué franja me encuentro
            hora <- as.numeric(strsplit(epoca, ":")[[1]][1])
            if(5 <= hora && hora <= 9)
                franja <- F3_Franjas[1]
            else if(10 <= hora && hora <= 14)
                franja <- F3_Franjas[2]
            else if(15 <= hora && hora <= 18)
                franja <- F3_Franjas[3]
            else if(19 <= hora && hora <= 23)
                franja <- F3_Franjas[4]
            # Extraer los retornos inmediatos para cada una de las decisiones
            inmediatos <- C[franja, as.character(estado), ]
            # Calcular el valor esperado de los retornos futuros
            probabilidades <- P[franja, , as.character(estado), ]
            epoca_futuro <- match(epoca, F3_epocas) + 1
            futuros <- probabilidades %*% f[, epoca_futuro]
            # Hallar los retornos de Bellman
            retornos <- inmediatos + futuros
            # Tomar la mejor decisión
            f[as.character(estado), epoca] <- min(retornos)
            decisiones[as.character(estado), epoca] <- which.min(retornos) - 1
        }
    }
    return(list(decisiones, f))
}

