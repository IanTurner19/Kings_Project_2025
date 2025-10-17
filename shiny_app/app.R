# install.packages(c("shiny","dplyr","DT","plotly"))  # if needed
library(shiny)
library(dplyr)
library(DT)
library(plotly)

# load the data that lives next to app.R on the server
intl_per_game <- read.csv("intl_per_game.csv", check.names = FALSE)


# --- assume intl_per_game already exists with percentiles, *_tier, nba_probability ---
# Build/ensure a single consistent defense metric: defense_percentile
players <- intl_per_game %>%
  mutate(
    defense_percentile = if ("defense_percentile" %in% names(intl_per_game)) {
      defense_percentile
    } else {
      # Fallback: average of block and (optional) steal percentiles if present
      rowMeans(cbind(
        shot_blocker_percentile,
        if ("steal_percentile" %in% names(intl_per_game)) steal_percentile else NA_real_
      ), na.rm = TRUE)
    }
  ) %>%
  dplyr::select(
    first_name, last_name, age, nba_experience, most_recent_year,
    games, minutes, nba_probability,
    scorer_percentile, post_scorer_percentile, rebounder_percentile,
    facilitator_percentile, shot_blocker_percentile, floor_spacer_percentile,
    defense_percentile,
    scorer_tier, post_scorer_tier, rebounder_tier,
    facilitator_tier, shot_blocker_tier, floor_spacer_tier,
    dplyr::any_of(c("currently_in_nba"))  # optional
  )

# Dropdown mapping for 3D axis choices
percentile_cols <- c(
  "Scorer"        = "scorer_percentile",
  "Post Scorer"   = "post_scorer_percentile",
  "Rebounder"     = "rebounder_percentile",
  "Facilitator"   = "facilitator_percentile",
  "Rim Protector" = "shot_blocker_percentile",
  "Floor Spacer"  = "floor_spacer_percentile",
  "Defensive"     = "defense_percentile"
)

ui <- fluidPage(
  titlePanel("Kings Player Finder"),
  sidebarLayout(
    sidebarPanel(
      textInput("q", "Search name", ""),
      sliderInput("age_max","Max age", min = 16, max = 45, value = 30, step = 1),
      sliderInput("min_games","Min games", min = 0, max = 82, value = 10, step = 1),
      sliderInput("min_minutes","Min minutes", min = 0, max = 40, value = 15, step = 1),
      
      radioButtons(
        "nba_status", "NBA status",
        choices = c("Any" = "any", "NBA only" = "nba_only", "Not currently in NBA" = "not_nba"),
        selected = "any", inline = TRUE
      ),
      checkboxInput("nba_ready","NBA ready (nba_probability > 0.5)", FALSE),
      
      tags$hr(),
      h4("Archetype filters (percentile mins)"),
      sliderInput("min_scorer", "Scorer",         0, 100, 0, step = 5),
      sliderInput("min_post",   "Post Scorer",    0, 100, 0, step = 5),
      sliderInput("min_reb",    "Rebounder",      0, 100, 0, step = 5),
      sliderInput("min_fac",    "Facilitator",    0, 100, 0, step = 5),
      sliderInput("min_block",  "Rim Protector",  0, 100, 0, step = 5),
      sliderInput("min_space",  "Floor Spacer",   0, 100, 0, step = 5),
      sliderInput("min_def",    "Defense",        0, 100, 0, step = 5),
      
      tags$hr(),
      h4("Quick presets"),
      actionButton("preset_big","Two-way Big (post+block+reb 70+)"),
      actionButton("preset_guard","Lead Guard (facil+scorer 85+)"),
      actionButton("preset_3nd","3-and-D Wing (space 80+, block 60+)"),
      
      tags$hr(),
      downloadButton("dl", "Download CSV")
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Finder (Table)", DTOutput("tbl")),
        tabPanel("3D Graph",
                 fluidRow(
                   column(4, selectInput("x_var", "X axis", choices = percentile_cols, selected = "post_scorer_percentile")),
                   column(4, selectInput("y_var", "Y axis", choices = percentile_cols, selected = "shot_blocker_percentile")),
                   column(4, selectInput("z_var", "Z axis", choices = percentile_cols, selected = "rebounder_percentile"))
                 ),
                 plotlyOutput("p3d", height = "620px"),
                 helpText("Top 3 by the mean of selected axes are highlighted in orange and labeled. Only players with most_recent_year >= 2019 are shown.")
        )
      )
    )
  )
)

