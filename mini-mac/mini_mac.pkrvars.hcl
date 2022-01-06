file_url              = "https://downloads.raspberrypi.org/raspios_full_armhf/images/raspios_full_armhf-2021-11-08/2021-10-30-raspios-bullseye-armhf-full.zip"
file_target_extension = "zip"

file_checksum_url  = "https://downloads.raspberrypi.org/raspios_full_armhf/images/raspios_full_armhf-2021-11-08/2021-10-30-raspios-bullseye-armhf-full.zip.sha256"
file_checksum_type = "sha256"

image_path = "mini_mac.img"

cloudinit_metadata_file = "mini-mac/mini_mac.metadata.yaml"
cloudinit_userdata_file = "mini-mac/mini_mac.userdata.yaml"

boot_config_filters = [
    [
        "[pi4]",

        # Enable audio (loads snd_bcm2835)
        "dtparam=audio=on",

        # Enable DRM VC4 V3D driver
        "dtoverlay=vc4-fkms-v3d",
        "max_framebuffers=2",

        # Disable compensation for displays with overscan
        "disable_overscan=1"
    ]
]
