## Name: Te-Jou Hou (Carol)

library(shiny)
library(tidyverse)
library(broom)
library(bslib)
library(DT)
library(thematic)
library(showtext)

thematic_shiny(font = "auto")

## Read in Data ------------------
energyData <- readRDS("./dc_energy_layouts/data/energy_year.rds")

## Transform Data to Factors
energyData |>
  mutate(across(c("Ward", "Report_Year", "Type_SS", 
                  "Type_EPA", "Metered_Energy", "Metered_Water"),
                ~ as.factor(.x)))->
  energyData


## Create `Built`
energyData |>
  mutate(
    Era = case_when(
      Built < 1900 ~ "Pre-1900",
      Built < 1951 ~ "Early-Mid 20th",
      Built < 2000 ~ "Late 20th",
      Built < 2011 ~ "Aughts",
      TRUE ~ "Teens and later"), .after = Built)->
  energyData


## Create t.test function with tibble output
t_test_summary <- function(data, mu) {
  t_test_result <- t.test(data, mu = mu)
  
  summary <- tidy(t_test_result) |>
    select(estimate, p.value, conf.low, conf.high) |>
    mutate(Null_Value = mu, .after = estimate)
  
  return(as_tibble(summary))
}

custom_theme <- function() {
  theme(
    axis.text = element_text(size = rel(1.2)),  
    axis.title = element_text(size = rel(1.2))  
  )
}

source("./dc_energy_layouts/R/intro_html.R")

###
### Enter Business Logic before this line
###

###
## Begin User Interface Section ----------------
ui <- fluidPage(
  theme = bslib::bs_theme(version = 5, bootswatch = "minty"),
  titlePanel("Analyzing Building Energy Performance Data"),
  
  tabsetPanel(
    tabPanel("Introduction", intro_content),
    
    tabPanel("Univariate analysis", 
             sidebarLayout(
               sidebarPanel(
                 varSelectInput("selected_var", "Variable?", 
                                data = energyData, 
                                selected = "Energy_Star_Score"),
                 checkboxInput("log_transform", "Log Transform?"),
                 checkboxInput("flip_coords", "Flip Coordinates on Factors?"),
                 sliderInput("bins", "Number of Bins?",
                             value = 40, min = 1, max = 100),
                 numericInput("null_value", "Null Value",
                              value = 0, min = 0, 
                              max = max(energyData$Electricity_Grid_Usage)),
                 checkboxGroupInput("report_year", "Which Report Years?",
                                    choices = c(2012:2022), selected = 2022),
                 
               ), # sidebarPanel
               mainPanel(
                 plotOutput("single_plot"),
                 tableOutput("ttest_results")
               )  # mainPanel
             ) # sidebarLayout
    ), # tabPanel
 
    tabPanel("Bivariate analysis",
             sidebarLayout(
               sidebarPanel(
                 varSelectInput("x_var", "X variable?", data = energyData),
                 checkboxInput("log_x", "Log_Transform?"),
                 varSelectInput("y_var", "Y variable?", data = energyData),
                 checkboxInput("log_y", "Log Transform?"),
                 checkboxInput("add_smooth", "Fit a Linear Model?"),
                 checkboxInput("add_nonlinear_smooth", "Fit a non-linear smoother?"),
                 checkboxGroupInput("report_years_bi", "Which Report Years?", 
                                    choices = c(2012:2022), selected = 2022)
               ), # sidebarPanel
               mainPanel(
                 plotOutput("bivariate_plot"),
                 verbatimTextOutput("lm_summary"),
                 uiOutput("lm_summary_and_plots")
               )  # mainPanel
             ) # sidebarLayout
    ), # tabPanel
                 
    tabPanel("Data Table",
             sidebarPanel(
               checkboxInput("numeric_vars", "Numeric Only?")
             ), # sidebarPanel
             mainPanel(
               dataTableOutput("interactive_table")
             )  # mainPanel
    ) # tabPanel
  ) # tabsetPanel
) # fluidpage

