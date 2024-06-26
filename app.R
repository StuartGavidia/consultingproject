library(shiny)
library(shinydashboard)
library(ggplot2)
library(reshape2)
library(cowplot)
library(dplyr)
library(tidyr)

ui <- dashboardPage(
  dashboardHeader(title = "Windhoek Central Hospital NICU Data"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
      menuItem("CLABSI Rates", tabName = "clabsi_rates", icon = icon("chart-line")),
      menuItem("Hand Hygiene Compliance", tabName = "hand_hygiene", icon = icon("hands-wash")),
      menuItem("Perception Surveys", tabName = "perception_survey", icon = icon("eye"))
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "dashboard",
              fluidRow(
                box(title = "Welcome to our analysis of the WCH NICU Data", status = "primary", solidHeader = TRUE,
                    "Our goal is to analyze the data and answer these research questions: ",
                    
                    "1. What is the baseline CLABSI infection rate in the WCH NICU for the last 5
years (pre intervention)? What is the CLABSI infection rate after
intervention?
            2. What is the baseline hand hygiene compliance rate of WCH NICU nurses?
What is the hand hygiene compliance rate after intervention?

            3. Does increased hand hygiene compliance correlate to decreased CLABSI
infection rates? In other words, did the intervention work, is my hypothesis
correct?
            4. Does knowledge, perception, and attitude surrounding hand
hygiene/infection control actually improve compliance to those
practices? Can you have good knowledge but suboptimal practice?
Can you have poor knowledge and have optimal practice?"
                )
              )
      ),
tabItem(tabName = "clabsi_rates",
        fluidRow(
          box(title = "CLABSI Rates Before Intervention By Source Name", status = "warning", plotOutput("plotPreCLABSI"), width = 6),
          box(title = "CLABSI Rates After Intervention By Source Name", status = "warning", plotOutput("plotPostCLABSI"), width = 6)
        ),
        fluidRow(
          box(title = "CLABSI Rates By Source Name", status = "warning", plotOutput("plotCLABSI"), width = 12)
        ),
        fluidRow(
          box(title = "CLABSI Rates Over Time", status = "warning", plotOutput("plotLineCLABSI"), width = 12)
        )
),
tabItem(tabName = "hand_hygiene",
        fluidRow(
          box(title = "Hand Hygiene Compliance by Ward", status = "warning", plotOutput("plotHHWard"), width = 12)
        ),
        fluidRow(
          box(title = "Hand Hygiene Compliance by 5 Moments of Hand Hygiene", status = "warning", plotOutput("plotHH5M"), width = 12)
        )
),
tabItem(tabName = "perception_survey",
        fluidRow(
          box(title = "Comparing Nurses’ Perceptions of Hand Hygiene Compliance Pre and Post Intervention", status = "warning", tableOutput("tableNursesPerceptionHH"), width = 12)
        ),
        fluidRow(
          box(title = "Comparing Nurse Survey Responses on Hand Hygiene Value and Effectiveness Pre and Post Intervention On a Scale from “Very Low” to “Very High”", status = "warning", tableOutput("tableNursesSurveyEfficacy"), width = 12)
        ),
        fluidRow(
          box(title = "Comparing Average Nurse Survey Responses to Efficacy of Various Actions to Improve Hand Hygiene Pre and Post Intervention On a Scale of 1-7", status = "warning", tableOutput("tableNursesSurveyHH"), width = 12)
        ),
        fluidRow(
          box(title = "Comparing Average Nurse Survey Responses to Value of Assigned to Hand Hygiene Pre and Post Intervention On a Scale of 1-7", status = "warning", tableOutput("tableNursesSurveyValue"), width = 12)
        ),
        fluidRow(
          box(title = "Hand Hygiene Plot", status = "warning", plotOutput("plotHH"), width = 12)
        ),
      )
    )
  )
)

# code for hand hygiene tab
generate_graph <- function(categories, opportunities, HR, HW, title, x_label) {
  HR_pct <- HR / opportunities * 100
  HW_pct <- HW / opportunities * 100
  data <- data.frame(category = categories, HR = HR_pct, HW = HW_pct)
  data_long <- melt(data, id.vars = "category", variable.name = "Type", value.name = "Percentage")
  
  plot <- ggplot(data_long, aes(x = category, y = Percentage, fill = Type)) +
    geom_bar(stat = "identity", position = "stack", width = 0.5) +
    labs(title = title,
         x = x_label,
         y = "% of Opportunities Seized",
         fill = "Type") +
    theme_minimal() + 
    scale_fill_manual(values = c("purple", "blue")) + 
    scale_y_continuous(limits = c(0, 100))
  
  return(plot)
}

