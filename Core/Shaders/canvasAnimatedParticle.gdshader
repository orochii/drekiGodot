// NOTE: Shader automatically converted from Godot Engine 4.1.1.stable's CanvasItemMaterial.

shader_type canvas_item;
render_mode blend_mix;
uniform int particles_anim_h_frames;
uniform int particles_anim_v_frames;
uniform int particles_start_frame;
uniform int particles_end_frame;
uniform bool particles_anim_loop;

void vertex() {
	float h_frames = float(particles_anim_h_frames);
	float v_frames = float(particles_anim_v_frames);
	VERTEX.xy /= vec2(h_frames, v_frames);
	float particle_total_frames = float(particles_anim_h_frames * particles_anim_v_frames);
	float particle_anim_length = float(particles_end_frame - particles_start_frame);
	float particle_start = float(particles_start_frame);
	float particle_frame = particle_start + floor(INSTANCE_CUSTOM.z * particle_anim_length);
	if (!particles_anim_loop) {
		particle_frame = clamp(particle_frame, particle_start, float(particles_end_frame));
	} else {
		particle_frame = particle_start + mod(particle_frame-particle_start, particle_anim_length);
	}
	UV /= vec2(h_frames, v_frames);
	UV += vec2(mod(particle_frame, h_frames) / h_frames, floor((particle_frame + 0.5) / h_frames) / v_frames);
}
