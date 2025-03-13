library(shiny)
library(shinyjs)

ui <- fluidPage(
  useShinyjs(),
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")
  ),
  uiOutput("welcome_ui"),
  uiOutput("choose_ui"),
  uiOutput("rules_ui"),
  uiOutput("game_ui")
  #CREATE VICTORY WINDOW UI
)

server <- function(input, output, session) {

  output$welcome_ui <- renderUI({
    tagList(
      img(src = "title.png", class = "title-img"),
      div(class = "btn-container",
          actionButton("play", "PLAY", class = "btn btn-custom"),
          actionButton("how_to_play", "HOW TO PLAY?", class = "btn btn-custom"),
          actionButton("exit", "EXIT", class = "btn btn-custom")
      )
    )
  })

  output$choose_ui <- renderUI({
    tagList(
      div(class = "panel-custom",
          div(
            radioButtons("board_size", "Choose Board Size:",
                         choices = c("4x4", "6x6", "8x8"),
                         selected = "6x6")
          ),
          div(
            radioButtons("difficulty", "Choose Difficulty Level:",
                         choices = c("Easy", "Medium", "Hard"),
                         selected = "Medium")
          )
      ),
      div(class = "button-container",
          actionButton("start_game", "START GAME", class = "btn btn-custom"),
          actionButton("return", "RETURN", class = "btn btn-custom")
      )
    )
  })

  output$rules_ui <- renderUI({
    tagList(
      div(class = "rules-container",
          img(src = "rules.png", class = "rules-img"), #TO TEST
          actionButton("return_from_rules", "RETURN", class = "btn btn-custom")
      )
    )
  })

  output$game_ui <- renderUI({
    tagList(
      div(class = "game-container",
          div(class = "difficulty-img-container",
              img(src = switch(input$difficulty,
                               "Easy" = "easy_mode.png",
                               "Normal" = "normal_mode.png",
                               "Hard" = "hard_mode.png"),
                  class = "difficulty-img")
          ),

          div(class = "game-btn-container",
              actionButton("solver", "SOLVE", class = "btn btn-custom"),
              actionButton("return_to_menu", "QUIT", class = "btn btn-custom")
          )
      ),

      div(class = "game-grid",
          h3("GAME GRID"),
          # GAME LOGIC TO DO
      )
    )
  })

  shinyjs::hide("choose_ui")
  shinyjs::hide("rules_ui")
  shinyjs::hide("game_ui")

  observeEvent(input$play, {
    shinyjs::hide("welcome_ui")
    shinyjs::show("choose_ui")
  })

  observeEvent(input$how_to_play, {
    shinyjs::hide("welcome_ui")
    shinyjs::show("rules_ui")
  })

  observeEvent(input$return, {
    shinyjs::hide("choose_ui")
    shinyjs::show("welcome_ui")
  })

  observeEvent(input$return_from_rules, {
    shinyjs::hide("rules_ui")
    shinyjs::show("welcome_ui")
  })

  observeEvent(input$start_game, {
    shinyjs::hide("choose_ui")
    shinyjs::show("game_ui")
  })

  observeEvent(input$return_to_menu, {
    shinyjs::hide("game_ui")
    shinyjs::show("choose_ui")
  })

  observeEvent(input$exit, {
    stopApp()
  })
}

shinyApp(ui, server)


