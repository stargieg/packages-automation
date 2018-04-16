# $Id: Makefile 1146 2005-06-05 13:32:28Z nbd $

include $(TOPDIR)/rules.mk

PKG_NAME:=linknx-uci
PKG_VERSION:=0.1.4
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/linknx-uci
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Config generator for KNX
  URL:=https://sourceforge.net/p/linknx/wiki/Main_Page/
  DEPENDS:=+linknx +luci-lib-json +luci-lib-nixio  +bacnet-stack-uci
endef

define Build/Compile
endef

define Package/bacnet-stack/postinst
#!/bin/sh

[ -n $${IPKG_INSTROOT} ] || {
	( . /etc/uci-defaults/linknx-uci ) && rm /etc/uci-defaults/linknx-uci
	/etc/init.d/linknx-uci enable
	/etc/init.d/linknx-uci restart

}

endef

define Package/linknx-uci/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/etc/init.d/linknx-uci $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/etc/linknx
	$(INSTALL_DATA) ./files/etc/linknx/config.socket.xml $(1)/etc/linknx.xml
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/etc/uci-defaults/linknx-uci $(1)/etc/uci-defaults/linknx-uci
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) ./files/usr/bin/linknxloaddata.lua $(1)/usr/bin
	$(INSTALL_BIN) ./files/usr/bin/linknxmapper.lua $(1)/usr/bin
	$(INSTALL_BIN) ./files/usr/bin/linknxreadvalue.lua $(1)/usr/bin
	$(INSTALL_BIN) ./files/usr/bin/linknxwritevalue.lua $(1)/usr/bin
	$(INSTALL_BIN) ./files/usr/bin/linknxwritevalue1.lua $(1)/usr/bin
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) ./files/usr/sbin/linknx-uci.lua $(1)/usr/sbin
endef

$(eval $(call BuildPackage,linknx-uci))
