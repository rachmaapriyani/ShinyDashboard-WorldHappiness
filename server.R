function(input, output, session) {
  
  # World Map page 
  ## Create reactive data frame to use for world map and data table
  
  react_data <- reactive({
    map_happiness = happiness %>%
      select(c('year','Score','Country','code',input$happiness_features,'Dystopia.Residual')) %>%
      filter(year == input$worldmap_year)
    
    map_happiness %>%
      mutate(Score = rowSums(.[5:length(map_happiness)], na.rm=TRUE)) %>%
      arrange(desc(Score))
  })
  
  ## Create output plot of world map
  output$worldmap <- renderPlotly({
    react_data() %>%
      plot_geo() %>%
          add_trace(z = ~Score,
                    zmin = 0,
                    zmax = max(map_happiness$Score),
                    color = ~Score,
                    colors = 'Blues',
                    colorscale = 'Electric',
                    text = ~Country,  
                    locations = ~code, 
                    marker = list(line = l)
          ) %>%
          colorbar(title = 'Score') %>%
          layout(title = 'Happiness Score 2017-2020' ,geo = g)
  })
  
  ## Create output data table from reactive data frame
  output$data_happiness = renderDataTable({
    react_data() %>%
      select(-code)
  })
  
  
  
  # Explore page Correlation tab
  
  ## Create reactive data frame for scatter plots
  happiness_scatter = reactive({
    happiness_scatter = happiness %>%
      filter(year %in% as.numeric(input$variables_year))
         
  })
  
  ## Create output scatter plot 
  output$scatter = renderPlotly(
    happiness_scatter() %>%
      plot_ly(x= ~get(input$var1), 
              y= ~get(input$var2),
              color= ~continent,
              text= ~paste("Country: ",Country, "\nYear: ",year),
              type='scatter',
              mode='markers'
              ) %>%
      add_trace(x= ~get(input$var1),
                y=fitted(lm(get(input$var2)~get(input$var1), data=happiness_scatter())),
                color='',
                mode = "lines",
                name = 'Predicted') %>%
      layout(
        title = paste(input$var1, 'vs', input$var2),
        xaxis = list(title = input$var1),
        yaxis = list(title = input$var2)
      )
  )
  
  ## output for correlation
  output$correlation = renderText({
    x=happiness_scatter() %>%
      select(input$var1)
    y=happiness_scatter() %>%
      select(input$var2)
    corr = round(cor(x, y), digits = 5)
    
    paste('Correlation:',as.character(corr))
  })
  
  
  # Explore page Trends tab
  ## Create output line graph for yearly trend
  
  output$trend = renderPlotly(
    happiness %>%
      filter(Country %in% input$countries,
             year %in% as.numeric(input$trends_variables_year)) %>%
      plot_ly(x=~year,
              y=~get(input$trend_variable), 
              color=~Country,
              type='scatter',
              mode='lines',
              text = ~paste("Country: ",Country)) %>%
      layout(
        title = paste("Trend", input$trend_variable,"by Year"),
        yaxis = list(title = input$trend_variable),
        xaxis = list(title = 'Year',
                     dtick=1)
      )
  )
  output$trend_table = renderDataTable({
    start = happiness %>%
      filter(year == input$trends_variables_year[1]) %>%
      select('Score','code','Country')
    
    end = happiness %>%
      filter(year == tail(input$trends_variables_year,n=1)) %>%
      select('Score','code','Country')
    
    merge(start, end, by='code') %>%
      mutate(ChangeValue=round(Score.y-Score.x,5)) %>%
      select(Country.x,ChangeValue) %>%
      rename(Country = Country.x) %>%
      arrange(desc(ChangeValue))
  })
  
  
  
  # Explore page Regions tab
  ## Regional bar chart
  
  output$regional = renderPlotly({
    react_regional() %>%
      plot_ly(x= ~get(input$region_or_continent), 
              y= ~Score,
              type='bar'
              
      ) %>%
      layout(
        title = paste('Scores by',input$region_or_continent),
        xaxis = list(title = input$region_or_continent),
        yaxis = list(title = 'Score')
      )
     
      
  })
  ## Regional reactive
  
  react_regional <- reactive({
    regional_happiness <-  happiness%>%
      select(c('year','sub_region','continent','Score','Country','code',input$regional_features,'Dystopia.Residual')) %>%
      filter(year == input$regional_year)
    
    
    regional_happiness <- regional_aggregate %>%
      group_by_(input$region_or_continent) %>%
      summarise(Score= round( mean(Score),3)) %>%
      arrange(desc(Score))
  })
  
  ## Regional data table
  output$regional_scores = renderDataTable({
    react_regional()
  })
  

 
}