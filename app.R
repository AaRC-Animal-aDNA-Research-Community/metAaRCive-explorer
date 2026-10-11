library(shiny)
library(leaflet)
library(dplyr)
library(DT)
library(shinyWidgets)
library(jsonlite)

# read data
df <- read.delim("https://raw.githubusercontent.com/AaRC-Animal-aDNA-Research-Community/metAaRCive/refs/heads/main/metAaRCive.txt", sep = "\t", header = TRUE, encoding = "UTF-8")

# read curator data
curators <- jsonlite::fromJSON(
  "https://raw.githubusercontent.com/AaRC-Animal-aDNA-Research-Community/metAaRCive/refs/heads/main/.zenodo.json"
)$creators$name
curators <- sub("^([^,]+),\\s*(.+)$", "\\2 \\1", curators)

# format data
df$sample_age <- suppressWarnings(as.numeric(df$sample_age))
df$nuclear_depth_of_coverage <- suppressWarnings(as.numeric(df$nuclear_depth_of_coverage))
df$latitude <- as.numeric(df$latitude)
df$longitude <- as.numeric(df$longitude)

numeric_range <- function(x, field_name) {
  values <- x[is.finite(x)]
  if (!length(values)) {
    stop(sprintf("Cannot initialize %s controls: no numeric values were found.", field_name))
  }

  bounds <- range(values)
  if (bounds[1] == bounds[2]) {
    bounds <- bounds + c(-1, 1)
  }
  bounds
}

age_range <- numeric_range(df$sample_age, "sample age")
coverage_range <- numeric_range(df$nuclear_depth_of_coverage, "nuclear coverage")