wards <- c("ICU", "High Care", "Baby Room", "Baby Bed", "Isolation")
opportunities_ward_pre <- c(152, 146, 10, 254, 75)
HR_ward_pre <- c(19, 32, 4, 57, 25)
HW_ward_pre <- c(16, 5, 0, 13, 16)

opportunities_ward_post <- c(227, 288, 125, 83, 16)
HR_ward_post <- c(57, 75, 21, 41, 5)
HW_ward_post <- c(5, 15, 15, 2, 3)

pre_HH_ward_graph <- generate_graph(wards, opportunities_ward_pre, HR_ward_pre, HW_ward_pre, "Pre intervention", "Ward")
post_HH_ward_graph <- generate_graph(wards, opportunities_ward_post, HR_ward_post, HW_ward_post, "Post intervention", "Ward")

ward_plot <- plot_grid(pre_HH_ward_graph, post_HH_ward_graph, ncol = 2, nrow = 1)

five_moments <- c("BFTAP", "BCAP", "ABFER", "ATAP", "ATPS")
opportunities_5M_pre <- c(166, 110, 55, 148, 158)
HR_5M_pre <- c(25, 17, 17, 41, 37)
HW_5M_pre <- c(9, 6, 5, 10, 20)

opportunities_5M_post <- c(184, 163, 55, 166, 171)
HR_5M_post <- c(42, 36, 23, 50, 48)
HW_5M_post <- c(6, 3,7, 10, 14)

pre_HH_5M_graph <- generate_graph(five_moments, opportunities_5M_pre, HR_5M_pre, HW_5M_pre, "Pre intervention", "5 Moments")
post_HH_5M_graph <- generate_graph(five_moments, opportunities_5M_post, HR_5M_post, HW_5M_post, "Post intervention", "5 Moments")

indication_plot <- plot_grid(pre_HH_5M_graph, post_HH_5M_graph, ncol = 2, nrow = 1)

# code for clabsi tab
data <- read.csv("working_clabsi_data_2023.csv")

filtered_data <- data %>%
  filter(grepl("CVP LINE|CATHETER TIP|TIP", SourceName))

pre_inter_data <- filtered_data %>%
  filter(as.Date(Collection.Date, "%m/%d/%y") >= as.Date("2023-03-08") &
           as.Date(Collection.Date, "%m/%d/%y") <= as.Date("2023-05-17"))

post_inter_data <- filtered_data %>%
  filter(as.Date(Collection.Date, "%m/%d/%y") >= as.Date("2023-08-01") &
           as.Date(Collection.Date, "%m/%d/%y") <= as.Date("2023-10-14"))

bac_pre_inter_data <- pre_inter_data %>%
  mutate(Bacterial_Growth = ifelse(OrganismName == "No bacterial growth", "No", "Yes"))

bac_post_inter_data <- post_inter_data %>%
  mutate(Bacterial_Growth = ifelse(OrganismName == "No bacterial growth", "No", "Yes"))

pre_summary_table <- table(bac_pre_inter_data$Bacterial_Growth)
pre_proportion_yes <- pre_summary_table[["Yes"]] / sum(pre_summary_table)

post_summary_table <- table(bac_post_inter_data$Bacterial_Growth)
post_proportion_yes <- post_summary_table[["Yes"]] / sum(post_summary_table)

pre_proportions <- bac_pre_inter_data %>%
  group_by(SourceName, Bacterial_Growth) %>%
  summarise(count = n(), .groups = 'drop') %>%
  complete(SourceName, Bacterial_Growth, fill = list(count = 0)) %>%
  mutate(pre_prop = count / sum(count))

