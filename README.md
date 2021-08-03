
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

## Required Inputs

The following input variables are required:

### boot\_cmdline

Description: [`/boot/cmdline.txt`](https://www.raspberrypi.org/documentation/configuration/cmdline-txt.md) config.  
      
Linux kernel boot parameters, as a list, which will be joined as a space-delimited string.

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

Type: `list(string)`

### cloudinit\_metadata\_file

Description: The local path to a cloud-init metadata file

Type: `string`

### cloudinit\_userdata\_file

Description: The local path to a cloud-init userdata file

Type: `string`

### file\_checksum\_url

Description: The checksum file URL of `file_url`.  
See [packer-builder-arm](https://github.com/mkaczanowski/packer-builder-arm#remote-file)

Type: `string`

### file\_url

Description: The URL of the OS image file.  
See [packer-builder-arm](https://github.com/mkaczanowski/packer-builder-arm#remote-file)

Type: `string`

### image\_path

Description: The file path the new OS image to create

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### boot\_config

Description: [`/boot/config.txt` Raspberry Pi configs](https://www.raspberrypi.org/documentation/configuration/config-txt/README.md) as a list.

Type: `list(string)`

Default: `[]`

### boot\_config\_filters

Description: [`/boot/config.txt` Raspberry Pi *conditional filters* configs](https://www.raspberrypi.org/documentation/configuration/config-txt/conditional.md), as a map of the type `<filter>: [<configs list>]`.<br/><br/>e.g. `{"[pi0]": ["item1", "item2"]}` will yield:<br/>`[pi0]`<br/>`item1`<br/>`item2`

Type: `map(list(string))`

Default: `{}`

### file\_checksum\_type

Description: The checksum type of `file_checksum_url`.  
See [packer-builder-arm](https://github.com/mkaczanowski/packer-builder-arm#remote-file)

Type: `string`

Default: `"sha256"`

### file\_target\_extension

Description: The file extension of `file_url`.  
See [packer-builder-arm](https://github.com/mkaczanowski/packer-builder-arm#remote-file)

Type: `string`

Default: `"zip"`

### kernel\_modules

Description: List of Linux kernel modules to enable, as seen in `/etc/modules`

Type: `list(string)`

Default: `[]`

### locales

Description: List of locales to generate, as seen in `/etc/locale.gen`

Type: `list(string)`

Default:

```json
[
  "en_CA.UTF-8 UTF-8",
  "en_US.UTF-8 UTF-8"
]
```

### wpa\_supplicant\_country

Description: The [ISO 3166-1 alpha-2](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2) country code in which the device is operating.  
Required by the wpa\_supplicant.

Type: `string`

Default: `"CA"`

### wpa\_supplicant\_enabled

Description: Create a [`wpa_supplicant.conf` file](https://www.raspberrypi.org/documentation/configuration/wireless/wireless-cli.md) on the image.  
If `wpa_supplicant_path` exists, it will be copied to the OS image, otherwise a basic `wpa_supplicant.conf` file will be created using `wpa_supplicant_ssid`, `wpa_supplicant_pass` and `wpa_supplicant_country`

Type: `bool`

Default: `true`

### wpa\_supplicant\_pass

Description: The WiFi password

Type: `string`

Default: `""`

### wpa\_supplicant\_path

Description: The local path to existing `wpa_supplicant.conf` to copy to the image.

Type: `string`

Default: `"/tmp/dummy"`

### wpa\_supplicant\_ssid

Description: The WiFi SSID

Type: `string`

Default: `""`
