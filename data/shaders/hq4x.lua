-- This is a hq4x glsl shader implementation from the mari0 project.
-- http://stabyourself.net/mari0/

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
	name = "hw_hq4x",
	-- Default scale of the window compared to the quest_size.
	default_window_scale = 4,
	-- Set the validity range of the shader.
    --TODO check the real validity range.
	is_shader_valid = video_driver_name == "opengl",
	-- Source of the fragment shader.
	fragment_source = [[
		#define TEXEL(x,y) ]] .. texture_type .. [[(x,y)
		
		uniform ]] .. sampler_type .. [[ solarus_sampler;
		
		const float mx = 0.325;    // start smoothing factor
		const float k = -0.250;    // smoothing decrease factor
		const float max_w = 0.25;
		const float min_w =-0.10;  // min smoothing/sharpening weigth
		const float lum_add = 0.2; // effects smoothing

		vec2 texcoord = gl_TexCoord[0].xy;

		void main()
		{
			float x = 0.5;
			float y = 0.5;

			vec2 dg1 = vec2( x,y);
			vec2 dg2 = vec2(-x,y);
			vec2 sd11 = dg1*0.5;
			vec2 sd21 = dg2*0.5;
	
			vec3 c  = TEXEL(solarus_sampler, texcoord).xyz;
			vec3 i1 = TEXEL(solarus_sampler, texcoord - sd11).xyz; 
			vec3 i2 = TEXEL(solarus_sampler, texcoord - sd21).xyz; 
			vec3 i3 = TEXEL(solarus_sampler, texcoord + sd11).xyz; 
			vec3 i4 = TEXEL(solarus_sampler, texcoord + sd21).xyz; 
			vec3 o1 = TEXEL(solarus_sampler, texcoord - dg1).xyz; 
			vec3 o3 = TEXEL(solarus_sampler, texcoord + dg1).xyz; 
			vec3 o2 = TEXEL(solarus_sampler, texcoord - dg2).xyz;
			vec3 o4 = TEXEL(solarus_sampler, texcoord + dg2).xyz; 

			vec3 dt = vec3(1.0);

			float ko1=dot(abs(o1-c),dt);
			float ko2=dot(abs(o2-c),dt);
			float ko3=dot(abs(o3-c),dt);
			float ko4=dot(abs(o4-c),dt);

			float sd1 = dot(abs(i1-i3),dt);
			float sd2 = dot(abs(i2-i4),dt);

			float w1 = sd2; if (ko3<ko1) w1 = 0.0;
			float w2 = sd1; if (ko4<ko2) w2 = 0.0;
			float w3 = sd2; if (ko1<ko3) w3 = 0.0;
			float w4 = sd1; if (ko2<ko4) w4 = 0.0;

			c = (w1*o1+w2*o2+w3*o3+w4*o4+0.1*c)/(w1+w2+w3+w4+0.1);

			w3 = k/(0.4*dot(c,dt)+lum_add);
	 
			w1 = clamp(w3*sd1+mx,min_w,max_w); 
			w2 = clamp(w3*sd2+mx,min_w,max_w);

			gl_FragColor = vec4(w1*(i1+i3) + w2*(i2+i4) + (1.0-2.0*(w1+w2))*c, 1.0);
		}
	]]
}
