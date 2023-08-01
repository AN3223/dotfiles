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

nlmeans: nlmeans_default nlmeans_lq nlmeans_hq nlmeans_hqx nlmeans_experimental

# If RF=shader then that shader needs to be added to the prerequisites (i.e., alongside nlmeans_template)

NLM_NO_ROTATE=RI=0:RFI=0

NLM_SHARPEN_ONLY_DESC=Sharpen without denoising.
NLM_SHARPEN_ONLY=AS=2

NLM_SHARPEN_DENOISE_DESC=Sharpen and denoise.
NLM_SHARPEN_DENOISE=AS=1

NLM_TEMPORAL_DESC=Very experimental and buggy, limited to vo=gpu-next.
NLM_TEMPORAL=T_FRAME_LIMIT=2:T_RES=3840x3840
NLM_TEMPORAL_LUMA=T=2:$(NLM_NO_ROTATE)

NLM_LIGHT_DESC=Tuned for light noise.

nlmeans_default: ../nlmeans.glsl ../nlmeans_light.glsl ../nlmeans_temporal.glsl ../nlmeans_light_temporal.glsl ../nlmeans_sharpen_denoise.glsl ../nlmeans_light_sharpen_denoise.glsl ../nlmeans_sharpen_only.glsl ../nlmeans_light_sharpen_only.glsl ../nlmeans_temporal_sharpen_denoise.glsl 

../nlmeans.glsl: nlmeans_template
	./shader_cfg nlmeans_template OPTS="`./optimums/latest.sh $@ chroma`" OPTS_LUMA="`./optimums/latest.sh $@ luma`" > $@
../nlmeans_light.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_LIGHT_DESC)" OPTS="`./optimums/latest.sh $@ chroma`" OPTS_LUMA="`./optimums/latest.sh $@ luma`" nlmeans_template > $@
../nlmeans_temporal.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_TEMPORAL_DESC)" OPTS="$(NLM_TEMPORAL):`./optimums/latest.sh ../nlmeans.glsl chroma`" OPTS_LUMA="$(NLM_TEMPORAL_LUMA):`./optimums/latest.sh ../nlmeans.glsl luma`" nlmeans_template > $@
../nlmeans_light_temporal.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_TEMPORAL_DESC) $(NLM_LIGHT_DESC)" OPTS="$(NLM_TEMPORAL):`./optimums/latest.sh ../nlmeans_light.glsl chroma`" OPTS_LUMA="$(NLM_TEMPORAL_LUMA):`./optimums/latest.sh ../nlmeans_light.glsl luma`" nlmeans_template > $@
../nlmeans_sharpen_denoise.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_SHARPEN_DENOISE_DESC)" OPTS="`./optimums/latest.sh $@ chroma`" OPTS_LUMA="`./optimums/latest.sh $@ luma`" nlmeans_template > $@
../nlmeans_light_sharpen_denoise.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_SHARPEN_DENOISE_DESC) $(NLM_LIGHT_DESC)" OPTS="`./optimums/latest.sh $@ chroma`" OPTS_LUMA="`./optimums/latest.sh $@ luma`" nlmeans_template > $@
../nlmeans_sharpen_only.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_SHARPEN_ONLY_DESC)" OPTS="`./optimums/latest.sh $@ chroma`" OPTS_LUMA="`./optimums/latest.sh $@ luma`" nlmeans_template > $@
../nlmeans_light_sharpen_only.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_SHARPEN_ONLY_DESC) $(NLM_LIGHT_DESC)" OPTS="`./optimums/latest.sh $@ chroma`" OPTS_LUMA="`./optimums/latest.sh $@ luma`" nlmeans_template > $@
../nlmeans_temporal_sharpen_denoise.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_TEMPORAL_DESC) $(NLM_SHARPEN_DENOISE_DESC)" OPTS="$(NLM_TEMPORAL):`./optimums/latest.sh ../nlmeans_sharpen_denoise.glsl chroma`" OPTS_LUMA="$(NLM_TEMPORAL_LUMA):`./optimums/latest.sh ../nlmeans_sharpen_denoise.glsl luma`" nlmeans_template > $@


nlmeans_lq: ../LQ/nlmeans.glsl ../LQ/nlmeans_light.glsl ../LQ/nlmeans_temporal.glsl ../LQ/nlmeans_light_temporal.glsl ../LQ/nlmeans_sharpen_denoise.glsl ../LQ/nlmeans_light_sharpen_denoise.glsl ../LQ/nlmeans_sharpen_only.glsl ../LQ/nlmeans_light_sharpen_only.glsl ../LQ/nlmeans_temporal_sharpen_denoise.glsl ../LQ/nlmeans_light_temporal_sharpen_denoise.glsl 

NLM_LQ_DESC=Faster, but lower quality.

