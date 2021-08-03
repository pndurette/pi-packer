
# pi-packer

An opinionated [HashiCorp Packer](https://www.packer.io) template for Raspberry Pi images, built around the [`packer-builder-arm`](https://github.com/mkaczanowski/packer-builder-arm) ARM Packer builder plugin.

See [`pi.pkr.hcl`](pi.pkr.hcl).

## Usage

#### 1. Configuration values

Copy [`example.pkrvars.hcl`](example.pkrvars.hcl) and edit
*(See [Packer docs](https://www.packer.io/docs/templates/hcl_templates/variables#assigning-values-to-build-variables) for more ways to set input variables)*.

#### 2. Build

(e.g. using the [`usb-gadget/usb_gadget.pkrvars.hcl`](usb-gadget/usb\_gadget.pkrvars.hcl) [variable override file](https://www.packer.io/docs/templates/hcl_templates/variables#variable-definitions-pkrvars-hcl-and-auto-pkrvars-hcl-files) for the inputs below)
```bash
docker run --rm --privileged \
    -v /dev:/dev \
    -v ${PWD}:/build \
    mkaczanowski/packer-builder-arm \
        build \
        -var-file=usb-gadget/usb_gadget.pkrvars.hcl \
        pi.pkr.hcl
```
*(Using the above Docker image and run command is the easiest way build cross-platform ARM images. See [`packer-builder-arm`](https://github.com/mkaczanowski/packer-builder-arm#quick-start) for alternative ways to run Packer with the `packer-builder-arm` plugin)*

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| boot\_cmdline | [`/boot/cmdline.txt`](https://www.raspberrypi.org/documentation/configuration/cmdline-txt.md) config.<br>    <br>Linux kernel boot parameters, as a list, which will be joined as a space-delimited string.<br><br>e.g.:<pre>boot_cmdline = [<br>    "abc",<br>    "def"<br>]</pre>Will create `/boot/cmdline.txt` as<pre>abc def</pre> | `list(string)` | n/a | yes |
| boot\_config | [`/boot/config.txt` Raspberry Pi configs](https://www.raspberrypi.org/documentation/configuration/config-txt/README.md) as a list. | `list(string)` | `[]` | no |
| boot\_config\_filters | [`/boot/config.txt` Raspberry Pi *conditional filters* configs](https://www.raspberrypi.org/documentation/configuration/config-txt/conditional.md), as a map of the type `<filter>: [<configs list>]`.<br/><br/>e.g. `{"[pi0]": ["item1", "item2"]}` will yield:<br/>`[pi0]`<br/>`item1`<br/>`item2` | `map(list(string))` | `{}` | no |
| cloudinit\_metadata\_file | The local path to a cloud-init metadata file | `string` | n/a | yes |
| cloudinit\_userdata\_file | The local path to a cloud-init userdata file | `string` | n/a | yes |
| file\_checksum\_type | The checksum type of `file_checksum_url`.<br>See [packer-builder-arm](https://github.com/mkaczanowski/packer-builder-arm#remote-file) | `string` | `"sha256"` | no |
| file\_checksum\_url | The checksum file URL of `file_url`.<br>See [packer-builder-arm](https://github.com/mkaczanowski/packer-builder-arm#remote-file) | `string` | n/a | yes |
| file\_target\_extension | The file extension of `file_url`.<br>See [packer-builder-arm](https://github.com/mkaczanowski/packer-builder-arm#remote-file) | `string` | `"zip"` | no |
| file\_url | The URL of the OS image file.<br>See [packer-builder-arm](https://github.com/mkaczanowski/packer-builder-arm#remote-file) | `string` | n/a | yes |
| image\_path | The file path the new OS image to create | `string` | n/a | yes |
| kernel\_modules | List of Linux kernel modules to enable, as seen in `/etc/modules` | `list(string)` | `[]` | no |
| locales | List of locales to generate, as seen in `/etc/locale.gen` | `list(string)` | <pre>[<br>  "en_CA.UTF-8 UTF-8",<br>  "en_US.UTF-8 UTF-8"<br>]</pre> | no |
| wpa\_supplicant\_country | The [ISO 3166-1 alpha-2](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2) country code in which the device is operating.<br>Required by the wpa\_supplicant. | `string` | `"CA"` | no |
| wpa\_supplicant\_enabled | Create a [`wpa_supplicant.conf` file](https://www.raspberrypi.org/documentation/configuration/wireless/wireless-cli.md) on the image.<br>If `wpa_supplicant_path` exists, it will be copied to the OS image, otherwise a basic `wpa_supplicant.conf` file will be created using `wpa_supplicant_ssid`, `wpa_supplicant_pass` and `wpa_supplicant_country` | `bool` | `true` | no |
| wpa\_supplicant\_pass | The WiFi password | `string` | `""` | no |
| wpa\_supplicant\_path | The local path to existing `wpa_supplicant.conf` to copy to the image. | `string` | `"/tmp/dummy"` | no |
| wpa\_supplicant\_ssid | The WiFi SSID | `string` | `""` | no |
