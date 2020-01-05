include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-linknx
PKG_VERSION:=0.3.2
PKG_RELEASE:=1
PKG_BUILD_DEPENDS += LUCI_APP_LINKNX_SRCDIET:luasrcdiet/host
PKG_CONFIG_DEPENDS += CONFIG_LUCI_APP_LINKNX_SRCDIET
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-linknx
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=3. Applications
  TITLE:=linknx daemon
  URL:=https://github.com/linknx/linknx/wiki
  EXTRA_DEPENDS:=linknx-uci, luci-mod-admin-full, collectd-mod-exec, luci-app-statistics
endef

define Package/luci-app-linknx/config
  config LUCI_APP_LINKNX_SRCDIET
    bool "linknx Minify Lua sources"
    default n
endef

define SrcDiet
  $(FIND) $(1) -type f -name '*.lua' | while read src; do \
    if LUA_PATH="$(STAGING_DIR_HOSTPKG)/lib/lua/5.1/?.lua" luasrcdiet --noopt-binequiv -o "$$$$src.o" "$$$$src"; \
    then mv "$$$$src.o" "$$$$src"; fi; \
  done
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./luasrc $(PKG_BUILD_DIR)/
endef

define Build/Configure
endef

define Build/Compile
	$(if $(CONFIG_LUCI_APP_LINKNX_SRCDIET),$(call SrcDiet,$(PKG_BUILD_DIR)/luasrc/),true);
endef

define Package/luci-app-linknx/postinst
#!/bin/sh
[ -n "${IPKG_INSTROOT}" ] || {
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
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/luasrc/model/cbi/linknx_xml.lua $(1)/usr/lib/lua/luci/model/cbi
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/luasrc/view/linknx_diag.htm $(1)/usr/lib/lua/luci/view
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/etc/uci-defaults/linknx-uci $(1)/etc/uci-defaults
	$(INSTALL_DIR) $(1)/etc/collectd/conf.d
	$(INSTALL_DATA) ./files/etc/collectd/conf.d/linknx.conf $(1)/etc/collectd/conf.d
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) ./files/usr/bin/linknx-stat.sh $(1)/usr/bin
	$(INSTALL_DIR) $(1)/usr/share/collectd
	$(INSTALL_DATA) ./files/usr/share/collectd/linknx.db $(1)/usr/share/collectd
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/statistics/rrdtool/definitions
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/luasrc/statistics/rrdtool/definitions/linknx.lua $(1)/usr/lib/lua/luci/statistics/rrdtool/definitions
endef

$(eval $(call BuildPackage,luci-app-linknx))
