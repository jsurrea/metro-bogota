library(shiny)
library(plotly)
library(shinydashboard)
library(shinyWidgets)

source("Fase_1.R")
source("Fase_2.R")
source("Fase_3.R")

addResourcePath("www", "/app/www")

# Interfaz gráfica
ui <- dashboardPage(
    
    # Encabezado
    dashboardHeader(
        title = "Consultoría Metro"
    ),
    
    # Barra lateral
    dashboardSidebar(
        sidebarMenu(
            
            # Opción de la Portada
            menuItem(
                "Portada", 
                tabName = "P", 
                icon = icon("th")
            ),
            
            # Opción de la Fase 1
            menuItem(
                "Fase 1", 
                tabName = "F1", 
                icon = icon("th")
            ),
            
            # Opción de la Fase 2
            menuItem(
                "Fase 2", 
                tabName = "F2", 
                icon = icon("th")
            ),
            
            # Opción de la Fase 3
            menuItem(
                "Fase 3", 
                tabName = "F3", 
                icon = icon("th")
            )
        )
    ),
    
    # Cuerpo
    dashboardBody(
        tabItems(
            
            # Pestaña de la Portada
            tabItem(
                tabName = "P",
                h1("Herramienta final de consultoría", align = "center"),
                h2("Empresa Metro de Bogotá S.A.", align = "center"),
                hr(),
                div(img(src = "image.jpeg"), align = "center")
            ),
            
            # Pestaña de la Fase 1
            tabItem(
                tabName = "F1",
                h1("Fase 1", align = "center"),
                sidebarLayout(
                    
                    # Panel lateral
                    sidebarPanel(
                        
                        # Capacidad Primera de mayo
                        numericInput(
                            inputId = "F1_CapMayo",
                            label = "Capacidad de la estación Primera de Mayo:",
                            value = 57,
                            min = 1
                        ),
                        
                        # Capacidad NQS
                        numericInput(
                            inputId = "F1_CapNQS",
                            label = "Capacidad de la estación NQS:",
                            value = 256,
                            min = 1
                        ),
                        
                        # Capacidad Caracas
                        numericInput(
                            inputId = "F1_CapCaracas",
                            label = "Capacidad de la estación Caracas:",
                            value = 213,
                            min = 1
                        )
                    ),
                    
                    # Panel principal
                    mainPanel(
                        
                        # Resultados para la estación Primera de Mayo
                        box(
                            title = "Estación Primera de Mayo",
                            width = 12,
                            fluidRow(
                                
                                # Primera hora de operación
                                plotlyOutput("F1_MayoPlotA"),
                                
                                # Estado estable
                                plotlyOutput("F1_MayoPlotB"),
                            )
                        ),
                        
                        # Resultados para la estación NQS
                        box(
                            title = "Estación NQS",
                            width = 12,
                            fluidRow(
                                
                                # Primera hora de operación
                                plotlyOutput("F1_NQSPlotA"),
                                
                                # Estado estable
                                plotlyOutput("F1_NQSPlotB"),
                            )
                        ),
                        
                        # Resultados para la estación Caracas
                        box(
                            title = "Estación Caracas",
                            width = 12,
                            fluidRow(
                                
                                # Primera hora de operación
                                plotlyOutput("F1_CaracasPlotA"),
                                
                                # Estado estable
                                plotlyOutput("F1_CaracasPlotB"),
                            )
                        )
                    )
                )
            ),
            
            # Pestaña de la Fase 2
            tabItem(
                tabName = "F2",
                h1("Fase 2", align = "center"),
                sidebarLayout(
                    
                    # Panel lateral
                    sidebarPanel(
                        
                        # Archivo de entrada
                        fileInput(
                            inputId = 'F2_File', 
                            label = 'Ingrese el archivo de datos:',
                            accept = c(".xlsx")
                        ),
                        
                        # Costos en óptimas condiciones
                        sliderInput(
                            "F2_CostoOptimasCond",
                            "Costo promedio de un mes de operación en óptimas condiciones:",
                            min = 0,
                            max = 15000000,
                            value = 10000000,
                            step = 500000
                        ),
                        
                        # Costos en condiciones regulares
                        sliderInput(
                            "F2_CostoCondRegulares",
                            "Costo promedio de un mes de operación en condiciones regulares:",
                            min = 0,
                            max = 15000000,
                            value = 12500000,
                            step = 500000
                        )
                    ),
                    
                    # Panel principal
                    mainPanel(
                        
                        # Tiempo esperado de operación
                        textOutput("F2_TiempoOperacion"),
                        hr(),
                        
                        # Costo esperado de operación durante la vida útil
                        textOutput("F2_CostoOperacion"),
                        hr(),
                        
                        # Costo esperado de chatarrización
                        textOutput("F2_PagoChatarrizacion"),
                        hr(),
                        
                        # (Gráfica) Probabilidad de finalizar vida útil con x km acumulados
                        plotlyOutput("F2_Plot"),
                        hr()
                    )
                )
            ),
            
            # Pestaña de la Fase 3
            tabItem(
                tabName = "F3",
                h1("Fase 3", align = "center"),
                sidebarLayout(
                    
                    # Parámetros
                    sidebarPanel(
                        
                        # Estado inicial
                        numericInput(
                            inputId = "F3_EstadoInicial",
                            label = "Ocupación inicial de la estación:",
                            value = 0,
                            min = 0,
                            max = 150
                        ),
                        
                        # Hora
                        selectInput(
                            inputId = "F3_HoraInicial",
                            label = "Hora inicial:",
                            choices = as.character(5:23)
                        ),
                        
                        # Minuto
                        selectInput(
                            inputId = "F3_MinutoInicial",
                            label = "Minuto inicial:",
                            choices = formatC(seq(0, 45, 15), width = 2, format = "d", flag = "0")
                        ),
                        
                        # Costo por vagón
                        shinyWidgets::autonumericInput(
                            inputId = "F3_CostoVagon", 
                            label = "Costo por enviar un vagón:", 
                            value = 150000,
                            currencySymbol = "$",
                            currencySymbolPlacement = "p",
                            decimalPlaces = 0,
                            digitGroupSeparator = ".",
                            decimalCharacter = ",",
                            minimumValue = 0
                        ),
                        
                        # Costo por pérdida de confianza
                        shinyWidgets::autonumericInput(
                            inputId = "F3_CostoConfianza", 
                            label = "Costo por persona no recogida:", 
                            value = 6000,
                            currencySymbol = "$",
                            currencySymbolPlacement = "p",
                            decimalPlaces = 0,
                            digitGroupSeparator = ".",
                            decimalCharacter = ",",
                            minimumValue = 0
                        )
                    ),
                    
                    # Resultados
                    mainPanel(
                        
                        # Costo total de la política
                        textOutput("F3_CostoTotalPolitica"),
                        hr(),
                        
                        # Mapa de calor con las decisiones
                        plotlyOutput("F3_Plot"),
                    )
                )
            )
        )
    )
)

