library(shiny)
library(shinyjs)
library(TakuzuKL)

# Valid grids via zzz.R:
grids <- get_grids()

ui <- fluidPage(
  useShinyjs(),
  tags$head(tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")),
  uiOutput("welcome_ui"),
  uiOutput("choose_ui"),
  uiOutput("rules_ui"),
  uiOutput("game_ui"),
  uiOutput("victory_ui"),

  tags$audio(id = "audio_menu", src = "audio/menu_music.mp3", type = "audio/mp3", autoplay = FALSE, controls = FALSE),
  tags$audio(id = "audio_victory", src = "audio/victory.mp3", type = "audio/mp3", autoplay = FALSE, controls = FALSE),
  tags$audio(id = "audio_level_easy", src = "audio/level_easy.mp3", type = "audio/mp3", autoplay = FALSE, controls = FALSE),
  tags$audio(id = "audio_level_medium", src = "audio/level_medium.mp3", type = "audio/mp3", autoplay = FALSE, controls = FALSE),
  tags$audio(id = "audio_level_hard", src = "audio/level_hard.mp3", type = "audio/mp3", autoplay = FALSE, controls = FALSE)
)

server <- function(input, output, session) {

  game_data <- reactiveValues(grid = NULL, solution = NULL, observed = FALSE,
                              start_time = NULL, timer_active = FALSE, final_time = "00:00")

  stop_all_music <- function() {
    shinyjs::runjs('
      var audios = document.querySelectorAll("audio");
      audios.forEach(function(audio) {
        audio.pause();
        audio.currentTime = 0;
    });
  ')
  }

  play_audio <- function(audio_id) {
    shinyjs::runjs(sprintf('
    var audios = document.querySelectorAll("audio");
    audios.forEach(function(audio) {
      audio.pause();
      audio.currentTime = 0;
    });

    var targetAudio = document.getElementById("%s");
    if (targetAudio) {
      targetAudio.currentTime = 0;
      targetAudio.play();
    }
  ', audio_id))
  }

  # Welcome UI
  output$welcome_ui <- renderUI({
    tagList(
      # Add a centered .png title:
      img(src = "title_1.png", class = "title-img"),
      div(class = "btn-container",
          # Add three action buttons for navigation:
          actionButton("play", "PLAY", class = "btn btn-custom"),
          actionButton("how_to_play", "HOW TO PLAY?", class = "btn btn-custom"),
          actionButton("exit", "EXIT", class = "btn btn-custom")
      )
    )
  })

  # Rules UI
  output$rules_ui <- renderUI({
    tagList(
      div(class = "rules-container",
          # Add a centered .png rules:
          img(src = "rules.png", class = "rules-img"),
          # Add an action button for navigation:
          actionButton("return_from_rules", "RETURN", class = "btn btn-custom rules-button")
      )
    )
  })

  # Choose Board UI
  output$choose_ui <- renderUI({
    tagList(
      # Show a panel with two radio buttons to choose board size and difficulty level:
      div(class = "panel-custom",
          radioButtons("board_size", "Choose Board Size:",
                       choices = c("4x4", "6x6", "8x8"),
                       selected = "6x6"),
          radioButtons("difficulty", "Choose Difficulty Level:",
                       choices = c("Easy", "Medium", "Hard"),
                       selected = "Medium")          # 6x6 - Medium is the pre-selected settings
      ),
      # Add two action button below for navigation:
      div(class = "button-container",
          actionButton("start_game", "START GAME", class = "btn btn-custom"),
          actionButton("return", "RETURN", class = "btn btn-custom")
      )
    )
  })


 # Game Timer
  output$game_timer <- renderText({
    if (isTRUE(game_data$timer_active) && !is.null(game_data$start_time)) {
      invalidateLater(1000)
      format(.POSIXct(difftime(Sys.time(), game_data$start_time, units = "secs"), tz = "GMT"), "%M:%S")
    } else {
      "00:00"
    }
  })

  # Game UI
  output$game_ui <- renderUI({
    req(game_data$grid)

    # Retrieve grid size in order to create IDs:
    n <- nrow(game_data$grid)

    # Cells are a distinct color depending on difficulty:
    cell_color <- switch(input$difficulty,
                         "Easy" = "easy",
                         "Medium" = "medium",
                         "Hard" = "hard")

    tagList(
      div(class = "game-container",
          # Add a centered .png container with a distinct color depending on difficulty:
          div(class = "difficulty-img-container",
              img(src = switch(input$difficulty,
                               "Easy" = "easy_mode.png",
                               "Medium" = "medium_mode.png",
                               "Hard" = "hard_mode.png"),
                  class = "difficulty-img")
          ),
          div(class = "game-grid",
              do.call(tagList, lapply(1:n, function(i) {

                # Create an ID for each cell:
                div(lapply(1:n, function(j) {
                  btn_id <- paste0("cell_", i, "_", j)
                  value <- game_data$grid[i, j]

                  # Only blank (2) cells can be edited:
                  is_editable <- game_data$original_grid[i, j] == 2

                  # Editable cells are turned as action buttons with color schemes:
                  actionButton(
                    btn_id,
                    label = ifelse(value == 2, "", value),
                    class = ifelse(is_editable, paste0("cell-editable ", cell_color), paste0("cell-fixed ", cell_color))
                  )
                })
                )
              }))
          ),

          div(class = "game-controls-container",
              div(class = "game-timer", textOutput("game_timer")),
              actionButton("toggle_music",
                           tags$img(src = "volume-up.png", height = "20px", width = "20px"),
                           class = "btn btn-custom"),
              actionButton("check_solution", "CHECK", class = "btn btn-custom"),
              actionButton("solve_grid", "SOLVE", class = "btn btn-custom"),
              actionButton("return_to_menu", "QUIT", class = "btn btn-custom")
          )
      )
    )
  })


  # Handle Game Start
  observeEvent(input$start_game, {

    game_data$start_time <- Sys.time()
    game_data$timer_active <- TRUE

    # Retrieve chosen grid size:
    grid_size <- as.integer(strsplit(input$board_size, "x")[[1]][1])
    # Randomly pick grid from grids of chosen size:
    grid_name <- paste0("grids_", grid_size)
    chosen_grid <- as.matrix(sample(grids[[grid_name]], 1)[[1]])

    # Save picked grid as solution
    game_data$solution <- chosen_grid
    difficulty_level <- switch(input$difficulty,
                               "Easy" = 0.25,
                               "Medium" = 0.5,
                               "Hard" = 0.75)
    # Randomly hide (turn 0 or 1 to 2) cells depending on difficulty:
    game_data$grid <- hide_by_difficulty(difficulty_level, chosen_grid)
    game_data$original_grid <- game_data$grid

    # JavaScript navigation:
    shinyjs::hide("choose_ui")
    shinyjs::show("game_ui")

    # Start music when the game starts:
    audio_id <- switch(input$difficulty,
                       "Easy" = "audio_level_easy",
                       "Medium" = "audio_level_medium",
                       "Hard" = "audio_level_hard")
    play_audio(audio_id)
  })

  # Handle Playable Cells
  observe({
    req(game_data$grid)

    # Retrieve grid size in order to create IDs:
    n <- nrow(game_data$grid)

    # Create an ID for each editable cell:
    for (i in seq_len(n)) {
      for (j in seq_len(n)) {
        if (game_data$grid[i, j] == 2) {
          local({
            ii <- i
            jj <- j
            btn_id <- paste0("cell_", ii, "_", jj)

            observeEvent(input[[btn_id]], {
              isolate({
                # Cell selected switch from 2 to 1, from 1 to 0, from 0 to 2:
                current_val <- game_data$grid[ii, jj]
                new_val <- switch(as.character(current_val),
                                  "2" = 1,
                                  "1" = 0,
                                  "0" = 2)
                game_data$grid[ii, jj] <- new_val

                # Ensure the selected cell remains editable:
                updateActionButton(session, btn_id,
                                   label = ifelse(new_val == 2, "", as.character(new_val)))
              })
            }, ignoreInit = TRUE, ignoreNULL = TRUE)
          })
        }
      }
    }
  })


  # Handle Solution Check
  observeEvent(input$check_solution, {
    req(game_data$grid, game_data$solution)

    # If the grid is correct, navigate to Victory UI:
    if (all(game_data$grid == game_data$solution)) {

      # Record the final time:
      secs <- as.numeric(difftime(Sys.time(), game_data$start_time, units = "secs"))
      game_data$final_time <- paste0(
        formatC(secs %/% 60, width = 2, flag = "0"),
        ":",
        formatC(secs %% 60, width = 2, flag = "0")
      )
      game_data$timer_active <- FALSE

      play_audio("audio_victory")

      shinyjs::hide("game_ui")
      shinyjs::show("victory_ui")
    } else {
      # If the grid is not correct, show modal to encourage user:
      showModal(modalDialog(
        title = "Incorrect",
        "The grid is not solved correctly. Keep trying!"
      ))
    }
  })

  # Share Solution
  observeEvent(input$solve_grid, {
    req(game_data$grid, game_data$solution)

    # Replace the playable grid with the saved solution:
    game_data$grid <- game_data$solution

    # Show a modal with a navigation action button:
    showModal(modalDialog(
      title = "Nice try",
      "Let's try another one!",
      easyClose = TRUE,
      footer = tagList(
        actionButton("return_to_menu_modal", "RETURN TO MENU")
      )
    ))
  })


  # Checking music
  observeEvent(input$toggle_music, {
    current_audio <- if (!is.null(game_data$grid)) {
      switch(input$difficulty,
             "Easy" = "audio_level_easy",
             "Medium" = "audio_level_medium",
             "Hard" = "audio_level_hard")
    } else {
      "audio_menu"
    }

    shinyjs::runjs(sprintf('
      var audio = document.getElementById("%s");
      if (audio.paused) {
        audio.play();
      } else {
        audio.pause();
      }
    ', current_audio))
  })


  # Victory UI
  output$victory_ui <- renderUI({
    req(game_data$grid)
    tagList(
      div(class = "rules-container",
          # Add a centered .png victory:
          img(src = "victory.png", class = "rules-img"),
          div(
            HTML(paste0(
            # Add a message with the recorded timer:
            "Congratulations!<br>",
            "You solved the puzzle in ", game_data$final_time, "!<br><br>")),
            class = "victory-message"
          ),
          # Add an action button for navigation:
          actionButton("return_to_menu_victory", "RETURN TO MENU", class = "btn btn-custom rules-button")
      )
    )
  })

  # Handle UI Navigation
  shinyjs::hide("choose_ui")
  shinyjs::hide("rules_ui")
  shinyjs::hide("game_ui")
  shinyjs::hide("victory_ui")


  observeEvent(input$play, {
    play_audio("audio_menu")
    shinyjs::hide("welcome_ui")
    shinyjs::show("choose_ui")
  })

  observeEvent(input$how_to_play, {
    shinyjs::hide("welcome_ui")
    shinyjs::show("rules_ui")
  })


  observeEvent(input$return, {
    play_audio("audio_menu")
    shinyjs::hide("choose_ui")
    shinyjs::show("welcome_ui")
  })


  observeEvent(input$return_from_rules, {
    shinyjs::hide("rules_ui")
    shinyjs::show("welcome_ui")
  })


  observeEvent(input$return_to_menu_victory, {
    play_audio("audio_menu")
    shinyjs::hide("victory_ui")
    shinyjs::show("choose_ui")
    game_data$timer_active <- FALSE
  })


  observeEvent(input$return_to_menu, {
    play_audio("audio_menu")
    shinyjs::hide("game_ui")
    shinyjs::show("choose_ui")
    game_data$timer_active <- FALSE
  })


  observeEvent(input$return_to_menu_modal, {
    play_audio("audio_menu")
    removeModal()

    shinyjs::hide("game_ui")
    shinyjs::show("choose_ui")
  })


  observe({
    if (is.null(input$play) || input$play == 0) {
      play_audio("audio_menu")
    }
  })

  # Exit game:
  observeEvent(input$exit, {
    stopApp()
  })
}



shinyApp(ui, server)
