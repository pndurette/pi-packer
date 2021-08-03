/**
*
* # pi-packer
*
* An opinionated [HashiCorp Packer](https://www.packer.io) template for Raspberry Pi images, built around the [`packer-builder-arm`](https://github.com/mkaczanowski/packer-builder-arm) ARM Packer builder plugin.
*
* ## Usage
* (e.g. using the [`usb-gadget/usb_gadget.pkrvars.hcl`](usb-gadget/usb_gadget.pkrvars.hcl) [variable override file](https://www.packer.io/docs/templates/hcl_templates/variables#variable-definitions-pkrvars-hcl-and-auto-pkrvars-hcl-files) for the inputs below)
* ```bash
* docker run --rm --privileged \
*     -v /dev:/dev \
*     -v ${PWD}:/build \
*     mkaczanowski/packer-builder-arm \
*         build \
*         -var-file=usb_gadget.pkrvars.hcl \
*         pi.pkr.hcl
* ```
*
*/

# Variables: packer-builder-arm builder 'file_'
# https://github.com/mkaczanowski/packer-builder-arm#remote-file

variable "file_url" {
    type = string
    description = "The URL of the OS image file. See [packer-builder-arm](https://github.com/mkaczanowski/packer-builder-arm#remote-file)"
}

variable "file_target_extension" {
    type = string
    description = "The file extension of `file_url`. See [packer-builder-arm](https://github.com/mkaczanowski/packer-builder-arm#remote-file)"
    default = "zip"
}

variable "file_checksum_url" {
    type = string
    description = "The checksum file URL of `file_url`. See [packer-builder-arm](https://github.com/mkaczanowski/packer-builder-arm#remote-file)"
}

variable "file_checksum_type" {
    type = string
    description = "The checksum type of `file_checksum_url`. See [packer-builder-arm](https://github.com/mkaczanowski/packer-builder-arm#remote-file)"
    default = "sha256"
}

# Variables: packer-builder-arm builder 'image_'
# https://github.com/mkaczanowski/packer-builder-arm#image-config

variable "image_path" {
    type = string
    description = "The file path the new OS image to create"
}

# Variables: OS Config

variable "locales" {
    type = list(string)
    description = "List of locales to generate, as seen in `/etc/locale.gen`"
    default = ["en_CA.UTF-8 UTF-8", "en_US.UTF-8 UTF-8"]
}

# Variables: /boot configs

variable "wpa_supplicant_enabled" {
    type = bool
    description = "Create a [`wpa_supplicant.conf` file](https://www.raspberrypi.org/documentation/configuration/wireless/wireless-cli.md) on the image.<br/>If `wpa_supplicant_path` exists, it will be copied to the OS image, otherwise a basic `wpa_supplicant.conf` file will be created using `wpa_supplicant_ssid`, `wpa_supplicant_pass` and `wpa_supplicant_country`"
    default = true
}

variable "wpa_supplicant_path" {
    type = string
    description = "The local path to existing `wpa_supplicant.conf` to copy to the image."
    default = "/tmp/dummy" # fileexists() doesn't like empty strings
}

variable "wpa_supplicant_ssid" {
    type = string
    description = "The WiFi SSID"
    default = ""
}

variable "wpa_supplicant_pass" {
    type = string
    description = "The WiFi password"
    default = ""
}

variable "wpa_supplicant_country" {
    type = string
    description = "The [ISO 3166-1 alpha-2](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2) country code in which the device is operating, for `wpa_supplicant`. Necessary for [country-specific radio regulations](https://www.oreilly.com/library/view/learn-robotics-programming/9781789340747/5027f394-f16e-4096-bbaf-05e19070e84e.xhtml)"
    default = "CA"
}

variable "boot_cmdline" {
    type = list(string)
    description = "[`/boot/cmdline.txt`](https://www.raspberrypi.org/documentation/configuration/cmdline-txt.md) Linux kernel boot parameters, as a list, which will be joined into a space-delimited string"
    default = [
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
}

variable "boot_config" {
    type = list(string)
    description = "[`/boot/config.txt` Raspberry Pi configs](https://www.raspberrypi.org/documentation/configuration/config-txt/README.md) as a list."
    default = []
}

variable "boot_config_filters" {
    type = map(list(string))
    description = "[`/boot/config.txt` Raspberry Pi *conditional filters* configs](https://www.raspberrypi.org/documentation/configuration/config-txt/conditional.md), as a map of the type `<filter>: [<configs list>]`.<br/><br/>e.g. `{\"[pi0]\": [\"item1\", \"item2\"]}` will yield:<br/>`[pi0]`<br/>`item1`<br/>`item2`"
    default = {}
}

variable "cloudinit_metadata_file" {
    type = string
    description = "The local path to a cloud-init metadata file"
}

variable "cloudinit_userdata_file" {
    type = string
    description = "The local path to a cloud-init userdata file"
}

variable "kernel_modules" {
    type = list(string)
    description = "List of Linux kernel modules to enable, as seen in `/etc/modules`"
    default = []
}

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
        %{ for filter_name, filter_values in var.boot_config_filters ~}
        ${~ filter_name}
        %{ for config in filter_values ~}
        ${~ config}
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

    # # Install cloud-init
    # TODO: Make multi-distro
    provisioner "shell" {
        inline = [
            "sudo apt-get update",
            "sudo apt-get install -y cloud-init"
        ]
    }

    # cloud-init cloud.cfg
    # TODO: Make more generic/configurable
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
        -var-file=base.pkrvars.hcl \
        -var-file=usb_gadget.pkrvars.hcl \
        pi.pkr.hcl
*/