
for(x in 1:1142){
  r<-
    ggplot(data = filter(premsub[x,])) + 
    geom_sf(color = 0, fill="#3CB043")+
    theme_void()+
    theme(legend.position="none")+
    ggtitle(wrapper(premsub$NAME[x], width = 18))+
    theme(plot.title = element_text(hjust = 0.5, size=100, lineheight=.2),
          text = element_text(family = "Raleway"))
  ggsave(paste0("output/allparks/",premsub$NAME[x],".png"),plot=r, dpi=300)
  
}