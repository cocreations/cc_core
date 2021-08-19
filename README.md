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
  Here there are four options:
  * homeScreen
  * leftSide
  * bottom
  * intro

  There can only be one homeScreen and it is the first screen the user would normally see when opening the app.

  leftSide is the left hamburger menu.

  bottom is the bottom app bar menu.

  intro is the screen the user sees when the open the app for the first time. It's recommended you use a `SwipeableIntroScreen`, but you can use whatever you wish.

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
  An image to add to the app bar. If set to "false", the app won't show an app bar, but if it is empty or omitted completely, the apps name will be used instead.

  1. appBarButtonColor : String int colour value.
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

  ##### value
  See above.

  ##### id
  Must be unique.


### Translation Layer
  Did you decide to make your database before checking the README? Well if the answer is yes, you're in luck! We've built a solution for just this problem and it's called the Translation Layer.
  All it needs is a small json file to understand your mess of a database.
  
  It's layed out like so :

  ```json
  {
    "yourTableName": {
      "table": "yourTableName",
      "filters": [
        {
          "field": "field",
          "op": "equals",
          "value": "value"
        }
      ],
      "output": {
      }
    }
  }
  ```

  Lets break this down a bit.

  * `"yourTableName"` This is the table or faux table that needs to be translated. Whenever this table is accessed in the app, it will be intercepted by the translation layer which will apply the filters and parse the result.
  
  * `"table"` This is the actual table in the database the app is going to get. This means that you can have multiple "faux" tables that all just apply filters to a single giant table. This is required.

  * `"filters"` These are the filters that will be applied when getting data from the database. This is not required if you don't need to filter the results.

    This is a list of objects that contain three keys
    1. `"field"` This is the database column to check against.
    2. `"op"` This is the operation to perform. Can be either 'equals' or 'arrayContains'.
    3. `"value"` This is the value that the field should match, or the array should contain

  * `"output"` This is what the end result will output. It should be structured to match whatever component is using this data. 
  Using curly brackets ({}), you can interpolate the values from your database into the result. This is not required if you don't need any special parsing.
   
  Here's an example of a translation layer set up to get songs from an entertainment table and return them in the `ListViewScreen` schema.


  ```json
  {
    "songs": {
      "table": "entertainment",
      "filters": [
        {
          "field": "category",
          "op": "equals",
          "value": "Songs"
        }
      ],
      "output": {
        "id": "{id}",
        "name": "{title}",
        "tileImageUrl": "",
        "appScreen": "SmallAudioPlayer",
        "appScreenParam": "{contentUrl},<b>{title}</b><br />{creator},{coverArt}",
        "style": "imageSize:120,elevation:1.5,cornerRadius:25"
      }
    }
  }
  ```
  Here's an example of the database that this is translating:

  ```json
  {
    "0": {
      "id": "0",
      "category": "Songs",
      "title": "Never Gonna Give You Up",
      "creator": "Rick Astley",
      "contentUrl": "https://www.songbank.com/never_gonna_give_you_up/mp3.mp3",
      "coverArt":"https://www.songbank.com/never_gonna_give_you_up/image.jpg"
    }
  }
  ```
  
You can see that we're using almost all the data in the output, but it's shuffled around quite a bit.
