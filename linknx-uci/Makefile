# $Id: Makefile 1146 2005-06-05 13:32:28Z nbd $

include $(TOPDIR)/rules.mk

PKG_NAME:=linknx-uci
PKG_VERSION:=0.3.0
PKG_RELEASE:=0

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/linknx-uci
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Config generator for LINKNX and mqtt-client
  URL:=https://sourceforge.net/p/linknx/wiki/Main_Page/
  EXTRA_DEPENDS:=linknx, libuci-lua, luaexpat, luci-lib-nixio, lua-mosquitto, mosquitto
endef

define Build/Compile
endef

define Package/linknx-uci/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/etc/init.d/linknx-uci $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) ./files/usr/bin/linknxloaddata.lua $(1)/usr/bin
	$(INSTALL_BIN) ./files/usr/bin/linknxmapper.lua $(1)/usr/bin
	$(INSTALL_BIN) ./files/usr/bin/linknxreadvalue.lua $(1)/usr/bin
	$(INSTALL_BIN) ./files/usr/bin/linknxwritevalue.lua $(1)/usr/bin
	$(INSTALL_BIN) ./files/usr/bin/ets5xml2uci.lua $(1)/usr/bin
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) ./files/usr/sbin/linknxsubsscribemqtt.lua $(1)/usr/sbin
endef

$(eval $(call BuildPackage,linknx-uci))
