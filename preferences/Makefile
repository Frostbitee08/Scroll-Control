include theos/makefiles/common.mk

BUNDLE_NAME = Preferences
Preferences_FILES = Preferences.mm
Preferences_INSTALL_PATH = /Library/PreferenceBundles
Preferences_FRAMEWORKS = UIKit
Preferences_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/Preferences.plist$(ECHO_END)
