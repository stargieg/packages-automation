include $(TOPDIR)/rules.mk

PKG_NAME:=automation-defaults
PKG_VERSION:=2018-4-8
PKG_RELEASE:=2

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/automation-defaults
  SECTION:=net
  CATEGORY:=Network
  TITLE:=automation-defaults
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/automation-defaults/postinst
#!/bin/sh

if [ -z $${IPKG_INSTROOT} ] ; then
	( . /etc/uci-defaults/automation ) && rm /etc/uci-defaults/automation
fi

endef

define Package/automation-defaults/install
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/automation.defaults $(1)/etc/uci-defaults/zautomation
endef

$(eval $(call BuildPackage,automation-defaults))
