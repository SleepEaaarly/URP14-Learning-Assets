Shader "Custom/PixelizeShader"
{
    Properties
    {
        // _MainTex ("Texture", 2D) = "white" {}
        _BlitTexture ("Texture", 2D) = "white" {}
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline"="UniversalPipeline"}

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            // #include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float2 uv : TEXCOORD0;
                float4 positionCS : SV_POSITION;
            };

            TEXTURE2D(_BlitTexture);
            float4 _BlitTexture_TexelSize;
            float4 _BlitTexture_ST;

            SamplerState sampler_point_clamp;

            uniform float2 _BlockCount;
            uniform float2 _BlockSize;
            uniform float2 _HalfBlockSize;

            Varyings vert (Attributes IN)
            {
                Varyings OUT;
                OUT.positionCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv = TRANSFORM_TEX(IN.uv, _BlitTexture);
                return OUT;
            }

            half4 frag (Varyings IN) : SV_Target
            {
                // sample the texture
                float2 blockPos = floor(IN.uv * _BlockCount);\
                float2 blockCenter = blockPos * _BlockSize + _HalfBlockSize;

                half4 col = SAMPLE_TEXTURE2D(_BlitTexture, sampler_point_clamp, blockCenter);

                return col;
            }
            ENDHLSL
        }
    }
}
