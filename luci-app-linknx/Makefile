# $Id: Makefile 1146 2005-06-05 13:32:28Z nbd $

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-linknx
PKG_VERSION:=0.2.0
PKG_RELEASE:=2

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-linknx
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=3. Applications
  TITLE:=linknx daemon
  URL:=https://github.com/linknx/linknx/wiki
  DEPENDS:=+linknx +luci-mod-admin-full +luci-lib-nixio
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./luasrc $(PKG_BUILD_DIR)/
endef

define Build/Configure
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR)/luasrc
endef

define Package/luci-app-linknx/postinst
#!/bin/sh
[ -n "${IPKG_INSTROOT}" ] || {
	( . /etc/uci-defaults/luci-app-linknx ) && rm -f /etc/uci-defaults/luci-app-linknx
	rm -f /tmp/luci-indexcache
	exit 0
}

endef

define Package/luci-app-linknx/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/view
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/luasrc/controller/linknx.lua $(1)/usr/lib/lua/luci/controller
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/luasrc/model/cbi/linknx.lua $(1)/usr/lib/lua/luci/model/cbi
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/luasrc/view/linknx_diag.htm $(1)/usr/lib/lua/luci/view
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) files/etc/uci-defaults/luci-app-linknx $(1)/etc/uci-defaults/
endef

$(eval $(call BuildPackage,luci-app-linknx))
