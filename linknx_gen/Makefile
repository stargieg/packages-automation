# $Id: Makefile 1146 2005-06-05 13:32:28Z nbd $

include $(TOPDIR)/rules.mk

PKG_NAME:=linknx_gen
PKG_VERSION:=0.2.0
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/linknx_gen
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Config generator for KNX
  URL:=https://sourceforge.net/p/linknx/wiki/Main_Page/
  DEPENDS:=+linknx +luci-lib-json +luci-lib-nixio
endef

define Build/Compile
endef

define Package/linknx_gen/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) ./files/etc/config/linknx_exp $(1)/etc/config
	$(INSTALL_DATA) ./files/etc/config/linknx_group $(1)/etc/config
	$(INSTALL_DATA) ./files/etc/config/linknx_medialist $(1)/etc/config
	$(INSTALL_DATA) ./files/etc/config/linknx_varlist_R201 $(1)/etc/config
	$(INSTALL_DATA) ./files/etc/config/linknx_varlist_R301 $(1)/etc/config
	$(INSTALL_DATA) ./files/etc/config/linknx_varlist_R302 $(1)/etc/config
	$(INSTALL_DATA) ./files/etc/config/linknx_varlist_R303 $(1)/etc/config
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/etc/init.d/linknx_gen $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/etc/linknx
	$(INSTALL_DATA) ./files/etc/linknx/config.local.xml $(1)/etc/linknx
	$(INSTALL_DATA) ./files/etc/linknx/config.socket.xml $(1)/etc/linknx
	$(INSTALL_DATA) ./files/etc/linknx/config.xml $(1)/etc/linknx
	$(INSTALL_DATA) ./files/etc/linknx/example.esf $(1)/etc/linknx
	$(INSTALL_BIN) ./files/etc/linknx/linknxmail.sh $(1)/etc/linknx
	$(INSTALL_BIN) ./files/etc/linknx/linknxwrapper.sh $(1)/etc/linknx
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) ./files/usr/bin/esf2uci.lua $(1)/usr/bin
	$(INSTALL_BIN) ./files/usr/bin/linknxloaddata.lua $(1)/usr/bin
	$(INSTALL_BIN) ./files/usr/bin/linknxmapper.lua $(1)/usr/bin
	$(INSTALL_BIN) ./files/usr/bin/linknxreadvalue.lua $(1)/usr/bin
	$(INSTALL_BIN) ./files/usr/bin/linknxwriterule.lua $(1)/usr/bin
	$(INSTALL_BIN) ./files/usr/bin/linknxwritevalue.lua $(1)/usr/bin
	$(INSTALL_BIN) ./files/usr/bin/linknxwritevalue1.lua $(1)/usr/bin
endef

$(eval $(call BuildPackage,linknx_gen))
