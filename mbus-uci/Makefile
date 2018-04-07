# $Id$

include $(TOPDIR)/rules.mk

PKG_NAME:=mbus-uci
PKG_VERSION:=0.2
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)
PKG_BUILD_DEPENDS:=libmbus

include $(INCLUDE_DIR)/package.mk

define Package/mbus-uci/default
  SECTION:=net
  CATEGORY:=Network
  TITLE:=mbus-uci gateway
  DEPENDS:=+libmbus +libuci +bacnet-stack-uci
endef

define Package/mbus-uci
  $(Package/mbus-uci/default)
  MENU:=1
endef

define Package/mbus-uci/description
 mbus-uci-gateway
 use libmbus http://www.rscada.se/libmbus
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/bacnet-stack/postinst
#!/bin/sh

[ -n $${IPKG_INSTROOT} ] || {
	/etc/init.d/mbus enable
	/etc/init.d/mbus restart
}
endef

define Package/mbus-uci/install
	$(INSTALL_DIR) $(1)/etc/init.d $(1)/etc/config $(1)/etc/uci-defaults
	$(INSTALL_DATA) ./files/mbus.config $(1)/etc/config/mbus
	$(INSTALL_BIN) ./files/mbus.init $(1)/etc/init.d/mbus
	$(INSTALL_DIR) $(1)/usr/sbin $(1)/usr/bin
	$(INSTALL_BIN) ./files/xml_parser.sh $(1)/usr/bin/xml_parser.sh
	$(INSTALL_BIN) ./files/mbus-uci.sh $(1)/usr/sbin/mbus-uci
endef

$(eval $(call BuildPackage,mbus-uci))

