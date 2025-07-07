Shader "MFPS/HDRP/ParticleUnlit"
{
    Properties
    {
        _Color("Color Tint", Color) = (1,1,1,1)
        _MainTex("Albedo", 2D) = "white" {}
        _Normal("Normal Map", 2D) = "bump" {}
    }

    HLSLINCLUDE
    // Include HDRP shader core libraries
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariables.hlsl"
    ENDHLSL

    SubShader
    {
        Tags
        {
            "RenderPipeline" = "HDRenderPipeline"
            "Queue" = "Transparent"
            "RenderType" = "Transparent"
        }
        LOD 100

        Pass
        {
            Name "ForwardUnlit"
            Tags { "LightMode" = "ForwardUnlit" }

            Blend One OneMinusSrcAlpha
            ZWrite Off
            Cull Off

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag
            #pragma target 4.5

            TEXTURE2D(_MainTex);        SAMPLER(sampler_MainTex);
            TEXTURE2D(_Normal);         SAMPLER(sampler_Normal);
            float4 _Color;

            struct Attributes
            {
                float3 positionOS : POSITION;
                float2 uv         : TEXCOORD0;
                float4 color      : COLOR;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv         : TEXCOORD0;
                float4 color      : COLOR;
            };

            Varyings Vert(Attributes IN)
            {
                Varyings OUT;
                float3 positionWS = TransformObjectToWorld(IN.positionOS);
                OUT.positionCS = TransformWorldToHClip(positionWS);
                OUT.uv = IN.uv;
                OUT.color = IN.color;
                return OUT;
            }

            float4 Frag(Varyings IN) : SV_Target
            {
                float4 texColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv);
                float4 finalColor = texColor * _Color;
                finalColor.rgb *= IN.color.rgb;
                finalColor.a *= IN.color.a;

                return finalColor;
            }
            ENDHLSL
        }
    }

    FallBack Off
}
