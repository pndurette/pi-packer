file_url              = "https://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-2021-05-28/2021-05-07-raspios-buster-armhf-lite.zip"
file_target_extension = "zip"

file_checksum_url  = "https://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-2021-05-28/2021-05-07-raspios-buster-armhf-lite.zip.sha256"
file_checksum_type = "sha256"

image_path = "usb_gadget.img"

cloudinit_metadata_file = "usb-gadget/usb_gadget.metadata.yaml"
cloudinit_userdata_file = "usb-gadget/usb_gadget.userdata.yaml"

# Based on https://medium.com/sausheong/setting-up-a-raspberry-pi-4-as-an-development-machine-for-your-ipad-pro-3813f872fccc

boot_config = [
    "dtoverlay=dwc2"
]

boot_cmdline = [
    "console=serial0,115200",
    "console=tty1",
    "root=PARTUUID=9730496b-02",
    "rootfstype=ext4",
    "elevator=deadline",
    "fsck.repair=yes",
    "rootwait",
    "quiet",
    "init=/usr/lib/raspi-config/init_resize.sh",
    "modules-load=dwc2"
]

boot_config_filters = [
    [
        "[pi4]",
        "dtoverlay=vc4-fkms-v3d",
        "max_framebuffers=2"
    ]
]

kernel_modules = [
    "libcomposite"
]
