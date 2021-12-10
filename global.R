library(shiny)
library(shinythemes)
library(googleVis)
library(tidyverse)
library(DT)
library(countrycode)
library(ggplot2)
library(plotly)



# import csv data world happiness by year
happiness_2020 <-  read.csv("data/happiness_2020.csv")
happiness_2019 <-  read.csv("data/happiness_2019.csv")
happiness_2018 <-  read.csv("data/happiness_2018.csv")
happiness_2017 <-  read.csv("data/happiness_2017.csv")


# import data country for map visualization
country_conversion = read.csv("data/country_conversion.csv")

# add column year to each dataframe
happiness_2020$year <-  2020
happiness_2019$year <-  2019
happiness_2018$year <-  2018
happiness_2017$year <-  2017



# rename columns to merge into 1 dataframe

happiness_2017 <-  happiness_2017 %>%
  rename(
    Rank = Happiness.Rank,
    Score = Happiness.Score, 
    GDP.per.capita = Economy..GDP.per.Capita.,
    Healthy.life.expectancy = Health..Life.Expectancy.,
    Freedom.to.make.life.choices = Freedom, 
    Perceptions.of.corruption = Trust..Government.Corruption.,
    Social.support = Family
  )

happiness_2018$Perceptions.of.corruption <-  as.numeric(happiness_2018$Perceptions.of.corruption)
happiness_2018 <-  happiness_2018 %>%
  rename(
    Rank = Overall.rank,
    Country = Country.or.region
  )%>%
  mutate(Dystopia.Residual = Score-rowSums(.[4:9], na.rm=TRUE))


happiness_2019 <-  happiness_2019 %>%
  rename(
    Rank = Overall.rank,
    Country = Country.or.region
  ) %>%
  mutate(Dystopia.Residual = Score-rowSums(.[4:9], na.rm=TRUE))

happiness_2020 <-  happiness_2020 %>%
  rename(
    Country = Country.name,
    Region = Regional.indicator,
    Score = Ladder.score,
    GDP.per.capita = Logged.GDP.per.capita,
    Social.support = Social.support,
    Healthy.life.expectancy = Healthy.life.expectancy,
    Freedom.to.make.life.choices = Freedom.to.make.life.choices,
    Perceptions.of.corruption = Perceptions.of.corruption,
    Dystopia.Residual = Dystopia...residual
  )



# remove unnecessary columns

happiness_2020 <-  happiness_2020[-c(5,6,7,14,15,16,17,18,19,20)]  
happiness_2017 <-  happiness_2017[-c(4,5)]



# bind rows of yearly datasets
happiness <-  bind_rows(happiness_2017,happiness_2018,happiness_2019,happiness_2020)

# create continent and country code columns
happiness$code <-  countrycode(happiness$Country, origin='country.name',destination='iso3c', custom_match = c(Kosovo = "KSV"))
country_conversion = country_conversion %>%
  select(code_3,continent,sub_region)
happiness <-  happiness %>%
  left_join(country_conversion,by = c('code'='code_3'))
  

# reorder columns in happiness dataframe
column_order <-  c('year','sub_region','continent','Country','code','Rank','Score', 'GDP.per.capita', 'Healthy.life.expectancy' ,'Freedom.to.make.life.choices', 'Generosity', 'Perceptions.of.corruption','Social.support',"Dystopia.Residual" )
happiness <-  happiness[,column_order]



# drop na column

happiness <- happiness %>% 
  drop_na(sub_region,continent,Perceptions.of.corruption)


#round the numeric value
happiness <- happiness %>% 
  mutate_if(is.numeric,round,3)



# light grey boundaries for map layout
l <- list(color = toRGB("grey"), width = 0.5)
# specify map projection/options
g <- list(showframe = FALSE,showcoastlines = FALSE,
          projection = list(type = 'Mercator'))

# Choices used for input widget
scatter_choices <-  list("Happiness Score" = 'Score',
                       "GDP per Capita"="GDP.per.capita",
                       "Healthy Life Expectancy"="Healthy.life.expectancy",
                       "Freedom to Make Life Choices"="Freedom.to.make.life.choices",
                       "Generosity"="Generosity",
                       "Perception of Corruption" = 'Perceptions.of.corruption',
                       'Social Support' = 'Social.support',
                       'Dystopia residual' = 'Dystopia.Residual')




