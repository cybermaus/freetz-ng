$(call PKG_INIT_BIN, $(if $(FREETZ_PACKAGE_TINC_VERSION_1_1),1.1pre17,1.0.36))
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5_1.0.36  :=535b58ee026ec9551954dcc6ed56edca
$(PKG)_SOURCE_MD5_1.1pre17:=fb29dfa2e6d51cd5ab6c9d8c9bc95d48
$(PKG)_SOURCE_MD5:=$($(PKG)_SOURCE_MD5_$($(PKG)_VERSION))
$(PKG)_SITE:=http://www.tinc-vpn.org/packages

$(PKG)_CONDITIONAL_PATCHES+=$(if $(FREETZ_PACKAGE_TINC_VERSION_1_1),1.1,1.0)

$(PKG)_PATCH_POST_CMDS += $(call PKG_ADD_EXTRA_FLAGS,(C|LD)FLAGS,src)

$(PKG)_BINARY:=$($(PKG)_DIR)/src/tincd
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/tincd

$(PKG)_BINARY_CTL:=$($(PKG)_DIR)/src/tinc
$(PKG)_TARGET_BINARY_CTL:=$($(PKG)_DEST_DIR)/usr/sbin/tinc

$(PKG)_EXCLUDED += $(if $(FREETZ_PACKAGE_TINC_tinc),,$($(PKG)_TARGET_BINARY_CTL))

$(PKG)_DEPENDS_ON += lzo openssl zlib
$(PKG)_DEPENDS_ON += $(if $(FREETZ_PACKAGE_TINC_VERSION_1_1),ncurses readline)

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_TINC_VERSION_1_0
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_TINC_VERSION_1_1
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_TINC_STATIC
$(PKG)_REBUILD_SUBOPTS += FREETZ_OPENSSL_SHLIB_VERSION

$(PKG)_HARDENING_OPTS := check_cflags___fPIE check_ldflags___pie
#$(PKG)_HARDENING_OPTS += check_ldflags___Wl__z_relro check_ldflags___Wl__z_now
$(PKG)_CONFIGURE_ENV += $(foreach opt,$($(PKG)_HARDENING_OPTS),ax_cv_$(opt)=no)

$(PKG)_EXTRA_CFLAGS  += -ffunction-sections -fdata-sections
$(PKG)_EXTRA_LDFLAGS += -Wl,--gc-sections
ifeq ($(strip $(FREETZ_PACKAGE_TINC_STATIC)),y)
$(PKG)_EXTRA_LDFLAGS += -static
endif

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY) $($(PKG)_BINARY_CTL): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(TINC_DIR) \
		EXTRA_CFLAGS="$(TINC_EXTRA_CFLAGS)" \
		EXTRA_LDFLAGS="$(TINC_EXTRA_LDFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_TARGET_BINARY_CTL): $($(PKG)_BINARY_CTL)
	$(INSTALL_BINARY_STRIP)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $(if $(FREETZ_PACKAGE_TINC_tinc),$($(PKG)_TARGET_BINARY_CTL))

$(pkg)-clean:
	-$(SUBMAKE) -C $(TINC_DIR) clean
	$(RM) $(TINC_FREETZ_CONFIG_FILE)

$(pkg)-uninstall:
	$(RM) $(TINC_TARGET_BINARY) $(TINC_TARGET_BINARY_CTL)

$(PKG_FINISH)
