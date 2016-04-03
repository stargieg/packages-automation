include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-linknx_gen
PKG_VERSION:=0.2.3
PKG_RELEASE:=1
PKG_BUILD_DEPENDS += lua/host luci-base/host
PKG_CONFIG_DEPENDS += CONFIG_LUCI_APP_LINKNX_GEN_SRCDIET
PKG_SOURCE:=linknx.tgz
PKG_SOURCE_URL:=http://firmware-ga.lunatiki.de/firmwares/
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-linknx_gen
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=3. Applications
  TITLE:=linknx config generator
  URL:=https://sourceforge.net/p/linknx/wiki/Main_Page/
  DEPENDS:=+luci-mod-admin-full \
           +luci-app-statistics \
           +linknx_gen \
           +luci-lib-nixio \
           +luci-lib-json
endef

define Package/luci-app-linknx_gen/config
  config LUCI_APP_LINKNX_GEN_SRCDIET
    bool "linknx_gen Minify Lua sources"
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
	mkdir -p $(PKG_BUILD_DIR)/linknx
	$(CP) ./luasrc $(PKG_BUILD_DIR)/
	$(CP) ./src $(PKG_BUILD_DIR)/
	$(TAR) -C $(PKG_BUILD_DIR) -xzf $(DL_DIR)/$(PKG_SOURCE)
endef

define Build/Compile
	$(if $(CONFIG_LUCI_APP_LINKNX_GEN_SRCDIET),$(call SrcDiet,$(PKG_BUILD_DIR)/luasrc/),true);
	$(MAKE) -C $(PKG_BUILD_DIR)/src  CC="$(TARGET_CC)" CFLAGS="$(TARGET_CFLAGS)"
	#$(MAKE) -C ./senchasdk/linknx INSTALL_DIR="$(PKG_BUILD_DIR)"
endef

define Package/luci-app-linknx_gen/postinst
#!/bin/sh
[ -n "${IPKG_INSTROOT}" ] || {
	( . /etc/uci-defaults/luci-app-linknx_gen ) && rm -f /etc/uci-defaults/luci-app-linknx_gen
	rm -f /tmp/luci-indexcache
	exit 0
}

endef

define Package/luci-app-linknx_gen/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/luasrc/controller/linknx_gen.lua $(1)/usr/lib/lua/luci/controller
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi/linknx
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/luasrc/model/cbi/statusjson.lua $(1)/usr/lib/lua/luci/model/cbi
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/luasrc/model/cbi/writejson.lua $(1)/usr/lib/lua/luci/model/cbi
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/luasrc/model/cbi/linknx/groups.lua $(1)/usr/lib/lua/luci/model/cbi/linknx
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/luasrc/model/cbi/linknx/linknx.lua $(1)/usr/lib/lua/luci/model/cbi/linknx
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/luasrc/model/cbi/linknx/medialist.lua $(1)/usr/lib/lua/luci/model/cbi/linknx
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/luasrc/model/cbi/linknx/public_status.lua $(1)/usr/lib/lua/luci/model/cbi/linknx
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/luasrc/model/cbi/linknx/rules.lua $(1)/usr/lib/lua/luci/model/cbi/linknx
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/luasrc/model/cbi/linknx/types.lua $(1)/usr/lib/lua/luci/model/cbi/linknx
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/luasrc/model/cbi/linknx/varlist.lua $(1)/usr/lib/lua/luci/model/cbi/linknx
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/view/linknx
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/luasrc/view/linknx/index.htm $(1)/usr/lib/lua/luci/view/linknx
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/etc/uci-defaults/luci-app-linknx_gen $(1)/etc/uci-defaults
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/etc/init.d/ws-mirror-server-linknx $(1)/etc/init.d
	$(INSTALL_BIN) ./files/etc/init.d/ubus-linknx $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/ubus-linknx $(1)/usr/sbin
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) ./files/usr/bin/linknx-uci-event.sh $(1)/usr/bin
	$(INSTALL_BIN) ./files/usr/bin/ubus-linknx.lua $(1)/usr/bin
	$(INSTALL_DIR) $(1)/www/luci-static/linknx
	$(INSTALL_DATA) ./files/www/linknx.html $(1)/www
	$(CP) $(PKG_BUILD_DIR)/linknx/* $(1)/www/luci-static/linknx
#	$(CP) $(PKG_BUILD_DIR)/production/* $(1)/www/luci-static/linknx
#	$(CP) $(PKG_BUILD_DIR)/testing/* $(1)/www/luci-static/linknx
endef

$(eval $(call BuildPackage,luci-app-linknx_gen))
