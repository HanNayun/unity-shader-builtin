#ifndef SHADER_IO_STRUCTS
#define SHADER_IO_STRUCTS

struct a2v
{
    float4 pos: POSITION;
    float3 normal: NORMAL;
    float4 tangent: TANGENT;
    float4 texcoord: TEXCOORD0;
};

struct v2f
{
    float4 pos: SV_POSITION;
    float3 worldNormal: TEXCOORD0;
    float3 worldPos: TEXCOORD1;
    float2 uv: TEXCOORD2;
    fixed3 color: COLOR;
};
#endif
