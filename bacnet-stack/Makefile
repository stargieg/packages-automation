include $(TOPDIR)/rules.mk

PKG_NAME:=bacnet-stack
PKG_VERSION:=2018-03-31-8
PKG_SOURCE_VERSION:=ba42aacd7758a8d6b0937c05400c4b5efb5d3f04
PKG_RELEASE:=$(PKG_SOURCE_VERSION)

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=git://github.com/stargieg/bacnet-stack.git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(BUILD_VARIANT)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk


define Package/bacnet-stack/Default
  SECTION:=net
  CATEGORY:=Network
  TITLE:=BACnet Protocol Stack UCI Fork
  URL:=http://bacnet-stack.sourceforge.net/
  DEPENDS:=+libpthread +librt +libuci +libubox
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
  MENU:=1
  VARIANT:=bip
  DEPENDS+= +bacnet-stack-uci
endef

define Package/bacnet-stack-bip/description
  This package is built with IPv4 support.
endef

define Package/bacnet-stack-bip6
$(call Package/bacnet-stack/Default)
  TITLE+= (IPv6)
  MENU:=1
  VARIANT:=bip6
  DEPENDS+= +bacnet-stack-uci
endef

define Package/bacnet-stack-bip6/description
  This package is built with IPv6 support.
endef

define Package/bacnet-stack-ethernet
$(call Package/bacnet-stack/Default)
  TITLE+= (ETHERNET)
  MENU:=1
  VARIANT:=ethernet
  DEPENDS+= +bacnet-stack-uci
endef

define Package/bacnet-stack-ethernet/description
  This package is built with Ethernet support.
endef

define Package/bacnet-stack-mstp
$(call Package/bacnet-stack/Default)
  TITLE+= (MSTP)
  MENU:=1
  VARIANT:=mstp
  DEPENDS+= +bacnet-stack-uci
endef

define Package/bacnet-stack-mstp/description
  This package is built with MSTP support.
endef

define Package/bacnet-stack-router
$(call Package/bacnet-stack/Default)
  TITLE+= (ROUTER BIP MSTP)
  MENU:=1
  VARIANT:=router
  DEPENDS+= +bacnet-stack-uci
endef

define Package/bacnet-stack-router/description
  This package is built with Routing MSTP BIP support.
endef

define Package/bacnet-stack-bip/config
  source "$(SOURCE)/Config-bip.in"
endef

define Package/bacnet-stack-bip6/config
  source "$(SOURCE)/Config-bip6.in"
endef

define Package/bacnet-stack-ethernet/config
  source "$(SOURCE)/Config-ethernet.in"
endef

define Package/bacnet-stack-mstp/config
  source "$(SOURCE)/Config-mstp.in"
endef

MAKE_VARS += BUILD=release
MAKE_VARS += BACNET_PORT=linux
MAKE_VARS += UCI_LIB_DIR="$(STAGING_DIR)/usr/lib"
MAKE_VARS += UCI_INCLUDE_DIR="$(STAGING_DIR)/usr/include"
MAKE_VARS += CC="$(TARGET_CC)"
MAKE_VARS += AR="$(TARGET_AR)"
MAKE_VARS += MAKE_DEFINE="$(TARGET_CFLAGS)"

