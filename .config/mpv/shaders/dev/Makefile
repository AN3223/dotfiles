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

nlmeans: nlmeans_default nlmeans_lq nlmeans_hq nlmeans_experimental

# If G=shader then that shader needs to be added to the prerequisites (i.e., alongside nlmeans_template)

NLM_NO_ROTATE=RI=0:RFI=0

NLM_SHARPEN_ONLY_DESC=Sharpen without denoising.
NLM_SHARPEN_ONLY=AS=2

NLM_SHARPEN_DENOISE_DESC=Sharpen and denoise.
NLM_SHARPEN_DENOISE=AS=1

NLM_TEMPORAL_DESC=Very experimental and buggy, limited to vo=gpu-next.
NLM_TEMPORAL=T_FRAME_LIMIT=2:T_RES=3840x3840
NLM_TEMPORAL_LUMA=T=2

NLM_LIGHT_DESC=Tuned for light noise.

nlmeans_default: ../nlmeans.glsl ../nlmeans_light.glsl ../nlmeans_temporal.glsl ../nlmeans_light_temporal.glsl ../nlmeans_sharpen_denoise.glsl ../nlmeans_light_sharpen_denoise.glsl ../nlmeans_sharpen_only.glsl ../nlmeans_light_sharpen_only.glsl ../nlmeans_temporal_sharpen_denoise.glsl ../nlmeans_light_temporal_sharpen_denoise.glsl 

../nlmeans.glsl: nlmeans_template
	./shader_cfg nlmeans_template OPTS="`./optimums/latest.sh optimums/DEFAULT/nlmeans/chroma.optim`" OPTS_LUMA="`./optimums/latest.sh optimums/DEFAULT/nlmeans/luma.optim`" > $@
../nlmeans_light.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_LIGHT_DESC)" OPTS="`./optimums/latest.sh optimums/DEFAULT/nlmeans/light/chroma.optim`" OPTS_LUMA="`./optimums/latest.sh optimums/DEFAULT/nlmeans/light/luma.optim`" nlmeans_template > $@
../nlmeans_temporal.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_TEMPORAL_DESC)" OPTS="$(NLM_TEMPORAL):`./optimums/latest.sh optimums/DEFAULT/nlmeans/chroma.optim`" OPTS_LUMA="$(NLM_TEMPORAL_LUMA):`./optimums/latest.sh optimums/DEFAULT/nlmeans/luma.optim`" nlmeans_template > $@
../nlmeans_light_temporal.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_TEMPORAL_DESC) $(NLM_LIGHT_DESC)" OPTS="$(NLM_TEMPORAL):`./optimums/latest.sh optimums/DEFAULT/nlmeans/light/chroma.optim`" OPTS_LUMA="$(NLM_TEMPORAL_LUMA):`./optimums/latest.sh optimums/DEFAULT/nlmeans/light/luma.optim`" nlmeans_template > $@
../nlmeans_sharpen_denoise.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_SHARPEN_DENOISE_DESC)" OPTS="`./optimums/latest.sh optimums/DEFAULT/nlmeans/sharpen_denoise/chroma.optim`" OPTS_LUMA="`./optimums/latest.sh optimums/DEFAULT/nlmeans/sharpen_denoise/luma.optim`" nlmeans_template > $@
../nlmeans_temporal_sharpen_denoise.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_TEMPORAL_DESC) $(NLM_SHARPEN_DENOISE_DESC)" OPTS="$(NLM_TEMPORAL):`./optimums/latest.sh optimums/DEFAULT/nlmeans/sharpen_denoise/chroma.optim`" OPTS_LUMA="$(NLM_TEMPORAL_LUMA):`./optimums/latest.sh optimums/DEFAULT/nlmeans/sharpen_denoise/luma.optim`" nlmeans_template > $@
../nlmeans_light_sharpen_denoise.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_SHARPEN_DENOISE_DESC) $(NLM_LIGHT_DESC)" OPTS="`./optimums/latest.sh optimums/DEFAULT/nlmeans/light/sharpen_denoise/chroma.optim`" OPTS_LUMA="`./optimums/latest.sh optimums/DEFAULT/nlmeans/light/sharpen_denoise/luma.optim`" nlmeans_template > $@
../nlmeans_light_temporal_sharpen_denoise.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_TEMPORAL_DESC) $(NLM_LIGHT_DESC)" OPTS="$(NLM_TEMPORAL):`./optimums/latest.sh optimums/DEFAULT/nlmeans/light/sharpen_denoise/chroma.optim`" OPTS_LUMA="$(NLM_TEMPORAL_LUMA):`./optimums/latest.sh optimums/DEFAULT/nlmeans/light/sharpen_denoise/luma.optim`" nlmeans_template > $@
../nlmeans_sharpen_only.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_SHARPEN_ONLY_DESC)" OPTS="`./optimums/latest.sh optimums/DEFAULT/nlmeans/sharpen_only/chroma.optim`" OPTS_LUMA="`./optimums/latest.sh optimums/DEFAULT/nlmeans/sharpen_only/luma.optim`" nlmeans_template > $@
../nlmeans_light_sharpen_only.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_SHARPEN_ONLY_DESC) $(NLM_LIGHT_DESC)" OPTS="`./optimums/latest.sh optimums/DEFAULT/nlmeans/light/sharpen_only/chroma.optim`" OPTS_LUMA="`./optimums/latest.sh optimums/DEFAULT/nlmeans/light/sharpen_only/luma.optim`" nlmeans_template > $@

