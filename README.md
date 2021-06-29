# cc_core

All the tools you need to build an app in 2 minutes.

## Getting Started

### Android:
  set the kotlin version to at least '1.4.0' in build.gradle
  should look like this:

  `ext.kotlin_version = '1.4.0'`

### iOS
  idk haven't run it on an iPhone yet


### Database schema

  #### Menus
  So for the `menus` table, you need five columns:

  * name 
  * id 
  * type
  * appScreen 
  * appScreenParam
  
  ##### name
  The name that will appear in the app.

  ##### id
  The internally used id, these must be unique. Can be either int or string.

  ##### type
  This is how the screen is accessed.
  Here there are three options:
  * homeScreen
  * leftSide
  * bottom

  There can only be one homeScreen and it is the first screen the user sees when opening the app.

  leftSide is the left hamburger menu.

  bottom is the bottom app bar menu.

  It's recommended that you also copy the homeScreen onto either leftSide, or bottom so the users can access it again once they've navigated away.

  ##### appScreen
  This is the actual screen you want the app to open.
  All available pre-installed screens can be seen in appScreens.md.

  ##### appScreenParam
  This is all the info passed to the screen.
  This may be a url for an image on an image screen or a table name for a menu screen.


  #### Style
  For the `style` table, you only need three columns:
  * name
  * value
  * id

  ##### name
  You've only got eight options here.
  1. appBarBackground : String int colour value. "0xFF00FF00" would be 100% opacity green for instance.
  This will set the background colour of the app bar.
  Defaults to blue.

  2. backgroundColor : String int colour value.
  This will set the background colour of the side menu.
  Defaults to white.

  3. appBarBanner : Url.
  An image to add to the app bar. If none is supplied, the apps name will be used instead.

  4. appBarButtonColor : String int colour value.
  Sets the colour of the side menu button.
  Defaults to white.

  5. primaryColor : String int colour value.
  Sets the primary theme colour of the app.
  Defaults to blue.

  6. accentColor : String int colour value.
  Sets the accent theme colour of the app.
  Defaults to blueAccent.

  7. sideDrawerType : String enum value.
  Sets the look of the side menu.
  * appBarBannerAtTop : puts the appBarBanner at the top of the menu.
  * compendiumStyle : doesn't extend fully to the top and bottom, has rounded corners.
  * standard : normal side menu.
  Defaults to standard.

  8. defaultListViewStyle : Comma separated key-value pair that define the default style property of a listview item.
  More info about the properties them selves can be found in appScreens.md under ListViewScreen > style.