pre_proportions_plot <- ggplot(pre_proportions, aes(x = SourceName, y = pre_prop, fill = Bacterial_Growth)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(title = "Pre-Interventions Proportion of Bacterial Growth by SourceName",
       y = "Proportion",
       x = "SourceName",
       fill = "Bacterial Growth")

post_proportions <- bac_post_inter_data %>%
  group_by(SourceName, Bacterial_Growth) %>%
  summarise(count = n(), .groups = 'drop') %>%
  complete(SourceName, Bacterial_Growth, fill = list(count = 0)) %>%
  mutate(post_prop = count / sum(count))

post_proportions_plot <- ggplot(post_proportions, aes(x = SourceName, y = post_prop, fill = Bacterial_Growth)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(title = "Post-Interventions Proportion of Bacterial Growth by SourceName",
       y = "Proportion",
       x = "SourceName",
       fill = "Bacterial Growth")

bac_pre_inter_data$Collection.Date <- as.Date(bac_pre_inter_data$Collection.Date, format = "%m/%d/%Y")

pre_proportions <- bac_pre_inter_data %>%
  group_by(Collection.Date, Bacterial_Growth) %>%
  summarise(count = n()) %>%
  mutate(pre_prop = count / sum(count))

bac_post_inter_data$Collection.Date <- as.Date(bac_post_inter_data$Collection.Date, format = "%m/%d/%Y")

post_proportions <- bac_post_inter_data %>%
  group_by(Collection.Date, Bacterial_Growth) %>%
  summarise(count = n()) %>%
  mutate(post_prop = count / sum(count))

bac_both_inter_data <- filtered_data %>%
  mutate(Bacterial_Growth = ifelse(OrganismName == "No bacterial growth", "No", "Yes"))

both_summary_table <- table(bac_both_inter_data$Bacterial_Growth)
both_proportion_yes <- both_summary_table[["Yes"]] / sum(both_summary_table)

both_proportions <- bac_both_inter_data %>%
  group_by(SourceName, Bacterial_Growth) %>%
  summarise(count = n(), .groups = 'drop') %>%
  complete(SourceName, Bacterial_Growth, fill = list(count = 0)) %>%
  mutate(both_prop = count / sum(count))

both_proportions_plot <- ggplot(both_proportions, aes(x = SourceName, y = both_prop, fill = Bacterial_Growth)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(title = "Both-Interventions Proportion of Bacterial Growth by SourceName",
       y = "Proportion",
       x = "SourceName",
       fill = "Bacterial Growth")

bac_both_inter_data$Collection.Date <- as.Date(bac_both_inter_data$Collection.Date, format = "%m/%d/%Y")

both_proportions <- bac_both_inter_data %>%
  group_by(Collection.Date, Bacterial_Growth) %>%
  summarise(count = n()) %>%
  mutate(both_prop = count / sum(count))

both_proportions_line_plot <- ggplot(both_proportions, aes(x = Collection.Date, y = both_prop, color = Bacterial_Growth)) +
  geom_line() +
  labs(title = "Both-Interventions Proportion of Bacterial Growth Over Time",
       y = "Proportion",
       x = "Collection Date",
       color = "Bacterial Growth")

# code for perception surveys
nurses_perception_HH <- read.csv("./nurses_perception_HH.csv", check.names = FALSE)
nurses_survey_efficacy <- read.csv("./nurses_survey_efficacy.csv", check.names = FALSE)
nurses_survey_HH <- read.csv("./nurses_survey_HH.csv", check.names = FALSE)
nurses_survey_value <- read.csv("./nurses_survey_value.csv", check.names = FALSE)

# code for HH plot
hh <- read.csv("./HHPerception_Reality.csv")
numeric_cols <- Filter(is.numeric, hh)
averages <- colMeans(numeric_cols, na.rm = TRUE)
colors <- c("#F4A582", "#4393C3", "#F4A582", "#4393C3")

# code for T test


server <- function(input, output) {
  output$plotPreCLABSI <- renderPlot({
    pre_proportions_plot
  })
  output$plotPostCLABSI <- renderPlot({
    post_proportions_plot
  })
  
  output$plotCLABSI <- renderPlot({
    both_proportions_plot
  })
  
  output$plotLineCLABSI <- renderPlot({
    both_proportions_line_plot
  })
  
  output$plotHHWard <- renderPlot({
    ward_plot
  })
  
  output$plotHH5M <- renderPlot({
    indication_plot
  })

  output$tableNursesPerceptionHH <- renderTable({
    nurses_perception_HH
  })

  output$tableNursesSurveyEfficacy <- renderTable({
    nurses_survey_efficacy
  })

  output$tableNursesSurveyHH <- renderTable({
    nurses_survey_HH
  })

  output$tableNursesSurveyValue <- renderTable({
    nurses_survey_value
  })
  
  output$plotHH <- renderPlot({
    barplot(averages,
            main = "Average Hand Hygiene Perceived And Actual Compliance Rates Across Nurses",
            xlab = "Time of Survey and Sample",
            ylab = "Average Percentage of Hand Hygiene Compliance",
            col = colors,
            border = "black",
            ylim = c(0, max(averages)*1.2), 
            las = 1)
    
    bar_centers <- barplot(averages, plot = FALSE)
    rounded_values <- round(averages, digits = 2)
    text(x = bar_centers, y = averages, labels = paste0(rounded_values, "%"), pos = 3, cex = 0.8, col = "black")
  })

}

shinyApp(ui = ui, server = server)