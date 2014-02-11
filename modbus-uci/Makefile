# $Id$

include $(TOPDIR)/rules.mk

PKG_NAME:=modbus-uci
PKG_VERSION:=0.5
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)
PKG_BUILD_DEPENDS:=libmodbus

include $(INCLUDE_DIR)/package.mk

define Package/modbus-uci/default
  SECTION:=net
  CATEGORY:=Network
  TITLE:=modbus-uci uci-gateway
  DEPENDS:=+libmodbus +libuci
endef

define Package/modbus-uci
  $(Package/modbus-uci/default)
  MENU:=1
endef

define Package/modbus-uci/description
 modbus-uci-gateway
 use libmodbus https://github.com/stephane/libmodbus
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef

define Package/bacnet-stack/postinst
#!/bin/sh

if [ -z $${IPKG_INSTROOT} ] ; then
	( . /etc/uci-defaults/modbus-uci ) && rm /etc/uci-defaults/modbus-uci
fi

[ -n $${IPKG_INSTROOT} ] || {
	/etc/init.d/modbus-uci enable
	/etc/init.d/modbus-uci restart
}
endef

define Package/modbus-uci/install
	$(INSTALL_DIR) $(1)/etc/init.d $(1)/etc/config $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/modbus-uci.config $(1)/etc/config/modbus
	$(INSTALL_BIN) ./files/modbus-uci.defaults $(1)/etc/uci-defaults/modbus-uci
	$(INSTALL_BIN) ./files/modbus-uci.init $(1)/etc/init.d/modbus-uci
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/modbus-uci $(1)/usr/sbin/modbus-uci
endef

$(eval $(call BuildPackage,modbus-uci))

