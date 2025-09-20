package zombie

@(private)
Camera :: struct {
	x:          f32,
	y:          f32,
	zoom:       f32,
	max_zoom:   f32,
	zoom_speed: f32,
	speed:      f32,
}

@(private)
@(require_results)
camera_init :: proc() -> Camera {
	camera: Camera = Camera {
		x          = 0,
		y          = 0,
		zoom       = 3.0,
		max_zoom   = 3.0, 
		zoom_speed = 4.0,
		speed      = 0.0,
	}

	return camera
}





