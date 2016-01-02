# $Id: Makefile 2010-02-04 23:25:21Z pg $

include $(TOPDIR)/rules.mk

PKG_NAME:=linknx-statistics
PKG_VERSION:=0.0.1
PKG_RELEASE:=4

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/linknx-statistics
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=3. Applications
  TITLE:=Linknx LuCI Statistics Application
  DEPENDS:=+collectd +rrdtool1 +collectd-mod-rrdtool +collectd-mod-interface +collectd-mod-load +collectd-mod-exec +collectd-mod-network +luci-app-statistics
endef

define Package/linknx-statistics/conffiles
	/etc/config/linknx_luci_statistics
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/luci-app-eibd/postinst
#!/bin/sh
[ -n "${IPKG_INSTROOT}" ] || {
	( . /etc/uci-defaults/linknx-statistics ) && rm -f /etc/uci-defaults/linknx-statistics
	rm -f /tmp/luci-indexcache
	/etc/init.d/luci_statistics enable
	/etc/init.d/collectd enable
	/etc/init.d/luci_statistics start
	/etc/init.d/collectd start
	exit 0
}

endef

define Package/linknx-statistics/install
	$(CP) -a ./ipkg/* $(1)/CONTROL/ 2>/dev/null || true
	$(INSTALL_DIR) $(1)/etc/collectd/conf.d
	$(CP) ./files/etc/collectd/conf.d/linknx.conf $(1)/etc/collectd/conf.d
	$(INSTALL_DIR) $(1)/usr/share/collectd
	$(CP) ./files/usr/share/collectd/linknx.db $(1)/usr/share/collectd
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(CP) ./files/etc/uci-defaults/* $(1)/etc/uci-defaults
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) ./files/usr/bin/* $(1)/usr/bin
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci
	$(CP) ./luasrc/* $(1)/usr/lib/lua/luci
endef

$(eval $(call BuildPackage,linknx-statistics))
