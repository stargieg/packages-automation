include $(TOPDIR)/rules.mk

PKG_NAME:=libpiface
PKG_VERSION:=1.0
PKG_RELEASE:=0

PKG_SOURCE_URL:=http://lunatiki.de/
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
#PKG_FIXUP:=autoreconf
#PKG_REMOVE_FILES:=autogen.sh
PKG_INSTALL:=1
#CONFIGURE_CMD = ./autogen.sh

include $(INCLUDE_DIR)/package.mk

define Package/libpiface
  SECTION:=net
  CATEGORY:=Network
  TITLE:=libpiface
  URL:=https://github.com/thomasmacpherson/piface
  DEPENDS:=@TARGET_brcm2708 +kmod-spi-bcm2708
endef

define Package/libpiface/description
  libpiface
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_BUILD_DIR)/src/piface/pfio.h $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/.libs/libpiface-* $(1)/usr/lib/
endef

define Package/libpiface/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/.libs/libpiface-1.0.so.* $(1)/usr/lib
endef

#	$(CP) $(PKG_INSTALL_DIR)/libpiface-1.0.so.* $(1)/usr/lib

$(eval $(call BuildPackage,libpiface))
