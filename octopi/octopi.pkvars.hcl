file_url              = "https://github.com/guysoft/OctoPi/releases/download/0.18.0/octopi-buster-armhf-lite-0.18.0.zip"
file_target_extension = "zip"

file_checksum    = "43387c99873210969a21083520ec963b"
file_checksum_type = "md5"

image_path = "octopi.img"

cloudinit_metadata_file = "octopi/octopi.metadata.yaml"
cloudinit_userdata_file = "octopi/octopi.userdata.yaml"

boot_config_filters = [
    [
        "[all]",
        # Enable raspicam
        "start_x=1",
        "gpu_mem=128"
    ]
]