 
 // 

   // Equal Cg / HLSL framework in the vertex shaders 

   // for Sections 7.4.2, 7.4.3, and 7.4.4 

   // 
struct VS_INPUT {
float3 vPosition : POSITION;
float3 vNormal : NORMAL;
float2 TexCoords : TEXCOORD0;

  // This member is needed in Section 7.4.4     float3 vObjectPosition : TEXCOORD1;
};

struct VS_OUTPUT {
float4 vPosition : POSITION;
float4 vDiffuse : COLOR;
float2 TexCoords : TEXCOORD0;
};
struct VS_TEMP {
float3 vPosition;
float3 vNormal;
};

float4x4 mWorldViewProjMatrix;
float4 vLight;
float fObjectHeight;

VS_OUTPUT main(const VS_INPUT v) {
VS_OUTPUT out;
VS_TEMP temp;

  // Animate the upper vertices and normals only     
  if (v.TexCoords.y <= 0.1) {

      // Or:
      if(v.TexCoords.y >= 0.9)     
      // A N I M A T I O N  (to world space)     
      // Insert the code for 7.4.2, 7.4.3, or 7.4.4     . . .  
      // <- Code for our different animation methods   } 

  // Output stuff   out.vPosition = mul(float4(temp.vPosition, 1),                       mWorldViewProjMatrix);
out.vDiffuse = dot(vLight, temp.vNormal);
out.TexCoords = v.TexCoords;
return out;
}

 // 
   // Animation per Cluster of Grass Objects (7.4.2) 
   // 
float3 vClusterTranslation; // Calculated on CPU 
VS_OUTPUT main(const VS_INPUT v) {
// A N I M A T I O N (to world space)     
// Here comes the code for 7.4.2  
temp.vPosition = v.vPosition + vClusterTranslation;
temp.vNormal = normalize(v.vNormal * fObjectHeight + vClusterTranslation);
}
