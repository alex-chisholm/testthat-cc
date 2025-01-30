library(shiny)
library(bslib)
library(testthat)

ui <- page_sidebar(
  title = "Interactive testthat Demo",
  sidebar = sidebar(
    textAreaInput("function_code", "Function to Test:", 
                  value = 'add_numbers <- function(a, b) {\n  a + b\n}',
                  height = "100px"),
    textAreaInput("test_code", "Test Case:", 
                  value = 'test_that("addition works", {\n  expect_equal(add_numbers(2, 2), 4)\n  expect_equal(add_numbers(-1, 1), 0)\n})',
                  height = "100px"),
    actionButton("run_test", "Run Tests", class = "btn-primary")
  ),
  
  card(
    card_header("Test Results"),
    card_body(
      verbatimTextOutput("test_results")
    )
  )
)

server <- function(input, output, session) {
  
  run_tests <- eventReactive(input$run_test, {
    # Create a new environment to evaluate the function
    test_env <- new.env()
    
    # Try to evaluate the function in the new environment
    tryCatch({
      eval(parse(text = input$function_code), envir = test_env)
      
      # Run the tests and capture output
      test_output <- capture_output({
        eval(parse(text = input$test_code), envir = test_env)
      })
      
      if (test_output == "") {
        return("All tests passed!")
      } else {
        return(test_output)
      }
      
    }, error = function(e) {
      return(paste("Error:", e$message))
    })
  })
  
  output$test_results <- renderText({
    run_tests()
  })
}

shinyApp(ui, server)
