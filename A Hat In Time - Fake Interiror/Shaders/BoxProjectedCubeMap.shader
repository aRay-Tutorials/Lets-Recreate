Shader "Custom/BoxProjectedCubeMap" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0

		_Cube("Cubemap", CUBE) = "" {}
		_BoxSize("Box Size", Vector) = (10, 10, 10)
		_BoxOffset("Box Offset", Vector) = (0, 0, 0)
	}

	SubShader {
		Tags { "RenderType" = "Opaque" }
		LOD 200

		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		struct Input {
			float2 uv_MainTex;
			float3 worldPos;
			float3 worldRefl;
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;

		samplerCUBE _Cube;
		fixed4 _BoxOffset;
		fixed4 _BoxSize;

		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_BUFFER_START(Props)
		
		// put more per-instance properties here
		UNITY_INSTANCING_BUFFER_END(Props)

		fixed4 localCorrect(fixed3 worldRefl, float3 worldPos) {
			float3 boxPosition = _BoxOffset + mul(unity_ObjectToWorld, float4(0, 0, 0, 1));
			float3 boxStart = boxPosition - (_BoxSize / 2.0);

			float3 firstPlaneIntersect = (boxStart + _BoxSize - worldPos) / worldRefl;
			float3 secondPlaneIntersect = (boxStart - worldPos) / worldRefl;

			float3 furthestPlane = (worldRefl > 0.0) ? firstPlaneIntersect : secondPlaneIntersect;
			float3 intersectDistance = min(min(furthestPlane.x, furthestPlane.y), furthestPlane.z);
			float3 intersectPosition = worldPos + worldRefl * intersectDistance;

			return texCUBE(_Cube, intersectPosition - boxPosition);
		}

		void surf(Input IN, inout SurfaceOutputStandard o) {

			fixed4 cubeMapColor = localCorrect(IN.worldRefl, IN.worldPos);

			o.Albedo = cubeMapColor.rgb * _Color;

			// Metallic and smoothness come from slider variables
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = cubeMapColor.a;
		}
		ENDCG
	}

	FallBack "Diffuse"
}
