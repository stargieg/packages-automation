# call BuildPackage - OpenWrt buildroot signature
include $(TOPDIR)/rules.mk

PKG_NPM_NAME:=homebridge-mpd
PKG_NAME:=node-$(PKG_NPM_NAME)
PKG_VERSION:=0.0.13
PKG_RELEASE:=1
PKG_SOURCE:=$(PKG_NPM_NAME)-$(PKG_VERSION).tgz
PKG_SOURCE_URL:=https://registry.npmjs.org/$(PKG_NPM_NAME)/-/
PKG_HASH:=344d9fca5da5f7c5ec6ec85a2d4370abc261cac85e3ece1115f4c5b27ad77c7f

PKG_BUILD_DEPENDS:=node/host
PKG_USE_MIPS16:=0

PKG_MAINTAINER:=Hirokazu MORIKAWA <morikw2@gmail.com>
PKG_LICENSE:=ISC Apache-2.0
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/node-homebridge-mpd
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Node.js
  TITLE:=hombridge shim for mpd
  DEPENDS:=+node +node-npm
  EXTRA_DEPENDS:=node-homebridge
  USERID:=homebridge:homebridge
endef


TAR_OPTIONS+= --strip-components 1
TAR_CMD=$(HOST_TAR) -C $(1) $(TAR_OPTIONS)

NODEJS_CPU:=$(subst powerpc,ppc,$(subst aarch64,arm64,$(subst x86_64,x64,$(subst i386,ia32,$(ARCH)))))
TMPNPM:=$(shell mktemp -u XXXXXXXXXX)

TARGET_CFLAGS+=$(FPIC)
TARGET_CPPFLAGS+=$(FPIC)

define Build/Compile
	$(MAKE_VARS) \
	$(MAKE_FLAGS) \
	npm_config_arch=$(NODEJS_CPU) \
	npm_config_target_arch=$(NODEJS_CPU) \
	npm_config_build_from_source=true \
	npm_config_nodedir=$(STAGING_DIR)/usr/ \
	npm_config_prefix=$(PKG_INSTALL_DIR)/usr/ \
	npm_config_cache=$(TMP_DIR)/npm-cache-$(TMPNPM) \
	npm_config_tmp=$(TMP_DIR)/npm-tmp-$(TMPNPM) \
	npm install -g $(PKG_BUILD_DIR)
	rm -rf $(TMP_DIR)/npm-tmp-$(TMPNPM)
	rm -rf $(TMP_DIR)/npm-cache-$(TMPNPM)
endef

define Package/$(PKG_NAME)/postinst
cd $${IPKG_INSTROOT}/usr/lib/node/homebridge/node_modules/$(PKG_NPM_NAME)/node_modules
for i in * ; do
        ln -s $(PKG_NPM_NAME)/node_modules/$$i ../../
done
exit 0
endef

define Package/node-homebridge-mpd/install
	$(INSTALL_DIR) $(1)/usr/lib/node/homebridge/node_modules/$(PKG_NPM_NAME)
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/node_modules/$(PKG_NPM_NAME)/{*.json,*.md,*.js} \
		$(1)/usr/lib/node/homebridge/node_modules/$(PKG_NPM_NAME)/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/node_modules/$(PKG_NPM_NAME)/LICENSE \
		$(1)/usr/lib/node/homebridge/node_modules/$(PKG_NPM_NAME)/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/node_modules/$(PKG_NPM_NAME)/node_modules \
		$(1)/usr/lib/node/homebridge/node_modules/$(PKG_NPM_NAME)/
endef

$(eval $(call BuildPackage,node-homebridge-mpd))