../LQ/nlmeans.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_LQ_DESC)" OPTS="`./optimums/latest.sh $@ chroma`" OPTS_LUMA="`./optimums/latest.sh $@ luma`" nlmeans_template > $@
../LQ/nlmeans_light.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_LQ_DESC) $(NLM_LIGHT_DESC)" OPTS="`./optimums/latest.sh $@ chroma`" OPTS_LUMA="`./optimums/latest.sh $@ luma`" nlmeans_template > $@
../LQ/nlmeans_temporal.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_LQ_DESC) $(NLM_TEMPORAL_DESC)" OPTS="$(NLM_TEMPORAL):`./optimums/latest.sh ../LQ/nlmeans.glsl chroma`" OPTS_LUMA="$(NLM_TEMPORAL_LUMA):`./optimums/latest.sh ../LQ/nlmeans.glsl luma`" nlmeans_template > $@
../LQ/nlmeans_light_temporal.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_LQ_DESC) $(NLM_TEMPORAL_DESC) $(NLM_LIGHT_DESC)" OPTS="$(NLM_TEMPORAL):`./optimums/latest.sh ../LQ/nlmeans_light.glsl chroma`" OPTS_LUMA="$(NLM_TEMPORAL_LUMA):`./optimums/latest.sh ../LQ/nlmeans_light.glsl luma`" nlmeans_template > $@
../LQ/nlmeans_sharpen_denoise.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_LQ_DESC) $(NLM_SHARPEN_DENOISE_DESC)" OPTS="`./optimums/latest.sh $@ chroma`" OPTS_LUMA="`./optimums/latest.sh $@ luma`" nlmeans_template > $@
../LQ/nlmeans_light_sharpen_denoise.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_LQ_DESC) $(NLM_SHARPEN_DENOISE_DESC) $(NLM_LIGHT_DESC)" OPTS="`./optimums/latest.sh $@ chroma`" OPTS_LUMA="`./optimums/latest.sh $@ luma`" nlmeans_template > $@
../LQ/nlmeans_sharpen_only.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_LQ_DESC) $(NLM_SHARPEN_ONLY_DESC)" OPTS="`./optimums/latest.sh $@ chroma`" OPTS_LUMA="`./optimums/latest.sh $@ luma`" nlmeans_template > $@
../LQ/nlmeans_light_sharpen_only.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_LQ_DESC) $(NLM_SHARPEN_ONLY_DESC) $(NLM_LIGHT_DESC)" OPTS="`./optimums/latest.sh $@ chroma`" OPTS_LUMA="`./optimums/latest.sh $@ luma`" nlmeans_template > $@
../LQ/nlmeans_temporal_sharpen_denoise.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_LQ_DESC) $(NLM_TEMPORAL_DESC) $(NLM_SHARPEN_DENOISE_DESC)" OPTS="$(NLM_TEMPORAL):`./optimums/latest.sh ../LQ/nlmeans_sharpen_denoise.glsl chroma`" OPTS_LUMA="$(NLM_TEMPORAL_LUMA):`./optimums/latest.sh ../LQ/nlmeans_sharpen_denoise.glsl luma`" nlmeans_template > $@
../LQ/nlmeans_light_temporal_sharpen_denoise.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_LQ_DESC) $(NLM_TEMPORAL_DESC) $(NLM_SHARPEN_DENOISE_DESC) $(NLM_LIGHT_DESC)" OPTS="$(NLM_TEMPORAL):`./optimums/latest.sh ../LQ/nlmeans_light_sharpen_denoise.glsl chroma`" OPTS_LUMA="$(NLM_TEMPORAL_LUMA):`./optimums/latest.sh ../LQ/nlmeans_light_sharpen_denoise.glsl luma`" nlmeans_template > $@

nlmeans_hq: ../HQ/nlmeans.glsl ../HQ/nlmeans_light.glsl ../HQ/nlmeans_temporal.glsl ../HQ/nlmeans_light_temporal.glsl ../HQ/nlmeans_sharpen_denoise.glsl ../HQ/nlmeans_light_sharpen_denoise.glsl ../HQ/nlmeans_sharpen_only.glsl ../HQ/nlmeans_light_sharpen_only.glsl ../HQ/nlmeans_temporal_sharpen_denoise.glsl ../HQ/nlmeans_light_temporal_sharpen_denoise.glsl 

NLM_HQ_DESC=Slow, but higher quality.