server <- function(input, output, session) {
  
###  
### Enter Server Code After this line
###

  df_year <- reactive({
    req(input$selected_var)
    
    temp_data <- energyData |>
      filter(Report_Year %in% input$report_year) |>
      select(!!sym(input$selected_var), Report_Year)
    
    if (is.numeric(temp_data[[input$selected_var]])) {
      temp_data <- temp_data |> filter(!!sym(input$selected_var) > 0)
    }
    
    validate(
      need(is.numeric(temp_data[[input$selected_var]]) || is.factor(temp_data[[input$selected_var]]), 
           "Please Choose Numeric or Factor Variable"),
      need(!(input$log_transform && is.factor(temp_data[[input$selected_var]])), 
           "Variable is a factor so can't be logged"),
      need(!(input$log_transform && any(temp_data[[input$selected_var]] <= 0)), 
           "Variable has one or more values <= 0 so can't be logged"),
      need(any(temp_data[[input$selected_var]] != 0), 
           "The selected variable is all zeros")
    )
    
    temp_data
  })
  
## Create single variable plot
## Create base plot
  output$single_plot <- renderPlot({
    
    req(df_year())
    
    energyData |>
      filter(Report_Year %in% input$report_year)->
      data_selected
    
    pl <- ggplot(data_selected, aes(x = !!input$selected_var))+
      facet_wrap(~Report_Year)+
      custom_theme()

## Check for other inputs and adjust base plot   
    if (is.numeric(data_selected[[input$selected_var]])) {
      pl <- pl + geom_histogram(bins = input$bins)
    } else {
      pl <- pl + geom_bar()
    } 
    
    if (input$flip_coords) {
      pl <- pl + coord_flip()
    } 
    
    if (input$log_transform) {
      pl <- pl + scale_x_log10()
    }
    
    pl
  })
  
  
## Run t.test
## Inside the render function, create a temporary data frame 
## of just the selected variable for the report years and no 0 values
## and save it.
  output$ttest_results <- renderTable({
    
    req(df_year())
    
    energyData |>
      filter(Report_Year %in% input$report_year) |>
      select(!!sym(input$selected_var)) |>
      filter(!!sym(input$selected_var) > 0)->
      data_selected
    
    validate(
      need(is.numeric(data_selected[[input$selected_var]]), 
           "Variable is non-numeric so no t-test")
    )
    
    data_selected_vector <- data_selected |> pull(!!sym(input$selected_var))
    
## Check for log and then run t.test of transformed data (or not) 
## using function from business logic section   
    if (is.numeric(data_selected_vector)) {
      
      if (input$log_transform) {
        data_for_test <- log(data_selected_vector)
        result <- t_test_summary(data_for_test, mu = log(input$null_value))
      } else {
        result <- t_test_summary(data_selected_vector, 
                                 mu = input$null_value)
      }
      return(result)
    } else {
      return(NULL)
    }
  })
  
  
  
  df_year_b <- reactive({
    req(input$x_var, input$y_var)
    
    temp_data_b <- energyData |>
      filter(Report_Year %in% input$report_years_bi) |>
      select(input$x_var, input$y_var, Report_Year) 
    
    if (is.numeric(temp_data_b[[input$x_var]]) && is.numeric(temp_data_b[[input$y_var]])) {
      temp_data_b <- temp_data_b |>
        filter(!!sym(input$x_var) > 0, !!sym(input$y_var) > 0)
    }
    
    validate(
      need(is.numeric(temp_data_b[[input$x_var]]) || is.factor(temp_data_b[[input$x_var]]), 
           "Please Choose Numeric or Factor Variable for X"),
      need(is.numeric(temp_data_b[[input$y_var]]) || is.factor(temp_data_b[[input$y_var]]), 
           "Please Choose Numeric or Factor Variable for Y"),
      need(!(input$log_x && is.factor(temp_data_b[[input$x_var]])), 
           "X Variable is a factor so can't be logged"),
      need(!(input$log_y && is.factor(temp_data_b[[input$y_var]])), 
           "Y Variable is a factor so can't be logged"),
      need(!(input$log_x && any(temp_data_b[[input$x_var]] <= 0)), 
           "X Variable has one or more values <= 0 so can't be logged."),
      need(!(input$log_y && any(temp_data_b[[input$y_var]] <= 0)), 
           "Y Variable has one or more values <= 0 so can't be logged."),
      need(!(all(temp_data_b[[input$x_var]] == 0 & temp_data_b[[input$y_var]] == 0)), 
           "The selected X and Y variables are all zeros")
    )
    
    temp_data_b
  })
  
## Create 2 Variable Plots
## Inside the render function, create the base plot
## with data from the selected years
  output$bivariate_plot <- renderPlot({
    
    req(df_year_b())
    
    data_selected <- df_year_b()
    
    pl <- ggplot(data_selected, 
                 aes(x = !!(input$x_var), y=!!(input$y_var)))+
      custom_theme()
## Add Geom based on class of x and y inputs
## Create flag variables for is.numeric for x and y
## Replace ... with appropriate variables
    isnx <- is.numeric(data_selected[[input$x_var]])
    isny <- is.numeric(data_selected[[input$y_var]])

## Use flag variables to test what type of data has been selected
## and then add the correct geoms, log scales, and labels 
 
    if (isnx & isny) { # Are both x and y numeric
      pl <- pl + geom_point(aes(color = Report_Year))
      
      if (input$log_x) { # log transform x Axis?
        pl <- pl + scale_x_log10() + labs(x = paste0("Log_Scale(", input$x_var, ")"))
      } #end if log x
      
      if (input$log_y) { # log transform y Axis?
        pl <- pl + scale_y_log10() + labs(y = paste0("Log_Scale(", input$y_var, ")")) 
        
      } # end if log y
      
      if (input$add_smooth) { # Add OLS smoother?
        pl <- pl + geom_smooth(method = "lm", se = FALSE)
      }
      
      if (input$add_nonlinear_smooth) {  # Add a non-linear smoother?
        pl <- pl + geom_smooth(method = "loess", color = "red", linetype = 2, se = FALSE)
      }
      #  # end if both numeric
      # 
    } else if (isnx) {  # if x is numeric and y is not
      pl <- pl + geom_boxplot(
        aes(x = !!(input$x_var), y = as.factor(!!input$y_var)))   
      
      if (input$log_x) {# Is x logged
        pl <- pl + scale_x_log10()     
      } #end if log x (on the y axis)
      
    } else if (isny) {# if y is numeric and x is not
      pl <- pl + geom_boxplot(
        aes(x = as.factor(!!input$x_var), y = (!!input$y_var)))   
      if (input$log_y) {  # Is y logged
        pl <- pl + scale_y_log10()      
      } #end if log y (on the x axis)
      
    } else { # neither x or y are numeric
      pl <- pl + geom_jitter(
        aes(x = as.factor(!!input$x_var), y = as.factor(!!input$y_var), color = Report_Year))
    } #end if
    pl <- pl + labs(color = "Report Year")
    
    pl
  }) 

  lmout <- reactive({
    req(input$add_smooth)
    
    data_selected <- df_year_b()
    x_var <- sym(input$x_var)
    y_var <- sym(input$y_var)
    
    validate(
      need(is.numeric(data_selected[[input$x_var]]), "X variable must be numeric for linear model"),
      need(is.numeric(data_selected[[input$y_var]]), "Y variable must be numeric for linear model"),
      need(!(input$log_x && any(data_selected[[input$x_var]] <= 0)), 
           "X Variable has values <= 0 so can't be logged."),
      need(!(input$log_y && any(data_selected[[input$y_var]] <= 0)), 
           "Y Variable has values <= 0 so can't be logged.")
    )
    
    if (input$log_x) {
      data_selected[[input$x_var]] <- log(data_selected[[input$x_var]])
    }
    if (input$log_y) {
      data_selected[[input$y_var]] <- log(data_selected[[input$y_var]])
    }
    
    lm(data_selected[[input$y_var]] ~ data_selected[[input$x_var]], data = data_selected)
  })
  
  output$lm_summary_and_plots <- renderUI({
    req(lmout()) 
    
    fluidRow(
      column(12, 
             verbatimTextOutput("lm_summary")  
      ),
      column(6, 
             plotOutput("residual_plot")  
      ),
      column(6, 
             plotOutput("qq_plot")  
      )
    )
  })

## Create Linear Model Output
## Inside the render function, check if the OLS is selected
## If so, create a temporary data frame with data from the selected years
    output$lm_summary <- renderPrint({
      req(lmout())
      summary(lmout())
    })
    
## Create Residual Plot
    output$residual_plot <- renderPlot({
      req(lmout())  
      
      model <- lmout()
      residuals <- resid(model)  
      fitted_values <- fitted(model)  
      
      ggplot(data.frame(Fitted = fitted_values, Residuals = residuals), aes(x = Fitted, y = Residuals)) +
        geom_point() +
        labs(title = "Residuals vs Fitted", x = "x", y = "y")+
        custom_theme()
    })
    
## Create QQ Plot
    output$qq_plot <- renderPlot({
      req(lmout())  
      
      model <- lmout()
      
      ggplot(data.frame(Residuals = resid(model)), aes(sample = Residuals)) +
        stat_qq() +
        stat_qq_line() +
        labs(title = "QQ Plot", x = "x", y = "y")+
        custom_theme() 
    })
    


## Create output table for all data with page length 20
    output$interactive_table <- renderDT({
      filtered_data <- if (input$numeric_vars) {
        energyData[sapply(energyData, is.numeric)]
      } else {
        energyData
      }
      datatable(filtered_data, options = list(pageLength = 20),
                filter = 'top')
    })

    
### Enter Server code above this line
}# server

shinyApp(ui, server)
