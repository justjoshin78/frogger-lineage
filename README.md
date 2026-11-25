# LineageOS 23.2 for Nothing Phone (4a) "frogger"

An unofficial LineageOS 23.2 (Android 16) build for the Nothing Phone (4a), SM7635.
It's based on the [FroggerSpace](https://github.com/FroggerSpace) lineage-24.0 trees,
backported to 23.2.

Prebuilt zips are on the [Releases](../../releases) page.

## Status

Daily-usable. SELinux is enforcing, and builds are signed with private release keys.

Working:
- Calls, including VoLTE call audio on the earpiece, mic and Bluetooth
- Mobile data, Wi-Fi, Bluetooth and NFC
- All cameras, audio, sensors and display
- Fingerprint and face unlock
- Haptics and charging
- Glyph lights, through the bundled Glyph app

Known gaps:
- Miracast is built from stock B4.1 blobs, but it hasn't been tested on a device.

## What's changed from upstream

Each changed project has a `frogger-23.2` branch in a fork. [`local_manifests/frogger.xml`](local_manifests/frogger.xml)
points to those forks.

| Project | Main changes |
|---|---|
| device/nothing/frogger | Backport to 23.2, NFC detection fix, enforcing SELinux policy, the Glyph app (`glyph/`), face-enroll overlay, 60 Hz minimum refresh |
| vendor/nothing/frogger | System-side blobs from stock B4.1 (telephony, IMS, QCC, Miracast) in place of the Android 17 ones |
| hardware/nothing | `libdmabufheap` and `libcxx` shims for the B4.1 blobs |
| kernel/nothing/sm7635 | `vendor/frogger.config` fragment (frogger audio dailinks) |
| kernel/nothing/sm7635-modules | Build fixes for aw882xx, video, qcacld-3.0 and touch drivers |
| frameworks/base | Default minimum refresh rate of 60 Hz. The panel treats 30 Hz as always-on display, which makes brightness flash. |
| packages/apps/Settings | `config_face_enroll_hal_preview`: the face HAL draws the enrollment preview, because it needs the front camera itself |

[`patches/`](patches) holds one-line build fixes for repos that aren't forked:
- `vendor_available` on skia, XMP-Toolkit-SDK and google-highway
- A renamed IPA kernel-headers module in qcom-caf

[`docs/BUILD_NOTES.md`](docs/BUILD_NOTES.md) is the full working log.

## Building

You need about 400 GB of disk space and at least 32 GB of RAM.

```bash
mkdir lineage-23.2 && cd lineage-23.2
repo init -u https://github.com/LineageOS/android.git -b lineage-23.2 --git-lfs
git clone https://github.com/justjoshin78/frogger-lineage ../frogger-lineage
mkdir -p .repo/local_manifests
cp ../frogger-lineage/local_manifests/frogger.xml .repo/local_manifests/
repo sync -c -j8
../frogger-lineage/apply-patches.sh .
```

### Signing keys

Builds should be signed with your own keys. Otherwise Trust warns about public test keys, and anyone could
sign an update your phone would accept. Generate a set once with `development/tools/make_key`:
- releasekey, platform, shared, media, networkstack, sdk_sandbox, bluetooth, nfc and testkey
- Put them in `vendor/lineage-priv/keys/`.
- Back them up, and never commit them anywhere.

Then create `vendor/lineage-priv/keys/keys.mk`:

```make
PRODUCT_DEFAULT_DEV_CERTIFICATE := vendor/lineage-priv/keys/releasekey
PRODUCT_MAINLINE_BLUETOOTH_SEPOLICY_DEV_CERTIFICATES := vendor/lineage-priv/keys
```

You need the second line. Without it, SELinux expects the AOSP test Bluetooth key, and Bluetooth crashes on start.

Also add a `BUILD.bazel` file next to the keys:

```
filegroup(name = "android_certificate_directory", srcs = glob(["*.pk8", "*.pem"]), visibility = ["//visibility:public"])
```

### Build

```bash
LINEAGE_TOP=$PWD ../frogger-lineage/build_frogger.sh bacon
```

The zip is written to `out/target/product/frogger/lineage-23.2-<date>-UNOFFICIAL-frogger.zip`.

Host notes:
- Run the build from a clean shell environment. The build script does this.
- On Arch, install `libxcrypt-compat`, because the bundled perl needs `libcrypt.so.1`.

## Flashing

The zip also flashes the stock **C5.0** firmware (abl, xbl, tz, modem, …).

1. Unlock the bootloader.
2. Flash LineageOS recovery.
3. Run `adb reboot sideload`, then `adb sideload lineage-23.2-…-frogger.zip`.

Release-zip signing:
- The release zips are signed with this project's own key.
- If you're coming from a build signed with other keys, recovery shows "signature verification failed" on the first flash. Choose **Yes** to install anyway.
- Moving between differently-signed builds keeps app data, but a clean install is safer.

Coming from stock with a screen lock or Google account set up: Factory Reset Protection can stay active after
a format. Remove the account in stock before unlocking.

## Credits and notice

- [LineageOS](https://lineageos.org)
- [FroggerSpace](https://github.com/FroggerSpace) for the device, kernel and vendor trees
- Nothing for the kernel source

`vendor/nothing/frogger` holds proprietary Nothing and Qualcomm binaries extracted from stock firmware.
They're redistributed only so the device can be built, and they remain the property of their owners.

Unofficial and unsupported. Use at your own risk.
