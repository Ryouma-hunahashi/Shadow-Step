#ifndef SAMPLE_OVERLAY_INCLUDED
#define SAMPLE_OVERLAY_INCLUDED

void _OverLay_float(
in float3 baseColor,
in float3 blendColor,
in float threshold,
out float3 overlayColor
)
{
    float stepResult;
    // R’l‚ÌŒvŽZ
    stepResult = step(threshold, baseColor.r);
    baseColor.r *= 255;
    blendColor.r *= 255;
    overlayColor.r = (1 - stepResult) * baseColor.r * blendColor.r * 2.0f / 65025.0f + stepResult * (2.0f * (baseColor.r + blendColor.r - baseColor.r * blendColor.r / 255.0f) - 255.0f)/255.0f;
    // G’l‚ÌŒvŽZ
    stepResult = step(threshold, baseColor.g);
    baseColor.g *= 255;
    blendColor.g *= 255;
    overlayColor.g = (1 - stepResult) * baseColor.g * blendColor.g * 2.0f / 65025.0f + stepResult * (2.0f * (baseColor.g + blendColor.g - baseColor.g * blendColor.g / 255.0f) - 255.0f)/255.0f;
    // B’l‚ÌŒvŽZ
    stepResult = step(threshold, baseColor.b);
    baseColor.b *= 255;
    blendColor.b *= 255;
    overlayColor.b = (1 - stepResult) * baseColor.b * blendColor.b * 2.0f / 65025.0f + stepResult * (2.0f * (baseColor.b + blendColor.b - baseColor.b * blendColor.b / 255.0f) - 255.0f)/255.0f;

}

#endif