ifeq ($(BUILD_VARIANT),bip)
MAKE_VARS += BACDL_DEFINE=-DBACDL_BIP=1
MAKE_VARS += BACNET_DEFINES="\
-DBACAPP_ALL \
-DPRINT_ENABLED=0 \
-DBACNET_PROPERTY_LISTS=1 \
-DBAC_UCI \
-DBACNET_PROTOCOL_REVISION=13 \
$(if $(CONFIG_BACNET_STACK_BIP_AI),-DAI) \
$(if $(CONFIG_BACNET_STACK_BIP_AI),-DMAX_ANALOG_INPUTS=$(shell echo $(CONFIG_BACNET_STACK_BIP_AI_MAX))) \
$(if $(CONFIG_BACNET_STACK_BIP_AO),-DAO) \
$(if $(CONFIG_BACNET_STACK_BIP_AO),-DMAX_ANALOG_OUTPUTS=$(shell echo $(CONFIG_BACNET_STACK_BIP_AO_MAX))) \
$(if $(CONFIG_BACNET_STACK_BIP_AV),-DAV) \
$(if $(CONFIG_BACNET_STACK_BIP_AV),-DMAX_ANALOG_VALUES=$(shell echo $(CONFIG_BACNET_STACK_BIP_AV_MAX))) \
$(if $(CONFIG_BACNET_STACK_BIP_BI),-DBI) \
$(if $(CONFIG_BACNET_STACK_BIP_BI),-DMAX_BINARY_INPUTS=$(shell echo $(CONFIG_BACNET_STACK_BIP_BI_MAX))) \
$(if $(CONFIG_BACNET_STACK_BIP_BO),-DBO) \
$(if $(CONFIG_BACNET_STACK_BIP_BO),-DMAX_BINARY_OUTPUTS=$(shell echo $(CONFIG_BACNET_STACK_BIP_BO_MAX))) \
$(if $(CONFIG_BACNET_STACK_BIP_BV),-DBV) \
$(if $(CONFIG_BACNET_STACK_BIP_BV),-DMAX_BINARY_VALUES=$(shell echo $(CONFIG_BACNET_STACK_BIP_BV_MAX))) \
$(if $(CONFIG_BACNET_STACK_BIP_MSI),-DMSI) \
$(if $(CONFIG_BACNET_STACK_BIP_MSI),-DMAX_MULTI_STATE_INPUTS=$(shell echo $(CONFIG_BACNET_STACK_BIP_MSI_MAX))) \
$(if $(CONFIG_BACNET_STACK_BIP_MSO),-DMSO) \
$(if $(CONFIG_BACNET_STACK_BIP_MSO),-DMAX_MULTI_STATE_OUTPUTS=$(shell echo $(CONFIG_BACNET_STACK_BIP_MSO_MAX))) \
$(if $(CONFIG_BACNET_STACK_BIP_MSV),-DMSV) \
$(if $(CONFIG_BACNET_STACK_BIP_MSV),-DMAX_MULTI_STATE_VALUES=$(shell echo $(CONFIG_BACNET_STACK_BIP_MSV_MAX))) \
$(if $(CONFIG_BACNET_STACK_BIP_NC),-DINTRINSIC_REPORTING) \
$(if $(CONFIG_BACNET_STACK_BIP_NC),-DMAX_NOTIFICATION_CLASSES=$(shell echo $(CONFIG_BACNET_STACK_BIP_NC_MAX))) \
$(if $(CONFIG_BACNET_STACK_BIP_TRENDLOG),-DTRENDLOG) \
$(if $(CONFIG_BACNET_STACK_BIP_TRENDLOG),-DMAX_TREND_LOGS=$(shell echo $(CONFIG_BACNET_STACK_BIP_TRENDLOG_MAX))) \
$(if $(CONFIG_BACNET_STACK_BIP_FILE),-DBACFILE) \
$(if $(CONFIG_BACNET_STACK_BIP_FILE),-DBACNET_TIME_MASTER) \
"
MAKE_VARS += BBMD_DEFINE=" \
$(if $(CONFIG_BACNET_STACK_BIP_BBMD),-DBBMD_ENABLED=1) \
$(if $(CONFIG_BACNET_STACK_BIP_BBMD_CLIENT),-DBBMD_CLIENT_ENABLED=1) \
"

define Build/Compile
	+$(MAKE_VARS) $(MAKE) $(PKG_JOBS) \
		-C $(PKG_BUILD_DIR) \
		server
endef
endif

