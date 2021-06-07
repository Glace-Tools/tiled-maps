# Tiled to Glace Map Conversion

## Creating the Tiled file

Create a file in Tiled (available [here](https://www.mapeditor.org/)):

+ Orientation: Orthogonal
+ Tile layer format: CSV
+ Tile render order: Right Down
+ Map size: Fixed, width and height can be whatever you want
+ Tile size: 32x32 px

You should use the tilesets included in this repository. If you use one from somewhere else, the R code might not work properly.

You can only use one zone's tileset for the foreground (you can use a different one in the background, but that needs to be a separate file). Make sure to add this first (in the tilesets window, click the arrow in the top right and add external tileset).

Design your level! Make sure there are 4 layers (use the default "Tile Layer 1,2,3,4" names). Glace will pass through all tiles except those in Layer 3. For entities, add the "Enemies and Objects" tileset (after adding the level tileset). Create an Object Layer, and place the entities in that layer. Don't put enemies in a tile layer! Make sure to include a Glace entity; this is the starting location.

For background .tmx files, you should have 3 tile layers. Again, you can only use one zone's tileset (but it can be different from the foreground tileset). NOTE: The dimensions of the background .tmx file must be exactly half that of the map file in both X and Y (e.g. a map that is 1000x60 must have a background of 500x30). Also note that Tiled counts coordinates from 0, so the last coordinate will be the map size minus 1.

Make sure to have the right number of tile layers in both files, and one object layer in the level file. If you have more, it might still work, but only the first 4 (or 3 for the background) tile layers and first object layer will be read in. If you have fewer layers, I don't know if it will work or not. I suspect not. Also, if you have multiple Glace entities in your map, only one will be used as the start location (I think the first one you placed).

Now you're ready to run the conversion!



## Converting the Tiled file to a Glace file

### Step 1: Install R
If R is not already installed on your computer, you need to install it. R and its instructions can be found [here](https://www.r-project.org/).


### Step 2: Edit the R Script

You will need to edit the first section of the R script before running it. This is the section called "Manually set some values".


#### Set paths

NOTE: Paths will need forward slashes ("/") instead of back slashes ("\\").

+ tmxPath: This is the path to your Tiled .tmx file (including the .tmx extension) that you wish to convert.
+ bgTmxPath: This is the path to your .tmx file to be used as the background. NOTE: The dimensions of the background .tmx file must be exactly half that of the map file in both X and Y (e.g. a map that is 1000x60 must have a background of 500x30). Also note that Tiled counts coordinates from 0, so the last coordinate will be the map size minus 1.
+ glaceMapsPath: This is the path to the "Maps" folder in the same directory as your "Glace.exe". Don't include a "/" after the folder path.

#### Set map name

This is the name of the Glace level you want to overwrite (it must match an existing level name). Do not add the ".MAP" extension to this value.

#### Set zone

These values dictate the zones to use for music, tileset, background tileset, and background image (static).

#### Set number of beads and number of layers

These are pretty self-explanatory. HOWEVER, for now the number of layers must be 4. I'm not sure if there's a possibility to customize this, if not I'll remove this value.

#### Set SFX and frequency

Set up to 4 ambient SFX to play. A table of SFX and their values is in the same directory as this file. The "sec" values set here are the seconds between each occurrence of the given sound.

#### Set parallax values

I'm not sure exactly how these work; feel free to mess around with their values. NOTE: Valid values are between 0 and 1.

### Step 3: Run the code!

In R, use the command `source("path/to/tmxToMap.R")` to run the script!

### Step 4: Cross your fingers and hope the code works!

The code will give you a few warnings, some related to parsing failures (expecting one more column of data than exists), and some related to `writeChar()` (something along the lines of "more characters requested -- will zero-pad). These ones you can ignore. If there are other warnings or errors, double-check your input data at the top of the script as well as your .tmx files. If that all seems to be in order, it's probably something with the code, which will hopefully be fixed shortly thereafter!

Enjoy! :D