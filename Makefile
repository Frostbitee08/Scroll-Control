include theos/makefiles/common.mk

TWEAK_NAME = ScrollControl
ScrollControl_FILES = Tweak.xm ScrollControl.m
ScrollControl_FRAMEWORKS = UIKit, QuartzCore

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += preferences
include $(THEOS_MAKE_PATH)/aggregate.mk