nlmeans_lq: ../LQ/nlmeans.glsl ../LQ/nlmeans_light.glsl ../LQ/nlmeans_temporal.glsl ../LQ/nlmeans_light_temporal.glsl ../LQ/nlmeans_sharpen_denoise.glsl ../LQ/nlmeans_light_sharpen_denoise.glsl ../LQ/nlmeans_sharpen_only.glsl ../LQ/nlmeans_light_sharpen_only.glsl ../LQ/nlmeans_temporal_sharpen_denoise.glsl ../LQ/nlmeans_light_temporal_sharpen_denoise.glsl 

NLM_LQ_DESC=Faster, but lower quality.

../LQ/nlmeans.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_LQ_DESC)" OPTS="`./optimums/latest.sh optimums/LQ/nlmeans/chroma.optim`" OPTS_LUMA="`./optimums/latest.sh optimums/LQ/nlmeans/luma.optim`" nlmeans_template > $@
../LQ/nlmeans_temporal.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_LQ_DESC) $(NLM_TEMPORAL_DESC)" OPTS="$(NLM_TEMPORAL):`./optimums/latest.sh optimums/LQ/nlmeans/chroma.optim`" OPTS_LUMA="$(NLM_TEMPORAL_LUMA):`./optimums/latest.sh optimums/LQ/nlmeans/luma.optim`" nlmeans_template > $@
../LQ/nlmeans_light.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_LQ_DESC) $(NLM_LIGHT_DESC)" OPTS="`./optimums/latest.sh optimums/LQ/nlmeans/light/chroma.optim`" OPTS_LUMA="`./optimums/latest.sh optimums/LQ/nlmeans/light/luma.optim`" nlmeans_template > $@
../LQ/nlmeans_light_temporal.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_LQ_DESC) $(NLM_TEMPORAL_DESC) $(NLM_LIGHT_DESC)" OPTS="$(NLM_TEMPORAL):`./optimums/latest.sh optimums/LQ/nlmeans/light/chroma.optim`" OPTS_LUMA="$(NLM_TEMPORAL_LUMA):`./optimums/latest.sh optimums/LQ/nlmeans/light/luma.optim`" nlmeans_template > $@
../LQ/nlmeans_sharpen_denoise.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_LQ_DESC) $(NLM_SHARPEN_DENOISE_DESC)" OPTS="`./optimums/latest.sh optimums/LQ/nlmeans/sharpen_denoise/chroma.optim`" OPTS_LUMA="`./optimums/latest.sh optimums/LQ/nlmeans/sharpen_denoise/luma.optim`" nlmeans_template > $@
../LQ/nlmeans_light_sharpen_denoise.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_LQ_DESC) $(NLM_SHARPEN_DENOISE_DESC) $(NLM_LIGHT_DESC)" OPTS="`./optimums/latest.sh optimums/LQ/nlmeans/light/sharpen_denoise/chroma.optim`" OPTS_LUMA="`./optimums/latest.sh optimums/LQ/nlmeans/light/sharpen_denoise/luma.optim`" nlmeans_template > $@
../LQ/nlmeans_sharpen_only.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_LQ_DESC) $(NLM_SHARPEN_ONLY_DESC)" OPTS="`./optimums/latest.sh optimums/LQ/nlmeans/sharpen_only/chroma.optim`" OPTS_LUMA="`./optimums/latest.sh optimums/LQ/nlmeans/sharpen_only/luma.optim`" nlmeans_template > $@
../LQ/nlmeans_light_sharpen_only.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_LQ_DESC) $(NLM_SHARPEN_ONLY_DESC) $(NLM_LIGHT_DESC)" OPTS="`./optimums/latest.sh optimums/LQ/nlmeans/light/sharpen_only/chroma.optim`" OPTS_LUMA="`./optimums/latest.sh optimums/LQ/nlmeans/light/sharpen_only/luma.optim`" nlmeans_template > $@
../LQ/nlmeans_temporal_sharpen_denoise.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_LQ_DESC) $(NLM_TEMPORAL_DESC) $(NLM_SHARPEN_DENOISE_DESC)" OPTS="$(NLM_TEMPORAL):`./optimums/latest.sh optimums/LQ/nlmeans/sharpen_denoise/chroma.optim`" OPTS_LUMA="$(NLM_TEMPORAL_LUMA):`./optimums/latest.sh optimums/LQ/nlmeans/sharpen_denoise/luma.optim`" nlmeans_template > $@
../LQ/nlmeans_light_temporal_sharpen_denoise.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_LQ_DESC) $(NLM_TEMPORAL_DESC) $(NLM_SHARPEN_DENOISE_DESC) $(NLM_LIGHT_DESC)" OPTS="$(NLM_TEMPORAL):`./optimums/latest.sh optimums/LQ/nlmeans/light/sharpen_denoise/chroma.optim`" OPTS_LUMA="$(NLM_TEMPORAL_LUMA):`./optimums/latest.sh optimums/LQ/nlmeans/light/sharpen_denoise/luma.optim`" nlmeans_template > $@

nlmeans_hq: ../HQ/nlmeans.glsl ../HQ/nlmeans_light.glsl ../HQ/nlmeans_temporal.glsl ../HQ/nlmeans_light_temporal.glsl ../HQ/nlmeans_sharpen_denoise.glsl ../HQ/nlmeans_light_sharpen_denoise.glsl ../HQ/nlmeans_sharpen_only.glsl ../HQ/nlmeans_light_sharpen_only.glsl ../HQ/nlmeans_temporal_sharpen_denoise.glsl ../HQ/nlmeans_light_temporal_sharpen_denoise.glsl 

NLM_HQ_DESC=Slow, but higher quality.

