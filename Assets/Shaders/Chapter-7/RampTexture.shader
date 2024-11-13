Shader "Shaders/Chapter 7/RampTexture"
{
    Properties
    {
        _Color("Color",Color) = (1,1,1,1)
        _RampTexture("Ramp Texture", 2D) = "white" {}
        _Specular("Specular Color", Color) = (1,1,1,1)
        _Gloss("Gloss",Range(1.0, 256)) = 8.0
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
            #pragma vertex  vert
            #pragma fragment frag

            #include "Lighting.cginc"

            struct a2v
            {
                float4 vertex: POSITION;
                float3 normal: NORMAL;
                float2 texcoord: TEXCOORD0;
            };

            struct v2f
            {
                float4 pos: SV_POSITION;
                float3 worldNormal: TEXCOORD0;
                float3 worldPos: TEXCOORD1;
                float2 uv: TEXCOORD2;
            };

            fixed4 _Color;
            sampler2D _RampTexture;
            float4 _RampTexture_ST;
            fixed4 _Specular;
            half _Gloss;

            v2f vert(a2v v)
            {
                v2f o;

                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.uv = TRANSFORM_TEX(v.texcoord, _RampTexture);

                return o;
            }

            fixed4 frag(v2f i): SV_Target
            {
                fixed3 normal = normalize(i.worldNormal);
                fixed3 lightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                fixed3 light = _LightColor0.rgb;

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;

                fixed halfLambert = 0.5 * dot(lightDir, normal) + 0.5;
                fixed albedo = tex2D(_RampTexture, fixed2(halfLambert, halfLambert)).rgb * _Color.rgb;
                fixed3 diffuse = light * albedo;


                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                fixed3 halfDir = normalize(viewDir + lightDir);
                fixed3 specular = light * _Specular * pow(max(0, dot(halfDir, normal)), _Gloss);

                return fixed4(ambient + diffuse + specular, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}