../HQ/nlmeans.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_HQ_DESC)" OPTS="`./optimums/latest.sh $@ chroma`" OPTS_LUMA="`./optimums/latest.sh $@ luma`" nlmeans_template > $@
../HQ/nlmeans_light.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_HQ_DESC) $(NLM_LIGHT_DESC)" OPTS="`./optimums/latest.sh $@ chroma`" OPTS_LUMA="`./optimums/latest.sh $@ luma`" nlmeans_template > $@
../HQ/nlmeans_temporal.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_HQ_DESC) $(NLM_TEMPORAL_DESC)" OPTS="$(NLM_TEMPORAL):`./optimums/latest.sh ../HQ/nlmeans.glsl chroma`" OPTS_LUMA="$(NLM_TEMPORAL_LUMA):`./optimums/latest.sh ../HQ/nlmeans.glsl luma`" nlmeans_template > $@
../HQ/nlmeans_light_temporal.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_HQ_DESC) $(NLM_TEMPORAL_DESC) $(NLM_LIGHT_DESC)" OPTS="$(NLM_TEMPORAL):`./optimums/latest.sh ../HQ/nlmeans_light.glsl chroma`" OPTS_LUMA="$(NLM_TEMPORAL_LUMA):`./optimums/latest.sh ../HQ/nlmeans_light.glsl luma`" nlmeans_template > $@
../HQ/nlmeans_sharpen_denoise.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_HQ_DESC) $(NLM_SHARPEN_DENOISE_DESC)" OPTS="`./optimums/latest.sh $@ chroma`" OPTS_LUMA="`./optimums/latest.sh $@ luma`" nlmeans_template > $@
../HQ/nlmeans_light_sharpen_denoise.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_HQ_DESC) $(NLM_SHARPEN_DENOISE_DESC) $(NLM_LIGHT_DESC)" OPTS="`./optimums/latest.sh $@ chroma`" OPTS_LUMA="`./optimums/latest.sh $@ luma`" nlmeans_template > $@
../HQ/nlmeans_sharpen_only.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_HQ_DESC) $(NLM_SHARPEN_ONLY_DESC)" OPTS="`./optimums/latest.sh $@ chroma`" OPTS_LUMA="`./optimums/latest.sh $@ luma`" nlmeans_template > $@
../HQ/nlmeans_light_sharpen_only.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_HQ_DESC) $(NLM_SHARPEN_ONLY_DESC) $(NLM_LIGHT_DESC)" OPTS="`./optimums/latest.sh $@ chroma`" OPTS_LUMA="`./optimums/latest.sh $@ luma`" nlmeans_template > $@
../HQ/nlmeans_temporal_sharpen_denoise.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_HQ_DESC) $(NLM_TEMPORAL_DESC) $(NLM_SHARPEN_DENOISE_DESC)" OPTS="$(NLM_TEMPORAL):`./optimums/latest.sh ../HQ/nlmeans_sharpen_denoise.glsl chroma`" OPTS_LUMA="$(NLM_TEMPORAL_LUMA):`./optimums/latest.sh ../HQ/nlmeans_sharpen_denoise.glsl luma`" nlmeans_template > $@
../HQ/nlmeans_light_temporal_sharpen_denoise.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_HQ_DESC) $(NLM_TEMPORAL_DESC) $(NLM_SHARPEN_DENOISE_DESC) $(NLM_LIGHT_DESC)" OPTS="$(NLM_TEMPORAL):`./optimums/latest.sh ../HQ/nlmeans_light_sharpen_denoise.glsl chroma`" OPTS_LUMA="$(NLM_TEMPORAL_LUMA):`./optimums/latest.sh ../HQ/nlmeans_light_sharpen_denoise.glsl luma`" nlmeans_template > $@

nlmeans_hqx: ../HQX/nlmeans.glsl

NLM_HQX_DESC=Very slow, should offer the best quality.
NLM_HQX_LUMA=P=5:`./optimums/latest.sh optimums/HQ/nlmeans/luma`
NLM_HQX=P=5:`./optimums/latest.sh optimums/HQ/nlmeans/chroma`

# XXX expand & optimize
../HQX/nlmeans.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_HQX_DESC)" OPTS="$(NLM_HQX)" OPTS_LUMA="$(NLM_HQX_LUMA)" nlmeans_template > $@

nlmeans_experimental: experimental/nlmeans_2x.glsl experimental/nlmeans_lgc.glsl experimental/nlmeans_ffmpeg_eqv.glsl

NLM_2X_DESC=Experimental upscaler
NLM_2X_LUMA=`./optimums/latest.sh optimums/DEFAULT/nlmeans_2x/luma`

experimental/nlmeans_2x.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_2X_DESC)" OPTS="$(NLM_2X_LUMA)" nlmeans_template > $@

NLM_LGC_DESC=Experimental luma-guided chroma denoising, kinda similar to KrigBilateral
NLM_LGC=CFG_HOOKS=CHROMA:RF=SHARE_LUMA:RF_LUMA=0:D1W=1:S=11.66:WD=0:SW=0.75:RI=3:RFI=2

experimental/nlmeans_lgc.glsl: nlmeans_template ../LQ/nlmeans.glsl
	./shader_cfg DESC="$@: $(NLM_LGC_DESC)" OPTS="$(NLM_LGC)" nlmeans_template > $@

NLM_FFMPEG_EQV_DESC=Should be roughly equivalent to ffmpeg's -vf=nlmeans
NLM_FFMPEG_EQV=S=0.5:P=7:R=15:SW=1.0:RS=0:PS=0:WD=0:RI=0:RFI=0:RO=0:SST=0:GI=0:RF=0:RF_LUMA=0

experimental/nlmeans_ffmpeg_eqv.glsl: nlmeans_template
	./shader_cfg DESC="$@: $(NLM_FFMPEG_EQV_DESC)" OPTS="$(NLM_FFMPEG_EQV)" OPTS_LUMA="$(NLM_FFMPEG_EQV)" nlmeans_template > $@

hdeband: ../LQ/hdeband.glsl

../LQ/hdeband.glsl: ../hdeband.glsl
	./shader_cfg OPTS="RADIUS=4:SPARSITY=0.5:DIRECTIONS=3" $? > $@

optimize: optimize_lq optimize_default optimize_hq

