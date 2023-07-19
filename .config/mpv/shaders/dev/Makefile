#!/usr/bin/make -f

all: pyramid guided nlmeans hdeband

pyramid: pyramid.glsl

pyramid.glsl: pyramid_template
	./shader_cfg $? > $@

guided: ../guided.glsl ../guided_s.glsl ../guided_s_fast.glsl ../guided_fast.glsl experimental/guided_lgc.glsl 

GUIDED_SELF_DESC=Self-guided.

GUIDED_LGC_DESC=Luma-guided-chroma denoising.
GUIDED_LGC=CFG_HOOKS=CHROMA:I=SHARE_LUMA:MEANI=2.0/:E=100.0

GUIDED_FAST_DESC=Fast.
GUIDED_FAST=I=2/:MEANI=1.5/
GUIDED_FAST_S=IP=2/:MEANIP=1.5/:E=0.001

../guided.glsl: guided_template
	./shader_cfg $? > $@
../guided_s.glsl: guided_s_template
	./shader_cfg $? > $@
../guided_s_fast.glsl: guided_s_template
	./shader_cfg DESC="$@: $(GUIDED_SELF_DESC) $(GUIDED_FAST_DESC)" OPTS="$(GUIDED_FAST_S)" $? > $@
../guided_fast.glsl: guided_template
	./shader_cfg DESC="$@: $(GUIDED_FAST_DESC)" OPTS="$(GUIDED_FAST)" $? > $@
experimental/guided_lgc.glsl: guided_template
	./shader_cfg DESC="$@: $(GUIDED_LGC_DESC)" OPTS="$(GUIDED_LGC)" $? > $@

nlmeans: ../nlmeans.glsl ../nlmeans_temporal.glsl ../nlmeans_sharpen_denoise.glsl ../nlmeans_sharpen_only.glsl ../nlmeans_temporal_sharpen_denoise.glsl ../LQ/nlmeans.glsl ../LQ/nlmeans_temporal.glsl ../LQ/nlmeans_sharpen_denoise.glsl ../LQ/nlmeans_sharpen_only.glsl ../LQ/nlmeans_temporal_sharpen_denoise.glsl ../HQ/nlmeans.glsl ../HQ/nlmeans_temporal.glsl ../HQ/nlmeans_sharpen_denoise.glsl ../HQ/nlmeans_sharpen_only.glsl ../HQ/nlmeans_temporal_sharpen_denoise.glsl ../HQX/nlmeans.glsl experimental/nlmeans_2x.glsl experimental/nlmeans_lgc.glsl

NLM_NO_ROTATE=RI=0:RFI=0

NLM_SHARPEN_ONLY_DESC=Sharpen without denoising.
NLM_SHARPEN_ONLY=AS=2

NLM_SHARPEN_DENOISE_DESC=Sharpen and denoise.
NLM_SHARPEN_DENOISE=AS=1

NLM_TEMPORAL_DESC=Very experimental and buggy, limited to vo=gpu-next.
NLM_TEMPORAL=T_FRAME_LIMIT=2:T_RES=3840x3840
NLM_TEMPORAL_LUMA=T=2:WD=1:C=0:$(NLM_NO_ROTATE)

# If RF=shader then that shader needs to be added to the prerequisites (i.e., alongside nlmeans_template)

../nlmeans.glsl: nlmeans_template ../LQ/nlmeans.glsl
	./shader_cfg nlmeans_template > $@
../nlmeans_temporal.glsl: nlmeans_template ../LQ/nlmeans.glsl
	./shader_cfg DESC="$@: $(NLM_TEMPORAL_DESC)" OPTS="$(NLM_TEMPORAL)" OPTS_LUMA="$(NLM_TEMPORAL_LUMA)" nlmeans_template > $@
../nlmeans_sharpen_denoise.glsl: nlmeans_template ../LQ/nlmeans.glsl
	./shader_cfg DESC="$@: $(NLM_SHARPEN_DENOISE_DESC)" OPTS="$(NLM_SHARPEN_DENOISE)" nlmeans_template > $@
