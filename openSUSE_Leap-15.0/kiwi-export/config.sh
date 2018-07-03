test -f /.kconfig && . /.kconfig
test -f /.profile && . /.profile
baseMount
suseSetupProduct
suseImportBuildKey
suseConfig
zypper -n ar --name='Education' --type='rpm-md' --disable 'http://download.opensuse.org/repositories/Education/openSUSE_Leap_15.0/' 'Education'
zypper -n mr --priority=99 'Education'
zypper -n ar --name='Filesystems' --type='rpm-md' --disable 'http://download.opensuse.org/repositories/filesystems/openSUSE_Leap_15.0/' 'Filesystems'
zypper -n mr --priority=99 'Filesystems'
zypper -n ar --name='Packman Repository' --type='rpm-md' 'http://packman.inode.at/suse/openSUSE_Leap_15.0/' 'packman.inode.at-suse'
zypper -n mr --priority=99 'Packman Repository'
zypper -n ar --name='Publishing' --type='rpm-md' --disable 'https://download.opensuse.org/repositories/Publishing/openSUSE_Leap_15.0/' 'Publishing'
zypper -n mr --priority=99 'Publishing'
zypper -n ar --name='X2Go' --type='rpm-md' 'http://download.opensuse.org/repositories/X11:/RemoteDesktop:/x2go/openSUSE_Leap_15.0/' 'X2Go'
zypper -n mr --priority=99 'X2Go'
zypper -n ar --name='google-chrome' --type='rpm-md' 'http://dl.google.com/linux/chrome/rpm/stable/x86_64' 'google-chrome'
zypper -n mr --priority=99 'google-chrome'
zypper -n ar --name='openSUSE-Leap-15.0-Non-Oss' --type='rpm-md' 'http://download.opensuse.org/distribution/leap/15.0/repo/non-oss/' 'repo-non-oss'
zypper -n mr --priority=99 'openSUSE-Leap-15.0-Non-Oss'
zypper -n ar --name='openSUSE-Leap-15.0-Oss' --type='rpm-md' 'http://download.opensuse.org/distribution/leap/15.0/repo/oss/' 'repo-oss'
zypper -n mr --priority=99 'openSUSE-Leap-15.0-Oss'
zypper -n ar --name='openSUSE-Leap-15.0-Update' --type='rpm-md' 'http://download.opensuse.org/update/leap/15.0/oss/' 'repo-update'
zypper -n mr --priority=99 'openSUSE-Leap-15.0-Update'
zypper -n ar --name='openSUSE-Leap-15.0-Update-Non-Oss' --type='rpm-md' 'http://download.opensuse.org/update/leap/15.0/non-oss/' 'repo-update-non-oss'
zypper -n mr --priority=99 'openSUSE-Leap-15.0-Update-Non-Oss'
zypper -n ar --name='security' --type='rpm-md' --disable 'http://download.opensuse.org/repositories/security/openSUSE_Leap_15.0/' 'security'
zypper -n mr --priority=99 'security'
systemctl enable ModemManager.service
systemctl enable NetworkManager-dispatcher.service
systemctl disable NetworkManager-wait-online.service
systemctl enable NetworkManager.service
systemctl disable SuSEfirewall2.service
systemctl disable SuSEfirewall2_init.service
systemctl enable YaST2-Firstboot.service
systemctl enable YaST2-Second-Stage.service
systemctl disable accounts-daemon.service
systemctl enable apparmor.service
systemctl disable appstream-sync-cache.service
systemctl disable atd.service
systemctl enable auditd.service
systemctl disable autofs.service
systemctl enable autovt@.service
systemctl disable autoyast-initscripts.service
systemctl enable avahi-daemon.service
systemctl enable avahi-daemon.socket
systemctl disable avahi-dnsconfd.service
systemctl disable blk-availability.service
systemctl enable bluetooth.service
systemctl disable bmc-snmp-proxy.service
systemctl disable btrfsmaintenance-refresh.service
systemctl enable ca-certificates.service
systemctl disable chrony-wait.service
systemctl disable chronyd.service
systemctl enable cloud-config.service
systemctl enable cloud-final.service
systemctl enable cloud-init-local.service
systemctl enable cloud-init.service
systemctl disable console-getty.service
systemctl disable containerd.service
systemctl disable containerd.socket
systemctl enable cron.service
systemctl disable cups-browsed.service
systemctl disable cups-lpd.socket
systemctl enable cups.service
systemctl disable cups.socket
systemctl disable cvs.socket
systemctl disable dbus-fi.epitest.hostap.WPASupplicant.service
systemctl disable dbus-fi.w1.wpa_supplicant1.service
systemctl enable dbus-org.bluez.service
systemctl enable dbus-org.freedesktop.Avahi.service
systemctl enable dbus-org.freedesktop.ModemManager1.service
systemctl enable dbus-org.freedesktop.network1.service
systemctl enable dbus-org.freedesktop.nm-dispatcher.service
systemctl disable debug-shell.service
systemctl enable display-manager.service
systemctl enable dm-event.socket
systemctl disable dmraid-activation.service
systemctl disable dnsmasq.service
systemctl disable docker.service
systemctl disable ebtables.service
systemctl disable exchange-bmc-os-info.service
systemctl disable firewalld.service
systemctl enable getty@tty1.service
systemctl disable getty@tty7.service
systemctl disable gpm.service
systemctl disable grub2-once.service
systemctl enable haveged.service
systemctl disable ipmi.service
systemctl disable ipmievd.service
systemctl enable irqbalance.service
systemctl enable iscsi.service
systemctl disable iscsid.service
systemctl enable iscsid.socket
systemctl disable iscsiuio.service
systemctl disable iscsiuio.socket
systemctl disable kadmind.service
systemctl enable kbdsettings.service
systemctl disable kdump-early.service
systemctl disable kdump.service
systemctl disable kexec-load.service
systemctl disable klogd.service
systemctl disable kpropd.service
systemctl disable krb5kdc.service
systemctl enable ksm.service
systemctl disable libvirt-guests.service
systemctl enable libvirtd.service
systemctl enable lvm2-lvmetad.socket
systemctl disable lvm2-lvmpolld.socket
systemctl disable lvm2-monitor.service
systemctl disable lxc-net.service
systemctl disable lxc.service
systemctl disable lxc@.service
systemctl disable lxcfs.service
systemctl disable man-db-create.service
systemctl disable mariadb.service
systemctl disable mariadb@.service
systemctl enable mcelog.service
systemctl disable memcached.service
systemctl disable multipathd.service
systemctl disable multipathd.socket
systemctl disable mysql.service
systemctl disable mysql@.service
systemctl enable network.service
systemctl disable nfs-blkmap.service
systemctl disable nfs-server.service
systemctl disable nfs.service
systemctl disable nfsserver.service
systemctl disable nmb.service
systemctl enable nscd.service
systemctl disable ntp-wait.service
systemctl enable ntpd.service
systemctl disable numad.service
systemctl disable openvpn@.service
systemctl disable openvswitch.service
systemctl disable ovn-controller-vtep.service
systemctl disable ovn-controller.service
systemctl disable ovn-northd.service
systemctl enable pcscd.socket
systemctl enable postfix.service
systemctl disable pppoe-server.service
systemctl disable pppoe.service
systemctl enable purge-kernels.service
systemctl disable qemu-ga@.service
systemctl disable radvd.service
systemctl disable raw.service
systemctl disable rfkill-block@.service
systemctl disable rfkill-unblock@.service
systemctl disable rng-tools.service
systemctl disable rollback.service
systemctl disable rpcbind.service
systemctl disable rpcbind.socket
systemctl disable rpmconfigcheck.service
systemctl disable rsyncd.service
systemctl disable rsyncd.socket
systemctl disable rtkit-daemon.service
systemctl disable salt-api.service
systemctl disable salt-master.service
systemctl disable salt-minion.service
systemctl disable salt-proxy@.service
systemctl disable salt-syndic.service
systemctl disable samba-ad-dc.service
systemctl disable saned.socket
systemctl disable serial-getty@ttyS0.service
systemctl disable serial-getty@ttyS0.service
systemctl disable serial-getty@ttyS1.service
systemctl disable serial-getty@ttyS1.service
systemctl disable serial-getty@ttyS2.service
systemctl disable serial-getty@ttyS2.service
systemctl disable slapd.service
systemctl enable smartd.service
systemctl disable smb.service
systemctl disable snmpd.service
systemctl disable snmptrapd.service
systemctl disable speech-dispatcherd.service
systemctl enable spice-vdagentd.service
systemctl enable sshd.service
systemctl disable sssd.service
systemctl disable svnserve.service
systemctl disable systemd-networkd-wait-online.service
systemctl enable systemd-networkd.service
systemctl disable systemd-networkd.socket
systemctl disable systemd-nspawn@.service
systemctl disable systemd-timesyncd.service
systemctl disable tftp.socket
systemctl disable tuned.service
systemctl disable udisks2.service
systemctl disable upower.service
systemctl enable vboxdrv.service
systemctl disable vboxes.service
systemctl enable virtlockd.socket
systemctl enable virtlogd.socket
systemctl disable vpnc@.service
systemctl disable wicked.service
systemctl disable wickedd-auto4.service
systemctl disable wickedd-dhcp4.service
systemctl disable wickedd-dhcp6.service
systemctl disable wickedd-nanny.service
systemctl disable winbind.service
systemctl disable wpa_supplicant.service
systemctl disable wpa_supplicant@.service
systemctl disable x2gocleansessions.service
systemctl enable xdm.service
systemctl enable xinetd.service
systemctl disable xrdp-sesman.service
systemctl disable xrdp.service
systemctl disable xvnc.socket
systemctl disable ypbind.service
perl /tmp/merge_users_and_groups.pl /etc/passwd /etc/shadow /etc/group
rm /tmp/merge_users_and_groups.pl
chmod 600 '/boot/grub2/grub.cfg'
chown root:root '/boot/grub2/grub.cfg'
chmod 600 '/boot/initrd-4.12.14-lp150.11-default'
chown root:root '/boot/initrd-4.12.14-lp150.11-default'
chmod 600 '/boot/initrd-4.12.14-lp150.12.4-default'
chown root:root '/boot/initrd-4.12.14-lp150.12.4-default'
rm -rf '/etc/bash_completion.d/cinder.bash_completion'
ln -s '/etc/alternatives/cinder.bash_completion' '/etc/bash_completion.d/cinder.bash_completion'
chown --no-dereference root:root '/etc/bash_completion.d/cinder.bash_completion'
rm -rf '/etc/bash_completion.d/heat.bash_completion'
ln -s '/etc/alternatives/heat.bash_completion' '/etc/bash_completion.d/heat.bash_completion'
chown --no-dereference root:root '/etc/bash_completion.d/heat.bash_completion'
rm -rf '/etc/bash_completion.d/ironic.bash_completion'
ln -s '/etc/alternatives/ironic.bash_completion' '/etc/bash_completion.d/ironic.bash_completion'
chown --no-dereference root:root '/etc/bash_completion.d/ironic.bash_completion'
rm -rf '/etc/bash_completion.d/magnum.bash_completion'
ln -s '/etc/alternatives/magnum.bash_completion' '/etc/bash_completion.d/magnum.bash_completion'
chown --no-dereference root:root '/etc/bash_completion.d/magnum.bash_completion'
rm -rf '/etc/bash_completion.d/manila.bash_completion'
ln -s '/etc/alternatives/manila.bash_completion' '/etc/bash_completion.d/manila.bash_completion'
chown --no-dereference root:root '/etc/bash_completion.d/manila.bash_completion'
chmod 640 '/etc/brlapi.key'
chown root:brlapi '/etc/brlapi.key'
chmod 600 '/etc/iscsi/initiatorname.iscsi'
chown root:root '/etc/iscsi/initiatorname.iscsi'
chmod 444 '/etc/udev/hwdb.bin'
chown root:root '/etc/udev/hwdb.bin'
chmod 644 '/etc/xml/catalog-d.xml'
chown root:root '/etc/xml/catalog-d.xml'
chmod 755 '/run/avahi-daemon'
chown avahi:avahi '/run/avahi-daemon'
chmod 700 '/run/cryptsetup'
chown root:root '/run/cryptsetup'
chmod 755 '/run/mcelog'
chown root:root '/run/mcelog'
chmod 1777 '/run/tmux'
chown root:root '/run/tmux'
chmod 644 '/usr/lib/udev/compat-symlink-generation'
chown root:root '/usr/lib/udev/compat-symlink-generation'
chmod 644 '/usr/share/fonts/100dpi/encodings.dir'
chown root:root '/usr/share/fonts/100dpi/encodings.dir'
chmod 644 '/usr/share/fonts/100dpi/fonts.scale'
chown root:root '/usr/share/fonts/100dpi/fonts.scale'
chmod 644 '/usr/share/fonts/75dpi/encodings.dir'
chown root:root '/usr/share/fonts/75dpi/encodings.dir'
chmod 644 '/usr/share/fonts/75dpi/fonts.scale'
chown root:root '/usr/share/fonts/75dpi/fonts.scale'
chmod 644 '/usr/share/fonts/Type1/encodings.dir'
chown root:root '/usr/share/fonts/Type1/encodings.dir'
chmod 644 '/usr/share/fonts/cyrillic/encodings.dir'
chown root:root '/usr/share/fonts/cyrillic/encodings.dir'
chmod 644 '/usr/share/fonts/cyrillic/fonts.scale'
chown root:root '/usr/share/fonts/cyrillic/fonts.scale'
chmod 644 '/usr/share/fonts/misc/encodings.dir'
chown root:root '/usr/share/fonts/misc/encodings.dir'
chmod 644 '/usr/share/fonts/misc/fonts.scale'
chown root:root '/usr/share/fonts/misc/fonts.scale'
chmod 644 '/usr/share/fonts/truetype/encodings.dir'
chown root:root '/usr/share/fonts/truetype/encodings.dir'
rm -rf '/usr/share/java/jaxp_parser_impl.jar'
ln -s '/etc/alternatives/jaxp_parser_impl' '/usr/share/java/jaxp_parser_impl.jar'
chown --no-dereference root:root '/usr/share/java/jaxp_parser_impl.jar'
rm -rf '/usr/share/java/jaxp_transform_impl.jar'
ln -s '/etc/alternatives/jaxp_transform_impl' '/usr/share/java/jaxp_transform_impl.jar'
chown --no-dereference root:root '/usr/share/java/jaxp_transform_impl.jar'
rm -rf '/usr/share/java/xml-commons-apis.jar'
ln -s '/etc/alternatives/xml-commons-apis' '/usr/share/java/xml-commons-apis.jar'
chown --no-dereference root:root '/usr/share/java/xml-commons-apis.jar'
rm -rf '/usr/share/java/xml-commons-resolver.jar'
ln -s '/etc/alternatives/xml-commons-resolver' '/usr/share/java/xml-commons-resolver.jar'
chown --no-dereference root:root '/usr/share/java/xml-commons-resolver.jar'
rm -rf '/usr/share/man/man1/ftp.1.gz'
ln -s '/etc/alternatives/ftp.1' '/usr/share/man/man1/ftp.1.gz'
chown --no-dereference root:root '/usr/share/man/man1/ftp.1.gz'
chmod 770 '/var/cache/cups'
chown root:lp '/var/cache/cups'
chmod 644 '/var/lib/PackageKit/transactions.db'
chown root:root '/var/lib/PackageKit/transactions.db'
chmod 444 '/var/lib/ca-certificates/ca-bundle.pem'
chown root:root '/var/lib/ca-certificates/ca-bundle.pem'
chmod 444 '/var/lib/ca-certificates/java-cacerts'
chown root:root '/var/lib/ca-certificates/java-cacerts'
chmod 711 '/var/lib/sudo'
chown root:root '/var/lib/sudo'
chmod 700 '/var/lib/sudo/ts'
chown root:root '/var/lib/sudo/ts'
chmod 600 '/var/lib/systemd/random-seed'
chown root:root '/var/lib/systemd/random-seed'
chmod 644 '/var/log/alternatives.log'
chown root:root '/var/log/alternatives.log'
chmod 664 '/var/log/lastlog'
chown root:utmp '/var/log/lastlog'
chmod 600 '/var/spool/atjobs/.SEQ'
chown at:at '/var/spool/atjobs/.SEQ'
chmod 644 '/etc/cloud/cloud.cfg'
chown root:root '/etc/cloud/cloud.cfg'
chmod 644 '/etc/default/grub'
chown root:root '/etc/default/grub'
chmod 644 '/etc/default/useradd'
chown root:root '/etc/default/useradd'
chmod 644 '/etc/filesystems'
chown root:root '/etc/filesystems'
chmod 644 '/etc/fonts/conf.d/10-rendering-options.conf'
chown root:root '/etc/fonts/conf.d/10-rendering-options.conf'
chmod 644 '/etc/fonts/conf.d/30-metric-aliases.conf'
chown root:root '/etc/fonts/conf.d/30-metric-aliases.conf'
chmod 644 '/etc/fonts/conf.d/58-family-prefer-local.conf'
chown root:root '/etc/fonts/conf.d/58-family-prefer-local.conf'
chmod 644 '/etc/libvirt/libvirtd.conf'
chown root:root '/etc/libvirt/libvirtd.conf'
chmod 644 '/etc/libvirt/qemu.conf'
chown root:root '/etc/libvirt/qemu.conf'
chmod 644 '/etc/locale.conf'
chown root:root '/etc/locale.conf'
chmod 444 '/etc/machine-id'
chown root:root '/etc/machine-id'
chmod 640 '/etc/ntp.conf'
chown root:ntp '/etc/ntp.conf'
chmod 644 '/etc/pam.d/common-auth'
chown root:root '/etc/pam.d/common-auth'
chmod 644 '/etc/pam.d/common-password'
chown root:root '/etc/pam.d/common-password'
chmod 644 '/etc/pam.d/common-session'
chown root:root '/etc/pam.d/common-session'
chmod 644 '/etc/postfix/main.cf'
chown root:root '/etc/postfix/main.cf'
chmod 644 '/etc/postfix/master.cf'
chown root:root '/etc/postfix/master.cf'
chmod 640 '/etc/ssh/sshd_config'
chown root:root '/etc/ssh/sshd_config'
chmod 440 '/etc/sudoers'
chown root:root '/etc/sudoers'
chmod 644 '/etc/sysconfig/SuSEfirewall2'
chown root:root '/etc/sysconfig/SuSEfirewall2'
chmod 644 '/etc/sysconfig/network/ifcfg-lo'
chown root:root '/etc/sysconfig/network/ifcfg-lo'
chmod 644 '/etc/unixODBC/odbcinst.ini'
chown root:root '/etc/unixODBC/odbcinst.ini'
chmod 644 '/etc/vconsole.conf'
chown root:root '/etc/vconsole.conf'
chmod 600 '/var/log/audit/audit.log'
chown root:root '/var/log/audit/audit.log'
# Apply the extracted unmanaged files
find /tmp/unmanaged_files -name *.tgz -exec tar -C / -X '/tmp/unmanaged_files_kiwi_excludes' -xf {} \;
rm -rf '/tmp/unmanaged_files' '/tmp/unmanaged_files_kiwi_excludes'
# Create directories
mkdir -p /install/courses
chown .users /install/courses
chmod 2777 /install/courses
# Clean up Download dirs
rm -rf /root/Downloads/*
rm -rf /home/tux/Downloads/*
# Install custom RPMs
cd /inst/rpm
rpm -U --force *.rpm
cd -
# Install custom scripts
cp /inst/scripts/* /usr/local/bin/
chmod +x /usr/local/bin/*
# Update fstab
if ! grep -q LIVE_HOME /etc/fstab
then
  #echo "/dev/disk/by-label/LIVE_HOME  /home  auto  defaults  0 0" >> /etc/fstab
  echo "LABEL=LIVE_HOME  /home  auto  defaults,nofail,x-systemd.device-timeout=1  0 0" >> /etc/fstab
fi
# other fixes
sed -i '0,/^avahi:/! s/^avahi:/avahi-autoipd:/' /etc/shadow
# Cleanup /inst
rm -rf /inst
# Cleanup logs
journalctl --vacuum-time 1m
# Set capabilities
chkstat --system --fscaps
baseCleanMount
exit 0
