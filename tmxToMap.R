##TODO##
#Maybe fix numbering of tilesets and BG tilesets
#What does each parallax value do specifically?

#NOTES:
#Only first objectgroup gets read
#Only first Glace (GID = 130) gets read (must be in first objectgroup)
#Map tileset must have 128 tiles (and 'firstGID' of first objectgroup must be 129)
#Only the first 4 tile layers (by 'id' value) will be read
#Only the first 3 BG layers (by 'id' value) will be read


################################################################################
################################################################################

#### Manually set some values ####

#Set paths:
tmxPath = "~/Glace speedrun stuff/map files/level maps tiled/swamp1_map.tmx"
bgTmxPath = "~/Glace speedrun stuff/map files/level bg/swamp1_bg.tmx"
glaceMapsPath = "C:/users/shayd/Documents/emulators/Glace12QuickFix/Maps"

#Set map name:
  #This needs to match one of the existing level names
  #DO NOT ADD THE .MAP EXTENSION
mapName = "Swamp1"

#Set zone:
  #"Grass", "Swamp", "Snow", or "Lab"
  #These dictates music, tilesets, and background
musicZone = "Snow"
tsZone    = "Swamp"
bgTsZone  = "Grass"
bgZone    = "Lab"

#Set beads:
numBeads = 1

#Set SFX and sec values:
  #Sec values are seconds between sfx playing
  #Set sfx and sec to 0 for unused slots
sfx1 = 12
sec1 = 5

sfx2 = 11
sec2 = 4

sfx3 = 10
sec3 = 7

sfx4 = 9
sec4 = 11

#Set parallax values:
  #Must be between 0 and 1
parallax1 = 0.10
parallax2 = 0.34
parallax3 = 0.61

################################################################################
################################################################################

#### Read in the data ####


library(xml2)
library(tidyverse)

map <- read_xml(tmxPath)

#Read Glace start position
glaceX <- as.integer(xml_attr(xml_find_first(map,'/map/objectgroup[1]/object[@gid = 130]'), 'x'))
glaceY <- as.integer(xml_attr(xml_find_first(map,'/map/objectgroup[1]/object[@gid = 130]'), 'y'))

#Read in map data
mapWidth <- as.numeric(xml_attr(xml_find_first(map, '/map'), 'width'))
mapHeight <- as.numeric(xml_attr(xml_find_first(map, '/map'), 'height'))

#Get tileset and music data
tileSet <- paste("Images//TileSets//TS_", tsZone, ".bmp", sep = '')
BGTileSet <- paste("Images//TileSets//BG_", bgTsZone, ".bmp", sep = '')
staticBG <- paste("Images//TileSets//ST_", bgZone, ".bmp", sep = '')
music = paste("Music/", musicZone, ".sgt", sep = '')

#Convert SFX seconds to Glace frequency values
freq1 = sec1 * 1000
freq2 = sec2 * 1000
freq3 = sec3 * 1000
freq4 = sec4 * 1000

#Set bead values
if(numBeads >= 1) numBead1 = 1 else numBead1 = 0
if(numBeads >= 2) numBead2 = 1 else numBead2 = 0
if(numBeads >= 3) numBead3 = 1 else numBead3 = 0
if(numBeads >= 4) numBead4 = 1 else numBead4 = 0

#Read number of actors
numActors <- xml_length(xml_find_first(map, "/map/objectgroup[1]"))

#Read actor information
actorIDs <- as.integer(gsub("\"", "", gsub("[a-zA-z]+=", "",
                       xml_find_all(map, "/map/objectgroup[1]/object[@gid != 130]/@gid"))))
actorXs <- as.integer(gsub("\"", "", gsub("[a-zA-z]+=", "",
                      xml_find_all(map, "/map/objectgroup[1]/object[@gid != 130]/@x"))))
actorYs <- as.integer(gsub("\"", "", gsub("[a-zA-z]+=", "",
                      xml_find_all(map, "/map/objectgroup[1]/object[@gid != 130]/@y"))))

#Create table of actor info
actorInfo <- data.frame(actorIDs, actorXs, actorYs)
colnames(actorInfo) <- c("ID", "X", "Y")

#Change actor IDs from Tiled value to Glace value
actorInfo['ID'] <- actorInfo['ID'] - 129

#Change actor Y-coordinates to be 32px higher
actorInfo['Y'] <- actorInfo['Y'] - 32

#Clean up unnecessary actor variables
rm(actorIDs, actorXs, actorYs)


#Read in Layer 1 data
layer1Tiles <- read_csv(gsub("\n</data>", "", gsub("<data encoding=\"csv\">\n", "",
                        toString(xml_find_first(map, '/map/layer[@id = 1]/data')))),
                        col_names = FALSE)
layer1Tiles <- layer1Tiles[,1:mapWidth]

#Read in Layer 2 data
layer2Tiles <- read_csv(gsub("\n</data>", "", gsub("<data encoding=\"csv\">\n", "",
                        toString(xml_find_first(map, '/map/layer[@id = 2]/data')))),
                        col_names = FALSE)
layer2Tiles <- layer2Tiles[,1:mapWidth]

#Read in Layer 3 data
layer3Tiles <- read_csv(gsub("\n</data>", "", gsub("<data encoding=\"csv\">\n", "",
                        toString(xml_find_first(map, '/map/layer[@id = 3]/data')))),
                        col_names = FALSE)