optimums/LQ: optimums/LQ/nlmeans/luma optimums/LQ/nlmeans/chroma optimums/LQ/nlmeans_light/luma optimums/LQ/nlmeans_light/chroma optimums/LQ/nlmeans_sharpen_only/luma optimums/LQ/nlmeans_sharpen_only/chroma optimums/LQ/nlmeans_light_sharpen_only/luma optimums/LQ/nlmeans_light_sharpen_only/chroma optimums/LQ/nlmeans_sharpen_denoise/luma optimums/LQ/nlmeans_sharpen_denoise/chroma optimums/LQ/nlmeans_light_sharpen_denoise/luma optimums/LQ/nlmeans_light_sharpen_denoise/chroma

optimums/DEFAULT: optimums/DEFAULT/nlmeans/luma optimums/DEFAULT/nlmeans/chroma optimums/DEFAULT/nlmeans_light/luma optimums/DEFAULT/nlmeans_light/chroma optimums/DEFAULT/nlmeans_sharpen_only/luma optimums/DEFAULT/nlmeans_sharpen_only/chroma optimums/DEFAULT/nlmeans_light_sharpen_only/luma optimums/DEFAULT/nlmeans_light_sharpen_only/chroma optimums/DEFAULT/nlmeans_sharpen_denoise/luma optimums/DEFAULT/nlmeans_sharpen_denoise/chroma optimums/DEFAULT/nlmeans_light_sharpen_denoise/luma optimums/DEFAULT/nlmeans_light_sharpen_denoise/chroma optimums/DEFAULT/nlmeans_2x/luma

optimums/HQ: optimums/HQ/nlmeans/luma optimums/HQ/nlmeans/chroma optimums/HQ/nlmeans_light/luma optimums/HQ/nlmeans_light/chroma optimums/HQ/nlmeans_sharpen_only/luma optimums/HQ/nlmeans_sharpen_only/chroma optimums/HQ/nlmeans_light_sharpen_only/luma optimums/HQ/nlmeans_light_sharpen_only/chroma optimums/HQ/nlmeans_sharpen_denoise/luma optimums/HQ/nlmeans_sharpen_denoise/chroma optimums/HQ/nlmeans_light_sharpen_denoise/luma optimums/HQ/nlmeans_light_sharpen_denoise/chroma 

# XXX add FSR/FSRCNNX/etc.
# XXX test against lossy codecs
# XXX test against different noise levels
# XXX test against softened noise
# XXX test temporal

OPT_NOISE=NOISE=10:10
OPT_NOISE_LIGHT=NOISE=5:10
OPT_BLUR=VF=gblur=0.625
OPT_2X=VF=scale=540:540

OPT_SHARP_MAX=ASF:ASA:ASP:ASS
OPT_LQ_LUMA_MAX=S:SW:SS:WDT:WDP:RO
OPT_LQ_CHROMA_MAX=S:SS:SW:WDT:WDP
OPT_DEFAULT_LUMA_MAX=S:SW:SS:WDT:RO:INJ_RF_LUMA_S:INJ_RF_LUMA_SW:INJ_RF_LUMA_SS:INJ_RF_LUMA_WDT:INJ_RF_LUMA_WDP:INJ_RF_LUMA_RO
OPT_DEFAULT_CHROMA_MAX=S:SW:SS:RO:INJ_RF_LUMA_S:INJ_RF_LUMA_SS:INJ_RF_LUMA_SW:INJ_RF_LUMA_WDT:INJ_RF_LUMA_WDP
OPT_2X_LUMA_MAX=S:SW:SS

optimums/LQ/nlmeans/luma:
	printf '%s\n' '# --corruption=$(OPT_NOISE)' >> $@
	./shader_test --corruption=$(OPT_NOISE) --max=$(OPT_LQ_LUMA_MAX) --optimum=$@ --no-baseline --no-stats images/ >> $@
	printf '\n' >> $@
optimums/LQ/nlmeans/chroma:
	printf '%s\n' '# --corruption=$(OPT_NOISE)' >> $@
	./shader_test --plane=CHROMA --corruption=$(OPT_NOISE) --max=$(OPT_LQ_CHROMA_MAX) --optimum=$@ --no-baseline --no-stats images/ >> $@
	printf '\n' >> $@
optimums/LQ/nlmeans_light/luma:
	printf '%s\n' '# --corruption=$(OPT_NOISE_LIGHT)' >> $@
	./shader_test --corruption=$(OPT_NOISE_LIGHT) --max=$(OPT_LQ_LUMA_MAX) --optimum=$@ --no-baseline --no-stats images/ >> $@
	printf '\n' >> $@
optimums/LQ/nlmeans_light/chroma:
	printf '%s\n' '# --corruption=$(OPT_NOISE_LIGHT)' >> $@
	./shader_test --plane=CHROMA --corruption=$(OPT_NOISE_LIGHT) --max=$(OPT_LQ_CHROMA_MAX) --optimum=$@ --no-baseline --no-stats images/ >> $@
	printf '\n' >> $@
