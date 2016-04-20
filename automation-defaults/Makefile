include $(TOPDIR)/rules.mk

PKG_NAME:=automation-defaults
PKG_VERSION:=2016-04-20
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/automation-defaults/Default
  SECTION:=net
  CATEGORY:=Network
  TITLE:=automation-defaults
endef

define Package/automation-defaults/Default/description
  automation-defaults
endef

define Package/automation-defaults/postinst
#!/bin/sh

if [ -z $${IPKG_INSTROOT} ] ; then
	( . /etc/uci-defaults/automation ) && rm /etc/uci-defaults/automation
fi

endef

define Package/automation-defaults/install
	$(INSTALL_BIN) ./files/automation.defaults $(1)/etc/uci-defaults/automation
endef

$(eval $(call BuildPackage,automation-defaults))
