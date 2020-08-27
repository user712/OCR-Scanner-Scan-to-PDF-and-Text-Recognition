varying vec2 textureCoordinate;

uniform sampler2D inputImageTexture;
uniform float threshold;

const vec3 W = vec3(0.2125, 0.7154, 0.0721);

void main()
{
    vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
    float luminance = dot(textureColor.rgb, W);
    float thresholdResult = step(luminance, threshold);
    vec3 finalColor = abs(thresholdResult - textureColor.rgb);

    gl_FragColor = vec4(vec3(finalColor), textureColor.w);
}
