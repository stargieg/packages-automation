# $Id$

include $(TOPDIR)/rules.mk

PKG_NAME:=modbus-client
PKG_VERSION:=0.1
PKG_RELEASE:=6

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)
PKG_BUILD_DEPENDS:=libmodbus

include $(INCLUDE_DIR)/package.mk

define Package/modbus-client/default
  SECTION:=net
  CATEGORY:=Network
  TITLE:=modbus-client
  DEPENDS:=+libmodbus
endef

define Package/modbus-client
  $(Package/modbus-client/default)
  MENU:=1
endef

define Package/modbus-client/description
 modbus-client
 use libmodbus https://github.com/stephane/libmodbus
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef

define Package/modbus-client/install
#	$(CP) -a ./ipkg/* $(1)/CONTROL/ 2>/dev/null || true
#	$(INSTALL_DIR) $(1)/etc/init.d
#	$(INSTALL_BIN) ./files/modbus-client.init $(1)/etc/init.d/modbus-client
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/modbus-client $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,modbus-client))

