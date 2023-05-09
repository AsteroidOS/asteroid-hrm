add_library(asteroid-hrm main.cpp resources.qrc)
set_target_properties(asteroid-hrm PROPERTIES PREFIX "")

target_link_libraries(asteroid-hrm PUBLIC
	AsteroidApp)

install(TARGETS asteroid-hrm
	DESTINATION ${CMAKE_INSTALL_LIBDIR})
