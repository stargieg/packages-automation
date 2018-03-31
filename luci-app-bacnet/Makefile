include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-bacnet
PKG_VERSION:=0.1.14
PKG_RELEASE:=5
PKG_BUILD_DEPENDS += lua/host luci-base/host
PKG_CONFIG_DEPENDS += CONFIG_LUCI_APP_BACNET_SRCDIET
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-bacnet
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=3. Applications
  TITLE:=Bacnet Device
  DEPENDS:=+bacnet-stack-uci +luci-mod-admin-full
endef

define Package/luci-app-bacnet/config
  config LUCI_APP_BACNET_SRCDIET
    bool "bacnet Minify Lua sources"
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
	$(if $(CONFIG_LUCI_APP_BACNET_SRCDIET),$(call SrcDiet,$(PKG_BUILD_DIR)/luasrc/),true);
endef

define Package/luci-app-bacnet/postinst
#!/bin/sh
[ -n "${IPKG_INSTROOT}" ] || {
	rm -f /tmp/luci-indexcache
	exit 0
}
endef

define Package/luci-app-bacnet/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/luasrc/controller/* $(1)/usr/lib/lua/luci/controller
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi/bacnet
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/luasrc/model/cbi/bacnet/* $(1)/usr/lib/lua/luci/model/cbi/bacnet
endef

$(eval $(call BuildPackage,luci-app-bacnet))
