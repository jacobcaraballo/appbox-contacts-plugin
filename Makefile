GO_EASY_ON_ME = 1

include theos/makefiles/common.mk

#you should be familiar with a makefile if your making a plugin

# your plugin name
BUNDLE_NAME = contacts
contacts_FILES = ContactsView.mm classes/ContactsSettingsController.mm

#this is where the appbox plugins live, dont change
contacts_INSTALL_PATH = /Library/Zogo/AppBox/Plugins
contacts_FRAMEWORKS = UIKit Foundation CoreGraphics AVFoundation MessageUI
contacts_PRIVATE_FRAMEWORKS = Preferences CoreTelephony

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/Zogo/AppBox/Plugins$(ECHO_END)
