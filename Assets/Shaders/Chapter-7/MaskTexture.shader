Shader "Shaders/Chapter 7/MaskTexture"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _BumpMap("Bump Map", 2D) = "white" {}
        _BumpScale("BumpScale", Range(0.0, 1.0)) = 1.0
        _SpecularMask("SpecularMask", 2D) = "white" {}
        _SpecularScale("SpecularScale", Range(0.0, 1.0)) = 1.0
        _Specular("Specular", Color) = (1, 1, 1, 1)
        _Gloss("Gloss", Range(1.0, 256)) = 8
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

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 lightDir : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
            };

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            fixed _BumpScale;
            sampler2D _SpecularMask;
            fixed _SpecularScale;
            fixed4 _Specular;
            half _Gloss;

            v2f vert(appdata v)
            {
                v2f o;

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;

                TANGENT_SPACE_ROTATION;
                o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex));
                o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex));

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo.rgb;

                fixed3 light = _LightColor0.rgb;
                fixed3 lightDir = normalize(i.lightDir);
                fixed3 normal = UnpackNormal(tex2D(_BumpMap, i.uv));
                normal.xy *= _BumpScale;
                normal.z = sqrt(1 - saturate(dot(normal.xy, normal.xy)));
                fixed3 diffuse = light * albedo * max(0, dot(normal, lightDir));

                fixed specularMask = tex2D(_SpecularMask, i.uv).r * _SpecularScale;
                fixed3 halfDir = normalize(i.viewDir + i.lightDir);
                fixed3 specular = light * _Specular.rgb * specularMask * pow(max(0, dot(halfDir, normal)), _Gloss);

                return fixed4(ambient + diffuse + specular, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}