../nlmeans_sharpen_only.glsl: nlmeans_template ../LQ/nlmeans.glsl
	./shader_cfg DESC="$@: $(NLM_SHARPEN_ONLY_DESC)" OPTS="$(NLM_SHARPEN_ONLY)" nlmeans_template > $@
../nlmeans_temporal_sharpen_denoise.glsl: nlmeans_template ../LQ/nlmeans.glsl
	./shader_cfg DESC="$@: $(NLM_TEMPORAL_DESC) $(NLM_SHARPEN_DENOISE_DESC)" OPTS="$(NLM_TEMPORAL):$(NLM_SHARPEN_DENOISE)" OPTS_LUMA="$(NLM_TEMPORAL_LUMA)" nlmeans_template > $@

NLM_LQ_DESC=Faster, but lower quality.
NLM_LQ_LUMA=S=3.5857557501951383:SS=0.5315282501448438:SW=0.7207404483924839:WDT=0.5124528114167508:WDP=5.404420119241573:RO=0.00010475046827390637:PS=4
NLM_LQ=S=5.100920322105462:SS=0.31580805565941705:SW=0.6429313578248627:WDT=0.9385150042004405:WD=1:C=0:RF=0:RF_LUMA=0:$(NLM_NO_ROTATE)

../LQ/nlmeans.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_LQ_DESC)" OPTS="$(NLM_LQ)" OPTS_LUMA="$(NLM_LQ_LUMA)" nlmeans_template > $@
../LQ/nlmeans_temporal.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_LQ_DESC) $(NLM_TEMPORAL_DESC)" OPTS="$(NLM_TEMPORAL):$(NLM_LQ)" OPTS_LUMA="$(NLM_TEMPORAL_LUMA):$(NLM_LQ_LUMA)" nlmeans_template > $@
../LQ/nlmeans_sharpen_denoise.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_LQ_DESC) $(NLM_SHARPEN_DENOISE_DESC)" OPTS="$(NLM_SHARPEN_DENOISE):$(NLM_LQ)" OPTS_LUMA="$(NLM_LQ_LUMA)" nlmeans_template > $@
../LQ/nlmeans_sharpen_only.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_LQ_DESC) $(NLM_SHARPEN_ONLY_DESC)" OPTS="$(NLM_SHARPEN_ONLY):$(NLM_LQ)" OPTS_LUMA="$(NLM_LQ_LUMA)" nlmeans_template > $@
../LQ/nlmeans_temporal_sharpen_denoise.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_LQ_DESC) $(NLM_TEMPORAL_DESC) $(NLM_SHARPEN_DENOISE_DESC)" OPTS="$(NLM_TEMPORAL):$(NLM_SHARPEN_DENOISE):$(NLM_LQ)" OPTS_LUMA="$(NLM_TEMPORAL_LUMA):$(NLM_LQ_LUMA)" nlmeans_template > $@

NLM_HQ_DESC=Slow, but higher quality.
NLM_HQ_LUMA=ASF=0.5483900509943984:ASA=1.1990767842629195:ASP=1.0006451175014668:ASS=0.3537519927847657:S=1.4460272592109746:SW=1.812902116179249:WDT=0.07232509380556876:CS=0.1060139658565394:SS=0.2952259847265974:PS=3:R=9
NLM_HQ=ASF=0.4804227336582368:ASA=2.0325416266014185:ASP=1.2022557068138862:ASS=0.0682805004673164:S=1.359261923810611:SW=1.4903543760666318:SS=0.17336705987012963:R=9

../HQ/nlmeans.glsl: nlmeans_template ../nlmeans.glsl
	./shader_cfg DESC="$@: $(NLM_HQ_DESC)" OPTS="$(NLM_HQ)" OPTS_LUMA="$(NLM_HQ_LUMA)" nlmeans_template > $@