optimums/LQ/nlmeans_sharpen_only/luma:
	printf '%s\n' '# --corruption=$(OPT_BLUR),$(OPT_NOISE) --acorruption=$(OPT_NOISE)' >> $@
	./shader_test --corruption=$(OPT_BLUR),$(OPT_NOISE) --acorruption=$(OPT_NOISE) --max=$(OPT_SHARP_MAX):$(OPT_LQ_LUMA_MAX) --optimum=$@ --no-baseline --no-stats images/ >> $@
	printf '\n' >> $@
optimums/LQ/nlmeans_sharpen_only/chroma:
	printf '%s\n' '# --corruption=$(OPT_BLUR),$(OPT_NOISE) --acorruption=$(OPT_NOISE)' >> $@
	./shader_test --plane=CHROMA --corruption=$(OPT_BLUR),$(OPT_NOISE) --acorruption=$(OPT_NOISE) --max=$(OPT_SHARP_MAX):$(OPT_LQ_CHROMA_MAX) --optimum=$@ --no-baseline --no-stats images/ >> $@
	printf '\n' >> $@
optimums/LQ/nlmeans_light_sharpen_only/luma:
	printf '%s\n' '# --corruption=$(OPT_BLUR),$(OPT_NOISE_LIGHT) --acorruption=$(OPT_NOISE_LIGHT)' >> $@
	./shader_test --corruption=$(OPT_BLUR),$(OPT_NOISE_LIGHT) --acorruption=$(OPT_NOISE_LIGHT) --max=$(OPT_SHARP_MAX):$(OPT_LQ_LUMA_MAX) --optimum=$@ --no-baseline --no-stats images/ >> $@
	printf '\n' >> $@
optimums/LQ/nlmeans_light_sharpen_only/chroma:
	printf '%s\n' '# --corruption=$(OPT_BLUR),$(OPT_NOISE_LIGHT) --acorruption=$(OPT_NOISE_LIGHT)' >> $@
	./shader_test --plane=CHROMA --corruption=$(OPT_BLUR),$(OPT_NOISE_LIGHT) --acorruption=$(OPT_NOISE_LIGHT) --max=$(OPT_SHARP_MAX):$(OPT_LQ_CHROMA_MAX) --optimum=$@ --no-baseline --no-stats images/ >> $@
	printf '\n' >> $@
optimums/LQ/nlmeans_sharpen_denoise/luma:
	printf '%s\n' '# --corruption=$(OPT_BLUR),$(OPT_NOISE)' >> $@
	./shader_test --corruption=$(OPT_BLUR),$(OPT_NOISE) --max=$(OPT_SHARP_MAX):$(OPT_LQ_LUMA_MAX) --optimum=$@ --no-baseline --no-stats images/ >> $@
	printf '\n' >> $@
optimums/LQ/nlmeans_sharpen_denoise/chroma:
	printf '%s\n' '# --corruption=$(OPT_BLUR),$(OPT_NOISE)' >> $@
	./shader_test --plane=CHROMA --corruption=$(OPT_BLUR),$(OPT_NOISE) --max=$(OPT_SHARP_MAX):$(OPT_LQ_CHROMA_MAX) --optimum=$@ --no-baseline --no-stats images/ >> $@
	printf '\n' >> $@
optimums/LQ/nlmeans_light_sharpen_denoise/luma:
	printf '%s\n' '# --corruption=$(OPT_BLUR),$(OPT_NOISE_LIGHT)' >> $@
	./shader_test --corruption=$(OPT_BLUR),$(OPT_NOISE_LIGHT) --max=$(OPT_SHARP_MAX):$(OPT_LQ_LUMA_MAX) --optimum=$@ --no-baseline --no-stats images/ >> $@
	printf '\n' >> $@
optimums/LQ/nlmeans_light_sharpen_denoise/chroma:
	printf '%s\n' '# --corruption=$(OPT_BLUR),$(OPT_NOISE_LIGHT)' >> $@
	./shader_test --plane=CHROMA --corruption=$(OPT_BLUR),$(OPT_NOISE_LIGHT) --max=$(OPT_SHARP_MAX):$(OPT_LQ_CHROMA_MAX) --optimum=$@ --no-baseline --no-stats images/ >> $@
	printf '\n' >> $@
optimums/DEFAULT/nlmeans/luma:
	printf '%s\n' '# --corruption=$(OPT_NOISE)' >> $@
	./shader_test --corruption=$(OPT_NOISE) --max=$(OPT_DEFAULT_LUMA_MAX) --optimum=$@ --no-baseline --no-stats images/ >> $@
	printf '\n' >> $@
optimums/DEFAULT/nlmeans/chroma:
	printf '%s\n' '# --corruption=$(OPT_NOISE)' >> $@
	./shader_test --plane=CHROMA --corruption=$(OPT_NOISE) --max=$(OPT_DEFAULT_CHROMA_MAX) --optimum=$@ --no-baseline --no-stats images/ >> $@
	printf '\n' >> $@
optimums/DEFAULT/nlmeans_light/luma:
	printf '%s\n' '# --corruption=$(OPT_NOISE_LIGHT)' >> $@
	./shader_test --corruption=$(OPT_NOISE_LIGHT) --max=$(OPT_DEFAULT_LUMA_MAX) --optimum=$@ --no-baseline --no-stats images/ >> $@
	printf '\n' >> $@