../HQ/nlmeans.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_HQ_DESC)" OPTS="`./optimums/latest.sh optimums/HQ/nlmeans/chroma.optim`" OPTS_LUMA="`./optimums/latest.sh optimums/HQ/nlmeans/luma.optim`" nlmeans_template > $@
../HQ/nlmeans_temporal.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_HQ_DESC) $(NLM_TEMPORAL_DESC)" OPTS="$(NLM_TEMPORAL):`./optimums/latest.sh optimums/HQ/nlmeans/chroma.optim`" OPTS_LUMA="$(NLM_TEMPORAL_LUMA):`./optimums/latest.sh optimums/HQ/nlmeans/luma.optim`" nlmeans_template > $@
../HQ/nlmeans_light.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_HQ_DESC) $(NLM_LIGHT_DESC)" OPTS="`./optimums/latest.sh optimums/HQ/nlmeans/light/chroma.optim`" OPTS_LUMA="`./optimums/latest.sh optimums/HQ/nlmeans/light/luma.optim`" nlmeans_template > $@
../HQ/nlmeans_light_temporal.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_HQ_DESC) $(NLM_TEMPORAL_DESC) $(NLM_LIGHT_DESC)" OPTS="$(NLM_TEMPORAL):`./optimums/latest.sh optimums/HQ/nlmeans/light/chroma.optim`" OPTS_LUMA="$(NLM_TEMPORAL_LUMA):`./optimums/latest.sh optimums/HQ/nlmeans/light/luma.optim`" nlmeans_template > $@
../HQ/nlmeans_sharpen_denoise.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_HQ_DESC) $(NLM_SHARPEN_DENOISE_DESC)" OPTS="`./optimums/latest.sh optimums/HQ/nlmeans/sharpen_denoise/chroma.optim`" OPTS_LUMA="`./optimums/latest.sh optimums/HQ/nlmeans/sharpen_denoise/luma.optim`" nlmeans_template > $@
../HQ/nlmeans_light_sharpen_denoise.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_HQ_DESC) $(NLM_SHARPEN_DENOISE_DESC) $(NLM_LIGHT_DESC)" OPTS="`./optimums/latest.sh optimums/HQ/nlmeans/light/sharpen_denoise/chroma.optim`" OPTS_LUMA="`./optimums/latest.sh optimums/HQ/nlmeans/light/sharpen_denoise/luma.optim`" nlmeans_template > $@
../HQ/nlmeans_sharpen_only.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_HQ_DESC) $(NLM_SHARPEN_ONLY_DESC)" OPTS="`./optimums/latest.sh optimums/HQ/nlmeans/sharpen_only/chroma.optim`" OPTS_LUMA="`./optimums/latest.sh optimums/HQ/nlmeans/sharpen_only/luma.optim`" nlmeans_template > $@
../HQ/nlmeans_light_sharpen_only.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_HQ_DESC) $(NLM_SHARPEN_ONLY_DESC) $(NLM_LIGHT_DESC)" OPTS="`./optimums/latest.sh optimums/HQ/nlmeans/light/sharpen_only/chroma.optim`" OPTS_LUMA="`./optimums/latest.sh optimums/HQ/nlmeans/light/sharpen_only/luma.optim`" nlmeans_template > $@
../HQ/nlmeans_temporal_sharpen_denoise.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_HQ_DESC) $(NLM_TEMPORAL_DESC) $(NLM_SHARPEN_DENOISE_DESC)" OPTS="$(NLM_TEMPORAL):`./optimums/latest.sh optimums/HQ/nlmeans/sharpen_denoise/chroma.optim`" OPTS_LUMA="$(NLM_TEMPORAL_LUMA):`./optimums/latest.sh optimums/HQ/nlmeans/sharpen_denoise/luma.optim`" nlmeans_template > $@
../HQ/nlmeans_light_temporal_sharpen_denoise.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_HQ_DESC) $(NLM_TEMPORAL_DESC) $(NLM_SHARPEN_DENOISE_DESC) $(NLM_LIGHT_DESC)" OPTS="$(NLM_TEMPORAL):`./optimums/latest.sh optimums/HQ/nlmeans/light/sharpen_denoise/chroma.optim`" OPTS_LUMA="$(NLM_TEMPORAL_LUMA):`./optimums/latest.sh optimums/HQ/nlmeans/light/sharpen_denoise/luma.optim`" nlmeans_template > $@

nlmeans_experimental: experimental/nlmeans_2x.glsl experimental/nlmeans_lgc.glsl experimental/nlmeans_ffmpeg_eqv.glsl experimental/nlmeans_2x_chroma.glsl experimental/nlmeans_simple_sharpen_only.glsl experimental/nlmeans_simple_2x.glsl experimental/nlmeans_simple_2x_chroma.glsl

NLM_2X_DESC=Experimental upscaler
NLM_SIMPLE_SHARPEN_DESC=Sharpen without actually running the NLM algorithm
NLM_SIMPLE_2X_DESC=Upscale without actually running the NLM algorithm

experimental/nlmeans_2x.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_2X_DESC)" OPTS="`./optimums/latest.sh optimums/experimental/nlmeans_2x/luma.optim`" nlmeans_template > $@
experimental/nlmeans_2x_chroma.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_2X_DESC)" OPTS="`./optimums/latest.sh optimums/experimental/nlmeans_2x/chroma.optim`" nlmeans_template > $@
experimental/nlmeans_simple_sharpen_only.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_SIMPLE_SHARPEN_DESC)" OPTS="`./optimums/latest.sh optimums/experimental/nlmeans_simple_sharpen_only/chroma.optim`" OPTS_LUMA="`./optimums/latest.sh optimums/experimental/nlmeans_simple_sharpen_only/luma.optim`" nlmeans_template > $@
experimental/nlmeans_simple_2x.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_SIMPLE_2X_DESC)" OPTS="CFG_HOOKS=LUMA:`./optimums/latest.sh optimums/experimental/nlmeans_simple_2x/luma.optim`" nlmeans_template > $@
experimental/nlmeans_simple_2x_chroma.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_SIMPLE_2X_DESC)" OPTS="CFG_HOOKS=CHROMA:`./optimums/latest.sh optimums/experimental/nlmeans_simple_2x/chroma.optim`" nlmeans_template > $@

