# Nothing Phone (4a) "frogger": LineageOS 23.2 build plan

Written 2026-11-20 after reviewing `/mnt/DATA_3TB/android`.

## Status (2026-11-22): flashed and daily-usable; VoLTE call audio confirmed (earpiece/mic and Bluetooth)

Steps 1–5 are done. `out/target/product/frogger/lineage-23.2-20261120-UNOFFICIAL-frogger.zip` (latest: `lineage-23.2-20261124-UNOFFICIAL-frogger.zip`, sha256 `dbf3a3c0…7c6846c7`, 2026-11-24, SELinux enforcing, release keys with Bluetooth SELinux cert fix, Glyph drag-and-drop priority, ADSP wakeup label; backup `backups/20261124-glyph-drag-wakeup/`; previous: `backups/20261124-release-keys-btfix/`) built with `./build_frogger.sh` (userdebug, release keys in `vendor/lineage-priv/keys` — private, never commit; kernel 6.1.177). Backups in `backups/`: pre-enforcing (test keys), enforcing-facepreview (test keys), release-keys. Last permissive build backed up in `backups/20261123-pre-enforcing/` (sha256 `39ce942f…4035deb7`).

All 757 modules listed in `modules.load.*` are present in their images. The OTA also flashes **C5.0 firmware** (abl, xbl, tz, modem, etc.), the same version that's on the phone now.

These are local commits on branch `frogger-23.2` in each FroggerSpace repo. Nothing is pushed.

