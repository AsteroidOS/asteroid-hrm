cmake_minimum_required(VERSION 3.6.0)

project(
	asteroid-hrm
	VERSION 2.0
	DESCRIPTION "Demo app for heart-rate-monitor bpm retrieval"
)

find_package(ECM REQUIRED NO_MODULE)
find_package(AsteroidApp6 REQUIRED)

set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH} ${ASTEROID_MODULE_PATH})

include(FeatureSummary)
include(GNUInstallDirs)
include(ECMFindQmlModule)
include(Asteroid6CMakeSettings)
include(Asteroid6Translations)

ecm_find_qmlmodule(QtSensors 6.10 REQUIRED)
ecm_find_qmlmodule(org.asteroid.controls 1.0 REQUIRED)
ecm_find_qmlmodule(org.asteroid.utils 1.0 REQUIRED)
ecm_find_qmlmodule(Nemo.KeepAlive 1.1 REQUIRED)

add_subdirectory(src)

configure_file(
	${CMAKE_CURRENT_SOURCE_DIR}/asteroid-hrm.in
	${CMAKE_BINARY_DIR}/asteroid-hrm
	@ONLY
)

install(
	PROGRAMS ${CMAKE_BINARY_DIR}/asteroid-hrm
	DESTINATION ${CMAKE_INSTALL_BINDIR}
)

build_translations(i18n)
generate_desktop(${CMAKE_SOURCE_DIR} asteroid-hrm)

feature_summary(WHAT ALL FATAL_ON_MISSING_REQUIRED_PACKAGES)