# Lógica del servidor
server <- function(input, output) {
    
    ############################## FASE 1 ##############################
    
    # Detectar cambios en la capacidad de la estación Primera de Mayo y devolver el nuevo modelo
    F1_ModeloMayo <- eventReactive(
        input$F1_CapMayo, 
        {
            if(is.null(input$F1_CapMayo)) 
                return(NULL) 
            # Se usan los valores de las tasas calculados en la Fase 1
            estados <- seq(0, input$F1_CapMayo)
            CMTC <- F1_CreateMarkovChain(estados, 11.9409077160783, 1/4)
            return(CMTC)
        }
    )
    
    # Detectar cambios en la capacidad de la estación NQS y devolver el nuevo modelo
    F1_ModeloNQS <- eventReactive(
        input$F1_CapNQS, 
        {
            if(is.null(input$F1_CapNQS)) 
                return(NULL) 
            # Se usan los valores de las tasas calculados en la Fase 1
            estados <- seq(0, input$F1_CapNQS)
            CMTC <- F1_CreateMarkovChain(estados, 8.96132246665456, 1/7)
            return(CMTC)
        }
    )
    
    # Detectar cambios en la capacidad de la estación Caracas y devolver el nuevo modelo
    F1_ModeloCaracas <- eventReactive(
        input$F1_CapCaracas, 
        {
            if(is.null(input$F1_CapCaracas)) 
                return(NULL) 
            # Se usan los valores de las tasas calculados en la Fase 1
            estados <- seq(0, input$F1_CapCaracas)
            CMTC <- F1_CreateMarkovChain(estados, 15.5507450722417, 1/25)
            return(CMTC)
        }
    )
    
    # Gráficas de la primera hora de operación
    F1_RenderPlotA <- function(modelo) {
        renderPlotly({
            if(is.null(modelo()))
                return(NULL)
            CMTC  <- modelo()
            data <- F1_CalculateStatistics(CMTC@generator)
            plot_ly(
                data,
                x = ~tiempo,
                y = ~high,
                type = "scatter",
                mode = "lines",
                line = list(color = 'rgba(82,142,183,1)'),
                showlegend = FALSE,
                name = "+1std"
            ) %>%
            add_trace(
                y = ~low,
                type = "scatter",
                mode = "lines",
                fill = 'tonexty',
                fillcolor = 'rgba(82,142,183,0.2)',
                line = list(color = 'rgba(82,142,183,1)'),
                showlegend = FALSE,
                name = "-1std"
            ) %>%
            add_trace(
                y = ~valores_esperados,
                type = "scatter",
                mode = "lines+markers",
                line = list(color = 'rgba(82,142,183,1)'),
                marker = list(color = 'rgba(82,142,183,1)'),
                name = "Valor esperado"
            ) %>%
            layout(
                title = "Ocupación durante la primera hora de operación",
                xaxis = list(title = "Minutos"),
                yaxis = list(title = "Número de personas")
            )
        })
    }
    output$F1_MayoPlotA <- F1_RenderPlotA(F1_ModeloMayo)
    output$F1_NQSPlotA <- F1_RenderPlotA(F1_ModeloNQS)
    output$F1_CaracasPlotA <- F1_RenderPlotA(F1_ModeloCaracas)
    
    # Gráficas de las probabilidades en estado estable
    F1_RenderPlotB <- function(modelo) {
        renderPlotly({
            if(is.null(modelo()))
                return(NULL)
            CMTC  <- modelo()
            data <- F1_CalculateSteadyStates(CMTC)
            plot_ly(
                data,
                x = ~estado,
                y = ~probabilidad,
                type = "bar",
                marker = list(color='rgba(82,142,183,1)')
            ) %>%
            layout(
                title = "Probabilidades de cada ocupación en estado estable",
                xaxis = list(title = "Ocupación de la estación"),
                yaxis = list(title = "Probabilidad")
            )
        })
    }
    output$F1_MayoPlotB <- F1_RenderPlotB(F1_ModeloMayo)
    output$F1_NQSPlotB <- F1_RenderPlotB(F1_ModeloNQS)
    output$F1_CaracasPlotB <- F1_RenderPlotB(F1_ModeloCaracas)
    
    
    ############################## FASE 2 ##############################
    
    # Detectar cambios en el archivo de entrada y devolver la cadena de Markov
    F2_Modelo <- eventReactive(
        input$F2_File, 
        {
            if(is.null(input$F2_File)) 
                return(NULL) 
            df <- read_excel(input$F2_File$datapath, sheet = 1, col_names = TRUE)
            CMTD <- F2_CreateMarkovChain(as.data.frame(df))
            return(CMTD)
        }
    )
    
    # Tiempo esperado de operación
    output$F2_TiempoOperacion <- renderText({
        if(is.null(F2_Modelo()))
            tiempo <- "0"
        else
            tiempo <- round(F2_TiempoOperacion(F2_Modelo()), 3)
        paste("El tiempo esperado de operación de un tren en años es:", tiempo)
    })
    
    # Costo esperado de chatarrización
    output$F2_PagoChatarrizacion <- renderText({
        if(is.null(F2_Modelo()))
            costo <- "0"
        else
            costo <- round(F2_PagoChatarrizacion(F2_Modelo()), 3)
        paste("El costo esperado de chatarrización de un tren es:", costo)
    })
    
    # Costo esperado de operación durante la vida útil
    output$F2_CostoOperacion <- renderText({
        if(is.null(F2_Modelo()))
            costo <- "0"
        else
            costo <- round(F2_CostoOperacion(F2_Modelo(), input$F2_CostoOptimasCond, input$F2_CostoCondRegulares), 3)
        paste("El costo esperado de operación de un tren durante su vida útil es:", costo)
    })
    
    # (Gráfica) Probabilidad de finalizar vida útil con x km acumulados
    output$F2_Plot <- renderPlotly({
        if(is.null(F2_Modelo()))
            return(NULL)
        data <- F2_PlotData(F2_Modelo())
        plot_ly(
            data,
            x = ~distancias,
            y = ~probs,
            type = "bar"
        ) %>%
        layout(
            title = "Probabilidad de ser chatarrizado por fallas irreparables",
            xaxis = list(title = "Kilometraje acumulado"),
            yaxis = list(title = "Probabilidad")
        )
    })
    
    
    ############################## FASE 3 ##############################
    
    # Detectar cambios en los costos para recalcular la política óptima
    F3_PoliticaOptima <- eventReactive(
        c(input$F3_CostoVagon, input$F3_CostoConfianza),
        {
            if(is.null(input$F3_CostoVagon) || is.null(input$F3_CostoConfianza)) 
                return(NULL) 
            retornos <- F3_CreateReturnsMatrix(input$F3_CostoVagon, input$F3_CostoConfianza)
            PO <- F3_SolveSDP(retornos)
            return(PO)
        }
    )
    
    # Costo óptimo
    output$F3_CostoTotalPolitica <- renderText({
        if(is.null(F3_PoliticaOptima()))
            costo <- 0
        else {
            f <- F3_PoliticaOptima()[[2]]
            costo <- round(f[as.character(input$F3_EstadoInicial), paste(input$F3_HoraInicial, input$F3_MinutoInicial, sep=":")], 3)
        }
        paste("El costo total esperado de la jornada de acuerdo con la política de decisión óptima es:", costo)
    })
    
    # Mapa de calor
    output$F3_Plot <- renderPlotly({
        if(is.null(F3_PoliticaOptima()))
            return(NULL)
        decisiones <- F3_PoliticaOptima()[[1]]
        plot_ly(
            x = F3_Epocas, 
            y = F3_Estados,
            z = decisiones,
            type = "heatmap"
        ) %>%
        layout(
            title = "Número de vagones que se deben enviar (Política Óptima)",
            xaxis = list(title = "Tiempo (Época)"),
            yaxis = list(title = "Ocupación de la estación (Estado)")
        )
    })
}

# Ejecutar la aplicación
shinyApp(ui = ui, server = server, options = list(port = 3838, host = "0.0.0.0"))