optimums/DEFAULT/nlmeans_light/chroma:
	printf '%s\n' '# --corruption=$(OPT_NOISE_LIGHT)' >> $@
	./shader_test --plane=CHROMA --corruption=$(OPT_NOISE_LIGHT) --max=$(OPT_DEFAULT_CHROMA_MAX) --optimum=$@ --no-baseline --no-stats images/ >> $@
	printf '\n' >> $@
optimums/DEFAULT/nlmeans_sharpen_only/luma:
	printf '%s\n' '# --corruption=$(OPT_BLUR),$(OPT_NOISE) --acorruption=$(OPT_NOISE)' >> $@
	./shader_test --corruption=$(OPT_BLUR),$(OPT_NOISE) --acorruption=$(OPT_NOISE) --max=$(OPT_SHARP_MAX):$(OPT_DEFAULT_LUMA_MAX) --optimum=$@ --no-baseline --no-stats images/ >> $@
	printf '\n' >> $@
optimums/DEFAULT/nlmeans_sharpen_only/chroma:
	printf '%s\n' '# --corruption=$(OPT_BLUR),$(OPT_NOISE) --acorruption=$(OPT_NOISE)' >> $@
	./shader_test --plane=CHROMA --corruption=$(OPT_BLUR),$(OPT_NOISE) --acorruption=$(OPT_NOISE) --max=$(OPT_SHARP_MAX):$(OPT_DEFAULT_CHROMA_MAX) --optimum=$@ --no-baseline --no-stats images/ >> $@
	printf '\n' >> $@
optimums/DEFAULT/nlmeans_light_sharpen_only/luma:
	printf '%s\n' '# --corruption=$(OPT_BLUR),$(OPT_NOISE_LIGHT) --acorruption=$(OPT_NOISE_LIGHT)' >> $@
	./shader_test --corruption=$(OPT_BLUR),$(OPT_NOISE_LIGHT) --acorruption=$(OPT_NOISE_LIGHT) --max=$(OPT_SHARP_MAX):$(OPT_DEFAULT_LUMA_MAX) --optimum=$@ --no-baseline --no-stats images/ >> $@
	printf '\n' >> $@
optimums/DEFAULT/nlmeans_light_sharpen_only/chroma:
	printf '%s\n' '# --corruption=$(OPT_BLUR),$(OPT_NOISE_LIGHT) --acorruption=$(OPT_NOISE_LIGHT)' >> $@
	./shader_test --plane=CHROMA --corruption=$(OPT_BLUR),$(OPT_NOISE_LIGHT) --acorruption=$(OPT_NOISE_LIGHT) --max=$(OPT_SHARP_MAX):$(OPT_DEFAULT_CHROMA_MAX) --optimum=$@ --no-baseline --no-stats images/ >> $@
	printf '\n' >> $@
optimums/DEFAULT/nlmeans_sharpen_denoise/luma:
	printf '%s\n' '# --corruption=$(OPT_BLUR),$(OPT_NOISE)' >> $@
	./shader_test --corruption=$(OPT_BLUR),$(OPT_NOISE) --max=$(OPT_SHARP_MAX):$(OPT_DEFAULT_LUMA_MAX) --optimum=$@ --no-baseline --no-stats images/ >> $@
	printf '\n' >> $@
optimums/DEFAULT/nlmeans_sharpen_denoise/chroma:
	printf '%s\n' '# --corruption=$(OPT_BLUR),$(OPT_NOISE)' >> $@
	./shader_test --plane=CHROMA --corruption=$(OPT_BLUR),$(OPT_NOISE) --max=$(OPT_SHARP_MAX):$(OPT_DEFAULT_CHROMA_MAX) --optimum=$@ --no-baseline --no-stats images/ >> $@
	printf '\n' >> $@
optimums/DEFAULT/nlmeans_light_sharpen_denoise/luma:
	printf '%s\n' '# --corruption=$(OPT_BLUR),$(OPT_NOISE_LIGHT)' >> $@
	./shader_test --corruption=$(OPT_BLUR),$(OPT_NOISE_LIGHT) --max=$(OPT_SHARP_MAX):$(OPT_DEFAULT_LUMA_MAX) --optimum=$@ --no-baseline --no-stats images/ >> $@
	printf '\n' >> $@
optimums/DEFAULT/nlmeans_light_sharpen_denoise/chroma:
	printf '%s\n' '# --corruption=$(OPT_BLUR),$(OPT_NOISE_LIGHT)' >> $@
	./shader_test --plane=CHROMA --corruption=$(OPT_BLUR),$(OPT_NOISE_LIGHT) --max=$(OPT_SHARP_MAX):$(OPT_DEFAULT_CHROMA_MAX) --optimum=$@ --no-baseline --no-stats images/ >> $@
	printf '\n' >> $@
optimums/DEFAULT/nlmeans_2x/luma:
	printf '%s\n' '# --corruption=$(OPT_2X)' >> $@
	./shader_test --corruption=$(OPT_2X) --max=$(OPT_SHARP_MAX):$(OPT_2X_LUMA_MAX) --optimum=$@ --no-baseline --no-stats images/ >> $@
	printf '\n' >> $@
