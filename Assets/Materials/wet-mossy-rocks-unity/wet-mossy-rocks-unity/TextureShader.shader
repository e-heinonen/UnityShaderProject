Shader "Custom/TextureShader"
{
    Properties
    {
        _MainTex("Main Texture", 2D) = "white" {}
        _SecTex("Secondary Texture", 2D) = "red" {}
        _Blend ("Blend Amount", Range(0, 1)) = 0.5
    }
    
    SubShader
    {
        Tags 
        { 
            "RenderType"="Opaque"
            "RenderPipeline" = "UniversalPipeline"
        }
        
        Pass
        {
            Name "OmaPass"
            Tags
            {
                "LightMode" = "UniversalForward"   
            }
            
        HLSLPROGRAM
        
        #pragma vertex Vert
        #pragma fragment Frag

        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        
        struct Attributes
        {
            float3 positionOS : POSITION;
            float2 uv : TEXCOORD0;
        };

        struct Varyings
        {
            float2 uv : TEXCOORD0;
            float4 positionHCS : SV_POSITION;
            float3 positionWS : TEXCOORD1;
        };

        TEXTURE2D(_MainTex);
        TEXTURE2D(_SecTex);
        SAMPLER(sampler_SecTex);
        SAMPLER(sampler_MainTex);
        
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_ST;
        float4 _SecTex_ST;
        half _Blend;
        CBUFFER_END

        Varyings Vert(const Attributes input)
        {
            Varyings output;
            output.uv = input.uv * _MainTex_ST.xy + (_MainTex_ST.zw + _Time);
            
            output.positionHCS = TransformObjectToHClip(input.positionOS);
            output.positionWS = TransformObjectToWorld(input.positionOS);

            return output;
        }
        
        float4 Frag(const Varyings input) : SV_TARGET
        {
            return lerp(SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv),
                SAMPLE_TEXTURE2D(_SecTex, sampler_SecTex, input.uv),
                _Blend);
        }
        
        ENDHLSL
        }

        Pass
        {
            Name "Depth"
            Tags
            {
                "LightMode" = "DepthOnly"
            }

            Cull Back
            ZTest LEqual
            ZWrite On
            ColorMask R

            HLSLPROGRAM
            #pragma vertex DepthVert
            #pragma fragment DepthFrag
            // PITÄÄ OLLA RELATIVE PATH TIEDOSTOON!!!
            #include "Assets/DepthPass.hlsl"
            ENDHLSL
        }

        Pass
        {
            Name "Normals"
            Tags
            {
                "LightMode" = "DepthNormalsOnly"
            }

            Cull Back
            ZTest LEqual
            ZWrite On

            HLSLPROGRAM
            #pragma vertex DepthNormalsVert
            #pragma fragment DepthNormalsFrag

            #include "Assets/DepthNormalsPass.hlsl"
            ENDHLSL
        }
    }
}
