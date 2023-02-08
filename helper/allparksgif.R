### greenspace gif

imgs <- list.files("output/allparks/", full.names = TRUE, pattern=".png", recursive = T)

library(magick)
img_list <- lapply(imgs, image_read)

## join the images together
img_joined <- image_join(img_list)

## animate at 2 frames per second
img_animated <- image_animate(img_joined, fps = 2)

## view animated image
img_animated

## save to disk
image_write(image = img_animated,
            path = "output/allparks.gif")