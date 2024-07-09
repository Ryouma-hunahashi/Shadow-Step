Shader "Custom/NewSurfaceShader 1"
{
    SubShader
    {
        Tags { "RenderType" = "Transparent" }

        Stencil {
            Ref 1
            Comp always
            Pass replace
        }
        CGPROGRAM
        #pragma surface surf Lambert alpha

        struct Input {
            fixed3 Albedo;
        };

        void surf(Input IN, inout SurfaceOutput o) {
            o.Albedo = fixed3(1, 1, 1);
            o.Alpha = 0;
        }
        ENDCG
        Pass
        {
            Tags{ "LightMode" = "ShadowCaster" }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_shadowcaster

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                V2F_SHADOW_CASTER;
            };

            v2f vert(appdata v)
            {
                v2f o;
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
        }
    }

        FallBack "Diffuse"
}

