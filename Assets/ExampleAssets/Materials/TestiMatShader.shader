Shader "Custom/TestiMatShader"
{
    Properties
    {
        _Color("Color", Color) = (1, 1, 1, 1)
        _Amount("Amount", Range(-0.5, 1)) = 0
        [KeywordEnum(Object, World, View)]
        _Space("Space", Float) = 0
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
        
        #pragma shader_feature_local _SPACE_OBJECT _SPACE_WORLD _SPACE_VIEW
        
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
        float _Amount;
        CBUFFER_END

        Varyings Vert(const Attributes input)
        {
            Varyings output;
            
            #if _SPACE_OBJECT
            const float3 vertex_pos = input.positionOS + float3(0, 1, 0) * _Amount;
            output.positionHCS = TransformObjectToHClip(vertex_pos);
            
            #elif _SPACE_WORLD
            const float3 vertex_pos = TransformObjectToWorld(input.positionOS) + float3(0, 1, 0) * _Amount;
            output.positionHCS = TransformWorldToHClip(vertex_pos);
            
            #elif _SPACE_VIEW
            const float3 vertex_pos = TransformObjectToWorld(input.positionOS);
            const float3 view_pos = TransformWorldToView(vertex_pos) + float3(0, 1, 0) * _Amount;
            output.positionHCS = TransformWViewToHClip(view_pos);
            
            #endif

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