ifeq ($(BUILD_VARIANT),bip6)
MAKE_VARS += BACDL_DEFINE=-DBACDL_BIP6=1
MAKE_VARS += BACNET_DEFINES="\
-DBACAPP_ALL \
-DPRINT_ENABLED=0 \
-DBACNET_PROPERTY_LISTS=1 \
-DBAC_UCI \
-DBACNET_PROTOCOL_REVISION=13 \
$(if $(CONFIG_BACNET_STACK_BIP6_AI),-DAI) \
$(if $(CONFIG_BACNET_STACK_BIP6_AI),-DMAX_ANALOG_INPUTS=$(shell echo $(CONFIG_BACNET_STACK_BIP6_AI_MAX))) \
$(if $(CONFIG_BACNET_STACK_BIP6_AO),-DAO) \
$(if $(CONFIG_BACNET_STACK_BIP6_AO),-DMAX_ANALOG_OUTPUTS=$(shell echo $(CONFIG_BACNET_STACK_BIP6_AO_MAX))) \
$(if $(CONFIG_BACNET_STACK_BIP6_AV),-DAV) \
$(if $(CONFIG_BACNET_STACK_BIP6_AV),-DMAX_ANALOG_VALUES=$(shell echo $(CONFIG_BACNET_STACK_BIP6_AV_MAX))) \
$(if $(CONFIG_BACNET_STACK_BIP6_BI),-DBI) \
$(if $(CONFIG_BACNET_STACK_BIP6_BI),-DMAX_BINARY_INPUTS=$(shell echo $(CONFIG_BACNET_STACK_BIP6_BI_MAX))) \
$(if $(CONFIG_BACNET_STACK_BIP6_BO),-DBO) \
$(if $(CONFIG_BACNET_STACK_BIP6_BO),-DMAX_BINARY_OUTPUTS=$(shell echo $(CONFIG_BACNET_STACK_BIP6_BO_MAX))) \
$(if $(CONFIG_BACNET_STACK_BIP6_BV),-DBV) \
$(if $(CONFIG_BACNET_STACK_BIP6_BV),-DMAX_BINARY_VALUES=$(shell echo $(CONFIG_BACNET_STACK_BIP6_BV_MAX))) \
$(if $(CONFIG_BACNET_STACK_BIP6_MSI),-DMSI) \
$(if $(CONFIG_BACNET_STACK_BIP6_MSI),-DMAX_MULTI_STATE_INPUTS=$(shell echo $(CONFIG_BACNET_STACK_BIP6_MSI_MAX))) \
$(if $(CONFIG_BACNET_STACK_BIP6_MSO),-DMSO) \
$(if $(CONFIG_BACNET_STACK_BIP6_MSO),-DMAX_MULTI_STATE_OUTPUTS=$(shell echo $(CONFIG_BACNET_STACK_BIP6_MSO_MAX))) \
$(if $(CONFIG_BACNET_STACK_BIP6_MSV),-DMSV) \
$(if $(CONFIG_BACNET_STACK_BIP6_MSV),-DMAX_MULTI_STATE_VALUES=$(shell echo $(CONFIG_BACNET_STACK_BIP6_MSV_MAX))) \
$(if $(CONFIG_BACNET_STACK_BIP6_NC),-DINTRINSIC_REPORTING) \
$(if $(CONFIG_BACNET_STACK_BIP6_NC),-DMAX_NOTIFICATION_CLASSES=$(shell echo $(CONFIG_BACNET_STACK_BIP6_NC_MAX))) \
$(if $(CONFIG_BACNET_STACK_BIP6_TRENDLOG),-DTRENDLOG) \
$(if $(CONFIG_BACNET_STACK_BIP6_TRENDLOG),-DMAX_TREND_LOGS=$(shell echo $(CONFIG_BACNET_STACK_BIP6_TRENDLOG_MAX))) \
$(if $(CONFIG_BACNET_STACK_BIP6_FILE),-DBACFILE) \
$(if $(CONFIG_BACNET_STACK_BIP6_FILE),-DBACNET_TIME_MASTER) \
"
MAKE_VARS += BBMD_DEFINE=" \
$(if $(CONFIG_BACNET_STACK_BIP6_BBMD),-DBBMD_ENABLED=1) \
$(if $(CONFIG_BACNET_STACK_BIP6_BBMD_CLIENT),-DBBMD_CLIENT_ENABLED=1) \
"

define Build/Compile
	+$(MAKE_VARS) $(MAKE) $(PKG_JOBS) \
		-C $(PKG_BUILD_DIR) \
		server
endef
endif