../HQ/nlmeans_temporal.glsl: nlmeans_template ../nlmeans.glsl
	./shader_cfg DESC="$@: $(NLM_HQ_DESC) $(NLM_TEMPORAL_DESC)" OPTS="$(NLM_TEMPORAL):$(NLM_HQ)" OPTS_LUMA="$(NLM_TEMPORAL_LUMA):$(NLM_HQ_LUMA)" nlmeans_template > $@
../HQ/nlmeans_sharpen_denoise.glsl: nlmeans_template ../nlmeans.glsl
	./shader_cfg DESC="$@: $(NLM_HQ_DESC) $(NLM_SHARPEN_DENOISE_DESC)" OPTS="$(NLM_SHARPEN_DENOISE):$(NLM_HQ)" OPTS_LUMA="$(NLM_HQ_LUMA)" nlmeans_template > $@
../HQ/nlmeans_sharpen_only.glsl: nlmeans_template ../nlmeans.glsl
	./shader_cfg DESC="$@: $(NLM_HQ_DESC) $(NLM_SHARPEN_ONLY_DESC)" OPTS="$(NLM_SHARPEN_ONLY):$(NLM_HQ)" OPTS_LUMA="$(NLM_HQ_LUMA)" nlmeans_template > $@
../HQ/nlmeans_temporal_sharpen_denoise.glsl: nlmeans_template ../nlmeans.glsl
	./shader_cfg DESC="$@: $(NLM_HQ_DESC) $(NLM_TEMPORAL_DESC) $(NLM_SHARPEN_DENOISE_DESC)" OPTS="$(NLM_TEMPORAL):$(NLM_SHARPEN_DENOISE):$(NLM_HQ)" OPTS_LUMA="$(NLM_TEMPORAL_LUMA):$(NLM_HQ_LUMA)" nlmeans_template > $@

NLM_HQX_DESC=Very slow, should offer the best quality.
NLM_HQX_LUMA=P=5:$(NLM_HQ_LUMA)
NLM_HQX=P=5:$(NLM_HQ)

# XXX expand
../HQX/nlmeans.glsl: nlmeans_template ../nlmeans.glsl
	./shader_cfg DESC="$@: $(NLM_HQX_DESC)" OPTS="$(NLM_HQX)" OPTS_LUMA="$(NLM_HQX_LUMA)" nlmeans_template > $@

NLM_2X_DESC=Experimental upscaler
NLM_2X=S=17.017602237233955:SW=0.8827444208717642:SS=1.3509665474695507:ASF=0.2778039037257505:ASA=3.0225604816404315:ASP=1.1368782379823874:ASS=0.5302822199949342:CFG_HOOKS=LUMA:CFG_SIZE=2*:RF_LUMA=2*:RF=0:SF=3:PS=0:RI=7:R=7:RS=8:SK=sphinx_:AS=1:ASK=sinc3:WD=0:C=0

experimental/nlmeans_2x.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_2X_DESC)" OPTS="$(NLM_2X)" nlmeans_template > $@

NLM_LGC_DESC=Experimental luma-guided chroma denoising, kinda similar to KrigBilateral
NLM_LGC=CFG_HOOKS=CHROMA:RF=SHARE_LUMA:RF_LUMA=0:D1W=1:S=11.66:WD=0:SW=0.75:RI=3:RFI=2

experimental/nlmeans_lgc.glsl: nlmeans_template ../LQ/nlmeans.glsl
	./shader_cfg DESC="$@: $(NLM_LGC_DESC)" OPTS="$(NLM_LGC)" nlmeans_template > $@

hdeband: ../LQ/hdeband.glsl

../LQ/hdeband.glsl: ../hdeband.glsl
	./shader_cfg OPTS="RADIUS=4:SPARSITY=0.5:DIRECTIONS=3" $? > $@

readme: result_images/clean.png result_images/noise10.png result_images/gblur0625.png result_images/gblur0625noise10.png result_images/nlmeans_noise10.png result_images/nlmeans_sharpen_denoise_gblur0625noise10.png result_images/nlmeans_sharpen_only_gblur0625noise10.png result_images/nlmeans_sharpen_only_gblur0625.png result_images/fsr_gblur0625noise10.png result_images/fsr_gblur0625.png 

