# $Id: Makefile 2010-02-04 23:25:21Z pg $

include $(TOPDIR)/rules.mk

PKG_NAME:=linknx-statistics
PKG_VERSION:=0.2.0
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/linknx-statistics
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=3. Applications
  TITLE:=Linknx LuCI Statistics Application
  DEPENDS:=+luci-app-statistics
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

define Package/linknx-statistics/postinst
#!/bin/sh
[ -n "${IPKG_INSTROOT}" ] || {
	rm -f /tmp/luci-indexcache
	exit 0
}

endef

define Package/linknx-statistics/install
	$(INSTALL_DIR) $(1)/etc/collectd/conf.d
	$(INSTALL_DATA) ./files/etc/collectd/conf.d/linknx.conf $(1)/etc/collectd/conf.d
	$(INSTALL_DIR) $(1)/usr/share/collectd
	$(INSTALL_DATA) ./files/usr/share/collectd/linknx.db $(1)/usr/share/collectd
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/etc/uci-defaults/* $(1)/etc/uci-defaults
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) ./files/usr/bin/* $(1)/usr/bin
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller/luci_statistics
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/luasrc/controller/luci_statistics/linknx_statistics.lua $(1)/usr/lib/lua/luci/controller/luci_statistics
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/statistics/rrdtool/definitions
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/luasrc/statistics/rrdtool/definitions/ezr.lua $(1)/usr/lib/lua/luci/statistics/rrdtool/definitions
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/luasrc/statistics/rrdtool/definitions/hk.lua $(1)/usr/lib/lua/luci/statistics/rrdtool/definitions
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/luasrc/statistics/rrdtool/definitions/rlt.lua $(1)/usr/lib/lua/luci/statistics/rrdtool/definitions
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/view/public_statistics
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/luasrc/view/public_statistics/graph_linknx.htm $(1)/usr/lib/lua/luci/view/public_statistics/
endef

$(eval $(call BuildPackage,linknx-statistics))
