/**
*
* # pi-packer
*
* An opinionated [HashiCorp Packer](https://www.packer.io) template for Raspberry Pi images, built around the [`packer-builder-arm`](https://github.com/mkaczanowski/packer-builder-arm) ARM Packer builder plugin. It implements [cloud-init](https://cloudinit.readthedocs.io/en/latest/index.html) for last-mile OS configuration and management.
*
* See [`pi.pkr.hcl`](pi.pkr.hcl).
*
* ## Usage
*
* ### 1. Configuration values
*
* Copy [`example.pkrvars.hcl`](example.pkrvars.hcl) and edit.
* 
* *(See [Packer docs](https://www.packer.io/docs/templates/hcl_templates/variables#assigning-values-to-build-variables) for more ways to set input variables)*
* 
* ### 2. Build
*
* (e.g. using [`usb-gadget/usb_gadget.pkrvars.hcl`](usb-gadget/usb_gadget.pkrvars.hcl))
* ```bash
* docker run --rm --privileged \
*     -v /dev:/dev \
*     -v ${PWD}:/build \
*     mkaczanowski/packer-builder-arm \
*         build \
*         -var-file=usb-gadget/usb_gadget.pkrvars.hcl \
*         -var "git_repo=$(git remote get-url origin)" \
*         -var "git_commit=$(git rev-parse HEAD)" \
*         pi.pkr.hcl
* ```
* *(Using the above Docker image and run command is the easiest way to build cross-platform ARM images. See [`packer-builder-arm`](https://github.com/mkaczanowski/packer-builder-arm#quick-start) for alternative ways to run Packer with the `packer-builder-arm` plugin)*
*/

# Variables: packer-builder-arm builder 'file_'
# https://github.com/mkaczanowski/packer-builder-arm#remote-file

