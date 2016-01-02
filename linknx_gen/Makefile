# $Id: Makefile 1146 2005-06-05 13:32:28Z nbd $

include $(TOPDIR)/rules.mk

PKG_NAME:=linknx
PKG_VERSION:=0.0.1.30
PKG_RELEASE:=6
PKG_MD5SUM:=5e0bb20131d958ef18f49c9cd373e204

PKG_SOURCE_URL:=@SF/linknx
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_CAT:=zcat
PKG_BUILD_DEPENDS:=pthsem curl argp-standalone

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
include $(INCLUDE_DIR)/package.mk

define Package/linknx
  SECTION:=net
  CATEGORY:=Network
  TITLE:=KNX home automation platform
  URL:=http://www.ouaye.net/linknx
  DEPENDS:=+pthsem +uclibcxx +lua +luac +libcurl +libesmtp +ubus +libcurl
endef

define Package/linknx/description
  KNX event daemon
endef

#define Build/Configure
#	(cd $(PKG_BUILD_DIR); \
#	$(SED) 's,\"2.0.4\",\"2.0.4\"\n_pth_version=\"2.0.8\",g' $(PKG_BUILD_DIR)/configure )
#	$(call Build/Configure/Default,--verbose --without-pth-test --with-pth=$(STAGING_DIR) --without-log4cpp --with-lua --with-libcurl --without-mysql, \
#	CXXFLAGS="$(TARGET_CFLAGS) -fno-builtin -lcrypt" \
#	)
#endef

define Build/Configure
	(cd $(PKG_BUILD_DIR); \
	$(SED) 's,\"2.0.4\",\"2.0.4\"\n_pth_version=\"2.0.8\",g' $(PKG_BUILD_DIR)/configure )
	$(call Build/Configure/Default,--without-log4cpp --disable-mysql --without-mysql --disable-smtp --without-pth-test,\
	CXXFLAGS="$(TARGET_CFLAGS) -fno-builtin -nostdinc++ -lcrypt" \
	CPPFLAGS="-I$(STAGING_DIR)/usr/include -I$(STAGING_DIR)/include" \
	LDFLAGS="-nodefaultlibs -L$(STAGING_DIR)/usr/lib -L$(STAGING_DIR)/lib -luClibc++ -lc -lm -lgcc -lgcc_s")
endef

define Build/Clean
endef

#define Build/Compile
#	$(MAKE) -C $(PKG_BUILD_DIR)/ \
#		LIBDIR="$(TARGET_LDFLAGS)" \
#		CC="$(TARGET_CC) $(TARGET_CFLAGS) $(TARGET_CPPFLAGS) " \
#		LD="$(TARGET_CROSS)ld -shared" \
#		LUA="$(STAGING_DIR_HOST)/bin/lua" \
#		LUAC="$(STAGING_DIR_HOST)/bin/luac" \
#		CFLAGS="$(TARGET_CFLAGS) -nostdinc++ -nodefaultlibs" all
#endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
	CC=$(TARGET_CC) \
	LIBS="-L$(STAGING_DIR)/lib -fno-builtin -nostdinc++ -nodefaultlibs -luClibc++ -lc -lm -lgcc_s -lgcc -largp -lpthsem" \
	CPPFLAGS="-I$(STAGING_DIR)/include -I$(STAGING_DIR)/usr/include -I$(STAGING_DIR)/usr/include/uClibc++"
endef

define Package/linknx/postinst
#!/bin/sh
[ -n "${IPKG_INSTROOT}" ] || {
	( . /etc/uci-defaults/linknx ) &&	rm -f /etc/uci-defaults/linknx
	/etc/init.d/ubus enable
	[ -n "$(pidof ubusd)" ] || /etc/init.d/ubus start
	/etc/init.d/linknx enable
	/etc/init.d/linknx start
	exit 0
}

endef

define Package/linknx/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/etc/linknx
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/linknx $(1)/usr/sbin/
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,linknx))
