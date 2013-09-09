# DLDialogBox

DLDialogBox is an easy to use dialog solution for cocos2d games. DLDialogBox takes care of many details and functionalities of a dialog box in standard RPG games so you don't have to. 

Check out the [features](#features) and [screenshots](#screenshots) below to get an idea of what you can do with DLDialogBox.

## Features

- **Powerful Customizations:** You can custom every aspect of DLDialogBox. dialog sizes, backgrounds, fonts, typing speeds, # of lines to display, content paddings, choice dialog backgrounds, dialog portraits, and many many more! (See [Usage](#usage) section)
- **Integrated Choice Dialogs:** No need to roll your own choice picker! I know that many times you would want to ask the player to select something after a dialog, thus DLDialogBox has an integrated choice dialog and using it is as simple as `[DLDialogBox dialogWithTextArray:texts choices:choices defaultPortrait:portrait];`.
- **Easy to Use and Customize:** Start using DLDialogBox with a single line of code! Even with a lot of customization you only need to write a simple customization template for all your dialog boxes!
- **Custom Animations:** Animations for showing or removing dialog boxes, choice dialogs, or event the portraits can be animated in any way you like. The control is yours with DLDialogBox as it exposes a very simple API for you to animate all these interactions.
- **Beautiful Presets:** DLDialogBox comes with some beatiful presets for dialog boxes with custom animations graphics. Use them directly or build on top of them! 
- **Great Utilities:** DLDialogBox comes with a `DLChoiceDialog` for getting user input, a `DLSelectableLabel` for generating labels that can be selected and `DLAutoTypeLabelBM` for animation text typing. All these classes can be used indepedentely for your needs. The same awesomeness of customization applies to all these classes!
- **Awesome Examples & Documentations:** Run the demo project to see some awesome example usages of DLDialogBox. Or if want to become an expert you can read the header files of the DLDialogBox related classes. All class properties and public methods are documented in great detail.

[insert i'm awesome gif]

## Screenshots

## Get Started

## Usage

## Known Bugs
- DLSelectableLabel does not support center alignment now. Thus you cannot center align choice labels in the DLChoicePicker. Left and right align works though. This is a cocos2d bug.

## Notes
DLDialogBox is created by [Draco Li](http://www.dracoli.com) when he is chilling at home with his laptop on while listening to [The Developer Song](http://www.youtube.com/watch?v=TROd29XFHY0) in Toronto, Canada.

## Thanks
- [CCScale9Sprite](https://github.com/YannickL/CCControlExtension/tree/master/CCControlExtension/CCControl/Utils)
- [CCAutoType](https://github.com/sceresia/CCAutoType)

## License
Licensed under [MIT](http://www.opensource.org/licenses/mit-license.php). Whoopeee!
