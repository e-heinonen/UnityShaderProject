Shader "Custom/Phong"
{
    Properties
    {
        _Color("Main Color", Color) = (1, 1, 1, 1)
        _MainTex("Main Texture", 2D) = "white" {}
        _NormalMap("Normal Map", 2D) = "bump" {}
        _Shininess("Shininess", Range(1, 512)) = 1
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
            Name "OmaPass2"

            Tags
            {
                "LightMode" = "UniversalForward"
            }

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            // input
            struct Attributes
            {
                float3 positionOS : POSITION;
                float3 normalsOS : NORMAL;
                float4 tangentOS : TANGENT;
                float2 uv : TEXCOORD0;
            };

            // output
            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 positionWS : TEXCOORD0;
                float3 normalWS : TEXCOORD01;
                float3 tangentWS : TEXCOORD2;
                float3 bitangentWS : TEXCOORD3;
                float2 uv : TEXCOORD4;
            };

            TEXTURE2D(_MainTex);
            TEXTURE2D(_NormalMap);
            SAMPLER(sampler_MainTex);
            SAMPLER(sampler_NormalMap);
            
            CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;
            float4 _NormalMap_ST;
                    float4 _Color;
                    float _Shininess;
            CBUFFER_END

            Varyings Vert(const Attributes input)
            {
                Varyings output;

                const VertexPositionInputs position_inputs = GetVertexPositionInputs(input.positionOS);
                const VertexNormalInputs normal_inputs = GetVertexNormalInputs(input.normalsOS, input.tangentOS);

                output.positionHCS = position_inputs.positionCS;
                output.positionWS = position_inputs.positionWS;
                output.normalWS = normal_inputs.normalWS;
                output.tangentWS = normal_inputs.tangentWS;
                output.bitangentWS = normal_inputs.bitangentWS;

                output.uv = input.uv;
                return output;
            }

            float4 BlinnPhong(const Varyings input, float4 color)
            {
                Light mainLight = GetMainLight();
            
                half3 ambientLighting = mainLight.color * 0.1f;
                half3 diffuseLighting = saturate(dot(input.normalWS, mainLight.direction)) * mainLight.color;

                const float3 viewDir = GetWorldSpaceViewDir(input.positionWS);
                const float3 halfwayDir = normalize(mainLight.direction + viewDir);

                const float3 specularLight = pow(saturate(dot(input.normalWS, halfwayDir)), _Shininess) * mainLight.color;

                return float4((ambientLighting + diffuseLighting + specularLight * 10) * color, 1);
            }

            float4 Frag(Varyings input) : SV_TARGET
            {
                const float4 texColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, TRANSFORM_TEX(input.uv, _MainTex));
                const float3 normalTS = UnpackNormal(SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, TRANSFORM_TEX(input.uv, _MainTex)));
                const float3x3 TangentToWorld = float3x3(input.tangentWS, input.bitangentWS, input.normalWS);

                const float3 normalWS = TransformTangentToWorld(normalTS, TangentToWorld, true);
                input.normalWS = normalWS;
                
                return BlinnPhong(input, texColor);
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