NLM_LGC_DESC=Experimental luma-guided chroma denoising, kinda similar to KrigBilateral
NLM_LGC=`./optimums/latest.sh optimums/experimental/nlmeans_lgc/chroma.optim`

experimental/nlmeans_lgc.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_LGC_DESC)" OPTS="$(NLM_LGC)" nlmeans_template > $@

NLM_FFMPEG_EQV_DESC=Should be roughly equivalent to ffmpeg's -vf=nlmeans
NLM_FFMPEG_EQV=S=0.5:P=7:R=15:SW=1.0:RS=0:PS=0:WD=0:RI=0:RFI=0:RO=0:SST=0:GI=0:GC=0:G=0

experimental/nlmeans_ffmpeg_eqv.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_FFMPEG_EQV_DESC)" OPTS="$(NLM_FFMPEG_EQV)" OPTS_LUMA="$(NLM_FFMPEG_EQV)" nlmeans_template > $@

hdeband: ../hdeband.glsl ../LQ/hdeband.glsl

../hdeband.glsl: hdeband_template
	./shader_cfg OPTS="`./optimums/latest.sh optimums/DEFAULT/hdeband/chroma.optim`" OPTS_LUMA="`./optimums/latest.sh optimums/DEFAULT/hdeband/luma.optim`" $? > $@
../LQ/hdeband.glsl: hdeband_template
	./shader_cfg OPTS="`./optimums/latest.sh optimums/LQ/hdeband/chroma.optim`" OPTS_LUMA="`./optimums/latest.sh optimums/LQ/hdeband/luma.optim`" $? > $@

optimize: optimize_nlmeans optimize_hdeband optimize_third_party

optimize_nlmeans: optimums/LQ/nlmeans optimums/DEFAULT/nlmeans optimums/HQ/nlmeans optimums/experimental/nlmeans_2x/luma.optim optimums/experimental/nlmeans_2x/chroma.optim optimize_nlmeans_experimental

optimums/LQ/nlmeans: optimums/LQ/nlmeans/luma.optim optimums/LQ/nlmeans/chroma.optim optimums/LQ/nlmeans/light/luma.optim optimums/LQ/nlmeans/light/chroma.optim optimums/LQ/nlmeans/sharpen_only/luma.optim optimums/LQ/nlmeans/sharpen_only/chroma.optim optimums/LQ/nlmeans/light/sharpen_only/luma.optim optimums/LQ/nlmeans/light/sharpen_only/chroma.optim optimums/LQ/nlmeans/sharpen_denoise/luma.optim optimums/LQ/nlmeans/sharpen_denoise/chroma.optim optimums/LQ/nlmeans/light/sharpen_denoise/luma.optim optimums/LQ/nlmeans/light/sharpen_denoise/chroma.optim 

optimums/DEFAULT/nlmeans: optimums/DEFAULT/nlmeans/luma.optim optimums/DEFAULT/nlmeans/chroma.optim optimums/DEFAULT/nlmeans/light/luma.optim optimums/DEFAULT/nlmeans/light/chroma.optim optimums/DEFAULT/nlmeans/sharpen_only/luma.optim optimums/DEFAULT/nlmeans/sharpen_only/chroma.optim optimums/DEFAULT/nlmeans/light/sharpen_only/luma.optim optimums/DEFAULT/nlmeans/light/sharpen_only/chroma.optim optimums/DEFAULT/nlmeans/sharpen_denoise/luma.optim optimums/DEFAULT/nlmeans/sharpen_denoise/chroma.optim optimums/DEFAULT/nlmeans/light/sharpen_denoise/luma.optim optimums/DEFAULT/nlmeans/light/sharpen_denoise/chroma.optim 

optimums/HQ/nlmeans: optimums/HQ/nlmeans/luma.optim optimums/HQ/nlmeans/chroma.optim optimums/HQ/nlmeans/light/luma.optim optimums/HQ/nlmeans/light/chroma.optim optimums/HQ/nlmeans/sharpen_only/luma.optim optimums/HQ/nlmeans/sharpen_only/chroma.optim optimums/HQ/nlmeans/light/sharpen_only/luma.optim optimums/HQ/nlmeans/light/sharpen_only/chroma.optim optimums/HQ/nlmeans/sharpen_denoise/luma.optim optimums/HQ/nlmeans/sharpen_denoise/chroma.optim optimums/HQ/nlmeans/light/sharpen_denoise/luma.optim optimums/HQ/nlmeans/light/sharpen_denoise/chroma.optim 

optimize_nlmeans_experimental: optimums/experimental/nlmeans_lgc/chroma.optim optimums/experimental/nlmeans_simple_sharpen_only/luma.optim optimums/experimental/nlmeans_simple_sharpen_only/chroma.optim optimums/experimental/nlmeans_simple_2x/luma.optim optimums/experimental/nlmeans_2x/chroma.optim

# XXX test against lossy codecs
# XXX test against different noise levels
# XXX test against softened noise
# XXX test temporal

OPT_NOISE_VF=noise=alls=10
OPT_NOISE=NOISE=10:10
OPT_NOISE_LIGHT_VF=noise=alls=5
OPT_NOISE_LIGHT=NOISE=5:10
OPT_BLUR_VF=gblur=0.75
OPT_BLUR=VF=$(OPT_BLUR_VF)
OPT_2X_VF=scale=540:540
OPT_2X=VF=$(OPT_2X_VF)
OPT_YUV420=VF=format=yuv420p,OUTOPTS='pix_fmt yuv420p'