ifeq ($(BUILD_VARIANT),ethernet)
MAKE_VARS += BACDL_DEFINE=-DBACDL_ETHERNET=1
MAKE_VARS += BACNET_DEFINES="\
-DBACAPP_ALL \
-DPRINT_ENABLED=0 \
-DBACNET_PROPERTY_LISTS=1 \
-DBAC_UCI \
-DBACNET_PROTOCOL_REVISION=13 \
$(if $(CONFIG_BACNET_STACK_ETHERNET_AI),-DAI) \
$(if $(CONFIG_BACNET_STACK_ETHERNET_AI),-DMAX_ANALOG_INPUTS=$(shell echo $(CONFIG_BACNET_STACK_ETHERNET_AI_MAX))) \
$(if $(CONFIG_BACNET_STACK_ETHERNET_AO),-DAO) \
$(if $(CONFIG_BACNET_STACK_ETHERNET_AO),-DMAX_ANALOG_OUTPUTS=$(shell echo $(CONFIG_BACNET_STACK_ETHERNET_AO_MAX))) \
$(if $(CONFIG_BACNET_STACK_ETHERNET_AV),-DAV) \
$(if $(CONFIG_BACNET_STACK_ETHERNET_AV),-DMAX_ANALOG_VALUES=$(shell echo $(CONFIG_BACNET_STACK_ETHERNET_AV_MAX))) \
$(if $(CONFIG_BACNET_STACK_ETHERNET_BI),-DBI) \
$(if $(CONFIG_BACNET_STACK_ETHERNET_BI),-DMAX_BINARY_INPUTS=$(shell echo $(CONFIG_BACNET_STACK_ETHERNET_BI_MAX))) \
$(if $(CONFIG_BACNET_STACK_ETHERNET_BO),-DBO) \
$(if $(CONFIG_BACNET_STACK_ETHERNET_BO),-DMAX_BINARY_OUTPUTS=$(shell echo $(CONFIG_BACNET_STACK_ETHERNET_BO_MAX))) \
$(if $(CONFIG_BACNET_STACK_ETHERNET_BV),-DBV) \
$(if $(CONFIG_BACNET_STACK_ETHERNET_BV),-DMAX_BINARY_VALUES=$(shell echo $(CONFIG_BACNET_STACK_ETHERNET_BV_MAX))) \
$(if $(CONFIG_BACNET_STACK_ETHERNET_MSI),-DMSI) \
$(if $(CONFIG_BACNET_STACK_ETHERNET_MSI),-DMAX_MULTI_STATE_INPUTS=$(shell echo $(CONFIG_BACNET_STACK_ETHERNET_MSI_MAX))) \
$(if $(CONFIG_BACNET_STACK_ETHERNET_MSO),-DMSO) \
$(if $(CONFIG_BACNET_STACK_ETHERNET_MSO),-DMAX_MULTI_STATE_OUTPUTS=$(shell echo $(CONFIG_BACNET_STACK_ETHERNET_MSO_MAX))) \
$(if $(CONFIG_BACNET_STACK_ETHERNET_MSV),-DMSV) \
$(if $(CONFIG_BACNET_STACK_ETHERNET_MSV),-DMAX_MULTI_STATE_VALUES=$(shell echo $(CONFIG_BACNET_STACK_ETHERNET_MSV_MAX))) \
$(if $(CONFIG_BACNET_STACK_ETHERNET_NC),-DINTRINSIC_REPORTING) \
$(if $(CONFIG_BACNET_STACK_ETHERNET_NC),-DMAX_NOTIFICATION_CLASSES=$(shell echo $(CONFIG_BACNET_STACK_ETHERNET_NC_MAX))) \
$(if $(CONFIG_BACNET_STACK_ETHERNET_TRENDLOG),-DTRENDLOG) \
$(if $(CONFIG_BACNET_STACK_ETHERNET_TRENDLOG),-DMAX_TREND_LOGS=$(shell echo $(CONFIG_BACNET_STACK_ETHERNET_TRENDLOG_MAX))) \
$(if $(CONFIG_BACNET_STACK_ETHERNET_FILE),-DBACFILE) \
$(if $(CONFIG_BACNET_STACK_ETHERNET_FILE),-DBACNET_TIME_MASTER) \
"
MAKE_VARS += BBMD_DEFINE=" \
$(if $(CONFIG_BACNET_STACK_ETHERNET_BBMD),-DBBMD_ENABLED=1) \
$(if $(CONFIG_BACNET_STACK_ETHERNET_BBMD_CLIENT),-DBBMD_CLIENT_ENABLED=1) \
"

define Build/Compile
	+$(MAKE_VARS) $(MAKE) $(PKG_JOBS) \
		-C $(PKG_BUILD_DIR) \
		server
endef
endif

