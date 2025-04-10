Shader "Custom/PixelizeShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline"="UniversalPipeline"}

        Cull Off ZWrite Off ZTest Always

        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"

        float2 _BlockCount;
        float2 _BlockSize;
        float2 _HalfBlockSize;

        half4 Frag (Varyings IN) : SV_Target
        {
            // sample the texture
            float2 blockPos = floor(IN.texcoord * _BlockCount);
            float2 blockCenter = blockPos * _BlockSize + _HalfBlockSize;

            half4 col = SAMPLE_TEXTURE2D(_BlitTexture, sampler_PointClamp, blockCenter);
            // return col;
            return col;
        }


        ENDHLSL

        Pass
        {
            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag

            ENDHLSL
        }
    }
    FallBack Off
}


