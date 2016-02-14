include $(TOPDIR)/rules.mk

PKG_NAME:=ws-mirror-server
PKG_VERSION:=0.9
PKG_RELEASE:=0

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/ws-mirror-server/default
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  TITLE:=ws-mirror-server - Websocket Mirror Server for js chat
  DEPENDS:=+libwebsockets +zlib \
    +libubox +libubus +ubusd +libblobmsg-json \
    +px5g +uhttpd
endef

define Package/ws-mirror-server
  $(Package/ws-mirror-server/default)
  MENU:=1
endef

define Package/ws-mirror-server/description
 ws-mirror-server Websocket Mirror Server for js chat
 use libwebsockets http://git.warmcat.com/cgi-bin/cgit/libwebsockets
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./src/Makefile $(PKG_BUILD_DIR)/
	$(CP) ./src/*.c $(PKG_BUILD_DIR)/
endef

define Package/ws-mirror-server/postinst
#!/bin/sh
if [ -z $${IPKG_INSTROOT} ] ; then
	/etc/init.d/ws-mirror-server enable
	/etc/init.d/ws-mirror-server start
fi
endef

define Package/ws-mirror-server/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/ws-mirror-server.init $(1)/etc/init.d/ws-mirror-server
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ws-mirror-server $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ws-mirror-server-ubus $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/www/ws-chat
	$(INSTALL_DATA) ./files/cascade.css $(1)/www/ws-chat
	$(INSTALL_DATA) ./files/chat.js $(1)/www/ws-chat
	$(INSTALL_DATA) ./files/favicon.ico $(1)/www/ws-chat
	$(INSTALL_DATA) ./files/index.html $(1)/www/ws-chat
	$(INSTALL_DATA) ./files/mobile.css $(1)/www/ws-chat
endef

$(eval $(call BuildPackage,ws-mirror-server))