layer3Tiles <- layer3Tiles[,1:mapWidth]

#Read in Layer 4 data
layer4Tiles <- read_csv(gsub("\n</data>", "", gsub("<data encoding=\"csv\">\n", "",
                        toString(xml_find_first(map, '/map/layer[@id = 4]/data')))),
                        col_names = FALSE)
layer4Tiles <- layer4Tiles[,1:mapWidth]

#Concatenate all the layer data and clean up
layersTiles = list(layer1Tiles, layer2Tiles, layer3Tiles, layer4Tiles)
rm(layer1Tiles, layer2Tiles, layer3Tiles, layer4Tiles)

#Convert layer tile IDs from Tiled format to Glace format
#Maybe unnecessary if correct tilesets are used
for(i in 1:4){
  layersTiles[[i]][layersTiles[[i]] == 0] <- NA
  layersTiles[[i]] = layersTiles[[i]] - 1
  layersTiles[[i]][is.na(layersTiles[[i]])] <- 0
}

#Cleanup
rm(map)

##BACKGROUND##

bg <- read_xml(bgTmxPath)

#Read BG layers
bgLayer1 <- read_csv(gsub("\n</data>", "", gsub("<data encoding=\"csv\">\n", "",
                     toString(xml_find_first(bg, '/map/layer[@id = 1]/data')))),
                     col_names = FALSE)
bgLayer1 <- bgLayer1[,1:(mapWidth/2)]

bgLayer2 <- read_csv(gsub("\n</data>", "", gsub("<data encoding=\"csv\">\n", "",
                     toString(xml_find_first(bg, '/map/layer[@id = 2]/data')))),
                     col_names = FALSE)
bgLayer2 <- bgLayer2[,1:(mapWidth/2)]

bgLayer3 <- read_csv(gsub("\n</data>", "", gsub("<data encoding=\"csv\">\n", "",
                     toString(xml_find_first(bg, '/map/layer[@id = 3]/data')))),
                     col_names = FALSE)
bgLayer3 <- bgLayer3[,1:(mapWidth/2)]

#Concatenate and clean up BG layers
bgLayers = list(bgLayer1, bgLayer2, bgLayer3)
rm(bgLayer1, bgLayer2, bgLayer3)

#Convert BG tile IDs from Tiled format to Glace format
#Maybe unnecessary if correct tilesets are used
for(i in 1:3){
  bgLayers[[i]][bgLayers[[i]] == 0] <- NA
  bgLayers[[i]] = bgLayers[[i]] - 1
  bgLayers[[i]][is.na(bgLayers[[i]])] <- 0
}

#Cleanup
rm(bg)

################################################################################

#### Write the file ####


#Open connection to file
newMap <- file(paste(glaceMapsPath, "/", mapName, ".MAP", sep = ''))
open(newMap, "wb")

#Write Glace start position
writeBin(as.integer(c(glaceX, glaceY)), newMap, size = 4, endian = 'little')    #0x00 - 0x07

#Write map info
writeChar(mapName, newMap, nchars = 32, eos = NULL)                             #0x08 - 0x27
writeChar(tileSet, newMap, nchars = 32, eos = NULL)                             #0x28 - 0x47
writeChar(BGTileSet, newMap, nchars = 32, eos = NULL)                           #0x48 - 0x67
writeChar(staticBG, newMap, nchars = 32, eos = NULL)                            #0x68 - 0x87

#Write music
for(i in 1:nchar(music)){
  writeChar(substr(music, i, i), newMap, nchars = 1, eos = NULL)
  writeBin(as.integer(0), newMap, size = 1)
}
writeChar(".", newMap, nchars = 2*(32- nchar(music)), eos = NULL)               #0x88 - 0xC7

#Write SFX and frequencies
writeBin(as.integer(c(sfx1, freq1, sfx2, freq2, sfx3, freq3, sfx4, freq4)),
         newMap, size = 4, endian = 'little')                                   #0xC8 - 0xE7

#Write bead info
writeBin(as.integer(c(numBead1, numBead2, numBead3, numBead4)),
         newMap, size = 4, endian = 'little')                                   #0xE8 - 0xF7

#Write number of layers
writeBin(as.integer(4), newMap, size = 1)                                       #0xF8

#Write map size and parallax values
writeBin(as.integer(c(mapWidth, mapHeight)),
         newMap, size = 4, endian = 'little')                                   #0xF9 - 0x100
writeBin(c(parallax1, parallax2, parallax3), newMap,
         size = 4, endian = 'little')                                           #0x101 - 0x10C

#Write number of actors
writeBin(as.integer(numActors), newMap, size = 4, endian = 'little')            #0x10D - 0x110

#Write actor info
for(i in 1:numActors) writeBin(as.integer(actorInfo[i,]),
                               newMap, size = 4, endian = 'little')             #0x111 - 

#Write map tiles
for(z in 1:4){
  for(y in 1:mapHeight){
    for(x in 1:mapWidth){
      writeBin(as.integer(layersTiles[[z]][y,x]), newMap, size = 1)
    }
  }
}

#Write BG tiles
for(z in 1:3){
  for(y in 1:(mapHeight/2)){
    for(x in 1:(mapWidth/2)){
      writeBin(as.integer(bgLayers[[z]][y,x]), newMap, size = 1)
    }
  }
}

close(newMap)
