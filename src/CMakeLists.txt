add_library(asteroid-hrm main.cpp)
set_target_properties(asteroid-hrm PROPERTIES PREFIX "")

asteroid_app_qml_module(asteroid-hrm
	main.qml
)

target_link_libraries(
	asteroid-hrm
	PUBLIC
		Asteroid::AsteroidApp6
)

install(
	TARGETS asteroid-hrm
	DESTINATION ${CMAKE_INSTALL_LIBDIR}
)