server <- function(input, output, session){
  
  # Presets
  observeEvent(input$preset_big, {
    updateSliderInput(session,"min_post",  value = 70)
    updateSliderInput(session,"min_block", value = 70)
    updateSliderInput(session,"min_reb",   value = 70)
  })
  observeEvent(input$preset_guard, {
    updateSliderInput(session,"min_fac",   value = 85)
    updateSliderInput(session,"min_scorer",value = 85)
  })
  observeEvent(input$preset_3nd, {
    updateSliderInput(session,"min_space", value = 80)
    updateSliderInput(session,"min_block", value = 60)
  })
  
  # Core filtered data
  filtered <- reactive({
    df <- players %>%
      filter(!is.na(most_recent_year) & most_recent_year >= 2019) %>%
      filter(
        is.na(age) | age <= input$age_max,
        games >= input$min_games,
        minutes >= input$min_minutes,
        scorer_percentile       >= input$min_scorer,
        post_scorer_percentile  >= input$min_post,
        rebounder_percentile    >= input$min_reb,
        facilitator_percentile  >= input$min_fac,
        shot_blocker_percentile >= input$min_block,
        floor_spacer_percentile >= input$min_space,
        defense_percentile      >= input$min_def
      )
    
    # NBA status
    if (input$nba_status == "nba_only") {
      df <- df %>% filter(if ("currently_in_nba" %in% names(.)) currently_in_nba else nba_experience)
    } else if (input$nba_status == "not_nba") {
      df <- df %>% filter(if ("currently_in_nba" %in% names(.)) !currently_in_nba else !nba_experience)
    }
    
    # NBA ready threshold
    if (input$nba_ready) df <- df %>% filter(!is.na(nba_probability) & nba_probability > 0.5)
    
    # Name search
    if (nzchar(input$q)) {
      pat <- tolower(input$q)
      df <- df %>%
        mutate(full_name = paste(first_name, last_name)) %>%
        filter(grepl(pat, tolower(full_name), fixed = TRUE)) %>%
        select(-full_name)
    }
    
    df %>%
      mutate(
        big_balance = rowMeans(cbind(post_scorer_percentile,
                                     shot_blocker_percentile,
                                     rebounder_percentile), na.rm = TRUE),
        guard_score = rowMeans(cbind(facilitator_percentile,
                                     scorer_percentile), na.rm = TRUE)
      ) %>%
      arrange(desc(pmax(big_balance, guard_score, scorer_percentile)))
  })
  
  output$tbl <- renderDT({
    datatable(
      filtered(),
      options = list(pageLength = 25, scrollX = TRUE),
      rownames = FALSE
    )
  })
  
  # 3D plot with selectable axes & top-3 highlight
  output$p3d <- renderPlotly({
    df <- filtered()
    req(nrow(df) > 0)
    
    xcol <- input$x_var; ycol <- input$y_var; zcol <- input$z_var
    
    df <- df %>%
      mutate(
        axes_mean = rowMeans(cbind(.data[[xcol]], .data[[ycol]], .data[[zcol]]), na.rm = TRUE)
      ) %>%
      arrange(desc(axes_mean)) %>%
      mutate(
        rank_axes = row_number(),
        is_top3   = rank_axes <= 3
      )
    
    has_prob <- "nba_probability" %in% names(df)
    
    df <- df %>%
      mutate(
        label = paste0(
          first_name, " ", last_name,
          "<br>Age: ", age,
          " | G: ", games, " | Min: ", minutes,
          "<br>", names(percentile_cols)[percentile_cols == xcol], ": ", round(.data[[xcol]]),
          "<br>", names(percentile_cols)[percentile_cols == ycol], ": ", round(.data[[ycol]]),
          "<br>", names(percentile_cols)[percentile_cols == zcol], ": ", round(.data[[zcol]]),
          if (has_prob) paste0("<br>NBA Prob: ", sprintf("%.2f", nba_probability)) else ""
        )
      )
    
    df_top  <- df %>% filter(is_top3)
    df_rest <- df %>% filter(!is_top3)
    
    p <- plot_ly(type = "scatter3d", mode = "markers")
    
    if (nrow(df_rest) > 0) {
      p <- add_trace(
        p, data = df_rest,
        x = ~.data[[xcol]], y = ~.data[[ycol]], z = ~.data[[zcol]],
        text = ~label, hoverinfo = "text",
        marker = list(size = 4),
        name = "Others", showlegend = TRUE
      )
    }
    
    if (nrow(df_top) > 0) {
      p <- add_trace(
        p, data = df_top,
        x = ~.data[[xcol]], y = ~.data[[ycol]], z = ~.data[[zcol]],
        text = ~label, hoverinfo = "text",
        marker = list(size = 7, color = "orange", line = list(width = 1)),
        name = "Top 3 (by selected axes)", showlegend = TRUE
      ) %>%
        add_text(
          data = df_top,
          x = ~.data[[xcol]], y = ~.data[[ycol]], z = ~.data[[zcol]],
          text = ~paste(first_name, last_name),
          textposition = "top center",
          showlegend = FALSE
        )
    }
    
    p %>% layout(
      scene = list(
        xaxis = list(title = names(percentile_cols)[percentile_cols == xcol]),
        yaxis = list(title = names(percentile_cols)[percentile_cols == ycol]),
        zaxis = list(title = names(percentile_cols)[percentile_cols == zcol])
      )
    )
  })
  
  output$dl <- downloadHandler(
    filename = function() paste0("kings_player_finder_", Sys.Date(), ".csv"),
    content = function(file) write.csv(filtered(), file, row.names = FALSE)
  )
}

shinyApp(ui, server)
