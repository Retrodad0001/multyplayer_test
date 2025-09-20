package zombie

import "base:runtime"
import "core:log"
import "core:mem"

import sdl "vendor:sdl3"

TARGET_FPS: u64 : 60
TARGET_FRAME_TIME: u64 : 1000 / TARGET_FPS


//TODO GameConfig see FPS to struct
//TODO GameState struct
//TODO add planning github
//draw some text and rect en move with lerp
//--> log filelogging and hot reload and debug info with f12
//--> add two rectangles that can be moved by 2 separate players

main :: proc() {
	context.logger = log.create_console_logger()
	log.debug("starting game")

	if (ODIN_DEBUG) {
		log.debug("zombie | Memory tracking enabled")

		track: mem.Tracking_Allocator
		mem.tracking_allocator_init(&track, context.allocator)
		context.allocator = mem.tracking_allocator(&track)

		defer {
			if len(track.allocation_map) > 0 {
				log.error("zombie | **%v allocations not freed: **\n", len(track.allocation_map))
				for _, entry in track.allocation_map {
					log.error("- %v bytes @ %v\n", entry.size, entry.location)
				}
			}
			if len(track.bad_free_array) > 0 {
				log.error("zombie | ** %v incorrect frees: **\n", len(track.bad_free_array))
				for entry in track.bad_free_array {
					log.error("- %p @ %v\n", entry.memory, entry.location)
				}
			}
			mem.tracking_allocator_destroy(&track)
		}
	} else {
		log.debug("zombie | Memory tracking disabled")
	}


	SDL_INIT_FLAGS :: sdl.INIT_VIDEO
	if (sdl.Init(SDL_INIT_FLAGS)) == false {
		log.error("zombie | SDL_Init failed: {}", sdl.GetError())
		if (ODIN_DEBUG) {
			assert(false)
		}
		return
	}
	defer sdl.Quit()

	INIT_WINDOWS_WIDTH :: 1920
	INIT_WINDOWS_HEIGHT :: 1080
	window_flags: sdl.WindowFlags
	window_flags += {.RESIZABLE}
	window: ^sdl.Window = sdl.CreateWindow(
		title = "zombie",
		w = INIT_WINDOWS_WIDTH,
		h = INIT_WINDOWS_HEIGHT,
		flags = window_flags,
	)
	defer sdl.DestroyWindow(window)
	if window == nil {
		log.error("zombie | SDL_CreateWindow failed: {}", sdl.GetError())
		if (ODIN_DEBUG) {
			assert(false)
		}
		return
	}

	should_debug := true
	if (ODIN_DEBUG) {
		log.debug("zombie | GPU debug enabled")
	} else {
		should_debug = false
		log.debug("zombie | GPU debug disabled")
	}

	camera := camera_init()

	last_ticks := sdl.GetTicks()

	GAME_LOOP: for {

		new_ticks := sdl.GetTicks()
		delta_time: f32 = f32(new_ticks - last_ticks) / 1000

		should_quit_game := handle_input(&camera, delta_time)
		if should_quit_game {
			break GAME_LOOP
		}

		//frame rate limiting
		frame_time := sdl.GetTicks() - last_ticks
		if frame_time < TARGET_FRAME_TIME {
			sdl.Delay(u32(TARGET_FRAME_TIME - frame_time))
		}
		last_ticks = new_ticks

		free_all(context.temp_allocator)
	}
}

sdl_log :: proc "c" (
	userdata: rawptr,
	category: sdl.LogCategory,
	priority: sdl.LogPriority,
	message: cstring,
) {
	context = (cast(^runtime.Context)userdata)^
	level: log.Level
	switch priority {
	case .INVALID, .TRACE, .VERBOSE, .DEBUG:
		level = .Debug
	case .INFO:
		level = .Info
	case .WARN:
		level = .Warning
	case .ERROR:
		level = .Error
		if (ODIN_DEBUG) {
			assert(false)
		}
	case .CRITICAL:
		level = .Fatal
	}
	log.logf(level, "SDL {}: {}", category, message)
}