#Alazar
library(shiny)
library(tidyverse)
library(janitor)
library(dplyr)
library(ggplot2)
library(ggpubr)
library(plotly)
library(readr)

# Load datasets
Genomics_Ref2 <- read.csv("data/Reference_Genomes.csv")
Archaea <- read.csv("data/archaea.csv")

# Define the UI
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
      
      # Conditional UI for Annotation Count filters
      conditionalPanel(
        condition = "input.plot_choice == 'Annotation Count'",
        selectInput("checkm_filter", "Filter by CheckM Marker Set:",
                    choices = NULL,  # Populated dynamically
                    multiple = TRUE)
      )
    ),
    
    mainPanel(
      uiOutput("plot_ui"),  # Output for the selected plot or plots
      
      hr(),
      h4("Description"),
      uiOutput("description_text")  # Dynamic description text
    )
  )
)

# Define the Server
server <- function(input, output, session) {
  # Populate the dropdown for filtering Annotation Count
  observe({
    top_checkm <- Genomics_Ref2 %>%
      count(CheckM.marker.set, sort = TRUE) %>%
      top_n(10, n) %>%
      pull(CheckM.marker.set)
    
    updateSelectInput(session, "checkm_filter", 
                      choices = top_checkm, 
                      selected = top_checkm)  # Default to all
  })
  
  # Reactive filtered data for Annotation Count
  filtered_data <- reactive({
    req(input$checkm_filter)  # Ensure selection is not empty
    Genomics_Ref2 %>%
      filter(CheckM.marker.set %in% input$checkm_filter)
  })
  
  # Dynamic rendering of plots based on dropdown choice
  output$plot_ui <- renderUI({
    if (input$plot_choice == "Annotation Count") {
      plotlyOutput("annotation_plot")  # Interactive Annotation Count plot
    } else if (input$plot_choice == "Oxygen and Temperature") {
      fluidRow(
        column(6, plotlyOutput("oxygen_plot")),  # Oxygen Requirements plot
        column(6, plotlyOutput("temperature_plot"))  # Temperature Ranges plot
      )
    } else if (input$plot_choice == "Frequency of CheckM") {
      plotlyOutput("frequency_plot")  # Sunburst Chart
    } else if (input$plot_choice == "Combined Plots") {
      plotOutput("combined_plot")  # Combined scatter, density, bar plot, and table
    }
  })
  
  # Render the Annotation Count plot
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
  
  
  
  # Fix for Oxygen and Temperature plots
  output$oxygen_plot <- renderPlotly({
    if (input$plot_choice == "Oxygen and Temperature") {
      oxygen_plot <- Archaea %>%
        count(OxygenReq, name = "Count") %>%
        filter(!is.na(OxygenReq)) %>%  # Exclude missing data
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
        filter(!is.na(TemperatureRange)) %>%  # Exclude missing data
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
  
  
  
  
  
  
  # Render the Frequency of CheckM plot (Sunburst)
  output$frequency_plot <- renderPlotly({
    if (input$plot_choice == "Frequency of CheckM") {
      freq_data <- Genomics_Ref2 %>%
        count(CheckM.marker.set, sort = TRUE) %>%
        top_n(15, n)
      
      plot_ly(
        data = freq_data,
        labels = ~`CheckM.marker.set`,
        parents = NA,  # No parent hierarchy
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
  
  # Render the Combined Plots
  output$combined_plot <- renderPlot({
    if (input$plot_choice == "Combined Plots") {
      # Filter for the top 5 CheckM marker sets
      top_checkm <- Genomics_Ref2 %>%
        count(CheckM.marker.set, sort = TRUE) %>%
        top_n(5, n) %>%
        pull(CheckM.marker.set)
      
      filtered_data <- Genomics_Ref2 %>%
        filter(CheckM.marker.set %in% top_checkm)
      
      # Create shortened names for marker sets
      short_names <- c(
        "Halobacteriales" = "Halo",
        "Methanosarcinaceae" = "M-Sarc",
        "Sulfolobaceae" = "Sulfo",
        "Thermococcus" = "Thermo",
        "Natrinema" = "Natri"
      )
      
      # Prepare bar plot data with shortened names
      bar_data <- filtered_data %>%
        group_by(`CheckM.marker.set`) %>%
        summarise(Average_Protein_Coding = mean(Annotation.Count.Gene.Protein.coding)) %>%
        mutate(Short_Name = recode(`CheckM.marker.set`, !!!short_names))
      
      # Density Plot
      density_plot <- ggplot(filtered_data, aes(x = Annotation.Count.Gene.Protein.coding, 
                                                fill = `CheckM.marker.set`)) +
        geom_density(alpha = 0.6) +
        labs(title = "A. Density Plot", x = "Protein-Coding Gene Count", y = "Density") +
        theme_minimal() +
        theme(
          plot.title = element_text(size = 12, face = "bold"),
          legend.position = "none"
        )
      
      # Bar Plot with updated y-axis label
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
      
      # Summary Table with formatted Mean and SD
      summary_data <- filtered_data %>%
        group_by(`CheckM.marker.set`) %>%
        summarise(
          Count = n(),
          Mean = round(mean(Annotation.Count.Gene.Protein.coding), 1),
          SD = round(sd(Annotation.Count.Gene.Protein.coding), 1)
        )
      
      # Create the table plot with a title
      table_plot <- ggtexttable(summary_data, rows = NULL, theme = ttheme("classic"))
      table_with_title <- annotate_figure(
        table_plot,
        top = text_grob("C. Table", face = "bold", size = 12)
      )
      
      # Combine plots without the scatter plot
      ggarrange(
        density_plot, bar_plot, 
        table_with_title,
        ncol = 2, nrow = 2,
        common.legend = TRUE,
        legend = "bottom"
      )
    }
  })
  
  # Dynamic description for each plot
  output$description_text <- renderUI({
    if (input$plot_choice == "Combined Plots") {
      HTML("<p>The combined plot shows a density plot, bar plot, and a summary table for the top 5 CheckM marker sets in a 2x2 layout.</p>")
    }
  })
}

# Run the app
shinyApp(ui = ui, server = server)

