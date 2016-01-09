# $Id: Makefile 1146 2005-06-05 13:32:28Z nbd $

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-knxd
PKG_VERSION:=0.2.0
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-knxd
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=3. Applications
  TITLE:=Eib KNX deamon
  URL:=https://github.com/knxd/knxd/wiki
  DEPENDS:=+knxd +luci-mod-admin-full
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

define Package/luci-app-knxd/postinst
#!/bin/sh
[ -n "${IPKG_INSTROOT}" ] || {
	rm -f /tmp/luci-indexcache
	exit 0
}

endef

define Package/luci-app-knxd/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/luasrc/controller/knxd.lua $(1)/usr/lib/lua/luci/controller
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/luasrc/model/cbi/knxd.lua $(1)/usr/lib/lua/luci/model/cbi
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) files/etc/uci-defaults/luci-app-knxd $(1)/etc/uci-defaults/
endef

$(eval $(call BuildPackage,luci-app-knxd))
