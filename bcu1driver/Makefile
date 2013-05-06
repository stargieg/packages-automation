#
# Copyright (C) 2006-2009 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# $Id: Makefile 14307 2009-07-09 13:26:57Z pg $

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

#http://www.auto.tuwien.ac.at/~mkoegler/eib/drv/bcu1driver-0.2.6.6.1.tar.gz
PKG_NAME:=bcu1driver
PKG_VERSION:=0.2.6.6.1
PKG_RELEASE:=2
PKG_SOURCE:=bcu1driver-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://www.auto.tuwien.ac.at/~mkoegler/eib/drv/
PKG_MD5SUM:=69cec37c4322b9740cd78948d797f8fb
PKG_BUILD_DIR:=$(KERNEL_BUILD_DIR)/bcu1driver-$(PKG_VERSION)
PATCH_DIR=./patches

include $(INCLUDE_DIR)/package.mk

BCU1DRIVER_FILES:= \
	$(PKG_BUILD_DIR)/eib-common.$(LINUX_KMOD_SUFFIX) \
	$(PKG_BUILD_DIR)/eib-8250.$(LINUX_KMOD_SUFFIX) \
	$(PKG_BUILD_DIR)/eib-pei16.$(LINUX_KMOD_SUFFIX)

define KernelPackage/bcu1driver
  SUBMENU:=Other modules
  TITLE:=RS232 EIB BCU1 Driver
  URL:=http://www.auto.tuwien.ac.at/~mkoegler/index.php/eibdriver
  FILES:=$(BCU1DRIVER_FILES)
  AUTOLOAD:=$(call AutoLoad,60,eib-common eib-8250 eib-pei16)
endef


MAKE_ARGS:= \
	PATH="$(TARGET_PATH)" \
	ARCH="$(LINUX_KARCH)" \
	CROSS_COMPILE="$(TARGET_CROSS)" \
	TOOLPREFIX="$(KERNEL_CROSS)" \
	TOOLPATH="$(KERNEL_CROSS)" \
	KERNELPATH="$(LINUX_DIR)" \
	KERNELDIR="$(LINUX_DIR)" \
	KDIR="$(LINUX_DIR)" \
	LDOPTS="--no-warn-mismatch " \
	CFLAGS="-I$(KERNEL_BUILD_DIR)/include $(TARGET_CFLAGS)" \
	KBUILD_VERBOSE=1

define Build/Prepare
	$(call Build/Prepare/Default)
endef

define Build/Compile
	$(MAKE_VARS) $(MAKE) -C $(PKG_BUILD_DIR) $(MAKE_ARGS)
endef


$(eval $(call KernelPackage,bcu1driver))
