# $Id: Makefile 1146 2005-06-05 13:32:28Z nbd $

include $(TOPDIR)/rules.mk

PKG_NAME:=bacnet4linux
PKG_VERSION:=0.3.12
PKG_RELEASE:=1
PKG_MD5SUM:=b4166ecb4683806cc67cbf511a3e6279

PKG_SOURCE_URL:=@SF/bacnet4linux
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tgz
PKG_CAT:=zcat

PKG_BUILD_DIR:=$(BUILD_DIR)/bacnet
include $(INCLUDE_DIR)/package.mk

define Package/bacnet4linux
  SECTION:=net
  CATEGORY:=Network
  TITLE:=BACnet Protocol (www.bacnet.org) stack for Linux
  URL:=http://bacnet4linux.sourceforge.net/
endef

define Package/bacnet4linux/description
  Note: This project is no longer active. See BACnet Stack at SourceForge for an active BACnet stack that runs on Linux.
endef

define Package/bacnet4linux/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bacnet4linux $(1)/usr/bin/
endef

$(eval $(call BuildPackage,bacnet4linux))
