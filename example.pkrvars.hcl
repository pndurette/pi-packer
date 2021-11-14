# Raspberry Pi OS base image
# https://github.com/mkaczanowski/packer-builder-arm#remote-file

file_url              = "https://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-2021-05-28/2021-05-07-raspios-buster-armhf-lite.zip"
file_target_extension = "zip"

file_checksum_url  = "https://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-2021-05-28/2021-05-07-raspios-buster-armhf-lite.zip.sha256"
file_checksum_type = "sha256"

# Resulting image file
# Could also be passed at the command line, e.g.
# -var="image_path=whatever.img"

image_path = "rpi.img"

# wpa_supplicant.conf file to use
# https://linux.die.net/man/5/wpa_supplicant.conf

wpa_supplicant_enabled = false
# wpa_supplicant_path = ""
# wpa_supplicant_ssid = ""
# wpa_supplicant_pass = ""
# wpa_supplicant_country = ""

# /boot/cmdline.txt (default)
# https://www.raspberrypi.org/documentation/configuration/cmdline-txt.md

boot_cmdline = [
    "console=serial0,115200",
    "console=tty1",
    "root=PARTUUID=9730496b-02",
    "rootfstype=ext4",
    "elevator=deadline",
    "fsck.repair=yes",
    "rootwait",
    "quiet",
    "init=/usr/lib/raspi-config/init_resize.sh"
]

# /boot/config.txt (properties) (default)
# http://rpf.io/configtxt
# https://elinux.org/RPiconfig

boot_config = []

# /boot/config.txt (conditional filters properties) (default)
# https://www.raspberrypi.org/documentation/configuration/config-txt/conditional.md

boot_config_filters = [
    [
        "[pi4]",
        "dtoverlay=vc4-fkms-v3d",
        "max_framebuffers=2"
    ]
]

# Kernel modules to load at boot time

kernel_modules = []

# cloud-init (NoCloud with local paths)
# https://cloudinit.readthedocs.io/en/latest/topics/datasources/nocloud.html

cloudinit_metadata_file = ""
cloudinit_userdata_file = ""