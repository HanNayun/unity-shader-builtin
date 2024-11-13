Shader "Shaders/Chapter 8/AlphaBlendZWriteOn"
{
    Properties
    {
        _Color("Color", Color) = (1, 1, 1, 1)
        _MainTexture("MainTexture", 2D) = "white" { }
        _AlphaScale("AlphaScale", Range(0, 1.0)) = 0.5
    }
    SubShader
    {
        Tags
        {
            "Queue" = "Transparent"
            "IgnoreProjector" = "True"
            "RenderType" = "Transparent"
        }
        
        Pass
        {
            ZWrite On
            ColorMask 0
        }

        Pass
        {
            Tags
            {
                "LightMode" = "ForwardBase"
            }
            
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD0;
                float3 pos : TEXCOORD1;
                float2 uv : TEXCOORD2;
            };

            float4 _Color;
            sampler2D _MainTexture;
            float4 _MainTexture_ST;
            fixed _AlphaScale;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.vertex);
                o.pos = mul(unity_ObjectToWorld, v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTexture);
                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                fixed4 texColor = tex2D(_MainTexture, i.uv);

                fixed4 albedo = texColor * _Color;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo.rgb;

                fixed3 normal = normalize(i.normal);
                fixed3 lightDir = UnityWorldSpaceLightDir(i.pos);
                fixed3 diffuse = max(0, dot(normal, lightDir)) * albedo.rgb * _LightColor0.rgb;

                return fixed4(ambient + diffuse, texColor.a * _AlphaScale);
            }
            ENDCG
        }
    }
}