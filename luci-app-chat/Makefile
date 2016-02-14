include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-chat
PKG_VERSION:=0.8
PKG_RELEASE:=0

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-chat
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=3. Applications
  TITLE:=LocalChat
  DEPENDS:=+ws-mirror-server +luci-mod-admin-full
endef

define Package/luci-app-chat/description
  Local Chat via Web Sockets
  with libwsocket
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

define Package/luci-app-chat/postinst
#!/bin/sh
[ -n "${IPKG_INSTROOT}" ] || {
	rm -f /tmp/luci-indexcache
	exit 0
}
endef

define Package/luci-app-chat/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/view
	$(CP) $(PKG_BUILD_DIR)/luasrc/controller/* $(1)/usr/lib/lua/luci/controller
	$(CP) $(PKG_BUILD_DIR)/luasrc/view/* $(1)/usr/lib/lua/luci/view
	$(INSTALL_DIR) $(1)/www/luci-static/resources
	$(CP) ./luci-static/resources/* $(1)/www/luci-static/resources
endef

$(eval $(call BuildPackage,luci-app-chat))
