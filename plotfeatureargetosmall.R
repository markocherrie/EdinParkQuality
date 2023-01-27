library(sf)
library(geobr)
library(mapview)
library(ggplot2)
library(gridExtra)
# download and install via google fonts
library(extrafont)
library(showtext)
library(ggpubr)
library(dplyr)

#font_import("fonts")
font_add_google(name = "Raleway",   # Name of the font on the Google Fonts site
                family = "Raleway")
showtext_auto()

parksfromedinburghcouncil<-read_sf("geo/Open_Space_Audit_2016.shp")


# function
wrapper <- function(x, ...) 
{
  paste(strwrap(x, ...), collapse = "\n")
}


cowplotter<-function(data, pan, np, n, padding, size){
  
  premsub<-data
  
  # filter
  premsub<-parksfromedinburghcouncil %>%
    dplyr::filter(PAN65==pan) %>%
    dplyr::filter(NP_Name==np)
  
  # specific cleaning
  premsub$NAME[premsub$NAME=="The Meadows amd Bruntsfield Links"]<-"Bruntsfield Links"
  premsub$NAME[premsub$NAME=="The Meadows and Bruntsfield Links"]<-"The Meadows"
  
  premsub<-premsub[!duplicated(premsub$NAME),]
  
  
  premsub <- premsub %>% arrange(Area_ha) 
  #%>% top_n(n) %>% arrange(Area_ha) 
  
  premsub$centroid <- 
    premsub %>%
    sf::st_centroid() %>%
    sf::st_geometry() %>%
    sf::st_transform(27700)
  
  padding <-padding
  if(size=="diff"){
    graph <- function(x){
      ggplot(data = filter(premsub[x,])) + 
        geom_sf(color = 0, fill="#3CB043")+
        #geom_sf(data =premsub[x,]$centroid)+
        coord_sf(xlim = c(premsub$centroid[[x]][1]-padding , 
                          premsub$centroid[[x]][1]+padding), 
                 ylim = c(premsub$centroid[[x]][2]-padding , 
                          premsub$centroid[[x]][2]+padding), 
                 expand = FALSE)+
        theme_void()+
        theme(legend.position="none")+
        ggtitle(wrapper(premsub$NAME[x], width = 18))+
        theme(plot.title = element_text(hjust = 0.5, size=20),
              text = element_text(family = "Raleway"))
    }
  }else{
    graph <- function(x){
      ggplot(data = filter(premsub[x,])) + 
        geom_sf(color = 0, fill="#3CB043")+
        theme_void()+
        theme(legend.position="none")+
        ggtitle(wrapper(premsub$NAME[x], width = 18))+
        theme(plot.title = element_text(hjust = 0.5, size=20),
              text = element_text(family = "Raleway"))
    }
  }  
  
  
  plot_list <- lapply(X = 1:nrow(premsub), FUN = graph)
  
  g <- cowplot::plot_grid(plotlist = plot_list, ncol = 3)
  g

  
  #ggsave(g, paste0("output/", pan, np, n, padding, size, ".png"))
}




cowplotter(parksfromedinburghcouncil, "Public Parks & Gardens","City Centre NP", 5, 450,  size="diff")
cowplotter(parksfromedinburghcouncil, "Public Parks & Gardens","Pentlands NP", 5, 450,  size="same")

cowplotter(parksfromedinburghcouncil, "Public Parks & Gardens","Pentlands NP", 5, 300,  size="diff")
