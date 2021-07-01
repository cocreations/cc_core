# App Screens
This doc will outline all the pre-installed app screens and instructions on how to use them.

### TextScreen
`TextScreen` is a simple screen that takes a string as an input an displays it in the centre of the screen.
It will also parse html.

### SettingsScreen
`SettingsScreen` takes the settings table from the `configSource` and allows the user to alter the settings. Keep in mind you are responsible for populating the settings and adding functionality.

The settings table should have four columns with an optional fifth column.
* name
* type
* value
* defaultValue
* extraInfo

##### name
plays both the role of the id and display name.

##### type
can either be `"bool"` or `"string"`.
Bool will be a on-off toggle switch, and string will be a text input.

##### value
is the current value of the setting.
It should be set as the default value in the database as the app will keep track of the users data on its own.

##### defaultValue 
is the value the app will switch to if Reset to default is pressed.
It should be the same as value in the database

##### extraInfo
is extra optional information that can be added to a setting if the setting isn't clear by the name.
It will appear in the app as a small "i" button next to the setting. Once tapped it will show a popup with the text you have entered.

#### Example

``` dart
{
  "name":"Dark Theme",
  "type":"bool", 
  "value":"false",
  "defaultValue": "false",
  "extraInfo": "This will switch the app to dark theme for better night time use."
},
```

### ListViewScreen
`ListViewScreen` will take another table as its arg and return a list of the content of the table.
This table will be pulled from `dataSource` instead of `configSource` like other menu data allowing it to be updated without affecting the rest of the apps' load times.

#### Schema
The table should have six columns:
* id
* name
* tileImageUrl
* appScreen
* appScreenParam
* style
* displayContentAs

##### id
The internally used id, these must be unique. Can be either int or string

##### name
The name that will appear in the app.

##### tileImageUrl
A image url.

##### appScreen
This is the actual screen you want the app to open.

##### appScreenParam
This is all the info passed to the screen.
This may be a url for an image on an image screen or a table name for a menu screen.

##### style
The style data to add to the list items.

A key-value pair system that uses commas to separate the values and colons to separate the keys and values.

Example:
`"imageSize:120,elevation:1.5,cornerRadius:25"`

These are the options you have:

* imageSize : int or double. The square size of the image in logical pixels. Default is 70.
* elevation : int or double. The elevation of the card. Default is 1.
* cornerRadius : int or double. The radius of the corners of the card. Default is 4.
* cardColor : int colour value. "0xFF0000FF" would be 100% opacity blue for instance. The colour of the cards background.


##### displayAppScreen
This is whether to show the the appScreen as a whole page once the card is tapped, or to show it on the card it self overriding the tileImageUrl and name.
The values are:

* onCardTap (default)
* asCardContent


### Audio Players

There are three types of audio players, but they all follow the same rules.

1. `LargeAudioPlayer` LargeAudioPlayer gives a full size music app style audio player.
2. `SmallAudioPlayer` SmallAudioPlayer gives you a mini audio player that's fit for cards in a ListViewScreen
3. `SingleButtonAudioPlayer` SingleButtonAudioPlayer gives you only the play / pause button and no other controls. This is good for things like pronunciation in a language app.

All of these have three positional parameters. The first in required but the other two are optional.

1. Audio url.
2. Name. This will also parse html, so you can add colours and rich text.
3. Image url. 

Example as a home screen:
``` dart
{
"id":"1",
"name":"Cat sounds", 
"type":"homeScreen", 
"appScreen":"LargeAudioPlayer",
"appScreenParam":"https://www.catSounds.com/happy-cat.mp3,<b>Happy Cat</b>,https://www.catPhotos.com/happy-cat.jpg"
}
```

### SwipeableIntroScreen
`SwipeableIntroScreen` will pull from a dataSource table and display the table as a carousel.
It takes two positional parameters. The first in required but the other one is optional.
This was primarily built to be used in the app intro (see README.md) but it can be used in other areas of your app.

1. Database table.
2. Continue button text. The text that's shown on the last page to bring you into the app. This is only shown if `SwipeableIntroScreen` is type intro. (see README.md) Defaults to "Ok"

The table is pretty minimal compared to `ListViewScreen`, it only needs three columns.

* id
* appScreen
* appScreenParam

All of which are strings, and all you have probably seen before.