include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-modbus
PKG_VERSION:=0.7
PKG_RELEASE:=4
PKG_BUILD_DEPENDS += LUCI_APP_MODBUS_SRCDIET:luasrcdiet/host
PKG_CONFIG_DEPENDS += CONFIG_LUCI_APP_MODBUS_SRCDIET
PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-modbus
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=3. Applications
  TITLE:=Modbus Device
  EXTRA_DEPENDS:=modbus-uci, luci-mod-admin-full, luci-lib-nixio
endef

define Package/luci-app-modbus/config
  config LUCI_APP_MODBUS_SRCDIET
    bool "modbus Minify Lua sources"
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
	$(if $(CONFIG_LUCI_APP_MODBUS_SRCDIET),$(call SrcDiet,$(PKG_BUILD_DIR)/luasrc/),true);
endef

define Package/luci-app-modbus/postinst
#!/bin/sh
[ -n "${IPKG_INSTROOT}" ] || {
	rm -f /tmp/luci-indexcache
	exit 0
}
endef

define Package/luci-app-modbus/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi
	$(CP) $(PKG_BUILD_DIR)/luasrc/controller/* $(1)/usr/lib/lua/luci/controller
	$(CP) $(PKG_BUILD_DIR)/luasrc/model/cbi/* $(1)/usr/lib/lua/luci/model/cbi
endef

$(eval $(call BuildPackage,luci-app-modbus))
