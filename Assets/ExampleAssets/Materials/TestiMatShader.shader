Shader "Custom/TestiMatShader"
{
    Properties
    {
        _Color("Color", Color) = (1, 1, 1, 1)
        _InflateAmount("Inflate Amount", Range(-0.5, 1)) = 0
    }
    
    SubShader
    {
        Tags 
        { 
            "RenderType"="Opaque"
            "RenderPipeline" = "UniversalPipeline"
            "Queue" = "Geometry"
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
            float3 normal : NORMAL;
        };

        struct Varyings
        {
            float4 positionHCS : SV_POSITION;
            float3 positionWS : TEXCOORD0;
        };

        CBUFFER_START(UnityPerMaterial)
        float4 _Color;
        float _InflateAmount;
        CBUFFER_END

        Varyings Vert(const Attributes input)
        {
            Varyings output;
            const float3 vertex_pos = input.positionOS + input.normal * _InflateAmount;
            
            output.positionHCS = TransformObjectToHClip(vertex_pos);
            output.positionWS = TransformObjectToWorld(vertex_pos);

            return output;
        }

        float4 Frag(const Varyings input) : SV_TARGET
        {
            return _Color * clamp(input.positionWS.x, 0, 1);
        }
        
        ENDHLSL
        }
    }
}
