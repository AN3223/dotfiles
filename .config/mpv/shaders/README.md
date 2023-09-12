# Installation

Assuming you are on Linux/BSD/MacOS/etc and your `mpv.conf` is located at `~/.config/mpv/`:

```
cd ~/.config/mpv/
mkdir shaders
git clone --depth 1 https://github.com/an3223/dotfiles an3223_dotfiles
cd shaders
ln -s ../an3223_dotfiles/.config/mpv/shaders/* ./
```

Refer to mpv's man page for more details.

# Usage

There are multiple ways to use shaders in mpv. Here are three:

## input.conf

As an example, this will bind toggling the default Non-local means shader to the F4 key:

```
F4 no-osd change-list glsl-shaders toggle "~~/shaders/nlmeans.glsl"; show-text "Non-local means"
```

Being able to easily clear the list of shaders can be useful too:

```
F12 no-osd change-list glsl-shaders clr ""; show-text "GLSL shaders cleared"
```

Refer to mpv's man page for more details.

## pickshader.lua

Assuming you just followed the installation guide above, you can install this script like so:

```
cd ~/.config/mpv/
mkdir scripts
cd scripts
ln -s ../an3223_dotfiles/.config/mpv/scripts/pickshader.lua ./
```

It provides an interface similar to `^R` in Unix shells, if you're familiar with that. Pretty much just type `Ctrl+r` and then type a query for the shader you want, and then hit Enter.

More detailed documentation can be found in the header of the script itself.

## mpv.conf

To load a shader (for example, `nlmeans.glsl`) every time mpv starts up:

```
glsl-shaders='~~/shaders/nlmeans.glsl'
```

Conditional auto profiles are useful for enabling shaders (or any feature) automatically when a condition is met. For example:

```
[LQ]
profile-desc="Resolution less than 1/2 of 1280x720"
profile-cond=(width*height)<(1280*720/2)
profile-restore=copy-equal
glsl-shaders='~~/shaders/hdeband.glsl:~~/shaders/nlmeans_sharpen_denoise.glsl'
```

Refer to mpv's man page for more details.

# About

## nlmeans

These shaders are denoisers and/or adaptive sharpeners. They have documentation embedded in them, with each nlmeans profile having a profile description near the top. 

Some examples of shader output are pictured below. They follow the form of `clean/corrupt/reconstructed`, where `reconstructed` is the shader output when `corrupt` is given as input, so the goal is for `reconstructed` to resemble `clean` as much as possible.

nlmeans.glsl (clean/noisy/denoised):

![Clean image](dev/result_images/clean.png)
![Noisy image](dev/result_images/opt_noise.png)
![Denoised image](dev/result_images/nlmeans_opt_noise.png)

nlmeans\_sharpen\_denoise.glsl (clean/blurry+noisy/sharpened+denoised):

![Clean image](dev/result_images/clean.png)
![Blurry/noisy image](dev/result_images/opt_blur_opt_noise.png)
![Sharpened and denoised image](dev/result_images/nlmeans_sharpen_denoise_opt_blur_opt_noise.png)

nlmeans\_sharpen\_only.glsl (clean/blurry/sharpened):

![Clean image](dev/result_images/clean.png)
![Blurry image](dev/result_images/opt_blur.png)
![Sharpened image](dev/result_images/nlmeans_sharpen_only_opt_blur.png)

FSR for reference (clean/blurry/sharpened):

![Clean image](dev/result_images/clean.png)
![Blurry image](dev/result_images/opt_blur.png)
![Sharpened image](dev/result_images/fsr_opt_blur.png)

nlmeans\_sharpen\_only.glsl (noisy/blurry+noisy/sharpened):

![Noisy image](dev/result_images/opt_noise.png)
![Blurry/noisy image](dev/result_images/opt_blur_opt_noise.png)
![Sharpened image](dev/result_images/nlmeans_sharpen_only_opt_blur_opt_noise.png)

FSR for reference (noisy/blurry+noisy/sharpened):

![Noisy image](dev/result_images/opt_noise.png)
![Blurry/noisy image](dev/result_images/opt_blur_opt_noise.png)
![Sharpened image](dev/result_images/fsr_opt_blur_opt_noise.png)

## hdeband

This is a debanding algorithm that blurs homogeneous regions together.

It should be ran prior to any other shaders and mpv's built-in debanding should be disabled by setting `deband=no` in `mpv.conf`.

## guided

Also denoisers, lower quality than LQ NLM and not necessarily faster. The self-guided (\_s) variants are slightly faster but even lower quality.

# Troubleshooting

## Not seeing much effect

Denoisers/sharpeners have less effect as the resolution increases, since they only target the high frequency noise/detail. If the content has been upscaled beforehand (whether it was done by you or not), consider issuing a command to downscale in the mpv console (backtick ` key):

```
vf toggle scale=-2:720
```

...replacing 720 with whatever resolution seems appropriate. Rerun the command to undo its effect. It may take some trial-and-error to find the proper resolution.

## Too slow

Many shaders have LQ variants located in the LQ subdirectory here.

Consider trying alternative `--vo` and `--gpu-api` settings to get better performance, e.g., `--vo=gpu-next --gpu-api=vulkan`

## Totally broken

If you are an Nvidia user experiencing problems with nlmeans try using a `gpu-api=vulkan`, or `gpu-api=opengl` with `gpu-context=win`. Macbook Pro 2019 has been reported to be non-functional with NLM as well, any info on workarounds/fixes would be greatly appreciated.

Otherwise, please open an issue!

# Advanced usage

There is a Makefile in the dev directory which builds all of the shaders (only requires a POSIX system & awk).

There is also a testing script called `shader_test` in the dev directory, it requires `raku` and `ffmpeg` built with `--enable-libplacebo`.

