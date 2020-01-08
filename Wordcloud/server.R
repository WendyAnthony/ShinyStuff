# # http://www.baoruidata.com/examples/082-word-cloud/
# Text of the books downloaded from:
# A Mid Summer Night's Dream:
#  http://www.gutenberg.org/cache/epub/2242/pg2242.txt
# The Merchant of Venice:
#  http://www.gutenberg.org/cache/epub/2243/pg2243.txt
# Romeo and Juliet:
#  http://www.gutenberg.org/cache/epub/1112/pg1112.txt
# Roughing it in the Bush by Susanna Moodie
# http://www.gutenberg.org/cache/epub/4389/pg4389.txt
# Walden, and On The Duty Of Civil Disobedience by Henry David Thoreau
# http://www.gutenberg.org/files/205/205-0.txt
# An Inquiry into the Nature and Causes of the Wealth of Nations by Adam Smith
# http://www.gutenberg.org/files/3300/3300-0.txt


function(input, output, session) {
  # Define a reactive expression for the document term matrix
  terms <- reactive({
    # Change when the "update" button is pressed...
    input$update
    # ...but not for anything else
    isolate({
      withProgress({
        setProgress(message = "Processing corpus...")
        getTermMatrix(input$selection)
      })
    })
  })
  
  # Make the wordcloud drawing predictable during a session
  wordcloud_rep <- repeatable(wordcloud)
  
  output$plot <- renderPlot({
    v <- terms()
    wordcloud_rep(names(v), v, scale=c(4,0.5),
                  min.freq = input$freq, max.words=input$max,
                  colors=brewer.pal(8, "Dark2"), random.order = FALSE)
    # colors=brewer.pal(8, "Dark2"))
    # colors=brewer.pal(11, "Spectral")
  })
  
  # https://gallery.shinyapps.io/016-knitr-pdf/
#  output$downloadReport <- downloadHandler(
#    filename = function() {
#      paste('my-report', sep = '.', switch(
  #        input$format, PDF = 'pdf', HTML = 'html', Word = 'docx'
  #      ))
  #    },
    
  #    content = function(file) {
  #      src <- normalizePath('report.Rmd')
      
      # temporarily switch to the temp dir, in case you do not have write
      # permission to the current working directory
  #   owd <- setwd(tempdir())
  #    on.exit(setwd(owd))
  #    file.copy(src, 'report.Rmd', overwrite = TRUE)
      
  #    library(rmarkdown)
  #    out <- render('report.Rmd', switch(
  #      input$format,
  #      PDF = pdf_document(), HTML = html_document(), Word = word_document()
  #    ))
  #    file.rename(out, file)
  #  }
#  )
}