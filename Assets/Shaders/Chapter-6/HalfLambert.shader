Shader "Shaders/Chapter-6/HalfLambert"
{
    Properties
    {
        _Diffuse("Diffuse", Color) = (1,1,1,1)
    }

    SubShader
    {
        Pass
        {
            Tags
            {
                "LightMode" = "ForwardBase"
            }
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct a2v
            {
                float4 vertex: POSITION;
                float3 normal: NORMAL;
            };

            struct v2f
            {
                float4 vertex: SV_POSITION;
                float3 worldNormal: TEXCOORD0;
            };

            fixed4 _Diffuse;

            v2f vert(a2v v)
            {
                v2f o;

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldNormal = normalize(mul(v.normal, (float3x3)unity_ObjectToWorld));

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                float3 worldNormal = normalize(i.worldNormal);
                float3 worldLight = normalize(_WorldSpaceLightPos0.xyz);

                float3 diffuse = _LightColor0.rgb * _Diffuse.rgb * (0.5 * dot(worldNormal, worldLight) + 0.5);
                fixed3 color = ambient + diffuse;

                return fixed4(color, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}