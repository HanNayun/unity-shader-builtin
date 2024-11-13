#ifndef LIGHT_CALCULATOR
#define LIGHT_CALCULATOR

#include <HLSLSupport.cginc>

fixed3 Diffuse(fixed3 normal, fixed3 lightDir, fixed3 diffuseColor, fixed3 light)
{
    return max(0, dot(normal, lightDir)) * light * diffuseColor;
}

fixed3 Specular(fixed3 normal, fixed3 viewDir, fixed3 lightDir, float gloss, fixed3 specularColor, fixed3 light)
{
    fixed3 half_dir = normalize(viewDir + lightDir);
    return pow(max(0, dot(normal, half_dir)), gloss) * specularColor * light;
}
#endif
