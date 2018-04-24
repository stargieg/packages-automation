include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-knxd
PKG_VERSION:=0.2.5
PKG_RELEASE:=1
PKG_BUILD_DEPENDS += lua/host luci-base/host
PKG_CONFIG_DEPENDS += CONFIG_LUCI_APP_KNXD_SRCDIET
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-knxd
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=3. Applications
  TITLE:=Eib KNX deamon
  URL:=https://github.com/knxd/knxd/wiki
  DEPENDS:=+knxd +luci-mod-admin-full +luci-lib-nixio
endef

define Package/luci-app-knxd/config
  config LUCI_APP_KNXD_SRCDIET
    bool "knxd Minify Lua sources"
    default n
endef

define SrcDiet
  $(FIND) $(1) -type f -name '*.lua' | while read src; do \
    if $(STAGING_DIR_HOST)/bin/lua $(STAGING_DIR_HOST)/bin/LuaSrcDiet \
      --noopt-binequiv -o "$$$$src.o" "$$$$src"; \
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
	$(if $(CONFIG_LUCI_APP_KNXD_SRCDIET),$(call SrcDiet,$(PKG_BUILD_DIR)/luasrc/),true);
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
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/view
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/luasrc/controller/knxd.lua $(1)/usr/lib/lua/luci/controller
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/luasrc/model/cbi/knxd.lua $(1)/usr/lib/lua/luci/model/cbi
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/luasrc/view/knxd_diag.htm $(1)/usr/lib/lua/luci/view
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) files/etc/uci-defaults/luci-app-knxd $(1)/etc/uci-defaults/
endef

$(eval $(call BuildPackage,luci-app-knxd))
