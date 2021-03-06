#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

//custom
#import <MessageUI/MessageUI.h>

//this is where your plugin lives
//the view will be pulled by appbox as a view, so always subclass UIView!
@interface ContactsView : UIView <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate> //set whatever delegates you need (optional)

@property (nonatomic, retain) NSMutableDictionary *tweakSettings;
@property (nonatomic, assign) UIView *tweakView;

+ (id)sharedInstance;
- (id)init;
- (NSString *)name;
- (NSString *)identifier;
- (NSString *)appID;

- (NSString *)tweakSettingsPath;
- (id)settingsController;
- (id)settings;
- (void)updateSettings:(id)settings;
- (void)writeTweakSettings;
- (UIView *)lockScreenView;
- (void)updateFrameForOrientationChange;
- (CGRect)mainFrame;
- (CGRect)mainFrame:(CGRect)frame WithPadding:(float)padding;
- (void)reveal:(NSString *)appID;
- (void)hide;


@end

//Headers
@interface IMPerson : NSObject
- (int)recordID;
@end

extern "C" void CTCallDial(NSString *numberToDial);
extern "C" void CTCallListDisconnectAll();