ui <- navbarPage(
  title = div(
    style = "display: flex; align-items: center; padding-left: 10px;",
    div(
      tags$img(src = "AaRC_logo.png", height = "40px", style = "margin-right: 0px;"),
      tags$div("metAaRCive Explorer",
               style = "font-size: 20px; text-align: center; color: black; font-weight: normal;"
      )
    )
  ),
  
  header = tags$head(
    tags$style(HTML("
      .navbar {
        min-height: 80px;
      }
      .navbar-brand {
        height: 80px;
        padding-top: 10px;
        padding-bottom: 10px;
      }
      .navbar-nav > li > a {
        padding-top: 30px;
        padding-bottom: 30px;
      }
      .container-custom {
        max-width: 1200px;
        margin: 0 auto;
      }
      .scroll-container {
        overflow-x: auto;
        overflow-y: hidden;
        width: 100%;
        padding-bottom: 10px;
      }
      .inline-numeric input {
        width: 80px !important;
        display: inline-block;
        margin: 0 2px;
      }
    "))
  ),
  
  tabPanel("Explore",
           div(class = "container-custom",
               fluidRow(
                 column(4,
                        pickerInput("species", "Species",
                                    choices = unique(df$samp_taxon_common),
                                    selected = unique(df$samp_taxon_common),
                                    multiple = TRUE,
                                    options = list(`actions-box` = TRUE)),
                        
                        pickerInput("sex", "Sex",
                                    choices = unique(df$molecular_sex),
                                    selected = unique(df$molecular_sex),
                                    multiple = TRUE,
                                    options = list(`actions-box` = TRUE)),
                        
                        pickerInput("platform", "Sequencing platform",
                                    choices = unique(df$nuclear_sequencing_platform),
                                    selected = unique(df$nuclear_sequencing_platform),
                                    multiple = TRUE,
                                    options = list(`actions-box` = TRUE)),
                        
                        pickerInput("strandedness", "Nuclear library strandedness",
                                    choices = unique(df$nuclear_lib_strandedness),
                                    selected = unique(df$nuclear_lib_strandedness),
                                    multiple = TRUE,
                                    options = list(`actions-box` = TRUE)),
                        
                        # Sliders and inline numeric inputs for Age
                        # Compact Age inputs
                        div(style = "margin-top: 15px;",
                            sliderInput("age", "Sample age (years BP)",
                                        min = age_range[1], max = age_range[2], value = age_range),
                            div(style = "display: flex; align-items: center; gap: 5px;",
                                numericInput("age_min", NULL, value = age_range[1], min = age_range[1], max = age_range[2], width = "100px"),
                                span("to"),
                                numericInput("age_max", NULL, value = age_range[2], min = age_range[1], max = age_range[2], width = "100px")
                            )
                        ),
                        
                        # Compact Coverage inputs
                        div(style = "margin-top: 15px;",
                            sliderInput("coverage", "Nuclear coverage",
                                        min = coverage_range[1], max = coverage_range[2], value = coverage_range),
                            div(style = "display: flex; align-items: center; gap: 5px;",
                                numericInput("coverage_min", NULL, value = coverage_range[1], min = coverage_range[1], max = coverage_range[2], width = "80px"),
                                span("to"),
                                numericInput("coverage_max", NULL, value = coverage_range[2], min = coverage_range[1], max = coverage_range[2], width = "80px")
                            )
                        ),
                        
                        selectInput("colorBy", "Colour map points by:",
                                    choices = c("Species" = "samp_taxon_common",
                                                "Sex" = "molecular_sex",
                                                "Age" = "sample_age",
                                                "Coverage" = "nuclear_depth_of_coverage"),
                                    selected = "samp_taxon_common"),
                        
                        uiOutput("colorLegend")
                 ),
                 column(8,
                        leafletOutput("map", height = 600),
                        br(), br(),
                        div(style = "display: flex; justify-content: space-between; align-items: center;",
                            h4("Your filtered dataset:", style="font-size: 30px"),
                            div(style = "display: flex; gap: 10px;",
                                downloadButton("downloadData", "Download CSV"),
                                actionButton("clear_selection", "Clear selection")
                            )
                        ),
                        div(class = "scroll-container",
                            dataTableOutput("table")
                        )
                 )
               )
           )
  ),
  
  tabPanel("About",
           div(class = "container-custom",
               h2("About metAaRCive"),
               p("The AaRC (Animal aDNA Research Community) metAaRCive (pronounced \"meta-archive\") project aims to create a harmonised database compiling metadata for published ancient animal genomes."),
               p("We hope this will encourage better and more uniform metadata reporting standards. We eventually aim to align animal studies with other ongoing developments in the aDNA world, including humans."),
               p("This app is intended to allow people to explore what aDNA is out there, and provide access to the original publications and sequences.")
           )
  ),
  
  tabPanel("Curators",
           div(class = "container-custom",
               h2("Curators & contributors"),
               p("Thanks go to the following people who have contributed to the metAaRCive project:"),
               tags$ul(lapply(curators, function(name) tags$li(name)))
           )
  )
)

server <- function(input, output, session) {
  
  filteredData <- reactive({
    df %>%
      filter(
        sample_age >= input$age[1] | is.na(sample_age),
        sample_age <= input$age[2] | is.na(sample_age),
        nuclear_depth_of_coverage >= input$coverage[1] | is.na(nuclear_depth_of_coverage),
        nuclear_depth_of_coverage <= input$coverage[2] | is.na(nuclear_depth_of_coverage),
        samp_taxon_common %in% input$species,
        molecular_sex %in% input$sex,
        nuclear_sequencing_platform %in% input$platform,
        nuclear_lib_strandedness %in% input$strandedness
      )
  })
  
  # Sync sliders and numeric inputs
  observeEvent(input$age, {
    updateNumericInput(session, "age_min", value = input$age[1])
    updateNumericInput(session, "age_max", value = input$age[2])
  })
  observeEvent(list(input$age_min, input$age_max), {
    values <- c(input$age_min, input$age_max)
    req(length(values) == 2, all(is.finite(values)))
    values <- sort(pmin(age_range[2], pmax(age_range[1], values)))
    if (!isTRUE(all.equal(input$age_min, values[1]))) {
      updateNumericInput(session, "age_min", value = values[1])
    }
    if (!isTRUE(all.equal(input$age_max, values[2]))) {
      updateNumericInput(session, "age_max", value = values[2])
    }
    if (!isTRUE(all.equal(input$age, values))) {
      updateSliderInput(session, "age", value = values)
    }
  }, ignoreInit = TRUE)
  observeEvent(input$coverage, {
    updateNumericInput(session, "coverage_min", value = input$coverage[1])
    updateNumericInput(session, "coverage_max", value = input$coverage[2])
  })
  observeEvent(list(input$coverage_min, input$coverage_max), {
    values <- c(input$coverage_min, input$coverage_max)
    req(length(values) == 2, all(is.finite(values)))
    values <- sort(pmin(coverage_range[2], pmax(coverage_range[1], values)))
    if (!isTRUE(all.equal(input$coverage_min, values[1]))) {
      updateNumericInput(session, "coverage_min", value = values[1])
    }
    if (!isTRUE(all.equal(input$coverage_max, values[2]))) {
      updateNumericInput(session, "coverage_max", value = values[2])
    }
    if (!isTRUE(all.equal(input$coverage, values))) {
      updateSliderInput(session, "coverage", value = values)
    }
  }, ignoreInit = TRUE)
  
  output$map <- renderLeaflet({
    leaflet() %>%
      addTiles() %>%
      setView(lng = mean(df$longitude, na.rm = TRUE),
              lat = mean(df$latitude, na.rm = TRUE),
              zoom = 2)
  })
  
  # Track table row selection
  selected_rows <- reactiveVal(NULL)
  observeEvent(input$table_rows_selected, {
    selected_rows(input$table_rows_selected)
  })
  observeEvent(input$clear_selection, {
    selected_rows(NULL)
  })
  
  observe({
    data <- filteredData()
    colorField <- input$colorBy
    
    if (colorField %in% c("samp_taxon_common", "molecular_sex")) {
      color_pal <- colorFactor(palette = "Set1", domain = unique(df[[colorField]]))
      colors <- color_pal(data[[colorField]])
    } else {
      color_pal <- colorNumeric(palette = "viridis", domain = df[[colorField]], na.color = "grey")
      colors <- color_pal(data[[colorField]])
    }
    
    # Jitter for display, keep original coords
    data <- data %>%
      mutate(
        jitter_lat = latitude + runif(n(), -0.0009, 0.0009),
        jitter_lng = longitude + runif(n(), -0.0009, 0.0009) * cos(latitude * pi / 180)
      )
    
    # If rows selected, only show those
    if (!is.null(selected_rows())) {
      data <- data[selected_rows(), ]
    }
    
    leafletProxy("map", data = data) %>%
      clearMarkers() %>%
      addCircleMarkers(
        lng = ~jitter_lng, lat = ~jitter_lat,
        popup = ~paste0(
          "<b>Sample:</b> ", samp_name, "<br>",
          "<b>Species:</b> ", samp_taxon_common, "<br>",
          "<b>Sex:</b> ", molecular_sex, "<br>",
          "<b>Age:</b> ", sample_age, "<br>",
          "<b>Coverage:</b> ", nuclear_depth_of_coverage, "<br>",
          "<b>Site:</b> ", site_name, "<br>",
          "<b>Location:</b> ", geo_loc_name
        ),
        radius = 7,
        fillColor = colors,
        color = "black",
        weight = 0.5,
        fillOpacity = 1
      )
  })
  
  output$colorLegend <- renderUI({
    colorField <- input$colorBy
    if (colorField %in% c("samp_taxon_common", "molecular_sex")) {
      vals <- unique(df[[colorField]])
      pal <- colorFactor("Set1", domain = vals)
      div(
        style = "margin-top: 10px;",
        strong("Legend:"),
        tags$ul(style = "list-style: none; padding-left: 0;",
                lapply(vals, function(val) {
                  tags$li(
                    tags$span(style = paste0("display:inline-block;width:12px;height:12px;background-color:",
                                             pal(val), ";margin-right:6px;")),
                    val
                  )
                })
        )
      )
    } else {
      pal <- colorNumeric("viridis", domain = df[[colorField]], na.color = "grey")
      minVal <- round(min(df[[colorField]], na.rm = TRUE), 2)
      maxVal <- round(max(df[[colorField]], na.rm = TRUE), 2)
      div(
        style = "margin-top: 10px;",
        strong("Legend:"),
        tags$div(style = "display: flex; align-items: center;",
                 tags$span(paste(minVal), style = "margin-right: 8px;"),
                 tags$div(style = paste0("height: 10px; width: 150px; background: linear-gradient(to right,",
                                         paste(sapply(seq(0, 1, length.out = 10),
                                                      function(x) pal(x * (maxVal - minVal) + minVal)),
                                               collapse = ","), "); margin: 0 8px;")),
                 tags$span(paste(maxVal))
        )
      )
    }
  })
  
  output$table <- renderDataTable({
    datatable(
      filteredData(),
      rownames = TRUE,
      options = list(
        scrollX = TRUE,
        pageLength = 10,
        autoWidth = TRUE
      ),
      class = "display nowrap",
      selection = "multiple",
      colnames = colnames(filteredData()) # prevents adding X column
    )
  })
  
  output$downloadData <- downloadHandler(
    filename = function() {
      paste0("metAaRCive_filtered_data_", Sys.Date(), ".csv")
    },
    content = function(file) {
      write.csv(filteredData(), file, row.names = FALSE)
    }
  )
}

shinyApp(ui = ui, server = server)