ifeq ($(BUILD_VARIANT),mstp)
MAKE_VARS += BACDL_DEFINE=-DBACDL_MSTP=1
MAKE_VARS += BACNET_DEFINES="\
-DBACAPP_ALL \
-DPRINT_ENABLED=0 \
-DBACNET_PROPERTY_LISTS=1 \
-DBAC_UCI \
-DBACNET_PROTOCOL_REVISION=13 \
$(if $(CONFIG_BACNET_STACK_MSTP_AI),-DAI) \
$(if $(CONFIG_BACNET_STACK_MSTP_AI),-DMAX_ANALOG_INPUTS=$(shell echo $(CONFIG_BACNET_STACK_MSTP_AI_MAX))) \
$(if $(CONFIG_BACNET_STACK_MSTP_AO),-DAO) \
$(if $(CONFIG_BACNET_STACK_MSTP_AO),-DMAX_ANALOG_OUTPUTS=$(shell echo $(CONFIG_BACNET_STACK_MSTP_AO_MAX))) \
$(if $(CONFIG_BACNET_STACK_MSTP_AV),-DAV) \
$(if $(CONFIG_BACNET_STACK_MSTP_AV),-DMAX_ANALOG_VALUES=$(shell echo $(CONFIG_BACNET_STACK_MSTP_AV_MAX))) \
$(if $(CONFIG_BACNET_STACK_MSTP_BI),-DBI) \
$(if $(CONFIG_BACNET_STACK_MSTP_BI),-DMAX_BINARY_INPUTS=$(shell echo $(CONFIG_BACNET_STACK_MSTP_BI_MAX))) \
$(if $(CONFIG_BACNET_STACK_MSTP_BO),-DBO) \
$(if $(CONFIG_BACNET_STACK_MSTP_BO),-DMAX_BINARY_OUTPUTS=$(shell echo $(CONFIG_BACNET_STACK_MSTP_BO_MAX))) \
$(if $(CONFIG_BACNET_STACK_MSTP_BV),-DBV) \
$(if $(CONFIG_BACNET_STACK_MSTP_BV),-DMAX_BINARY_VALUES=$(shell echo $(CONFIG_BACNET_STACK_MSTP_BV_MAX))) \
$(if $(CONFIG_BACNET_STACK_MSTP_MSI),-DMSI) \
$(if $(CONFIG_BACNET_STACK_MSTP_MSI),-DMAX_MULTI_STATE_INPUTS=$(shell echo $(CONFIG_BACNET_STACK_MSTP_MSI_MAX))) \
$(if $(CONFIG_BACNET_STACK_MSTP_MSO),-DMSO) \
$(if $(CONFIG_BACNET_STACK_MSTP_MSO),-DMAX_MULTI_STATE_OUTPUTS=$(shell echo $(CONFIG_BACNET_STACK_MSTP_MSO_MAX))) \
$(if $(CONFIG_BACNET_STACK_MSTP_MSV),-DMSV) \
$(if $(CONFIG_BACNET_STACK_MSTP_MSV),-DMAX_MULTI_STATE_VALUES=$(shell echo $(CONFIG_BACNET_STACK_MSTP_MSV_MAX))) \
$(if $(CONFIG_BACNET_STACK_MSTP_NC),-DINTRINSIC_REPORTING) \
$(if $(CONFIG_BACNET_STACK_MSTP_NC),-DMAX_NOTIFICATION_CLASSES=$(shell echo $(CONFIG_BACNET_STACK_MSTP_NC_MAX))) \
$(if $(CONFIG_BACNET_STACK_MSTP_TRENDLOG),-DTRENDLOG) \
$(if $(CONFIG_BACNET_STACK_MSTP_TRENDLOG),-DMAX_TREND_LOGS=$(shell echo $(CONFIG_BACNET_STACK_MSTP_TRENDLOG_MAX))) \
$(if $(CONFIG_BACNET_STACK_MSTP_FILE),-DBACFILE) \
$(if $(CONFIG_BACNET_STACK_MSTP_FILE),-DBACNET_TIME_MASTER) \
"
MAKE_VARS += BBMD_DEFINE=" \
$(if $(CONFIG_BACNET_STACK_MSTP_BBMD),-DBBMD_ENABLED=1) \
$(if $(CONFIG_BACNET_STACK_MSTP_BBMD_CLIENT),-DBBMD_CLIENT_ENABLED=1) \
"

define Build/Compile
	+$(MAKE_VARS) $(MAKE) $(PKG_JOBS) \
		-C $(PKG_BUILD_DIR) \
		server