OPT_SHARP_MAX=ASF=0.5:ASA=0.5:ASP=1.0:ASS=0.25
OPT_SHARP_G_MAX=ASF=0.5:ASA=0.5:ASP=1.0:ASS=0.25:INJ_G_ASF=0.5:INJ_G_ASA=0.5:INJ_G_ASP=1.0:INJ_G_ASS=0.25

optimums/LQ/nlmeans/luma.optim:
	./shader_test --corruption=$(OPT_NOISE) --auto-max --optimum=$@ --no-stats images/ >> $@
optimums/LQ/nlmeans/chroma.optim:
	./shader_test --plane=CHROMA --corruption=$(OPT_NOISE) --auto-max --optimum=$@ --no-stats images/ >> $@
optimums/LQ/nlmeans/light/luma.optim: optimums/LQ/nlmeans/luma.optim
	./shader_test --corruption=$(OPT_NOISE_LIGHT) --auto-max --optimum=$@ --no-stats images/ >> $@
optimums/LQ/nlmeans/light/chroma.optim: optimums/LQ/nlmeans/chroma.optim
	./shader_test --plane=CHROMA --corruption=$(OPT_NOISE_LIGHT) --auto-max --optimum=$@ --no-stats images/ >> $@
optimums/LQ/nlmeans/sharpen_only/luma.optim: optimums/LQ/nlmeans/luma.optim
	./shader_test --corruption=$(OPT_BLUR),$(OPT_NOISE) --acorruption=$(OPT_NOISE) --auto-max --max=$(OPT_SHARP_MAX) --cfgopts=AS=2 --optimum=$@ --no-stats images/ >> $@
optimums/LQ/nlmeans/sharpen_only/chroma.optim: optimums/LQ/nlmeans/chroma.optim
	./shader_test --plane=CHROMA --corruption=$(OPT_BLUR),$(OPT_NOISE) --acorruption=$(OPT_NOISE) --auto-max --max=$(OPT_SHARP_MAX) --cfgopts=AS=2 --optimum=$@ --no-stats images/ >> $@
optimums/LQ/nlmeans/light/sharpen_only/luma.optim: optimums/LQ/nlmeans/light/luma.optim
	./shader_test --corruption=$(OPT_BLUR),$(OPT_NOISE_LIGHT) --acorruption=$(OPT_NOISE_LIGHT) --auto-max --max=$(OPT_SHARP_MAX) --cfgopts=AS=2 --optimum=$@ --no-stats images/ >> $@
optimums/LQ/nlmeans/light/sharpen_only/chroma.optim: optimums/LQ/nlmeans/light/chroma.optim
	./shader_test --plane=CHROMA --corruption=$(OPT_BLUR),$(OPT_NOISE_LIGHT) --acorruption=$(OPT_NOISE_LIGHT) --auto-max --max=$(OPT_SHARP_MAX) --cfgopts=AS=2 --optimum=$@ --no-stats images/ >> $@
optimums/LQ/nlmeans/sharpen_denoise/luma.optim: optimums/LQ/nlmeans/luma.optim
	./shader_test --corruption=$(OPT_BLUR),$(OPT_NOISE) --auto-max --max=$(OPT_SHARP_MAX) --cfgopts=AS=1 --optimum=$@ --no-stats images/ >> $@
optimums/LQ/nlmeans/sharpen_denoise/chroma.optim: optimums/LQ/nlmeans/chroma.optim
	./shader_test --plane=CHROMA --corruption=$(OPT_BLUR),$(OPT_NOISE) --auto-max --max=$(OPT_SHARP_MAX) --cfgopts=AS=1 --optimum=$@ --no-stats images/ >> $@
optimums/LQ/nlmeans/light/sharpen_denoise/luma.optim: optimums/LQ/nlmeans/light/luma.optim
	./shader_test --corruption=$(OPT_BLUR),$(OPT_NOISE_LIGHT) --auto-max --max=$(OPT_SHARP_MAX) --cfgopts=AS=1 --optimum=$@ --no-stats images/ >> $@
optimums/LQ/nlmeans/light/sharpen_denoise/chroma.optim: optimums/LQ/nlmeans/light/chroma.optim
	./shader_test --plane=CHROMA --corruption=$(OPT_BLUR),$(OPT_NOISE_LIGHT) --max=$(OPT_SHARP_MAX) --auto-max --cfgopts=AS=1 --optimum=$@ --no-stats images/ >> $@
optimums/DEFAULT/nlmeans/luma.optim:
	./shader_test --corruption=$(OPT_NOISE) --auto-max --optimum=$@ --no-stats images/ >> $@
optimums/DEFAULT/nlmeans/chroma.optim:
	./shader_test --plane=CHROMA --corruption=$(OPT_NOISE) --auto-max --optimum=$@ --no-stats images/ >> $@
optimums/DEFAULT/nlmeans/light/luma.optim: optimums/DEFAULT/nlmeans/luma.optim
	./shader_test --corruption=$(OPT_NOISE_LIGHT) --auto-max --optimum=$@ --no-stats images/ >> $@
optimums/DEFAULT/nlmeans/light/chroma.optim: optimums/DEFAULT/nlmeans/chroma.optim
	./shader_test --plane=CHROMA --corruption=$(OPT_NOISE_LIGHT) --auto-max --optimum=$@ --no-stats images/ >> $@
