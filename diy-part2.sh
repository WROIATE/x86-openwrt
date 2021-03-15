#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#

# Modify default IP
#sed -i 's/192.168.1.1/192.168.50.5/g' package/base-files/files/bin/config_generate

pushd package/lean
rm -rf luci-theme-argon
git clone -b 18.06 https://github.com/jerrykuku/luci-theme-argon luci-theme-argon
git clone https://github.com/jerrykuku/luci-app-argon-config
popd

# 去除 luci-app-socat与socat冲突文件
sed -i '/INSTALL_CONF/d' feeds/packages/net/socat/Makefile
sed -i '/socat\.init/d' feeds/packages/net/socat/Makefile

# 去除 lean的老版smartdns
rm -rf feeds/packages/net/smartdns
rm -rf package/feeds/packages/smartdns

mkdir ./package/self_add
pushd package/self_add

# Add Lienol access cnotrol
svn co https://github.com/Lienol/openwrt-package/trunk/luci-app-control-timewol
svn co https://github.com/Lienol/openwrt-package/trunk/luci-app-control-webrestriction
svn co https://github.com/Lienol/openwrt-package/trunk/luci-app-control-weburl
svn co https://github.com/Lienol/openwrt-package/trunk/luci-app-timecontrol

# Add luci-app-socat
svn co https://github.com/Lienol/openwrt-package/trunk/luci-app-socat

# Add self settings
git clone https://github.com/WROIATE/openwrt-settings

# Add luci-app-ustb
git clone https://github.com/WROIATE/luci-app-ustb

# Add ServerChan
git clone --depth=1 https://github.com/tty228/luci-app-serverchan

# Add OpenClash
git clone --depth=1 -b master https://github.com/vernesong/OpenClash

# Add luci-app-adguardhome
svn co https://github.com/Lienol/openwrt/trunk/package/diy/luci-app-adguardhome
sed -i "/.*noresolv=1/a\\\tuci set dhcp.@dnsmasq[0].cachesize=0" luci-app-adguardhome/root/etc/init.d/AdGuardHome
svn co https://github.com/WROIATE/openwrt-package/trunk/AdguardHome

# Add luci-app-jd-dailybonus
# git clone --depth=1 https://github.com/jerrykuku/node-request
# git clone --depth=1 https://github.com/jerrykuku/luci-app-jd-dailybonus

# Add luci-theme-rosy
svn co https://github.com/project-openwrt/openwrt/trunk/package/ctcgfw/luci-theme-rosy

# Add smartdns
svn co https://github.com/Lienol/openwrt-packages/trunk/net/smartdns
sed -i "s/PKG_SOURCE_VERSION:.*/PKG_SOURCE_VERSION:=Release33/g" smartdns/Makefile
svn co https://github.com/kenzok8/openwrt-packages/trunk/luci-app-smartdns

# Add OpenAppFilter
git clone --depth=1 https://github.com/destan19/OpenAppFilter
popd

# Mod zzz-default-settings
pushd package/lean/default-settings/files
sed -i "/commit luci/i\uci set luci.main.mediaurlbase='/luci-static/argon'" zzz-default-settings
sed -i "/-j REDIRECT --to-ports 53/d" zzz-default-settings
sed -i "/REDIRECT --to-ports 53/a\echo '# iptables -t nat -A PREROUTING -p udp --dport 53 -j REDIRECT --to-ports 53' >> /etc/firewall.user" zzz-default-settings
popd

# 修改限制时间防止passwall在nginx下无法使用 uwsgi ini file
pushd feeds/packages/net/uwsgi/files-luci-support
sed -i "s/limit-as = 1000/limit-as = 100000/g" luci-webui.ini
popd