-- This is a edge-detection glsl shader implementation from the bsnes project.
-- https://gitorious.org/bsnes/xml-shaders

video_driver_name = select(1, ...) -- Get the rendering driver name.
shading_language_version = select(2, ...) -- Get the shading language version.
sampler_type = select(3, ...) -- Get the type of samplers to use.

-- Get the type of texture2D function to use.
texture_type = "texture2D"
if (sampler_type == "sampler2DRect") then
	texture_type = "texture2DRect"	
end

videomode {
	-- Name of the video mode associated to the shader.
	name = "edge-detection",
	-- Default scale of the window compared to the quest_size.
	default_window_scale = 2,
	-- Set the validity range of the shader.
    --TODO check the real validity range.
	is_shader_valid = video_driver_name == "opengl",
	-- Source of the vertex shader.
	vertex_source = [[
     	void main()
     	{
			float x = 0.5;
			float y = 0.5;
			vec2 dg1 = vec2( x, y);
			vec2 dg2 = vec2(-x, y);
			vec2 dx = vec2(x, 0.0);
			vec2 dy = vec2(0.0, y);
 
			gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
			gl_TexCoord[0] = gl_MultiTexCoord0;
			gl_TexCoord[1].xy = gl_TexCoord[0].xy - dg1;
			gl_TexCoord[1].zw = gl_TexCoord[0].xy - dy;
			gl_TexCoord[2].xy = gl_TexCoord[0].xy - dg2;
			gl_TexCoord[2].zw = gl_TexCoord[0].xy + dx;
			gl_TexCoord[3].xy = gl_TexCoord[0].xy + dg1;
			gl_TexCoord[3].zw = gl_TexCoord[0].xy + dy;
			gl_TexCoord[4].xy = gl_TexCoord[0].xy + dg2;
			gl_TexCoord[4].zw = gl_TexCoord[0].xy - dx;
		}
	]],
	-- Source of the fragment shader.
	fragment_source = [[
		#define TEXEL(x,y) ]] .. texture_type .. [[(x,y)
		
     	uniform ]] .. sampler_type .. [[ solarus_sampler;
     	
		vec3 grayscale(vec3 color)
     	{
			return vec3(dot(color, vec3(0.3, 0.59, 0.11)));
     	}
 
     	void main ()
     	{
			vec3 c00 = TEXEL(solarus_sampler, gl_TexCoord[1].xy).xyz;
			vec3 c02 = TEXEL(solarus_sampler, gl_TexCoord[4].xy).xyz;
			vec3 c11 = TEXEL(solarus_sampler, gl_TexCoord[0].xy).xyz;
			vec3 c20 = TEXEL(solarus_sampler, gl_TexCoord[2].xy).xyz;
			vec3 c22 = TEXEL(solarus_sampler, gl_TexCoord[3].xy).xyz;

			vec2 tex = gl_TexCoord[0].xy;
			vec2 texsize = vec2(1.0);
 
			vec3 first = mix(c00, c20, fract(tex.x * texsize.x + 0.5));
			vec3 second = mix(c02, c22, fract(tex.x * texsize.x + 0.5));
 
			vec3 res = mix(first, second, fract(tex.y * texsize.y + 0.5));
			vec4 final = vec4(5.0 * grayscale(abs(res - c11)), 1.0);
			gl_FragColor = clamp(final, 0.0, 1.0);
     }
	]]
}