optimums/DEFAULT/nlmeans/sharpen_only/luma.optim: optimums/DEFAULT/nlmeans/luma.optim
	./shader_test --corruption=$(OPT_BLUR),$(OPT_NOISE) --acorruption=$(OPT_NOISE) --auto-max --max=$(OPT_SHARP_G_MAX) --cfgopts=AS=2:INJ_G_AS=2 --optimum=$@ --no-stats images/ >> $@
optimums/DEFAULT/nlmeans/sharpen_only/chroma.optim: optimums/DEFAULT/nlmeans/chroma.optim
	./shader_test --plane=CHROMA --corruption=$(OPT_BLUR),$(OPT_NOISE) --acorruption=$(OPT_NOISE) --auto-max --max=$(OPT_SHARP_G_MAX) --cfgopts=AS=2:INJ_G_AS=2 --optimum=$@ --no-stats images/ >> $@
optimums/DEFAULT/nlmeans/light/sharpen_only/luma.optim: optimums/DEFAULT/nlmeans/light/luma.optim
	./shader_test --corruption=$(OPT_BLUR),$(OPT_NOISE_LIGHT) --acorruption=$(OPT_NOISE_LIGHT) --auto-max --max=$(OPT_SHARP_G_MAX) --cfgopts=AS=2:INJ_G_AS=2 --optimum=$@ --no-stats images/ >> $@
optimums/DEFAULT/nlmeans/light/sharpen_only/chroma.optim: optimums/DEFAULT/nlmeans/light/chroma.optim
	./shader_test --plane=CHROMA --corruption=$(OPT_BLUR),$(OPT_NOISE_LIGHT) --acorruption=$(OPT_NOISE_LIGHT) --auto-max --max=$(OPT_SHARP_G_MAX) --cfgopts=AS=2:INJ_G_AS=2 --optimum=$@ --no-stats images/ >> $@
optimums/DEFAULT/nlmeans/sharpen_denoise/luma.optim: optimums/DEFAULT/nlmeans/luma.optim
	./shader_test --corruption=$(OPT_BLUR),$(OPT_NOISE) --auto-max --max=$(OPT_SHARP_G_MAX) --cfgopts=AS=1:INJ_G_AS=1 --optimum=$@ --no-stats images/ >> $@
optimums/DEFAULT/nlmeans/sharpen_denoise/chroma.optim: optimums/DEFAULT/nlmeans/chroma.optim
	./shader_test --plane=CHROMA --corruption=$(OPT_BLUR),$(OPT_NOISE) --max=$(OPT_SHARP_G_MAX) --auto-max --cfgopts=AS=1:INJ_G_AS=1 --optimum=$@ --no-stats images/ >> $@
optimums/DEFAULT/nlmeans/light/sharpen_denoise/luma.optim: optimums/DEFAULT/nlmeans/light/luma.optim
	./shader_test --corruption=$(OPT_BLUR),$(OPT_NOISE_LIGHT) --max=$(OPT_SHARP_G_MAX) --auto-max --cfgopts=AS=1:INJ_G_AS=1 --optimum=$@ --no-stats images/ >> $@
optimums/DEFAULT/nlmeans/light/sharpen_denoise/chroma.optim: optimums/DEFAULT/nlmeans/light/chroma.optim
	./shader_test --plane=CHROMA --corruption=$(OPT_BLUR),$(OPT_NOISE_LIGHT) --max=$(OPT_SHARP_G_MAX) --auto-max --cfgopts=AS=1:INJ_G_AS=1 --optimum=$@ --no-stats images/ >> $@
optimums/HQ/nlmeans/luma.optim:
	./shader_test --corruption=$(OPT_NOISE) --auto-max --optimum=$@ --no-stats images/ >> $@
optimums/HQ/nlmeans/chroma.optim:
	./shader_test --plane=CHROMA --corruption=$(OPT_NOISE) --auto-max --optimum=$@ --no-stats images/ >> $@
optimums/HQ/nlmeans/light/luma.optim: optimums/HQ/nlmeans/luma.optim
	./shader_test --corruption=$(OPT_NOISE_LIGHT) --auto-max --optimum=$@ --no-stats images/ >> $@
optimums/HQ/nlmeans/light/chroma.optim: optimums/HQ/nlmeans/chroma.optim
	./shader_test --plane=CHROMA --corruption=$(OPT_NOISE_LIGHT) --auto-max --optimum=$@ --no-stats images/ >> $@
optimums/HQ/nlmeans/sharpen_only/luma.optim: optimums/HQ/nlmeans/luma.optim
	./shader_test --corruption=$(OPT_BLUR),$(OPT_NOISE) --acorruption=$(OPT_NOISE) --auto-max --max=$(OPT_SHARP_G_MAX) --cfgopts=AS=2:INJ_G_AS=2 --optimum=$@ --no-stats images/ >> $@
optimums/HQ/nlmeans/sharpen_only/chroma.optim: optimums/HQ/nlmeans/chroma.optim
	./shader_test --plane=CHROMA --corruption=$(OPT_BLUR),$(OPT_NOISE) --acorruption=$(OPT_NOISE) --auto-max --max=$(OPT_SHARP_G_MAX) --cfgopts=AS=2:INJ_G_AS=2 --optimum=$@ --no-stats images/ >> $@
optimums/HQ/nlmeans/light/sharpen_only/luma.optim: optimums/HQ/nlmeans/light/luma.optim
	./shader_test --corruption=$(OPT_BLUR),$(OPT_NOISE_LIGHT) --acorruption=$(OPT_NOISE_LIGHT) --auto-max --max=$(OPT_SHARP_G_MAX) --cfgopts=AS=2:INJ_G_AS=2 --optimum=$@ --no-stats images/ >> $@
