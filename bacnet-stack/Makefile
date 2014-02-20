include $(TOPDIR)/rules.mk

PKG_NAME:=bacnet-stack
PKG_VERSION:=2014-02-20-1
PKG_SOURCE_VERSION:=7e4108a58363682ee54f39b738859464e5a6f6d4
PKG_RELEASE:=$(PKG_SOURCE_VERSION)

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=git://github.com/stargieg/bacnet-stack.git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz
#PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(BUILD_VARIANT)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk


define Package/bacnet-stack/Default
  SECTION:=net
  CATEGORY:=Network
  TITLE:=BACnet Protocol Stack UCI Fork
  URL:=http://bacnet-stack.sourceforge.net/
  DEPENDS:=+libpthread +librt +libuci
endef

define Package/bacnet-stack/Default/description
  Data Communication Protocol for Building Automation and Control Networks
endef

define Package/bacnet-stack-uci
$(call Package/bacnet-stack/Default)
  TITLE+= (UCI)
  VARIANT:=uci
endef

define Package/bacnet-stack-uci/description
  This package is a BACnet Meta Package with uci integration.
endef

define Package/bacnet-stack-utils
$(call Package/bacnet-stack/Default)
  TITLE+= (Utils)
  VARIANT:=utils
endef

define Package/bacnet-stack-utils/description
  This package is a BACnet utils bacrp,bacepics.
endef

define Package/bacnet-stack-bip
$(call Package/bacnet-stack/Default)
  TITLE+= (IPv4)
  VARIANT:=bip
  DEPENDS+= +bacnet-stack-uci
endef

define Package/bacnet-stack-bip/description
  This package is built with IPv4 support.
endef

define Package/bacnet-stack-ethernet
$(call Package/bacnet-stack/Default)
  TITLE+= (ETHERNET)
  VARIANT:=ethernet
  DEPENDS+= +bacnet-stack-uci
endef

define Package/bacnet-stack-ethernet/description
  This package is built with Ethernet support.
endef

define Package/bacnet-stack-mstp
$(call Package/bacnet-stack/Default)
  TITLE+= (MSTP)
  VARIANT:=mstp
  DEPENDS+= +bacnet-stack-uci
endef

define Package/bacnet-stack-mstp/description
  This package is built with MSTP support.
endef

TARGET_CFLAGS += -I$(STAGING_DIR)/usr/include
BUILD = debug

ifeq ($(BUILD_VARIANT),bip)
MAKE_VARS += BACDL_DEFINE=-DBACDL_BIP=1
endif

ifeq ($(BUILD_VARIANT),ethernet)
MAKE_VARS += BACDL_DEFINE=-DBACDL_ETHERNET=1
endif

ifeq ($(BUILD_VARIANT),mstp)
MAKE_VARS += BACDL_DEFINE=-DBACDL_MSTP=1
endif

ifeq ($(BUILD_VARIANT),utils)
MAKE_VARS += BACDL_DEFINE=-DBACDL_BIP=1
endif

ifeq ($(BUILD_VARIANT),uci)
define Build/Compile
endef
endif

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

define Package/bacnet-stack-uci/install
	$(INSTALL_DIR) $(1)/etc/init.d $(1)/etc/config $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/bacserv.defaults $(1)/etc/uci-defaults/bacserv
	$(INSTALL_BIN) ./files/bacserv.init $(1)/etc/init.d/bacserv
	$(INSTALL_DATA) ./files/bacnet_dev.config $(1)/etc/config/bacnet_dev
	$(INSTALL_DATA) ./files/bacnet_av.config $(1)/etc/config/bacnet_av
	$(INSTALL_DATA) ./files/bacnet_ao.config $(1)/etc/config/bacnet_ao
	$(INSTALL_DATA) ./files/bacnet_mv.config $(1)/etc/config/bacnet_mv
	$(INSTALL_DATA) ./files/bacnet_mi.config $(1)/etc/config/bacnet_mi
	$(INSTALL_DATA) ./files/bacnet_mo.config $(1)/etc/config/bacnet_mo
	$(INSTALL_DATA) ./files/bacnet_nc.config $(1)/etc/config/bacnet_nc
	$(INSTALL_DATA) ./files/bacnet_bi.config $(1)/etc/config/bacnet_bi
	$(INSTALL_DATA) ./files/bacnet_bv.config $(1)/etc/config/bacnet_bv
	$(INSTALL_DATA) ./files/bacnet_group.config $(1)/etc/config/bacnet_group
endef

define Package/bacnet-stack-bip/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/bacserv $(1)/usr/sbin/bacserv-bip
endef

define Package/bacnet-stack-ethernet/install
	$(INSTALL_DIR) $(1)/usr/bin $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/bacserv $(1)/usr/sbin/bacserv-ethernet
endef

define Package/bacnet-stack-mstp/install
	$(INSTALL_DIR) $(1)/usr/bin $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/bacserv $(1)/usr/sbin/bacserv-mstp
endef

define Package/bacnet-stack-util/install
	$(INSTALL_DIR) $(1)/usr/bin
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

$(eval $(call BuildPackage,bacnet-stack-uci))
$(eval $(call BuildPackage,bacnet-stack-bip))
$(eval $(call BuildPackage,bacnet-stack-ethernet))
$(eval $(call BuildPackage,bacnet-stack-mstp))
$(eval $(call BuildPackage,bacnet-stack-utils))
