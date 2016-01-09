# $Id: Makefile 1146 2005-06-05 13:32:28Z nbd $

include $(TOPDIR)/rules.mk

PKG_NAME:=linknx_gen
PKG_VERSION:=0.0.1.30
PKG_RELEASE:=6

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/linknx_gen
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Config generator for KNX
  URL:=https://sourceforge.net/p/linknx/wiki/Main_Page/
  DEPENDS:=+linknx +luci-lib-json +luci-lib-nixio
endef

define Package/linknx_gen/description
  KNX event daemon
endef

define Build/Compile
endef

define Package/linknx_gen/postinst
#!/bin/sh
[ -n "${IPKG_INSTROOT}" ] || {
	/etc/init.d/linknx_gen enable
	/etc/init.d/linknx_gen restart
	exit 0
}
endef

define Package/linknx_gen/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/etc/linknx
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_DIR) $(1)/usr/sbin
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,linknx_gen))
