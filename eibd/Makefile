# $Id: Makefile 2010-02-04 23:25:21Z pg $


include $(TOPDIR)/rules.mk

PKG_NAME:=bcusdk
PKG_VERSION:=0.0.5
PKG_RELEASE:=6
PKG_MD5SUM:=5f81bc4e6bb53564573d573e795a9a5f
PKG_SOURCE_URL:=http://switch.dl.sourceforge.net/project/bcusdk/bcusdk
PKG_SOURCE:=$(PKG_NAME)_$(PKG_VERSION).tar.gz
PKG_CAT:=zcat

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_BUILD_DEPENDS:=pthsem libxml2 argp-standalone

include $(INCLUDE_DIR)/package.mk

define Package/eibd
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Eib KNX deamon
  URL:=http://www.auto.tuwien.ac.at/~mkoegler/index.php/eibd
  DEPENDS:=+libeibd
endef

define Package/eibd/description
EIB KNX Daemon
endef

define Package/eibd-utils
	SECTION:=net
	CATEGORY:=Network
	TITLE:=Eib KNX Utils
	URL:=http://www.auto.tuwien.ac.at/~mkoegler/index.php/eibd
	DEPENDS:=+libeibd
endef

define Package/libeibd
	SECTION:=lib
	CATEGORY:=Network
	TITLE:=Eib KNX lib
	URL:=http://www.auto.tuwien.ac.at/~mkoegler/index.php/eibd
	DEPENDS:=+pthsem +libstdcpp
endef


define Package/eibd-utils/description
EIB KNX Utils
endef
define Build/Prepare
	$(call Build/Prepare/Default)
endef


define Build/Configure
	$(call Build/Configure/Default,--without-pth-test \
		--enable-onlyeibd \
		--enable-ft12 \
		--enable-eibnetip \
		--enable-eibnetiptunnel \
		--enable-eibnetipserver \
		--enable-usb \
		--enable-tpuart \
		--enable-tpuarts \
		--enable-pei16 \
		--enable-pei16s \
		--enable-groupcache \
		--without-pth-test \
		--without-libstdc )
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
		CC=$(TARGET_CC) \
		LIBS="-L$(STAGING_DIR)/usr/lib -fno-builtin -nostdinc++ -nodefaultlibs -lstdc++ -lc -lm -lgcc -largp -lpthsem " \
		CPPFLAGS="-I$(STAGING_DIR)/include -I$(STAGING_DIR)/usr/include"
		# -I$(LINUX_DIR)/include"

endef

define Package/eibd/postinst
#!/bin/sh
[ -n "${IPKG_INSTROOT}" ] || {
	( . /etc/uci-defaults/eibd ) &&	rm -f /etc/uci-defaults/eibd
	/etc/init.d/eibd enable
	/etc/init.d/eibd start
	exit 0
}

endef

define Package/eibd/install
	$(CP) -a ./ipkg/* $(1)/CONTROL/ 2>/dev/null || true
	$(CP) ./files/* $(1)/
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/eibd/server/eibd $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/eibd/bcu/bcuaddrtab $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/eibd/bcu/bcuread $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/eibd/usb/findknxusb $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/eibd/eibnet/eibnetsearch $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/eibd/eibnet/eibnetdescribe $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/eibd/examples/.libs/knxtool $(1)/usr/bin/
	-rm -f $(1)/usr/bin/knxread
	-rm -f $(1)/usr/bin/knxreadtemp
	-rm -f $(1)/usr/bin/knxwrite
	-rm -f $(1)/usr/bin/knxlog
	-rm -f $(1)/usr/bin/knxon
	-rm -f $(1)/usr/bin/knxoff
	-rm -f $(1)/usr/bin/knxif
	-rm -f $(1)/usr/bin/knxswrite
	-rm -f $(1)/usr/bin/knxbool
	-rm -f $(1)/usr/bin/knxdimup
	ln -s knxtool $(1)/usr/bin/knxread
	ln -s knxtool $(1)/usr/bin/knxreadtemp
	ln -s knxtool $(1)/usr/bin/knxwrite
	ln -s knxtool $(1)/usr/bin/knxlog
	ln -s knxtool $(1)/usr/bin/knxon
	ln -s knxtool $(1)/usr/bin/knxoff
	ln -s knxtool $(1)/usr/bin/knxif
	ln -s knxtool $(1)/usr/bin/knxswrite
	ln -s knxtool $(1)/usr/bin/knxbool
	ln -s knxtool $(1)/usr/bin/knxdimup
endef

define Package/eibd-utils/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/eibd/examples/.libs/busmonitor1 $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/eibd/examples/.libs/busmonitor2 $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/eibd/examples/.libs/groupcacheclear $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/eibd/examples/.libs/groupcachedisable $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/eibd/examples/.libs/groupcacheenable $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/eibd/examples/.libs/groupcacheread $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/eibd/examples/.libs/groupcachereadsync $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/eibd/examples/.libs/groupcacheremove $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/eibd/examples/.libs/grouplisten $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/eibd/examples/.libs/groupread $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/eibd/examples/.libs/groupreadresponse $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/eibd/examples/.libs/groupresponse $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/eibd/examples/.libs/groupsocketlisten $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/eibd/examples/.libs/groupsocketread $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/eibd/examples/.libs/groupsocketswrite $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/eibd/examples/.libs/groupsocketwrite $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/eibd/examples/.libs/groupsresponse $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/eibd/examples/.libs/groupswrite $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/eibd/examples/.libs/groupwrite $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/eibd/examples/.libs/madcread $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/eibd/examples/.libs/maskver $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/eibd/examples/.libs/mmaskver $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/eibd/examples/.libs/mpeitype $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/eibd/examples/.libs/mprogmodeoff $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/eibd/examples/.libs/mprogmodeon $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/eibd/examples/.libs/mprogmodestatus $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/eibd/examples/.libs/mprogmodetoggle $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/eibd/examples/.libs/mpropdesc $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/eibd/examples/.libs/mpropread $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/eibd/examples/.libs/mpropscan $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/eibd/examples/.libs/mpropscanpoll $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/eibd/examples/.libs/mpropwrite $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/eibd/examples/.libs/mread $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/eibd/examples/.libs/mrestart $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/eibd/examples/.libs/msetkey $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/eibd/examples/.libs/mwrite $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/eibd/examples/.libs/mwriteplain $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/eibd/examples/.libs/progmodeoff $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/eibd/examples/.libs/progmodeon $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/eibd/examples/.libs/progmodestatus $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/eibd/examples/.libs/progmodetoggle $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/eibd/examples/.libs/readindividual $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/eibd/examples/.libs/vbusmonitor1 $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/eibd/examples/.libs/vbusmonitor1poll $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/eibd/examples/.libs/vbusmonitor2 $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/eibd/examples/.libs/writeaddress $(1)/usr/bin/
endef

define Package/libeibd/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/eibd/client/c/.libs/libeibclient.so.0.0.0 $(1)/usr/lib/
	ln -s libeibclient.so.0.0.0 $(1)/usr/lib/libeibclient.so
	ln -s libeibclient.so.0.0.0 $(1)/usr/lib/libeibclient.so.0
endef


$(eval $(call BuildPackage,eibd))
$(eval $(call BuildPackage,eibd-utils))
$(eval $(call BuildPackage,libeibd))

