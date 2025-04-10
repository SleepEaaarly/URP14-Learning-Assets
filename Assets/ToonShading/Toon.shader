Shader "Custom/Toon"
{
	Properties
	{
		_Color("Color", Color) = (0.5, 0.65, 1, 1)
		_MainTex("Main Texture", 2D) = "white" {}	
		[HDR]
		_AmbientColor ("Ambient Color", Color) = (0.4, 0.4, 0.4, 1.0)
		[HDR]
		_SpecularColor ("Specular Color", Color) = (0.9, 0.9, 0.9, 1)
		_Glossiness ("Glossiness", Float) = 32
		[HDR]
		_RimColor ("Rim Color", Color) = (1,1,1,1)
		_RimAmount ("Rim Amount", Range(0,1)) = 0.716
		_RimExtension ("Rim Extension", Range(0,0.999)) = 0.1
	}
	SubShader
	{
		Tags {"RenderPipeline"="UniversalPipeline"}

		UsePass "Universal Render Pipeline/Lit/ShadowCaster"

		Pass
		{
			Tags {"LightMode"="UniversalForward"}
			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

			CBUFFER_START(UnityPerMaterial)
				float4 _Color;
				float4 _MainTex_ST;
				half4 _AmbientColor;
				float _Glossiness;
				half4 _SpecularColor;
				half4 _RimColor;
				float _RimAmount;
				float _RimExtension;
			CBUFFER_END

			struct Attributes
			{
				float4 positionOS : POSITION;				
				float4 texcoord : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct Varyings
			{
				float4 positionCS : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 worldNormal : TEXCOORD1;
				float3 positionWS : TEXCOORD2;
			};

			TEXTURE2D(_MainTex);
			SAMPLER(sampler_MainTex);
			
			Varyings vert (Attributes IN)
			{
				Varyings OUT;
				OUT.positionCS = TransformObjectToHClip(IN.positionOS.xyz);
				OUT.uv = TRANSFORM_TEX(IN.texcoord, _MainTex);
				OUT.worldNormal = TransformObjectToWorldNormal(IN.normal);
				OUT.positionWS = TransformObjectToWorld(IN.positionOS.xyz);
				return OUT;
			}
			
			half4 frag (Varyings IN) : SV_Target
			{
				Light mainLight = GetMainLight();
				float3 normal = normalize(IN.worldNormal);
				float3 worldLightDir = normalize(TransformObjectToWorldDir(mainLight.direction));
				float3 worldViewDir = GetWorldSpaceNormalizeViewDir(IN.positionWS);
				float3 halfDir = normalize(worldLightDir+worldViewDir);
				float NdotL = dot(worldLightDir, normal);
				float NdotH = dot(halfDir, normal);
				float rimDot = 1 - dot(worldViewDir, normal);

				// half atten = mainLight.distanceAttenuation;
				
				float lightIntensity = smoothstep(0, 0.01, NdotL);
				float diff = lightIntensity;												// Ramp
				float spec = pow(NdotH * lightIntensity, _Glossiness * _Glossiness);	// mul diff to ensure only lighting area will be specular!
				spec = smoothstep(0.005, 0.01, spec);
				float rim = rimDot * pow(saturate(NdotL), 1 - _RimExtension);
				rim = smoothstep(_RimAmount - 0.01, _RimAmount + 0.01, rim);

				half3 albedo = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv).rgb * _Color.rgb;

				half3 diffuse = diff * albedo * mainLight.color;
				half3 ambient = _AmbientColor.rgb * albedo;				// ctrl ambient light manually
				half3 specular = spec * _SpecularColor.rgb * albedo;	// ctrl specular light manually
				half3 rimColor = rim * _RimColor * albedo;

				return half4(ambient + diffuse + specular + rimColor, 1.0f);
			}
			ENDHLSL
		}
	}
	Fallback "Packages/com.unity.render-pipelines.universal/FallbackError"
}