optimums/HQ/nlmeans/luma:
	printf '%s\n' '# --corruption=$(OPT_NOISE)' >> $@
	./shader_test --corruption=$(OPT_NOISE) --max=$(OPT_DEFAULT_LUMA_MAX) --optimum=$@ --no-baseline --no-stats images/ >> $@
	printf '\n' >> $@
optimums/HQ/nlmeans/chroma:
	printf '%s\n' '# --corruption=$(OPT_NOISE)' >> $@
	./shader_test --plane=CHROMA --corruption=$(OPT_NOISE) --max=$(OPT_DEFAULT_CHROMA_MAX) --optimum=$@ --no-baseline --no-stats images/ >> $@
	printf '\n' >> $@
optimums/HQ/nlmeans_light/luma:
	printf '%s\n' '# --corruption=$(OPT_NOISE_LIGHT)' >> $@
	./shader_test --corruption=$(OPT_NOISE_LIGHT) --max=$(OPT_DEFAULT_LUMA_MAX) --optimum=$@ --no-baseline --no-stats images/ >> $@
	printf '\n' >> $@
optimums/HQ/nlmeans_light/chroma:
	printf '%s\n' '# --corruption=$(OPT_NOISE_LIGHT)' >> $@
	./shader_test --plane=CHROMA --corruption=$(OPT_NOISE_LIGHT) --max=$(OPT_DEFAULT_CHROMA_MAX) --optimum=$@ --no-baseline --no-stats images/ >> $@
	printf '\n' >> $@
optimums/HQ/nlmeans_sharpen_only/luma:
	printf '%s\n' '# --corruption=$(OPT_BLUR),$(OPT_NOISE) --acorruption=$(OPT_NOISE)' >> $@
	./shader_test --corruption=$(OPT_BLUR),$(OPT_NOISE) --acorruption=$(OPT_NOISE) --max=$(OPT_SHARP_MAX):$(OPT_DEFAULT_LUMA_MAX) --optimum=$@ --no-baseline --no-stats images/ >> $@
	printf '\n' >> $@
optimums/HQ/nlmeans_sharpen_only/chroma:
	printf '%s\n' '# --corruption=$(OPT_BLUR),$(OPT_NOISE) --acorruption=$(OPT_NOISE)' >> $@
	./shader_test --plane=CHROMA --corruption=$(OPT_BLUR),$(OPT_NOISE) --acorruption=$(OPT_NOISE) --max=$(OPT_SHARP_MAX):$(OPT_DEFAULT_CHROMA_MAX) --optimum=$@ --no-baseline --no-stats images/ >> $@
	printf '\n' >> $@
optimums/HQ/nlmeans_light_sharpen_only/luma:
	printf '%s\n' '# --corruption=$(OPT_BLUR),$(OPT_NOISE_LIGHT) --acorruption=$(OPT_NOISE_LIGHT)' >> $@
	./shader_test --corruption=$(OPT_BLUR),$(OPT_NOISE_LIGHT) --acorruption=$(OPT_NOISE_LIGHT) --max=$(OPT_SHARP_MAX):$(OPT_DEFAULT_LUMA_MAX) --optimum=$@ --no-baseline --no-stats images/ >> $@
	printf '\n' >> $@
optimums/HQ/nlmeans_light_sharpen_only/chroma:
	printf '%s\n' '# --corruption=$(OPT_BLUR),$(OPT_NOISE_LIGHT) --acorruption=$(OPT_NOISE_LIGHT)' >> $@
	./shader_test --plane=CHROMA --corruption=$(OPT_BLUR),$(OPT_NOISE_LIGHT) --acorruption=$(OPT_NOISE_LIGHT) --max=$(OPT_SHARP_MAX):$(OPT_DEFAULT_CHROMA_MAX) --optimum=$@ --no-baseline --no-stats images/ >> $@
	printf '\n' >> $@
optimums/HQ/nlmeans_sharpen_denoise/luma:
	printf '%s\n' '# --corruption=$(OPT_BLUR),$(OPT_NOISE)' >> $@
	./shader_test --corruption=$(OPT_BLUR),$(OPT_NOISE) --max=$(OPT_SHARP_MAX):$(OPT_DEFAULT_LUMA_MAX) --optimum=$@ --no-baseline --no-stats images/ >> $@
	printf '\n' >> $@
optimums/HQ/nlmeans_sharpen_denoise/chroma:
	printf '%s\n' '# --corruption=$(OPT_BLUR),$(OPT_NOISE)' >> $@
	./shader_test --plane=CHROMA --corruption=$(OPT_BLUR),$(OPT_NOISE) --max=$(OPT_SHARP_MAX):$(OPT_DEFAULT_CHROMA_MAX) --optimum=$@ --no-baseline --no-stats images/ >> $@
	printf '\n' >> $@
optimums/HQ/nlmeans_light_sharpen_denoise/luma:
	printf '%s\n' '# --corruption=$(OPT_BLUR),$(OPT_NOISE_LIGHT)' >> $@
	./shader_test --corruption=$(OPT_BLUR),$(OPT_NOISE_LIGHT) --max=$(OPT_SHARP_MAX):$(OPT_DEFAULT_LUMA_MAX) --optimum=$@ --no-baseline --no-stats images/ >> $@
	printf '\n' >> $@
