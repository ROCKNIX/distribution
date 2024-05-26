# The gbm functions that might be missing
gbm_check_funcs = [
  'gbm_bo_map',
  'gbm_bo_unmap',
  'gbm_bo_get_offset',
  'gbm_bo_get_plane_count',
  'gbm_device_get_format_modifier_plane_count',
  'gbm_bo_get_handle_for_plane',
  'gbm_bo_get_stride_for_plane',
  'gbm_bo_get_fd_for_plane',
  'gbm_bo_get_modifier',
  'gbm_bo_create_with_modifiers',
  'gbm_bo_create_with_modifiers2',
  'gbm_surface_create_with_modifiers',
  'gbm_surface_create_with_modifiers2',
  'gbm_bo_get_bpp',
  'gbm_format_get_name',
]

libhook_cflags = [
  '-DLIBMALI_SO="libmali.so.' + mali_version.split('.')[0] + '"',
]

libhook_dep = [
  dependency('threads'),
  cc.find_library('dl', required : false),
  dependency('libdrm', version : '>= 2.4.0'),
]

libhook_inc = []

if cc.has_function('gbm_create_device', dependencies : mali)
  # Add hooks to support new GBM APIs
  libhook_inc += include_directories('..' / gbm_headers.keys()[0])
  libhook_cflags += '-DHAS_GBM'
  foreach symbol : gbm_check_funcs
    if cc.has_function(symbol, dependencies : mali)
      libhook_cflags += '-DHAS_' + symbol
    endif
  endforeach
endif

if cc.has_function('eglCreateContext', dependencies : mali)
  # Add hooks to support default winsys
  libhook_inc += include_directories('../include')
  libhook_cflags += '-DHAS_EGL'

  if cc.has_function('wl_egl_window_create', dependencies : mali)
    libhook_cflags += '-DHAS_WAYLAND'
  endif

  if has_x11
    # Add hooks to init X11 threads
    libhook_dep += dependency('x11')
    libhook_cflags += '-DHAS_X11'
  endif
endif

vflag = '-Wl,--export-dynamic'

libhook = shared_library(
  'mali-hook',
  'hook.c',
  c_args : libhook_cflags,
  link_args : [vflag, '-L.', '-lmali-prebuilt'],
  include_directories : libhook_inc,
  dependencies : libhook_dep,
  install : true,
  install_rpath : '$ORIGIN',
  version : mali_version)

libhook_ldflags = ['-L${libdir}', '-lmali-hook']
