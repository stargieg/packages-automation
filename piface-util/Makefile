#
# Copyright (C) 2012-2013 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=piface-util
PKG_VERSION:=0.1
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/piface-util/default
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  TITLE:=piface-util
  DEPENDS:=+libpiface
endef

define Package/piface-util
  $(Package/piface-util/default)
  MENU:=1
endef
                            
define Package/piface-util/description
 piface-util dep on libpiface
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef

define Package/piface-util/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/input_reader $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/the_amazing_led_show $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/board_reset $(1)/usr/bin/
endef

$(eval $(call BuildPackage,piface-util))
