// Created by inigo quilez - iq/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

extern vec2 iResolution;
extern float iGlobalTime;

vec4 effect( vec4 color, Image texture, vec2 texturePos, vec2 fragCoord)
{
	vec4 pixel = Texel(texture, texturePos );//This is the current pixel color

    vec2 pos = 256.0 * fragCoord.xy/iResolution.x + iGlobalTime;

    vec3 col = vec3(0.0);
    for( int i=0; i<6; i++) 
    {
        vec2 a = floor(pos);
        vec2 b = fract(pos);
        
        vec4 w = fract((sin(a.x*7.0+31.0*a.y + 0.01*iGlobalTime)+vec4(0.035,0.01,0.0,0.7))*13.545317); // randoms
                
        col += w.xyz *                                  // color
               smoothstep(0.45,0.55,w.w) *              // intensity
               sqrt( 4.0*(1.0-b.x)*b.x*(1.0-b.y)*b.y ); // pattern
        
        pos /= 2.0; // lacunarity
      //  pos += iGlobalTime*0.4;
        col /= 2.0;
    }
    
    col *= 5.0;                             // contrast
    col = pow( col, vec3(1.0,1.0,0.7) );    // color shape
    
    pos = fragCoord.xy/iResolution.xy;
    col *= pow( 16.0*pos.x*pos.y*(1.0-pos.x)*(1.0-pos.y), 0.1 );
    
    vec4 fragColor = vec4( col, 1.0 );
	
	return fragColor * color * pixel;
}