optimums/HQ/nlmeans/light/sharpen_only/chroma.optim: optimums/HQ/nlmeans/light/chroma.optim
	./shader_test --plane=CHROMA --corruption=$(OPT_BLUR),$(OPT_NOISE_LIGHT) --acorruption=$(OPT_NOISE_LIGHT) --auto-max --max=$(OPT_SHARP_G_MAX) --cfgopts=AS=2:INJ_G_AS=2 --optimum=$@ --no-stats images/ >> $@
optimums/HQ/nlmeans/sharpen_denoise/luma.optim: optimums/HQ/nlmeans/luma.optim
	./shader_test --corruption=$(OPT_BLUR),$(OPT_NOISE) --max=$(OPT_SHARP_G_MAX) --auto-max --cfgopts=AS=1:INJ_G_AS=1 --optimum=$@ --no-stats images/ >> $@
optimums/HQ/nlmeans/sharpen_denoise/chroma.optim: optimums/HQ/nlmeans/chroma.optim
	./shader_test --plane=CHROMA --corruption=$(OPT_BLUR),$(OPT_NOISE) --max=$(OPT_SHARP_G_MAX) --auto-max --cfgopts=AS=1:INJ_G_AS=1 --optimum=$@ --no-stats images/ >> $@
optimums/HQ/nlmeans/light/sharpen_denoise/luma.optim: optimums/HQ/nlmeans/light/luma.optim
	./shader_test --corruption=$(OPT_BLUR),$(OPT_NOISE_LIGHT) --max=$(OPT_SHARP_G_MAX) --auto-max --cfgopts=AS=1:INJ_G_AS=1 --optimum=$@ --no-stats images/ >> $@
optimums/HQ/nlmeans/light/sharpen_denoise/chroma.optim: optimums/HQ/nlmeans/light/chroma.optim
	./shader_test --plane=CHROMA --corruption=$(OPT_BLUR),$(OPT_NOISE_LIGHT) --max=$(OPT_SHARP_G_MAX) --auto-max --cfgopts=AS=1:INJ_G_AS=1 --optimum=$@ --no-stats images/ >> $@
optimums/experimental/nlmeans_2x/luma.optim:
	./shader_test --corruption=$(OPT_2X) --auto-max --optimum=$@ --no-stats images/ >> $@
optimums/experimental/nlmeans_2x/chroma.optim:
	./shader_test --plane=CHROMA --corruption=$(OPT_YUV420) --auto-max --optimum=$@ --no-stats images/ >> $@
optimums/experimental/nlmeans_lgc/chroma.optim:
	./shader_test --plane=CHROMA --corruption=$(OPT_YUV420) --auto-max --optimum=$@ --no-stats images/ >> $@
optimums/experimental/nlmeans_simple_sharpen_only/luma.optim:
	./shader_test --corruption=$(OPT_BLUR) --auto-max --optimum=$@ --no-stats images/ >> $@
optimums/experimental/nlmeans_simple_sharpen_only/chroma.optim:
	./shader_test --plane=CHROMA --corruption=$(OPT_BLUR) --auto-max --optimum=$@ --no-stats images/ >> $@
optimums/experimental/nlmeans_simple_2x/luma.optim:
	./shader_test --corruption=$(OPT_2X) --auto-max --optimum=$@ --no-stats images/ >> $@
optimums/experimental/nlmeans_simple_2x/chroma.optim:
	./shader_test --plane=CHROMA --corruption=$(OPT_YUV420) --auto-max --optimum=$@ --no-stats images/ >> $@

optimize_hdeband: optimums/LQ/hdeband/luma.optim optimums/LQ/hdeband/chroma.optim optimums/DEFAULT/hdeband/luma.optim optimums/DEFAULT/hdeband/chroma.optim

# ideally 255 should be cleanly divisible by this, higher is more banding
OPT_BAND_PARAM=15.0
# parenthesis are only escaped for make
OPT_BAND_EXPR=round\(p\(X\,Y\)/$(OPT_BAND_PARAM)\)*$(OPT_BAND_PARAM)
OPT_BAND_VF=geq='$(OPT_BAND_EXPR):$(OPT_BAND_EXPR):$(OPT_BAND_EXPR)'
OPT_BAND=VF=$(OPT_BAND_VF)

optimums/LQ/hdeband/luma.optim:
	./shader_test --corruption=$(OPT_BAND) --auto-max --optimum=$@ --shader=hdeband_template --no-stats images/ >> $@
optimums/LQ/hdeband/chroma.optim:
	./shader_test --plane=CHROMA --corruption=$(OPT_BAND) --auto-max --optimum=$@ --shader=hdeband_template --no-stats images/ >> $@
optimums/DEFAULT/hdeband/luma.optim:
	./shader_test --corruption=$(OPT_BAND) --auto-max --optimum=$@ --shader=hdeband_template --no-stats images/ >> $@
optimums/DEFAULT/hdeband/chroma.optim:
	./shader_test --plane=CHROMA --corruption=$(OPT_BAND) --auto-max --optimum=$@ --shader=hdeband_template --no-stats images/ >> $@

optimize_third_party: optimums/third_party/FSRCNNX_8/luma.optim optimums/third_party/FSRCNNX_16/luma.optim optimums/third_party/FSR_sharpen/luma.optim optimums/third_party/FSR_2x/luma.optim 

optimums/third_party/FSRCNNX_8/luma.optim:
	./shader_test --corruption=$(OPT_2X) --optimum=$@ --no-stats --shader=../FSRCNNX_x2_8-0-4-1.glsl images/ >> $@
optimums/third_party/FSRCNNX_16/luma.optim:
	./shader_test --corruption=$(OPT_2X) --optimum=$@ --no-stats --shader=../FSRCNNX_x2_16-0-4-1.glsl images/ >> $@
