library(shiny)
library(tidyverse)
library(janitor)
library(dplyr)
library(ggplot2)
library(ggpubr)
library(plotly)
library(readr)

Genomics_Ref2 <- read.csv("~/Downloads/Reference_Genomes.csv")
Archaea <- read.csv("~/Downloads/archaea.csv")

ui <- fluidPage(
  titlePanel("Dataset Selection App"),
  
  sidebarLayout(
    sidebarPanel(
      h4("Select an Option"),
      selectInput("plot_choice", "Choose a plot to display:",
                  choices = c("Annotation Count", 
                              "Oxygen and Temperature", 
                              "Frequency of CheckM", 
                              "Combined Plots")),
      
     
      conditionalPanel(
        condition = "input.plot_choice == 'Annotation Count'",
        selectInput("checkm_filter", "Filter by CheckM Marker Set:",
                    choices = NULL,  
                    multiple = TRUE)
      )
    ),
    
    mainPanel(
      uiOutput("plot_ui"),  
      
      hr(),
      h4("Description"),
      uiOutput("description_text")  
    )
  )
)

server <- function(input, output, session) {
  observe({
    top_checkm <- Genomics_Ref2 %>%
      count(CheckM.marker.set, sort = TRUE) %>%
      top_n(10, n) %>%
      pull(CheckM.marker.set)
    
    updateSelectInput(session, "checkm_filter", 
                      choices = top_checkm, 
                      selected = top_checkm)  
  })
  
  filtered_data <- reactive({
    req(input$checkm_filter)  
    Genomics_Ref2 %>%
      filter(CheckM.marker.set %in% input$checkm_filter)
  })
  

  output$plot_ui <- renderUI({
    if (input$plot_choice == "Annotation Count") {
      plotlyOutput("annotation_plot")  
    } else if (input$plot_choice == "Oxygen and Temperature") {
      fluidRow(
        column(6, plotlyOutput("oxygen_plot")),  
        column(6, plotlyOutput("temperature_plot"))  
      )
    } else if (input$plot_choice == "Frequency of CheckM") {
      plotlyOutput("frequency_plot")  
    } else if (input$plot_choice == "Combined Plots") {
      plotOutput("combined_plot") 
    }
  })
  
  output$annotation_plot <- renderPlotly({
    if (input$plot_choice == "Annotation Count") {
      p <- ggplot(filtered_data(), aes(
        x = Annotation.Count.Gene.Protein.coding,
        y = Annotation.Count.Gene.Pseudogene,
        color = CheckM.marker.set
      )) +
        geom_point(size = 3, alpha = 0.7) +
        labs(
          title = "Annotation Count Relationship by Top 10 CheckM Marker Sets",
          x = "Annotation Count Gene Protein-coding",
          y = "Annotation Count Gene Pseudogene",
          color = "CheckM Marker Set"
        ) +
        theme_minimal() +
        theme(
          legend.position = "right",
          plot.title = element_text(size = 16, face = "bold", family = "serif"),  
          axis.title = element_text(size = 12, family = "serif"),  
          legend.title = element_text(size = 12, family = "serif"),  
          legend.text = element_text(size = 10, family = "serif")  
        )
      ggplotly(p)
    }
  })
  
  
  
  output$oxygen_plot <- renderPlotly({
    if (input$plot_choice == "Oxygen and Temperature") {
      oxygen_plot <- Archaea %>%
        count(OxygenReq, name = "Count") %>%
        filter(!is.na(OxygenReq)) %>%  
        ggplot(aes(x = reorder(OxygenReq, -Count), y = Count, fill = OxygenReq)) +
        geom_bar(stat = "identity") +
        labs(
          title = "Counts of Oxygen Requirements",
          x = "Oxygen Requirement",
          y = "Count",
          fill = "Oxygen Requirement"
        ) +
        theme_minimal() +
        theme(
          axis.text.x = element_text(angle = 45, hjust = 1),
          plot.title = element_text(size = 16, face = "bold", family = "serif")
        )
      ggplotly(oxygen_plot)
    }
  })
  
  output$temperature_plot <- renderPlotly({
    if (input$plot_choice == "Oxygen and Temperature") {
      temperature_plot <- Archaea %>%
        count(TemperatureRange, name = "Count") %>%
        filter(!is.na(TemperatureRange)) %>%  
        ggplot(aes(x = reorder(TemperatureRange, -Count), y = Count, fill = TemperatureRange)) +
        geom_bar(stat = "identity") +
        labs(
          title = "Counts of Temperature Ranges",
          x = "Temperature Range",
          y = "Count",
          fill = "Temperature Range"
        ) +
        theme_minimal() +
        theme(
          axis.text.x = element_text(angle = 45, hjust = 1),
          plot.title = element_text(size = 16, face = "bold", family = "serif")
        )
      ggplotly(temperature_plot)
    }
  })
  
  
  
  
  
  
  output$frequency_plot <- renderPlotly({
    if (input$plot_choice == "Frequency of CheckM") {
      freq_data <- Genomics_Ref2 %>%
        count(CheckM.marker.set, sort = TRUE) %>%
        top_n(15, n)
      
      plot_ly(
        data = freq_data,
        labels = ~`CheckM.marker.set`,
        parents = NA,  
        values = ~n,
        type = 'sunburst',
        textinfo = 'label+percent entry',
        insidetextorientation = 'radial'
      ) %>%
        layout(
          title = list(
            text = "Frequency of CheckM Marker Sets (Sunburst)",
            font = list(size = 16, family = "serif", face = "bold")
          )
        )
    }
  })
  
  output$combined_plot <- renderPlot({
    if (input$plot_choice == "Combined Plots") {
      top_checkm <- Genomics_Ref2 %>%
        count(CheckM.marker.set, sort = TRUE) %>%
        top_n(5, n) %>%
        pull(CheckM.marker.set)
      
      filtered_data <- Genomics_Ref2 %>%
        filter(CheckM.marker.set %in% top_checkm)
      
      short_names <- c(
        "Halobacteriales" = "Halo",
        "Methanosarcinaceae" = "M-Sarc",
        "Sulfolobaceae" = "Sulfo",
        "Thermococcus" = "Thermo",
        "Natrinema" = "Natri"
      )
      
      bar_data <- filtered_data %>%
        group_by(`CheckM.marker.set`) %>%
        summarise(Average_Protein_Coding = mean(Annotation.Count.Gene.Protein.coding)) %>%
        mutate(Short_Name = recode(`CheckM.marker.set`, !!!short_names))
      
      density_plot <- ggplot(filtered_data, aes(x = Annotation.Count.Gene.Protein.coding, 
                                                fill = `CheckM.marker.set`)) +
        geom_density(alpha = 0.6) +
        labs(title = "A. Density Plot", x = "Protein-Coding Gene Count", y = "Density") +
        theme_minimal() +
        theme(
          plot.title = element_text(size = 12, face = "bold"),
          legend.position = "none"
        )
      
      bar_plot <- ggplot(bar_data, aes(x = reorder(Short_Name, -Average_Protein_Coding), 
                                       y = Average_Protein_Coding, fill = `CheckM.marker.set`)) +
        geom_bar(stat = "identity", alpha = 0.8) +
        labs(title = "B. Bar Plot", x = "Marker Set", y = "Avg. gene count/genome") +
        theme_minimal() +
        theme(
          plot.title = element_text(size = 12, face = "bold"),
          legend.position = "bottom",
          axis.text.x = element_text(angle = 30, hjust = 1)
        )
      
      summary_data <- filtered_data %>%
        group_by(`CheckM.marker.set`) %>%
        summarise(
          Count = n(),
          Mean = round(mean(Annotation.Count.Gene.Protein.coding), 1),
          SD = round(sd(Annotation.Count.Gene.Protein.coding), 1)
        )
      
      table_plot <- ggtexttable(summary_data, rows = NULL, theme = ttheme("classic"))
      table_with_title <- annotate_figure(
        table_plot,
        top = text_grob("C. Table", face = "bold", size = 12)
      )
      
      ggarrange(
        density_plot, bar_plot, 
        table_with_title,
        ncol = 2, nrow = 2,
        common.legend = TRUE,
        legend = "bottom"
      )
    }
  })
  
  output$description_text <- renderUI({
    if (input$plot_choice == "Combined Plots") {
      HTML("<p>The combined plot shows a density plot, bar plot, and a summary table for the top 5 CheckM marker sets in a 2x2 layout.</p>")
    }
  })
}

shinyApp(ui = ui, server = server)