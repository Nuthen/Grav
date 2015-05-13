vec4 resultCol;
vec4 textureCol;

extern vec2 stepSize;

vec4 effect( vec4 col, Image texture, vec2 texturePos, vec2 screenPos )
{
	//vec4 pixel = Texel(texture, texturePos );//This is the current pixel color
	vec4 newCol = vec4(0.0);
	
    newCol += 5*texture2D( texture, texturePos);
	newCol *= col;
	
	newCol += -1*texture2D( texture, texturePos + vec2(-stepSize.x, 0.0f));
	newCol += -1*texture2D( texture, texturePos + vec2(stepSize.x, 0.0f));
	newCol += -1*texture2D( texture, texturePos + vec2(0.0f, -stepSize.y));
	newCol += -1*texture2D( texture, texturePos + vec2(0.0f, stepSize.y));
	
	//newCol += -1*texture2D( texture, texturePos + vec2(-stepSize.x, stepSize.y));
	//newCol += -1*texture2D( texture, texturePos + vec2(stepSize.x, -stepSize.y));
	//newCol += -1*texture2D( texture, texturePos + vec2(-stepSize.x, -stepSize.y));
	//newCol += -1*texture2D( texture, texturePos + vec2(stepSize.x, stepSize.y));
	
	newCol.a = 1.0;
	
    return newCol;
}