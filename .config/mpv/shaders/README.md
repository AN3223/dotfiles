The nlmeans shaders are denoisers and/or adaptive sharpeners. They have documentation embedded in them, with each nlmeans profile having a profile description near the top. 

The guided shaders are also denoisers. They are faster but lower quality than NLM. The self-guided (_s) variants are slightly faster but even lower quality.

Nvidia users have reported issues regarding NLM. If you are an Nvidia user experiencing problems, try setting `gpu-api=opengl` in mpv. If you still experience problems, try setting RI and RFI to zero. If it's too blurry, try turning down the denoising factor (`S`).

I unwisely placed these shaders in my dotfiles repository, not anticipating ever having more than just one shader here. They are here to stay though, since I do not want to break links/clones. I recommend cloning with `--depth 1` to save space/bandwidth/time.

Despite the fact that this is a dotfiles repository, please feel free to open issues and send pull requests, big or small!

