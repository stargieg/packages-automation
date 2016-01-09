# $Id: Makefile 1146 2005-06-05 13:32:28Z nbd $

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-linknx_gen
PKG_RELEASE:=0.2.0
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-linknx_gen
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=3. Applications
  TITLE:=linknx config generator
  URL:=https://sourceforge.net/p/linknx/wiki/Main_Page/
  DEPENDS:=+linknx_gen +luci-mod-admin-full +luci-lib-json
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./luasrc $(PKG_BUILD_DIR)/
	#$(CP) ./src $(PKG_BUILD_DIR)/
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR)/luasrc
	#$(MAKE) -C $(PKG_BUILD_DIR)/src  CC="$(TARGET_CC)" CFLAGS="$(TARGET_CFLAGS)"
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
	#$(INSTALL_BIN) ./files/etc/init.d/ws-mirror-server-linknx $(1)/etc/init.d
	#$(INSTALL_DIR) $(1)/etc/init.d
	#$(INSTALL_BIN) ./files/etc/init.d/ubus-linknx $(1)/etc/init.d
	#$(INSTALL_DIR) $(1)/usr/sbin
	#$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/ubus-linknx $(1)/usr/sbin
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) ./files/usr/bin/linknx-uci-event.sh $(1)/usr/bin
	$(INSTALL_BIN) ./files/usr/bin/ubus-linknx.lua $(1)/usr/bin
	$(INSTALL_DIR) $(1)/www/luci-static/linknx
	$(INSTALL_DATA) ./files/www/linknx.html $(1)/www
#	$(CP) $(PKG_BUILD_DIR)/production/* $(1)/www/luci-static/linknx
#	$(CP) $(PKG_BUILD_DIR)/testing/* $(1)/www/luci-static/linknx
endef

$(eval $(call BuildPackage,luci-app-linknx_gen))