optimums/third_party/FSR_sharpen/luma.optim:
	./shader_test --corruption=$(OPT_BLUR) --auto-max --optimum=$@ --no-stats --shader=../FSR.glsl images/ >> $@
optimums/third_party/FSR_2x/luma.optim:
	./shader_test --corruption=$(OPT_2X) --auto-max --optimum=$@ --no-stats --shader=../FSR.glsl images/ >> $@

upscalers=optimums/third_party/FSR_2x/luma.optim optimums/third_party/FSRCNNX_16/luma.optim optimums/third_party/FSRCNNX_8/luma.optim optimums/experimental/nlmeans_simple_2x/luma.optim optimums/experimental/nlmeans_2x/luma.optim
optimums/2x.comparisons: $(upscalers)
	./optimums/latest.sh $(upscalers) | sort -n -r -k 3 > $@

readme: result_images/clean.png result_images/opt_noise.png result_images/opt_blur.png result_images/opt_blur_opt_noise.png result_images/nlmeans_opt_noise.png result_images/nlmeans_sharpen_denoise_opt_blur_opt_noise.png result_images/nlmeans_sharpen_only_opt_blur_opt_noise.png result_images/nlmeans_sharpen_only_opt_blur.png result_images/fsr_opt_blur_opt_noise.png result_images/fsr_opt_blur.png 

../FSR.glsl:
	curl -L 'https://gist.githubusercontent.com/agyild/82219c545228d70c5604f865ce0b0ce5/raw/2623d743b9c23f500ba086f05b385dcb1557e15d/FSR.glsl' > $@
	sed -i '/^\/\/!WHEN/d' $@ # https://github.com/mpv-player/mpv/issues/10246#issuecomment-1303894445
result_images/clean.png: ../nlmeans.glsl
	ffmpeg -y -i images/anime/mountain_adventurer.webp -vf 'crop=128:128:y=128,format=yuv420p,scale=256:256:flags=neighbor' $@
result_images/opt_noise.png: ../nlmeans.glsl
	ffmpeg -y -i images/anime/mountain_adventurer.webp -vf 'crop=128:128:y=128,format=yuv420p,$(OPT_NOISE_VF),scale=256:256:flags=neighbor' $@
result_images/opt_blur.png: ../nlmeans.glsl
	ffmpeg -y -i images/anime/mountain_adventurer.webp -vf 'crop=128:128:y=128,format=yuv420p,$(OPT_BLUR_VF),scale=256:256:flags=neighbor' $@
result_images/opt_blur_opt_noise.png: ../nlmeans.glsl
	ffmpeg -y -i images/anime/mountain_adventurer.webp -vf 'crop=128:128:y=128,format=yuv420p,$(OPT_BLUR_VF),$(OPT_NOISE_VF),scale=256:256:flags=neighbor' $@
result_images/nlmeans_opt_noise.png: ../nlmeans.glsl
	ffmpeg -y -init_hw_device vulkan -i images/anime/mountain_adventurer.webp -vf 'crop=128:128:y=128,format=yuv420p,$(OPT_NOISE_VF),hwupload,libplacebo=w=128:h=128:custom_shader_path=$?,hwdownload,format=yuv420p,scale=256:256:flags=neighbor' $@
result_images/nlmeans_sharpen_denoise_opt_blur_opt_noise.png: ../nlmeans_sharpen_denoise.glsl
	ffmpeg -y -init_hw_device vulkan -i images/anime/mountain_adventurer.webp -vf 'crop=128:128:y=128,format=yuv420p,$(OPT_BLUR_VF),$(OPT_NOISE_VF),hwupload,libplacebo=w=128:h=128:custom_shader_path=$?,hwdownload,format=yuv420p,scale=256:256:flags=neighbor' $@
result_images/nlmeans_sharpen_only_opt_blur_opt_noise.png: ../nlmeans_sharpen_only.glsl
	ffmpeg -y -init_hw_device vulkan -i images/anime/mountain_adventurer.webp -vf 'crop=128:128:y=128,format=yuv420p,$(OPT_BLUR_VF),$(OPT_NOISE_VF),hwupload,libplacebo=w=128:h=128:custom_shader_path=$?,hwdownload,format=yuv420p,scale=256:256:flags=neighbor' $@
result_images/nlmeans_sharpen_only_opt_blur.png: ../nlmeans_sharpen_only.glsl
	ffmpeg -y -init_hw_device vulkan -i images/anime/mountain_adventurer.webp -vf 'crop=128:128:y=128,format=yuv420p,$(OPT_BLUR_VF),hwupload,libplacebo=w=128:h=128:custom_shader_path=$?,hwdownload,format=yuv420p,scale=256:256:flags=neighbor' $@
result_images/fsr_opt_blur_opt_noise.png: ../FSR.glsl
	ffmpeg -y -init_hw_device vulkan -i images/anime/mountain_adventurer.webp -vf 'crop=128:128:y=128,format=yuv420p,$(OPT_BLUR_VF),$(OPT_NOISE_VF),hwupload,libplacebo=w=128:h=128:custom_shader_path=$?,hwdownload,format=yuv420p,scale=256:256:flags=neighbor' $@
result_images/fsr_opt_blur.png: ../FSR.glsl
	ffmpeg -y -init_hw_device vulkan -i images/anime/mountain_adventurer.webp -vf 'crop=128:128:y=128,format=yuv420p,$(OPT_BLUR_VF),hwupload,libplacebo=w=128:h=128:custom_shader_path=$?,hwdownload,format=yuv420p,scale=256:256:flags=neighbor' $@

