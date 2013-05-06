# $Id: Makefile 1146 2005-06-05 13:32:28Z nbd $

include $(TOPDIR)/rules.mk

PKG_NAME:=bfr
PKG_VERSION:=0.2
PKG_RELEASE:=1
PKG_MD5SUM:=886a4fe51dbe0dbc02c883747e9af110

PKG_SOURCE_URL:=@SF/bfr/BFR 0.2
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-source.tar.gz
#PKG_CAT:=zcat
TAR1_CMD=$(HOST_TAR) -C $(1) $(TAR_OPTIONS)
UNPACK_CMD=gzip -dc $(DL_DIR)/$(PKG_SOURCE) | $(TAR1_CMD)

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
include $(INCLUDE_DIR)/package.mk

define Package/bfr
  SECTION:=net
  CATEGORY:=Network
  TITLE:=BACnet Firewall Router (BFR)
  URL:=http://bfr.sourceforge.net/
  DEPENDS:=+libpthread +librt +uclibcxx
endef

define Package/bfr/description
 BFR is an application that combines BACnet routing capability with traffic management functions to carefully control access to building automation and control networks
endef



define Build/Configure
	$(CP) ./Source/* $(PKG_BUILD_DIR)
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
	CC=$(TARGET_CC) \
	LIBS="-L$(STAGING_DIR)/lib -fno-builtin -nostdinc++ -nodefaultlibs -luClibc++ -lc -lm -lgcc_s -lgcc" \
	CPPFLAGS="-I$(STAGING_DIR)/include -I$(STAGING_DIR)/usr/include -I$(STAGING_DIR)/usr/include/uClibc++"
endef

define Package/bfr/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/BFR $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,bfr))
