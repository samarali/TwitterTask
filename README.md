TwitterTask Application
================================

### IMPORTANT! 
### TwitterTask can be found in https://github.com/samarali/TwitterTask


Features Include:
- Load List of followers
- Load List of follower’s Tweets
- Load List of users that logged in twitter settings
- Work Offline (list of followers & tweets and users)
- Load List of my tweets
- Application support arabic & english language

Libs:
1-Twitter (in Twitter Folder) library which integrate with oauth & twitter apis
2-side menu view (in sidemenuController Folder) to set controllers in navigation control : center control ,(left control or right control ) according to app localization
3-NilDictioary(NilDictionrary folder) with check if obj of dictionary is equal null 

StaticVariable.h:
contain all static variables in the app

CommonFuntions.h & CommonFuntions.m:
contain generic functions of the app :
1-hasConnectivity to check connection of the device 
2- showAlertWithTitle:Message to preview alert with message
3-isStringEmpty to check if string empty
4-isStringNull to check if string null
5-getTableCellBGColor_OddRow & getTableCellBGColor_EvenRow to get color of cell according to index of it

LocalizedMessages.h & Localizable.strings:
contain all localization strings of the app

Application Images & icons:
1- app icons could be found in Images/icons folder
2- app splash images screen  could be found in Images/splash folder
3- login screen background & images could be found in Images/login folder
4- SideMenu screen images could be found in Images/Sidemenu folder
5- Followers screen images could be found in Images/Followers folder
6- Tweets screen images could be found in Images/Tweets folder
7- There are other images could be found in Images/Tweets folder

Cells:
Each screen has tableviewcell header & implement classes which initialize content of cell in it.(could be found in Cells folder)


How To Use It
========================
1-First of all every next view controller extend from baseviewController view which has basic controls and properties.
2-to preview user data user have to login with his account once and the api with return user access token & secret key and the app save them for each logged in user to use them later to verify and authenticate user.

Step 1 - Login 
------------------------
LoginViewController:
1-you can Change application Language from by press language button (onLanguagePressed) which call:
	a-setAppLanguage to update app delete.current language and language key in NSUserDefaults.
	b-locatizeLables in update localization of screens
	c- switchToEnglishLayout or switchToArabicLayout according to previous language to update layout of screen. 
2-check last updated language if != curerent -> update the current language
3-in press login button (onLoginPressed) try to open authorization page with application ConsumerKey & ConsumerSecret.

Step 2 - Save user  
------------------------
LoginViewController
After user login:save his object data with access token and secret key in  user table in database in saveUserData which:
1-update userobj of appdeleget with this user
2-update is_selected field for all records in user table to be false 
3-select * from user table with this userID to check if user logged in previously or no:
	a-if yes update is_selected field for this record to be yes 
	b-else insert user object in user table of DB


 and update userobj of appdeleget with this user (saveUserData function in baseviewcontroller): with access token and secret key in  user table in database and 

Step 3 - Load user Followers 
------------------------
FollowersViewController
call list of followers for selected user (loadFollowersOnline function in FollowersViewController) and in response:
1-convert Dictionary objects to Account obj class (fillUsersArray: & convertDicToAccount functions)
2-delete the old records of followers for this user from follower table in Database (deleteOldFollowers function)
3-save Followers in follower table in database (AddNewFollowersDB function)
4-load them in the table view
if there is no connection or an error occurred try to load followers data for logged in user from database and also load them in table view (loadFollowersOffline function)

in heightForRowAtIndexPath function of tableviewdeleget set height of each row according to values height.
in pull list done refresh it and call loadFollowersOnline to load followers again and same top operation


Step 4 - Load Follower Tweets
------------------------
TweetsViewController
call list of tweets for selected follower (loadTweetsOnline function in TweetsViewController) and in response:
1-convert Dictionary objects to tweet obj class (fillTweetsArray: & convertDicToTweet functions)
2-delete the old records of tweets for this follower from tweet table in Database (deleteOldTweets function)
3-save Followers in follower table in database (AddNewTweetsDB function)
4-load them in the table view
5-load profile image & background image for selected follower
if there is no connection or an error occurred try to load followers data for logged in user from database and also load them in table view (loadTweetsOffline function)

in heightForRowAtIndexPath function of tableviewdeleget set height of each row according to values height.
in pull list done refresh it and call loadTweetsOnline to load tweets again and same top operation



SideMenuViewController:
------------------------
it contains 4 items (my profile , change language , users & logout)
each cell initiated by initWithMenu in SideMenuCell which take SideMenuCellObj obj
SideMenuCellObj initiated in getMenuForindex function which set object name & image according to the index

in didSelectRowAtIndexPath function of tableview delegate :
call getViewControllerName in SideMenuCellObj to init operation according to each cell:
1- my profile : send TweetsScreenName to function to load TweetsScreenName for logged in user with his tweets
2- Change Lang : 
	a-close side menu ([((BaseViewController*)[nav getTopView]) onMenuButtonPressed:nil];)
	b-update appdelegete.current language and language key in NSUserDefaults.
	c-call switchMenuDirection with change location of side menu of nav bar
	d-call onHomePressed of BaseViewController to load follower screen again
3-loadUsersPopup : 
	a-close side menu ([((BaseViewController*)[nav getTopView]) onMenuButtonPressed:nil];)
	b- call LoadUsers function with select all account from setting where there type = twitter and call chooseAccount function to check if the app granted to use them or no
	c- after select user (loginWithiOSAccount function) call  twitterAPIOSWithAccount & verifyCredentialsWithUserSuccessBlock to verify and authenticate user and save user data in database
	d-if done load followers for this use and do the above scenario of follower screen
	e-if error check if this user logged in previously and load his data (online or local according to connectivity function)

4-logout:
	a-close side menu ([((BaseViewController*)[nav getTopView]) onMenuButtonPressed:nil];)
	b-call [((BaseViewController*)[nav getTopView]) logout] to update logout flag of appdeleget and pop all screens and push login screen
	c-select list of followers for logged in user from follower table in DB 
	d-remove all tweets for all followers from tweet table in DB
	e-remove all followers for logged in user from follower table in DB 
	f-delete logged in user from user table in DB
	g-select list of users from user table in DB 
	h-if > 0 set is_selected field of first record = 1 in  user table in DB  to long in with him in next times



To Change application Language:
------------------------
you can do that from:
1-login screen by press language button (onLanguagePressed) which call:
	a-setAppLanguage to update app delete.current language and language key in NSUserDefaults.
	b-locatizeLables in update localization of screens
	c- switchToEnglishLayout or switchToArabicLayout according to previous language to update layout of screens
2-By press change language from sidemen (SideMenuViewController) in SideMenuCellObj class 

Multi User Login:
------------------------
LoginViewController:
in viewdidload select list of users from user table to get last user object and check his accesstoken and secret:
1- if = null this mean the last looged in user was from ios settings so verify the user by passing account object to api (twitterAPIOSWithAccount,verifyCredentialsWithUserSuccessBlock )and load his followers like previous.
2-else = value this mean thl last logged in user was authorized and the app has his access token & secret to verify the user by passing appConsumerKey, appConsumerSecret , accesstoken & secret (twitterAPIWithOAuthConsumerKey,getAccountVerifyCredentialsWithIncludeEntites) and lood his follwoers like previous also.