optimums/HQ/nlmeans_light_sharpen_denoise/chroma:
	printf '%s\n' '# --corruption=$(OPT_BLUR),$(OPT_NOISE_LIGHT)' >> $@
	./shader_test --plane=CHROMA --corruption=$(OPT_BLUR),$(OPT_NOISE_LIGHT) --max=$(OPT_SHARP_MAX):$(OPT_DEFAULT_CHROMA_MAX) --optimum=$@ --no-baseline --no-stats images/ >> $@
	printf '\n' >> $@

readme: result_images/clean.png result_images/noise10.png result_images/gblur0625.png result_images/gblur0625noise10.png result_images/nlmeans_noise10.png result_images/nlmeans_sharpen_denoise_gblur0625noise10.png result_images/nlmeans_sharpen_only_gblur0625noise10.png result_images/nlmeans_sharpen_only_gblur0625.png result_images/fsr_gblur0625noise10.png result_images/fsr_gblur0625.png 

../FSR.glsl:
	curl -L 'https://gist.githubusercontent.com/agyild/82219c545228d70c5604f865ce0b0ce5/raw/2623d743b9c23f500ba086f05b385dcb1557e15d/FSR.glsl' > $@
	sed -i '/^\/\/!WHEN/d' $@ # https://github.com/mpv-player/mpv/issues/10246#issuecomment-1303894445
result_images/clean.png: ../nlmeans.glsl
	ffmpeg -y -i images/anime/mountain_adventurer.webp -vf 'crop=128:128:y=128,format=yuv420p,scale=256:256:flags=neighbor' $@
result_images/noise10.png: ../nlmeans.glsl
	ffmpeg -y -i images/anime/mountain_adventurer.webp -vf 'crop=128:128:y=128,format=yuv420p,$(OPT_NOISE),scale=256:256:flags=neighbor' $@
result_images/gblur0625.png: ../nlmeans.glsl
	ffmpeg -y -i images/anime/mountain_adventurer.webp -vf 'crop=128:128:y=128,format=yuv420p,$(OPT_BLUR),scale=256:256:flags=neighbor' $@
result_images/gblur0625noise10.png: ../nlmeans.glsl
	ffmpeg -y -i images/anime/mountain_adventurer.webp -vf 'crop=128:128:y=128,format=yuv420p,$(OPT_BLUR),$(OPT_NOISE),scale=256:256:flags=neighbor' $@
result_images/nlmeans_noise10.png: ../nlmeans.glsl
	ffmpeg -y -init_hw_device vulkan -i images/anime/mountain_adventurer.webp -vf 'crop=128:128:y=128,format=yuv420p,$(OPT_NOISE),hwupload,libplacebo=w=128:h=128:custom_shader_path=$?,hwdownload,format=yuv420p,scale=256:256:flags=neighbor' $@
result_images/nlmeans_sharpen_denoise_gblur0625noise10.png: ../nlmeans_sharpen_denoise.glsl
	ffmpeg -y -init_hw_device vulkan -i images/anime/mountain_adventurer.webp -vf 'crop=128:128:y=128,format=yuv420p,$(OPT_BLUR),$(OPT_NOISE),hwupload,libplacebo=w=128:h=128:custom_shader_path=$?,hwdownload,format=yuv420p,scale=256:256:flags=neighbor' $@
result_images/nlmeans_sharpen_only_gblur0625noise10.png: ../nlmeans_sharpen_only.glsl
	ffmpeg -y -init_hw_device vulkan -i images/anime/mountain_adventurer.webp -vf 'crop=128:128:y=128,format=yuv420p,$(OPT_BLUR),$(OPT_NOISE),hwupload,libplacebo=w=128:h=128:custom_shader_path=$?,hwdownload,format=yuv420p,scale=256:256:flags=neighbor' $@
result_images/nlmeans_sharpen_only_gblur0625.png: ../nlmeans_sharpen_only.glsl
	ffmpeg -y -init_hw_device vulkan -i images/anime/mountain_adventurer.webp -vf 'crop=128:128:y=128,format=yuv420p,$(OPT_BLUR),hwupload,libplacebo=w=128:h=128:custom_shader_path=$?,hwdownload,format=yuv420p,scale=256:256:flags=neighbor' $@
result_images/fsr_gblur0625noise10.png: ../FSR.glsl
	ffmpeg -y -init_hw_device vulkan -i images/anime/mountain_adventurer.webp -vf 'crop=128:128:y=128,format=yuv420p,$(OPT_BLUR),$(OPT_NOISE),hwupload,libplacebo=w=128:h=128:custom_shader_path=$?,hwdownload,format=yuv420p,scale=256:256:flags=neighbor' $@
result_images/fsr_gblur0625.png: ../FSR.glsl
	ffmpeg -y -init_hw_device vulkan -i images/anime/mountain_adventurer.webp -vf 'crop=128:128:y=128,format=yuv420p,$(OPT_BLUR),hwupload,libplacebo=w=128:h=128:custom_shader_path=$?,hwdownload,format=yuv420p,scale=256:256:flags=neighbor' $@

