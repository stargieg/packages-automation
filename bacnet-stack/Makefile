include $(TOPDIR)/rules.mk

PKG_NAME:=bacnet-stack
PKG_VERSION:=2013-09-21-7
PKG_SOURCE_VERSION:=3dfa360ef5a472dde4abc4397f1d22e95d84374e
PKG_RELEASE:=$(PKG_SOURCE_VERSION)

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=git://github.com/stargieg/bacnet-stack.git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz


include $(INCLUDE_DIR)/package.mk


define Package/bacnet-stack
  SECTION:=net
  CATEGORY:=Network
  TITLE:=BACnet Protocol Stack UCI Fork
  URL:=http://bacnet-stack.sourceforge.net/
  DEPENDS:=+libpthread +librt +libuci
endef

define Package/bacnet-stack/description
  Data Communication Protocol for Building Automation and Control Networks
endef

TARGET_CFLAGS += -I$(STAGING_DIR)/usr/include
#BUILD=debug
#BACDL_DEFINE=-DBACDL_MSTP=1
#BACDL_DEFINE=-DBACDL_ETHERNET=1
BACDL_DEFINE=-DBACDL_BIP=1

# un-comment the next line to build the routing demo application
#BACNET_DEFINES += -DBAC_ROUTING

# Declare your level of BBMD support
BBMD_DEFINE:=-DBBMD_ENABLED=0
#BBMD_DEFINE:=-DBBMD_ENABLED=1
#BBMD_DEFINE:=-DBBMD_CLIENT_ENABLED

BACNET_PORT:=linux

define Package/bacnet-stack/postinst
#!/bin/sh

if [ -z $${IPKG_INSTROOT} ] ; then
	( . /etc/uci-defaults/bacserv ) && rm /etc/uci-defaults/bacserv
fi

[ -n $${IPKG_INSTROOT} ] || {
	/etc/init.d/bacserv enable
	/etc/init.d/bacserv restart
}
endef

define Package/bacnet-stack/install
	$(INSTALL_DIR) $(1)/usr/bin $(1)/usr/sbin $(1)/etc/init.d $(1)/etc/config $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/bacserv.defaults $(1)/etc/uci-defaults/bacserv
	$(INSTALL_BIN) ./files/bacserv.init $(1)/etc/init.d/bacserv
	$(INSTALL_DATA) ./files/bacnet_dev.config $(1)/etc/config/bacnet_dev
	$(INSTALL_DATA) ./files/bacnet_av.config $(1)/etc/config/bacnet_av
	$(INSTALL_DATA) ./files/bacnet_mv.config $(1)/etc/config/bacnet_mv
	$(INSTALL_DATA) ./files/bacnet_nc.config $(1)/etc/config/bacnet_nc
	$(INSTALL_DATA) ./files/bacnet_bi.config $(1)/etc/config/bacnet_bi
	$(INSTALL_DATA) ./files/bacnet_group.config $(1)/etc/config/bacnet_group
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/bacserv $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/bacarf $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/bacarf $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/bacdcc $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/baciamr $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/bacrd $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/bacrpm $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/bacucov $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/bacwh $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/bacwir $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/mstpcap $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/bacawf $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/bacepics $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/bacinitr $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/bacrp $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/bacscov $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/bacts $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/bacupt $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/bacwi $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/bacwp $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/mstpcrc $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/bacrpd.sh $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/bvlc.sh $(1)/usr/bin/
endef

$(eval $(call BuildPackage,bacnet-stack))