variable "file_url" {
    type = string
    description = <<-EOT
        The URL of the OS image file.
        
        See [packer-builder-arm](https://github.com/mkaczanowski/packer-builder-arm#remote-file).
    EOT
}

variable "file_target_extension" {
    type = string
    description = <<-EOT
        The file extension of `file_url`.
        
        See [packer-builder-arm](https://github.com/mkaczanowski/packer-builder-arm#remote-file).
    EOT
    default = "zip"
}

variable "file_checksum" {
    type = string
    description = <<-EOT
        The checksum value of `file_url`.

        See [packer-builder-arm](https://github.com/mkaczanowski/packer-builder-arm#remote-file).
    EOT
    default = ""
}


variable "file_checksum_url" {
    type = string
    description = <<-EOT
        The checksum file URL of `file_url`.
        
        See [packer-builder-arm](https://github.com/mkaczanowski/packer-builder-arm#remote-file).
    EOT
    default = ""
}

variable "file_checksum_type" {
    type = string
    description = <<-EOT
        The checksum type of `file_checksum_url`.
        
        See [packer-builder-arm](https://github.com/mkaczanowski/packer-builder-arm#remote-file).
    EOT
    default = "sha256"
}

# Variables: packer-builder-arm builder 'image_'
# https://github.com/mkaczanowski/packer-builder-arm#image-config

variable "image_path" {
    type = string
    description = "The file path the new OS image to create."
}

# Variables: OS Config

variable "locales" {
    type = list(string)
    description = "List of locales to generate, as seen in `/etc/locale.gen`."
    default = ["en_CA.UTF-8 UTF-8", "en_US.UTF-8 UTF-8"]
}

# Variables: /boot configs

variable "wpa_supplicant_enabled" {
    type = bool
    description = <<-EOT
        Create a [`wpa_supplicant.conf` file](https://www.raspberrypi.org/documentation/configuration/wireless/wireless-cli.md) on the image.
        
        If `wpa_supplicant_path` exists, it will be copied to the OS image, otherwise a basic `wpa_supplicant.conf` file will be created using `wpa_supplicant_ssid`, `wpa_supplicant_pass` and `wpa_supplicant_country`.
    EOT
    default = true
}

variable "wpa_supplicant_path" {
    type = string
    description = "The local path to existing `wpa_supplicant.conf` to copy to the image."
    default = "/tmp/dummy" # fileexists() doesn't like empty strings
}

variable "wpa_supplicant_ssid" {
    type = string
    description = "The WiFi SSID."
    default = ""
}

variable "wpa_supplicant_pass" {
    type = string
    description = "The WiFi password."
    default = ""
}

variable "wpa_supplicant_country" {
    type = string
    description = <<-EOT
        The [ISO 3166-1 alpha-2](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2) country code in which the device is operating.
        
        Required by the wpa_supplicant.
    EOT
    default = "CA"
}

variable "boot_cmdline" {
    type = list(string)
    description = <<-EOT
        [`/boot/cmdline.txt`](https://www.raspberrypi.org/documentation/configuration/cmdline-txt.md) config.
        
        Linux kernel boot parameters, as a list. Will be joined as a space-delimited string.

        e.g.:
        ```
        boot_cmdline = [
            "abc",
            "def"
        ]
        ```
        Will create `/boot/cmdline.txt` as
        ```
        abc def
        ```
    EOT
    default = [
        "console=serial0,115200",
        "console=tty1",
        "root=/dev/mmcblk0p2", # multimedia (SD) card block 0 partition 2
        "rootfstype=ext4",
        "elevator=deadline",
        "fsck.repair=yes",
        "rootwait",
        "quiet",
        "init=/usr/lib/raspi-config/init_resize.sh"
    ]
}

variable "boot_config" {
    type = list(string)
    description = <<-EOT
        [`/boot/config.txt`](https://www.raspberrypi.org/documentation/configuration/config-txt/README.md)

        Raspberry Pi system configuration, as a list. Will be joined by newlines.

        e.g.:
        ```
        boot_cmdline = [
            "abc=123",
            "def=456"
        ]
        ```
        Will begin `/boot/config.txt` with:
        ```
        abc=123
        def=456
        ```
    EOT
    default = []
}

variable "boot_config_filters" {
    type = list(list(string))
    description = <<-EOT
        [`/boot/config.txt`](ttps://www.raspberrypi.org/documentation/configuration/config-txt/conditional.md)

        Raspberry Pi system *conditional filters* configuration, as a list.

        e.g.:
        ```
        boot_config_filters = [
            [
                "[pi0]",
                "jhi=123",
                "klm=456"
            ],
            [
                "[pi0w]",
                "xzy",
                "123"
            ],
        ]
        ```
        Will end `/boot/config.txt` with:
        ```
        [pi0]
        jhi=123
        klm=456
        [pi0w]
        xyz
        123
        ```
    EOT
    default = [
        [
			"[pi4]",
            "dtoverlay=vc4-fkms-v3d",
            "max_framebuffers=2"
        ]
	]
}

variable "cloudinit_metadata_file" {
    type = string
    description = <<-EOT
        The local path to a cloud-init metadata file.
        
        See the `cloud-init` [`NoCloud` datasource](https://cloudinit.readthedocs.io/en/latest/topics/datasources/nocloud.html)
    EOT
}

variable "cloudinit_userdata_file" {
    type = string
    description = <<-EOT
        The local path to a cloud-init userdata file.
        
        See the `cloud-init` [`NoCloud` datasource](https://cloudinit.readthedocs.io/en/latest/topics/datasources/nocloud.html)
    EOT
}

variable "kernel_modules" {
    type = list(string)
    description = "List of Linux kernel modules to enable, as seen in `/etc/modules`"
    default = []
}

variable "git_repo" {
    type = string
    description = <<-EOT
        The current git remote to pass to the build. It will be prepended to `/boot/config.txt`

        Use on the command-line, i.e. `-var "git_repo=$(git remote get-url origin)" `
    EOT
    default = ""
}

variable "git_commit" {
    type = string
    description = <<-EOT
        The current git commit to pass to the build. It will be prepended to `/boot/config.txt`

        Use on the command-line, i.e. `-var "git_commit=$(git rev-parse HEAD)"`
    EOT
    default = ""
}

# File content is all generated within locals

locals {
    # Generate files string content

    # /boot/cmdline.txt
    boot_cmdline = join(" ", var.boot_cmdline)

    # /boot/config.txt
    boot_config = <<-EOF
# General config
%{ for config in var.boot_config ~}
${~ config}
%{ endfor ~}

# Filtered config
%{ for filter_block in var.boot_config_filters ~}
%{ for filter_element in filter_block ~}
${~ filter_element }
%{ endfor ~}
%{ endfor ~}
EOF

    # /etc/wpa_supplicant/wpa_supplicant.conf
    wpa_supplicant = <<-EOF
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
country=${upper(var.wpa_supplicant_country)}

network={
    ssid="${var.wpa_supplicant_ssid}"
    psk="${var.wpa_supplicant_pass}"
}
EOF

    # /etc/locale.gen
    localgen = join("\n", var.locales)

    # /etc/modules
    kernel_modules = join("\n", var.kernel_modules)
}

# Packer ARM builder
# https://github.com/mkaczanowski/packer-builder-arm

source "arm" "rpi" {
    file_urls             = [var.file_url]
    file_target_extension = var.file_target_extension

    file_checksum         = var.file_checksum
    file_checksum_url     = var.file_checksum_url
    file_checksum_type    = var.file_checksum_type

    image_build_method    = "reuse"
    
    image_partitions {
        filesystem   = "vfat"
        mountpoint   = "/boot"
        name         = "boot"
        size         = "256M"
        start_sector = "8192"
        type         = "c"
    }

    image_partitions {
        filesystem   = "ext4"
        mountpoint   = "/"
        name         = "root"
        size         = "0"
        start_sector = "532480"
        type         = "83"
    }

    image_path       = var.image_path
    image_size       = "1G"
    image_type       = "dos"
    image_chroot_env = ["PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin"]

    qemu_binary_destination_path = "/usr/bin/qemu-arm-static"
    qemu_binary_source_path      = "/usr/bin/qemu-arm-static"
}

build {
    sources = [
        "source.arm.rpi"
    ]

    # Backup original /boot files
    provisioner "shell" {
        inline = [
           "cp /boot/config.txt /boot/config.txt.bak",
           "cp /boot/cmdline.txt /boot/cmdline.txt.bak",
        ]
    }

    # Generate new /boot/config.txt
    # NB: the <tabs> for the indented HEREDOC
    provisioner "shell" {
        inline = [
        <<-EOF
			tee /boot/config.txt <<- CONFIG
				# Image: ${var.image_path} (generated $(date))
				# ${var.git_repo} (${var.git_commit})

				${local.boot_config}
				CONFIG
        EOF
        ]
    }

    # Generate new /boot/cmdline.txt
    # NB: the <tabs> for the indented HEREDOC
    provisioner "shell" {
        inline = [
        <<-EOF
			tee /boot/cmdline.txt <<- CONFIG
				${local.boot_cmdline}
				CONFIG
        EOF
        ]
    }

    # Generate /etc/wpa_supplicant/wpa_supplicant.conf (if enabled)
    # NB: send to /dev/null to prevent secrets from showing up in log
    # NB: the <tabs> for the indented HEREDOC
    provisioner "shell" {
        inline = [
        <<-EOF
            %{ if var.wpa_supplicant_enabled }
			tee /boot/wpa_supplicant.conf <<- CONFIG > /dev/null
				%{~ if fileexists(var.wpa_supplicant_path) ~}
				${ file(var.wpa_supplicant_path) }
				%{ else }
				${ local.wpa_supplicant }
				%{ endif }
				CONFIG
            %{ else }
            echo "wpa_supplicant disabled."
            %{ endif }
        EOF
        ]
    }

    # Add locales that will get generated on first boot
    # (by cloud-init's 'locale' module) 
    provisioner "shell" {
        inline = [
        <<-EOF
			tee -a /etc/locale.gen <<- CONFIG
				${local.localgen}
				CONFIG
        EOF
        ]
    }

    # Install cloud-init
    # TODO: Make multi-distro
    provisioner "shell" {
        inline = [
            "sudo apt-get update --allow-releaseinfo-change",
            "sudo apt-get install -y cloud-init"
        ]
    }

    # cloud-init cloud.cfg
    # TODO: Make more generic/configurable
    # TODO: Use /etc/cloud/cloud.cfg.d/*.cfg
    provisioner "file" {
        source = "cloud-init/cloud.cfg.yaml"
        destination = "/etc/cloud/cloud.cfg"
    }

    # Copy meta-data and user-data (NoCloud with local paths)
    # https://cloudinit.readthedocs.io/en/latest/topics/datasources/nocloud.html
    provisioner "file" {
        source = var.cloudinit_metadata_file
        destination = "/boot/meta-data"
    }

    provisioner "file" {
        source = var.cloudinit_userdata_file
        destination = "/boot/user-data"
    }

    # Add kernel modules to load
    provisioner "shell" {
        inline = [
        <<-EOF
			tee -a /etc/modules <<- CONFIG
				${local.kernel_modules}
				CONFIG
        EOF
        ]
    }

    # Enable services
    provisioner "shell" {
        inline = [
            "systemctl enable ssh",
            "systemctl enable cloud-init"
        ]
    }
}

/**

To re-gen the README.md:
(requires terraform-docs -- which only reads .tf,
and the header from main.tf)

cp pi.pkr.hcl main.tf \
&& terraform-docs markdown \
	--show "header,inputs" . > README.md \
&& rm main.tf

# Command:
docker run --rm --privileged \
    -v /dev:/dev \
    -v ${PWD}:/build \
    mkaczanowski/packer-builder-arm \
        build \
        -var-file=octopi/octopi.pkvars.hcl \
        -var-file=wifi.pkvars.hcl \
        -var "git_repo=$(git remote get-url origin)" \
        -var "git_commit=$(git rev-parse HEAD)" \
        pi.pkr.hcl
*/