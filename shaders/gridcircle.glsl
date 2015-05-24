extern vec2 resolution;
extern float dist;
extern vec2 mousePos;

vec4 effect( vec4 color, Image texture, vec2 texturePos, vec2 screenPos)
{
	//vec4 pixel = Texel(texture, texturePos);//This is the current pixel color
	
	//float alpha = 1;
	
	color.w = pow(1-(distance(screenPos, mousePos)/dist), .1);
	
	return color;
}