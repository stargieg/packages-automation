#
# Copyright (C) 2014-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libwebsockets
PKG_SOURCE_VERSION:=082e33b91f7ce1e0dad77d012ef2996ed3ba162a
PKG_VERSION:=2016-02-14-$(PKG_SOURCE_VERSION)
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/warmcat/libwebsockets.git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_SOURCE_SUBDIR)

PKG_LICENSE:=LGPL-2.1+exception
PKG_LICENSE_FILES:=LICENSE

CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/libwebsockets
	SECTION:=libs
	CATEGORY:=Libraries
	TITLE:=libwebsockets
	DEPENDS:=+zlib +libcyassl
endef

CMAKE_OPTIONS += -DLWS_WITHOUT_TESTAPPS=ON
CMAKE_OPTIONS += -DLWS_OPENSSL_CLIENT_CERTS=/etc/ssl/certs
CMAKE_OPTIONS += -DLWS_OPENSSL_SUPPORT=ON
CMAKE_OPTIONS += -DLWS_WITH_SSL=ON
CMAKE_OPTIONS += -DLWS_USE_CYASSL=ON
CMAKE_OPTIONS += -DLWS_USE_WOLFSSL=OFF
CMAKE_OPTIONS += -DLWS_CYASSL_LIBRARIES=$(STAGING_DIR)/usr/lib/libcyassl.so
CMAKE_OPTIONS += -DLWS_CYASSL_INCLUDE_DIRS=$(STAGING_DIR)/usr/include

define Package/libwebsockets/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/libwebsockets.so.6 $(1)/usr/lib/
	$(LN) $(1)/usr/lib/libwebsockets.so.6 $(1)/usr/lib/libwebsockets.so
endef

$(eval $(call BuildPackage,libwebsockets))