| Repo | Commit | Change |
|---|---|---|
| vendor/nothing/frogger | f179778, be426ec | Drop Android 17 system_ext WFD (Miracast) stack: it needs `libaudiobase` and display.config V16 (superseded by 0d5d8d1) |
| vendor + device | 0d5d8d1 / da2d159 | Restore system_ext WFD from stock **B4.1-260911-0959** (Android 16) blobs; `libwfdnative` → Lineage `libinput_shim`; drop A17-only fixups and `WfdCommon.patch`; WFD props |
| device/nothing/frogger | 47811ea | NFC detect: match `ST21*` (chip reports `ST21NFCL`), drop empty-`pbid` check; fixes hung ST HAL / com.android.nfc ANR loop |
| vendor + device | 0462780 / 114eeb2 | System-side DPM/Hotword/IMS/QCC/QCRIL blobs from B4.1: the C5.0 apps (ims, QtiTelephony, …) need minSdk 37 and were skipped, so no ImsService and no VoLTE calls. QCC uses B4.1 protobuf as `libprotobuf-cpp-full-b41` |
| frameworks/base + device | d93e638d8202 / b273a79 | Default `min_refresh_rate` 60 Hz (panel treats 30 Hz as AOD and re-applies brightness on exit = flash); rt6010 F0/DAQ nodes → `vendor_sysfs_haptics`; `system_app` reads zram stats. Open: power HAL `CPU_BOOST_HINT` 0x104E has no perfboostsconfig entry (values undocumented) |
| kernel + device | 49f799755841 / 5d7f91e | Glyph: build `led_aw20036.ko` (`CONFIG_LEDS_AW20036_FROGGER=m`), load from vendor_dlkm, label `dev_color`/`video_mode`. 7 LEDs: 6 white zones (index 0 = top) + red bottom LED (7-value `frame_brightness` write). Driver tested live; Glyph app not written yet (stock Nothing apps need Nothing's framework) |
| device | db67dfe | Glyph app `FroggerGlyph` (`device/nothing/frogger/glyph`, org.lineageos.glyph, system_app): progress bars from any notification, notification flash, volume/charging meters, call sweep; top-level Settings entry + QS tile. Defaults: levels bottom→top, progress top→bottom, priority calls > notifications > progress > levels. Not yet tested on device |
| device | 4a5761c | SELinux enforcing: removed `androidboot.selinux=permissive`; policy for vibrator nodes, qseecomd UFS bsg, qspmhal clients, camera/audio/qccvendor, jack extcon; face enroll camera preview disabled via overlay. Not yet flashed |
| Settings | 8a699015989 | `config_face_enroll_hal_preview` (branch `frogger-23.2`): Settings passes its TextureView to FaceManager#enroll so the face HAL draws the preview instead of Settings opening (and evicting) the front camera. Tested OK |
| device | 9f557be | Overlay enables `config_face_enroll_hal_preview` |
| (local) | — | Release keys: 4096-bit, subject `/C=AU/O=Private/CN=frogger`, `vendor/lineage-priv/keys/keys.mk`; build tags `release-keys`. First flash over test-keys needs "install anyway" in recovery |
| vendor + device | 3acc013 / ca60ee4 | Ship B4.1 `QtiTelephonyService`: it registers the IQcRilAudio callback that passes call_state/vsid to the audio HAL. Without it calls connected with no audio. **Confirmed fixed 2026-11-22** |
| vendor + device | 43ed682 / 25d0f7a | `lib-imsvt` → `libdmabufheap_shim` (`BufferAllocator::~BufferAllocator`) |
| vendor + device | f630b0f / 65356e4 | Ship stock `libprotobuf-cpp-full-6.33.5` for qccsyshal |
| vendor + device | 0bcd2fc / b524ac7 | protobuf 6.33.5 → `libcxx_shim` (`std::__1::__hash_memory`) |
| hardware/nothing | dbcd2e8, f2d6209 | New `shims/libdmabufheap`, `shims/libcxx` |
| device/nothing/frogger | e6133a3 | Revert zram sepolicy move (`per_boot_file` exists in platform policy only from A17) |
| device/nothing/frogger | 98f02b4 | Revert `BuildSystemFingerprint` override (not supported on 23.2) |
| device/nothing/frogger | a5d2b8a | Add `vendor/frogger.config` kernel fragment |
| device/nothing/frogger | af2fd4d | Framework matrix: `vendor.qti.data.txpwrservice` V8 |
| kernel/nothing/sm7635 | 1618fe05a515 | Kconfig `NOTHING_IS_{ASTEROIDS,FROGGER}` + `vendor/frogger.config` (frogger audio dailinks) |
| kernel/nothing/sm7635-modules | 11826603b3 | aw882xx: use `audio_info` only with `OEM_BOOTINFO` |
| kernel/nothing/sm7635-modules | 8df8b7e28e | video-driver: include `linux/minmax.h` before local MIN/MAX |
| kernel/nothing/sm7635-modules | 5253f6dcaf | qcacld-3.0: remove stray `endif` |
| kernel/nothing/sm7635-modules | 04c040069e | touch-drivers: fix focaltech `endif` |

The kernel and module fixes (1618fe05a515, 11826603b3, 5253f6dcaf, 04c040069e) aren't specific to 23.2, so they could go to FroggerSpace upstream.

Host notes:
- Build in a clean environment. The interactive shell's `grep`→`ugrep` wrapper breaks `lunch`.
- `libxcrypt-compat` must be installed, because Lineage's bundled perl needs `libcrypt.so.1`.
- ccache lives at `/mnt/DATA_3TB/ccache`.

Flashing note (FRP): coming from stock with a screen lock/Google account leaves an FRP record in the `frp` partition. After a recovery format, Android 16 keeps FRP active, which blocks setting a screen lock and installing APKs (no GApps setup wizard to clear it). ABL refuses `fastboot erase frp` (critical partition), so on userdebug: `adb root`, back up and zero `/dev/block/bootdevice/by-name/frp`, reboot. Backup of this phone's frp: `reference/frogger_frp_backup_20261121.img`.

Known gaps:
- Miracast is built from B4.1 blobs but untested on device.
- Glyph LED and Nothing's OEM info modules aren't built.
- SELinux is permissive.
- The build uses test keys.

## 1. Where things stand

| Area | State | Verdict |
|---|---|---|
| Lineage source (`lineage-23.2/`) | Full sync, 1164 projects, `hardware/qcom-caf/sm8650`, `device/qcom/sepolicy_vndr`, `hardware/qcom-caf/common` all present | Good |
| Device tree (`device/nothing/frogger`) | Hand-written stub: 4 makefiles, no partitions, AVB, fstab, init, sepolicy, VINTF, audio, modules lists, or vendor blobs. Not a git repo | Can't boot. Replace it |
| Vendor blobs (`vendor/nothing/frogger`) | **Missing** | Blocker |
| Kernel (`kernel/nothing/frogger`) | NothingOSS monolithic `sm7635/b/mr_Frogger` (6.1.157), with every `vendor/qcom/opensource/*` techpack inside the kernel tree | Wrong layout for Lineage |
| Kernel config | `gki_defconfig` + `pineapple_GKI` + **`consolidate.config`** (lockdep, kmemleak, DEBUG_OBJECTS, slub_debug, `LOCALVERSION=-qki-consolidate`) | Debug kernel: slow and panics easily. Remove it |
| Last build (`out/error.log`, 2026-11-20 11:36) | Kati fails: `kernel/nothing/frogger/vendor/qcom/opensource/audio-kernel/Android.mk:111: device/qcom/common/dlkm/Build_external_kernelmodule.mk: No such file` | Symptom of the kernel layout problem |
| `reference/` | Stock C5.0 and B4.1 images (extracted), ADB dump, Kleaf/Bazel experiments, ABI/CRC audits | Useful for blob extraction and checks. The Kleaf work isn't needed on the Lineage build path |

### Why the current build fails

Kati reads **every** `Android.mk` under the source root. NothingOSS keeps the QCOM techpacks (audio-kernel, display, camera, wlan…) inside the kernel tree. Their `Android.mk` files expect QCOM's proprietary `device/qcom/common/dlkm/*` build system, which Lineage doesn't have. `PRODUCT_SOURCE_ROOT_DIRS` in `device.mk` only hides `Android.bp` files from Soong. Kati still sees the `.mk` files, so you get one failure after another as each is excluded.

Lineage's own approach: keep the GKI kernel source in one repo and the techpacks in a separate `*-modules` repo. Then build the techpacks through `TARGET_KERNEL_EXT_MODULE_ROOT` / `TARGET_KERNEL_EXT_MODULES` in `vendor/lineage/build/tasks/kernel.mk`. Your local 23.2 checkout supports this (kernel.mk lines 118, 301, 542, 717).

## 2. An existing community port covers most of this

**FroggerSpace** (github.com/FroggerSpace) has an active Lineage port for frogger, last pushed 2026-11-19. It's adapted from a working Phone (3a) "asteroids" tree on the same SM7635 SoC:

| Repo | Branch | Path |
|---|---|---|
| android_device_nothing_frogger | `6.1/lineage-24.0` | device/nothing/frogger |
| android_kernel_nothing_sm7635 | `6.1/lineage-24.0` | kernel/nothing/sm7635 |
| android_kernel_nothing_sm7635-modules | `6.1/lineage-24.0` | kernel/nothing/sm7635-modules |
| android_kernel_nothing_sm7635-devicetrees | `6.1/lineage-24.0` | kernel/nothing/sm7635-devicetrees |
| proprietary_vendor_nothing_frogger | `lineage-24.0` | vendor/nothing/frogger |
| android_hardware_nothing | `lineage-24.0` | hardware/nothing |

Their device tree already has the things the stub lacks: real partition sizes (super = 9663676416), AVB/vbmeta layout, boot header v4, prebuilt dtb/dtbo from C5.0, modules.load lists for vendor_boot/vendor_dlkm/system_dlkm/recovery, the full `TARGET_KERNEL_EXT_MODULES` list, VINTF manifests, sepolicy, audio (sm8650 PAL/AGM), and extract-files.py with proprietary-files.txt.

I checked it against your local 23.2 source. Every path it references exists, apart from the repos listed above that the manifest itself brings in (and the optional `hardware/dolby`).

**Catch:** they only publish **lineage-24.0** (Android 17) branches. 23.2 needs a small backport (see step 5).

**About Android 17 blobs on Android 16:** the stock phone runs C5.0 on Android 17, but `ro.board.api_level=34`. The vendor partition is frozen at Android 14 level, so C5.0 vendor blobs should run under a 23.2 system. If a vendor HAL turns out to need something only Android 17 provides, extract blobs from the **B4.1 (Android 16)** images in `reference/frogger_stock_images_B4.1-260911-0959` instead.

## 3. Step-by-step

### Step 1: Move the conflicting trees out of the source root

```bash
cd /mnt/DATA_3TB/android
mkdir -p reference/old_lineage_attempt
mv lineage-23.2/device/nothing/frogger         reference/old_lineage_attempt/device_frogger_stub
mv lineage-23.2/kernel/nothing/frogger         reference/old_lineage_attempt/kernel_nothingoss_monolithic
rm lineage-23.2/kernel/nothing/msm-kernel      # symlink left over from the Kleaf experiment
mv lineage-23.2/kernel/nothing/external        reference/old_lineage_attempt/kernel_external
mv lineage-23.2/.repo/local_manifests/frogger.xml reference/old_lineage_attempt/
```

### Step 2: Add the FroggerSpace manifest

`lineage-23.2/.repo/local_manifests/frogger.xml`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<manifest>
    <remote name="froggerspace" fetch="https://github.com/FroggerSpace/" />
    <project path="device/nothing/frogger"             name="android_device_nothing_frogger"            remote="froggerspace" revision="6.1/lineage-24.0" />
    <project path="kernel/nothing/sm7635"              name="android_kernel_nothing_sm7635"             remote="froggerspace" revision="6.1/lineage-24.0" />
    <project path="kernel/nothing/sm7635-modules"      name="android_kernel_nothing_sm7635-modules"     remote="froggerspace" revision="6.1/lineage-24.0" />
    <project path="kernel/nothing/sm7635-devicetrees"  name="android_kernel_nothing_sm7635-devicetrees" remote="froggerspace" revision="6.1/lineage-24.0" />
    <project path="vendor/nothing/frogger"             name="proprietary_vendor_nothing_frogger"        remote="froggerspace" revision="lineage-24.0" />
    <project path="hardware/nothing"                   name="android_hardware_nothing"                  remote="froggerspace" revision="lineage-24.0" />
</manifest>
```

```bash
cd /mnt/DATA_3TB/android/lineage-23.2
repo sync -c -j8 device/nothing/frogger kernel/nothing/sm7635 kernel/nothing/sm7635-modules \
  kernel/nothing/sm7635-devicetrees vendor/nothing/frogger hardware/nothing
```

Then create a working branch in each of these repos (`repo start frogger-23.2 <paths>`) so the 23.2 changes are tracked and can be rebased onto upstream.

### Step 3: Vendor blobs (decide once)

- **Option A (fastest):** use `proprietary_vendor_nothing_frogger` as-is (C5.0 blobs).
- **Option B (best match for Android 16):** regenerate from B4.1:
  ```bash
  cd device/nothing/frogger
  ./extract-files.py /mnt/DATA_3TB/android/reference/frogger_stock_images_B4.1-260911-0959/images
  ```
  With B4.1 you must also flash B4.1 firmware, or check that the C5.0 modem/ADSP firmware still talks to B4.1 HALs. Start with A and fall back to B only if specific HALs fail.

### Step 4: Clean the build and confirm the kernel config

```bash
cd /mnt/DATA_3TB/android/lineage-23.2
rm -rf out          # the old out/ has the stub product's ninja and kernel state
```

FroggerSpace uses `TARGET_KERNEL_CONFIG := gki_defconfig vendor/pineapple_GKI.config` with no consolidate/debug fragment. That's what you want for stability, so don't port `consolidate.config` over. Check whether their tree also applies `vendor/Frogger.config` (CONFIG_NOTHING_IS_FROGGER, the AW20036 glyph LED, OEM hwinfo…). If not, append it to `TARGET_KERNEL_CONFIG`, because the frogger dtbo and the glyph sepolicy expect those drivers.

### Step 5: Backport the device tree from lineage-24.0 to 23.2

```bash
source build/envsetup.sh
breakfast frogger userdebug      # picks the right TARGET_RELEASE for 23.2
m installclean && m bacon -j16 2>&1 | tee ../frogger-build-$(date +%F).log
```

Expect a handful of errors. Fix each one in `device/nothing/frogger`, `hardware/nothing` or `vendor/nothing/frogger`. Likely areas:

- Soong/makefile variables added in 24.0 (remove or rename them).
- `framework_manifest.xml` / `framework_matrix_nothing.xml` entries for Android 17-only HAL versions (lower them to the 23.2 versions).
- RRO/overlay or `nothing-fwk` resources that reference Android 17 framework symbols.
- sepolicy types that exist only in 24.0 `system/sepolicy` (drop those rules).
- `PRODUCT_SHIPPING_API_LEVEL` / `BOARD_API_LEVEL_PROP_OVERRIDE`: keep 35 / 34.

Also have a look at the `asteroids` history in the device tree (the commits before "frogger: Initial Adaptation"). Their 22.2/23.x-era state is a useful reference for what the 23.2 versions of these files looked like.

### Step 6: Hardware and RAM limits

- 16 threads and 31 GB RAM: the kernel and techpack build plus Soong will hit OOM at `-j16`. Add 32 GB or more of swap/zram, or build with `-j12`.
- Disk: 2.0 TB free, which is plenty. Enable ccache (`export USE_CCACHE=1 CCACHE_EXEC=/usr/bin/ccache; ccache -M 100G`).

### Step 7: First flash (keep it reversible)

Output is in `out/target/product/frogger/`.

1. Keep the stock C5.0 images (`reference/frogger_stock_images/`) ready to restore.
2. First boot test, without touching super:
   `fastboot flash boot boot.img` / `init_boot` / `vendor_boot` / `dtbo`, then check `fastboot getvar current-slot`. Even better, use the recovery image first: `fastboot flash recovery recovery.img`, then sideload `lineage-23.2-*-frogger.zip`.
3. Keep the tree's `androidboot.selinux=permissive` for the first boots. Collect `adb logcat -b all` and `dmesg` (pstore: `/sys/fs/pstore`) if it bootloops.
4. The phone is already unlocked (`ro.boot.flash.locked=0`, orange state), so nothing else is needed.

### Step 8: Work through stability before calling it stable

Test in this order, because each layer depends on the one before:

1. Boots to UI. `lsmod` matches `modules.load.*`, and there are no `Unknown symbol` errors in dmesg (all modules come from the same kernel build, so there should be no KMI/CRC drift).
2. Display, touch, and panel refresh/AOD (`nt37706a` DSC panel).
3. Wi-Fi (qca6750), Bluetooth, RIL/data/VoLTE (`qcril-database`, IMS).
4. Audio (speaker amp, mic, call audio). This is the area most sensitive to blob or Android-version mismatches.
5. Camera (HAL plus `nt_cam_dev`); fingerprint (goodix, under-display); NFC (ROW SKU only).
6. Suspend/resume battery drain and thermals (the walt/perf HAL).
7. **SELinux enforcing:** drop `androidboot.selinux=permissive` from `BOARD_KERNEL_CMDLINE` and `BOARD_BOOTCONFIG`, fix the denials (`adb shell dmesg | grep avc`), and write sepolicy. A permissive build isn't a stable or secure build.
8. Sign the build with your own keys for releases (`m sign_target_files_apks` or the Lineage signing docs), not the test keys.

## 4. What to keep and what to retire

- **Keep:** the stock image sets, `frogger_adb_extract_*` (for checking props, VINTF and modules on the device), and the module CRC/ABI audit scripts (useful if you later rebase the kernel onto a newer GKI, for example to match stock 6.1.172).
- **Retire from the Lineage path:** the NothingOSS monolithic kernel tree, `consolidate.config`, the Kleaf overlay and Bazel outputs, and the stub device tree. Lineage builds the kernel and techpacks itself through kernel.mk.
- **Upstream sync:** watch FroggerSpace for fixes. The SM7635 kernel and modules repos are shared with the asteroids port, so fixes there usually apply to frogger too.
