// Upgrade NOTE: replaced '_LightMatrix0' with 'unity_WorldToLight'

Shader "Shaders/Chapter 9/ForwardRendering"
{
    Properties
    {
        _Diffuse("Diffuse", Color) = (1,1,1,1)
        _Specular("Specular", Color)= ( 1,1,1,1)
        _Gloss("Gloss", Range(8.0, 256)) = 20
    }
    SubShader
    {
        Pass // Base Pass
        {
            Tags
            {
                "LightMode" = "ForwardBase"
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase


            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "../Utils/LightCalculator.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normla : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 normal :TEXCOORD0;
                float3 pos :TEXCOORD1;
            };

            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = normalize(UnityObjectToWorldNormal(v.vertex));
                o.pos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                fixed3 lightDir = normalize(UnityWorldSpaceLightDir(i.pos));
                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.pos));
                fixed3 light = _LightColor0.rgb;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;
                fixed3 diffuse = Diffuse(i.normal, lightDir, _Diffuse, light);
                fixed3 specular = Specular(i.normal, viewDir, lightDir, _Gloss, _Specular, light);
                fixed atten = 1.0;
                return fixed4(ambient + atten * (diffuse + specular), 1.0);
            }
            ENDCG
        }

        Pass // For pixel light
        {
            Tags
            {
                "LightMode" = "ForwardAdd"
            }
            Blend One One

            CGPROGRAM
            #pragma multi_compile_fwdadd
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "Lighting.cginc"

            #include "../Utils/LightCalculator.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normla : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 normal :TEXCOORD0;
                float3 pos :TEXCOORD1;
            };

            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = normalize(UnityObjectToWorldNormal(v.vertex));
                o.pos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                    #ifdef USING_DIRECTIONAL_LIGHT
                fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                #else
                fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz - i.pos);
                #endif

                #ifdef USING_DIRECTIONAL_LIGHT
                fixed atten = 1.0;
                #else
                float3 lightCoord = mul(unity_WorldToLight, float4(i.pos, 1)).xyz;
                fixed atten = tex2D(_LightTexture0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
                #endif

                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.pos));
                fixed3 light = _LightColor0.rgb;
                fixed3 diffuse = Diffuse(i.normal, lightDir, _Diffuse, light);
                fixed3 specular = Specular(i.normal, viewDir, lightDir, _Gloss, _Specular, light);
                return fixed4(atten * (diffuse + specular), 1.0);   
            }
            ENDCG

        }
    }
    FallBack "Diffuse"
}