endef
endif

ifeq ($(BUILD_VARIANT),router)
MAKE_VARS += BACNET_DEFINES="\
-DPRINT_ENABLED=0 \
"
define Build/Compile
	+$(MAKE_VARS) $(MAKE) $(PKG_JOBS) \
		-C $(PKG_BUILD_DIR) \
		router
endef
endif

ifeq ($(BUILD_VARIANT),utils)
MAKE_VARS += BACDL_DEFINE=-DBACDL_BIP=1
MAKE_VARS += BACNET_DEFINES="\
-DBACAPP_ALL \
-DPRINT_ENABLED=1 \
-DBACNET_PROPERTY_LISTS=1 \
-DBAC_UCI \
"
define Build/Compile
	+$(MAKE_VARS) $(MAKE) $(PKG_JOBS) \
		-C $(PKG_BUILD_DIR) \
		demos
endef
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
	$(INSTALL_DIR) $(1)/etc/init.d $(1)/etc/config
	$(INSTALL_BIN) ./files/bacserv.init $(1)/etc/init.d/bacserv
	$(INSTALL_DATA) ./files/bacnet_dev.config $(1)/etc/config/bacnet_dev
	$(INSTALL_DATA) ./files/bacnet_ai.config $(1)/etc/config/bacnet_ai
	$(INSTALL_DATA) ./files/bacnet_ao.config $(1)/etc/config/bacnet_ao
	$(INSTALL_DATA) ./files/bacnet_av.config $(1)/etc/config/bacnet_av
	$(INSTALL_DATA) ./files/bacnet_bi.config $(1)/etc/config/bacnet_bi
	$(INSTALL_DATA) ./files/bacnet_bv.config $(1)/etc/config/bacnet_bo
	$(INSTALL_DATA) ./files/bacnet_bv.config $(1)/etc/config/bacnet_bv
	$(INSTALL_DATA) ./files/bacnet_mi.config $(1)/etc/config/bacnet_mi
	$(INSTALL_DATA) ./files/bacnet_mo.config $(1)/etc/config/bacnet_mo
	$(INSTALL_DATA) ./files/bacnet_mv.config $(1)/etc/config/bacnet_mv
	$(INSTALL_DATA) ./files/bacnet_nc.config $(1)/etc/config/bacnet_nc
	$(INSTALL_DATA) ./files/bacnet_tl.config $(1)/etc/config/bacnet_tl
	$(INSTALL_DATA) ./files/bacnet_group.config $(1)/etc/config/bacnet_group
endef

define Package/bacnet-stack-bip/install
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/bacserv_bip.defaults $(1)/etc/uci-defaults/bacserv_bip
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/bacserv $(1)/usr/sbin/bacserv-bip
endef

define Package/bacnet-stack-bip6/install
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/bacserv_bip6.defaults $(1)/etc/uci-defaults/bacserv_bip6
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/bacserv $(1)/usr/sbin/bacserv-bip6
endef

define Package/bacnet-stack-ethernet/install
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/bacserv_ethernet.defaults $(1)/etc/uci-defaults/bacserv_ethernet
	$(INSTALL_DIR) $(1)/usr/bin $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/bacserv $(1)/usr/sbin/bacserv-ethernet
endef

define Package/bacnet-stack-mstp/install
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/bacserv_mstp.defaults $(1)/etc/uci-defaults/bacserv_mstp
	$(INSTALL_DIR) $(1)/usr/bin $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/bacserv $(1)/usr/sbin/bacserv-mstp
endef

define Package/bacnet-stack-router/install
	$(INSTALL_DIR) $(1)/etc/init.d $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/bacserv_router.defaults $(1)/etc/uci-defaults/bacserv_router
	$(INSTALL_DIR) $(1)/usr/bin $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/router $(1)/usr/sbin/bacserv-router
	$(INSTALL_BIN) ./files/bacrouter.init $(1)/etc/init.d/bacrouter
endef

define Package/bacnet-stack-utils/install
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
$(eval $(call BuildPackage,bacnet-stack-bip6))
$(eval $(call BuildPackage,bacnet-stack-ethernet))
$(eval $(call BuildPackage,bacnet-stack-mstp))
$(eval $(call BuildPackage,bacnet-stack-router))
$(eval $(call BuildPackage,bacnet-stack-utils))
