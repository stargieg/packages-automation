# $Id: Makefile 1146 2005-06-05 13:32:28Z nbd $

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-eibd
PKG_RELEASE:=0.1.1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-eibd
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=3. Applications
  TITLE:=Eib KNX deamon
  URL:=http://www.auto.tuwien.ac.at/~mkoegler/index.php/eibd
  DEPENDS:=+eibd +luci-lib-web
endef

define Package/luci-app-eibd/description
  http://www.auto.tuwien.ac.at/~mkoegler/index.php/eibd
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

define Package/luci-app-eibd/postinst
#!/bin/sh
[ -n "${IPKG_INSTROOT}" ] || {
	rm -f /tmp/luci-indexcache
	exit 0
}

endef

define Package/luci-app-eibd/install
	$(CP) -a ./ipkg/* $(1)/CONTROL/ 2>/dev/null || true
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi/eibd
	$(CP) $(PKG_BUILD_DIR)/luasrc/controller/eibd.lua $(1)/usr/lib/lua/luci/controller
	$(CP) $(PKG_BUILD_DIR)/luasrc/model/cbi/eibd/eibd.lua $(1)/usr/lib/lua/luci/model/cbi/eibd
	$(CP) $(PKG_BUILD_DIR)/luasrc/model/cbi/eibd/eibdmini.lua $(1)/usr/lib/lua/luci/model/cbi/eibd
endef

$(eval $(call BuildPackage,luci-app-eibd))