../FSR.glsl:
	curl -L 'https://gist.githubusercontent.com/agyild/82219c545228d70c5604f865ce0b0ce5/raw/2623d743b9c23f500ba086f05b385dcb1557e15d/FSR.glsl' > $@
	sed -i '/^\/\/!WHEN/d' $@ # https://github.com/mpv-player/mpv/issues/10246#issuecomment-1303894445
result_images/clean.png: ../nlmeans.glsl
	ffmpeg -y -i images/anime/mountain_adventurer.webp -vf 'crop=128:128:y=128,format=yuv420p,scale=256:256:flags=neighbor' $@
result_images/noise10.png: ../nlmeans.glsl
	ffmpeg -y -i images/anime/mountain_adventurer.webp -vf 'crop=128:128:y=128,format=yuv420p,noise=alls=10,scale=256:256:flags=neighbor' $@
result_images/gblur0625.png: ../nlmeans.glsl
	ffmpeg -y -i images/anime/mountain_adventurer.webp -vf 'crop=128:128:y=128,format=yuv420p,gblur=0.625,scale=256:256:flags=neighbor' $@
result_images/gblur0625noise10.png: ../nlmeans.glsl
	ffmpeg -y -i images/anime/mountain_adventurer.webp -vf 'crop=128:128:y=128,format=yuv420p,gblur=0.625,noise=alls=10,scale=256:256:flags=neighbor' $@
result_images/nlmeans_noise10.png: ../nlmeans.glsl
	ffmpeg -y -init_hw_device vulkan -i images/anime/mountain_adventurer.webp -vf 'crop=128:128:y=128,format=yuv420p,noise=alls=10,hwupload,libplacebo=128:128:custom_shader_path=$?,hwdownload,format=yuv420p,scale=256:256:flags=neighbor' $@
result_images/nlmeans_sharpen_denoise_gblur0625noise10.png: ../nlmeans_sharpen_denoise.glsl
	ffmpeg -y -init_hw_device vulkan -i images/anime/mountain_adventurer.webp -vf 'crop=128:128:y=128,format=yuv420p,gblur=0.625,noise=alls=10,hwupload,libplacebo=128:128:custom_shader_path=$?,hwdownload,format=yuv420p,scale=256:256:flags=neighbor' $@
result_images/nlmeans_sharpen_only_gblur0625noise10.png: ../nlmeans_sharpen_only.glsl
	ffmpeg -y -init_hw_device vulkan -i images/anime/mountain_adventurer.webp -vf 'crop=128:128:y=128,format=yuv420p,gblur=0.625,noise=alls=10,hwupload,libplacebo=128:128:custom_shader_path=$?,hwdownload,format=yuv420p,scale=256:256:flags=neighbor' $@
result_images/nlmeans_sharpen_only_gblur0625.png: ../nlmeans_sharpen_only.glsl
	ffmpeg -y -init_hw_device vulkan -i images/anime/mountain_adventurer.webp -vf 'crop=128:128:y=128,format=yuv420p,gblur=0.625,hwupload,libplacebo=128:128:custom_shader_path=$?,hwdownload,format=yuv420p,scale=256:256:flags=neighbor' $@
result_images/fsr_gblur0625noise10.png: ../FSR.glsl
	ffmpeg -y -init_hw_device vulkan -i images/anime/mountain_adventurer.webp -vf 'crop=128:128:y=128,format=yuv420p,gblur=0.625,noise=alls=10,hwupload,libplacebo=128:128:custom_shader_path=$?,hwdownload,format=yuv420p,scale=256:256:flags=neighbor' $@
result_images/fsr_gblur0625.png: ../FSR.glsl
	ffmpeg -y -init_hw_device vulkan -i images/anime/mountain_adventurer.webp -vf 'crop=128:128:y=128,format=yuv420p,gblur=0.625,hwupload,libplacebo=128:128:custom_shader_path=$?,hwdownload,format=yuv420p,scale=256:256:flags=neighbor' $@

