# Variables: packer-builder-arm builder 'file_'
# https://github.com/mkaczanowski/packer-builder-arm#remote-file

variable "file_url" {
    type = string
}

variable "file_target_extension" {
    type = string
    default = "zip"
}

variable "file_checksum_url" {
    type = string
}

variable "file_checksum_type" {
    type = string
    default = "sha256"
}

# Variables: packer-builder-arm builder 'image_'
# https://github.com/mkaczanowski/packer-builder-arm#image-config

variable "image_path" {
    type = string
}

# Variables: OS Config

variable "locales" {
    type = list(string)
    default = ["en_CA.UTF-8 UTF-8", "en_US.UTF-8 UTF-8"]
    description = "List of locales to generate, as seen in /etc/locale.gen"
}

# Variables: /boot configs

variable "wpa_supplicant_enabled" {
    type = bool
    default = true
}

variable "wpa_supplicant_path" {
    type = string
}

variable "wpa_supplicant__ssid" {
    type = string
    default = ""
}

variable "wpa_supplicant_pass" {
    type = string
    default = ""
}

variable "wpa_supplicant_country" {
    type = string
    default = "CA"
}

variable "boot_cmdline" {
    type = list(string)
    default = []
}

variable "boot_config" {
    type = list(string)
    default = []
}

variable "boot_config_filters" {
    type = map(list(string))
    default = {}
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
        country=${upper(var.wpa_country)}

        network={
            ssid="${var.wpa_ssid}"
            psk="${var.wpa_pass}"
        }
    EOF

    # /etc/locale.gen
    localgen = join("\n", var.locales)
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
    image_size       = "2G"
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
    # Send to /dev/null to prevent secrets from showing up in log
    provisioner "shell" {
        inline = [
        <<-EOF
            %{ if var.wpa_supplicant_enabled }
                tee /etc/wpa_supplicant/wpa_supplicant.conf <<- CONFIG > /dev/null
                %{ if fileexists(var.wpa_supplicant_path) }
                ${file(var.wpa_supplicant_path)}
                %{ else }
                ${local.wpa_supplicant}
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
            cat <<- CONF >> /etc/locale.gen
            ${local.localgen}
            CONF
        EOF
        ]
    }

    # # Install cloud-init
    # provisioner "shell" {
    #     inline = [
    #         "sudo apt-get update",
    #         "sudo apt-get install -y cloud-init"
    #     ]
    # }

    # # cloud-init cloud.cfg
    # provisioner "file" {
    #     source = "config/cloud.cfg.yaml"
    #     destination = "/etc/cloud/cloud.cfg"
    # }

    # # Copy meta-data and user-data
    # provisioner "file" {
    #     source = "config/meta-data.yaml"
    #     destination = "/boot/meta-data"
    # }

    # provisioner "file" {
    #     source = "config/user-data.yaml"
    #     destination = "/boot/user-data"
    # }

    # # Enable services
    # provisioner "shell" {
    #     inline = [
    #         "systemctl enable ssh",
    #         "systemctl enable cloud-init"
    #     ]
    # }
}
