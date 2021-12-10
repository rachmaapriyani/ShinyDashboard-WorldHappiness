fluidPage(
    theme=shinytheme("flatly"),
    tags$head(
        tags$style(HTML(".navbar .navbar-nav {float: right;
        font-size:20px }
                        "))
    ),
    
    # Navigation bar on the top of the screen static position
    navbarPage(
        title="World Happiness Scores: 2017-2020",
        id="nav",
        position="static-top",
        
        # World Map page
        tabPanel("World Map", icon=icon('globe'),
                 fluidRow(
                     h4('World Happiness Scores'),
                     h5('How criteria makes each country happier than Dystopia.'),
                     br(),
                     h4('Data Source:'),
                     tags$a(href="https://worldhappiness.report", "World Happiness Report")
                 ),
                 fluidRow(
                     column(3,
                            br(),
                            sliderInput(
                                inputId="worldmap_year",
                                label="Select Year:",
                                min=2017, max=2020,
                                value=2020,
                                sep=""),
                            checkboxGroupInput(
                                inputId="happiness_features",
                                label="Select Criterias:",
                                choices=list("GDP per Capita"="GDP.per.capita",
                                             "Healthy Life Expectancy"="Healthy.life.expectancy",
                                             "Freedom to Make Life Choices"="Freedom.to.make.life.choices",
                                             "Generosity"="Generosity",
                                             "Perception of Corruption" = 'Perceptions.of.corruption',
                                             'Social Support' = 'Social.support'),
                                selected = c('GDP.per.capita','Healthy.life.expectancy','Freedom.to.make.life.choices','Generosity','Perceptions.of.corruption','Social.support')
                                )
                            ),
                     
                     column(8,
                            plotlyOutput('worldmap'))
                     ),
                 fluidRow(
                     dataTableOutput("data_happiness")
                     )
                 ),
        
        # Explore Page
        tabPanel("Explore",icon = icon("chart-bar"),
                 tabsetPanel(type='tabs', id='chart_tabs',
                             
                             # Variables tab within Explore Page
                             tabPanel("CORRELATION",
                                      fluidRow(
                                          br(),
                                          column(3,
                                                 sliderInput(
                                                   inputId = 'variables_year',
                                                   label = 'Select Years:',
                                                   min=2017, max=2020,
                                                   value=c(2017,2020),
                                                   sep=''
                                                   ),
                                                 selectizeInput(
                                                     inputId = "var1",
                                                     label = h5(strong("Select x-axis:")),
                                                     choices = scatter_choices
                                                     ),
                                                 selectizeInput(
                                                     inputId = "var2",
                                                     label = h5(strong("Select y-axis:")),
                                                     choices = scatter_choices
                                                     ),
                                                 h5(strong(htmlOutput("correlation")))
                                                 ),
                                          column(9,
                                                 plotlyOutput('scatter'))
                                          )
                                      ),
                             
                             # Trends tab within Explore Page
                             tabPanel("TRENDS",
                                      fluidRow(
                                          br(),
                                          column(3,
                                                 sliderInput(
                                                     inputId = 'trends_variables_year',
                                                     label = 'Select Years:',
                                                     min=2017, max=2020,
                                                     value=c(2017,2020),
                                                     sep=''
                                                 ),
                                                 selectizeInput(
                                                     inputId="countries",
                                                     label="Select countries:",
                                                     multiple = TRUE,
                                                     choices = sort(unique(happiness$Country))
                                                 ),
                                                 selectizeInput(
                                                     inputId = 'trend_variable',
                                                     label= 'Select variable:',
                                                     choices = c('Score','Rank'),
                                                     selected = 'Score'
                                                 )
                                          ),
                                          column(9,
                                                 plotlyOutput('trend'),
                                                 br(),
                                                 h4(strong("Happiness Score Change in Selected Time Range")),
                                                 dataTableOutput("trend_table")
                                                 )
                                        )
                                      ),
                             tabPanel("REGIONS",
                                      fluidRow(
                                          br(),
                                          column(3,
                                                 selectizeInput(
                                                     inputId = "region_or_continent",
                                                     label = h5(strong("Select Sub Region or Continent")),
                                                     choices = c('sub_region','continent')
                                                 ),
                                                 sliderInput(
                                                     inputId = 'regional_year',
                                                     label = 'Select Years:',
                                                     min=2017, max=2020,
                                                     value=c(2017,2020),
                                                     sep=''
                                                 ),
                                                 checkboxGroupInput(
                                                     inputId="regional_features",
                                                     label="Select Criterias:",
                                                     choices=list("GDP per Capita"="GDP.per.capita",
                                                                  "Healthy Life Expectancy"="Healthy.life.expectancy",
                                                                  "Freedom to Make Life Choices"="Freedom.to.make.life.choices",
                                                                  "Generosity"="Generosity",
                                                                  "Perception of Corruption" = 'Perceptions.of.corruption',
                                                                  'Social Support' = 'Social.support'),
                                                     selected = c('GDP.per.capita','Healthy.life.expectancy','Freedom.to.make.life.choices','Generosity','Perceptions.of.corruption','Social.support')
                                                 )
                                          ),
                                          column(9,
                                                 plotlyOutput('regional'),
                                                 dataTableOutput("regional_scores")
                                          )
                                          
                                      )
                                      
                             )
                             
                             
                        )
                 ),
        tabPanel("About", icon = icon('info-circle'),
                 tags$div(
                     tags$h4("Background"),
                     "The World Happiness Report is a publication of the United Nations Sustainable Development Solutions Network. It contains articles 
                      and rankings of national happiness,based on respondent ratings of their own lives, which the report also correlates with various 
                      (quality of) life factors. The World Happiness Report also a landmark survey of the state of global happiness. The first report was 
                      published in 2012. The report continues to gain global recognition as governments, organizations and civil societies increasingly use 
                      happiness indicators to inform their policy-making decisions. Leading experts across fields — economics, psychology, survey analysis, 
                      national statistics, health, public policy and more describe how measurements of well-being can be used effectively to assess the 
                      progress of nations.",
                     tags$br(),tags$br(),tags$h4("Sources"),
                     tags$b("Data Collecting from: "), tags$a(href="https://worldhappiness.report", "World Happiness Report"), "The World Happiness Report is 
                     a publication of the Sustainable Development Solutions Network, powered by data from ", tags$a(href="https://www.gallup.com/corporate/212381/who-we-are.aspx", "the Gallup World Poll"),
                     "and ", tags$a(href="https://www.lrfoundation.org.uk/en/", " Lloyd’s Register Foundation"),"who provided access to the World Risk Poll. The scores are from nationally representative samples, 
                      and take the data between the years 2017-2020. The Happiness Score is primarily driven by six factors — economic (GDP per capita), social support, healthy life expectancy, freedom, corruption, 
                      and generosity. Each of these factors contribute to making life evaluations higher in each country than they are in Dystopia .",
                     tags$br(),tags$br(),tags$h4("Insight"),
                     "From the visual, it was really helpful to see the rankings across the world and how they played against our own perceived assumptions of the happiest countries in the world. 
                     We check the correlation between variables that make up the Happiness Score, in the correlation visual we found out that it have strong correlations between ",  
                     tags$b("Happiness and Economy..GDP.per.Capita, Health..Life.Expectancy (life expectancy),and Social support (Family)."),"High scores among these categories speak to the likelihood of having a high overall Happiness Score.",
                     "The variable that look like interesting is between", tags$b("Generosity and Corruption"), "this two variable have a lowest point at this analysis, 0,10024 for generosity and 0,42801 for corruption.  
                      It is a bigger concern, it means generosity didn't effect to much for the happiness and Governments should be worried by the corruption scores which had very poor scores across the globe. ",
                      tags$br(),tags$br(),
                      "Between 2017 to 2020, one thing to note about that Economy. GDP per capita scores is extremely similar. The data shows that a good economy has a very strong correlation to overall happiness, maybe it make sense.
                      From the report also Oceania and Europe continent still have the highest score from others, and it means both continent was the overall happiest continent in the world.",
                     tags$br(),tags$br(),
                     "From the analysing reports, we are able to interpret what makes countries and their citizens happier, thus allowing us to focus on prioritizing and improving these aspects of each nation."
                                                              
                     
                     
                 )
                 
            
        )
    )
)