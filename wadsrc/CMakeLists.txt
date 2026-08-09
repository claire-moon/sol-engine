add_pk3(sol-engine.pk3 ${CMAKE_CURRENT_SOURCE_DIR}/static)

generate_language_files(sol-engine_pk3 static/language.csv ENGINE)

# Insert AppStream data into sol-engine.pk3 for release notes.
add_custom_target(
	copy_metadata
	COMMAND ${CMAKE_COMMAND} -E copy
		"${CMAKE_CURRENT_SOURCE_DIR}/../src/posix/freedesktop/io.github.claire_moon.solengine.metainfo.xml"
		"${CMAKE_CURRENT_SOURCE_DIR}/static/meta.xml"
	COMMAND ${CMAKE_COMMAND} -E copy
		"${CMAKE_CURRENT_SOURCE_DIR}/../CONTRIBUTORS"
		"${CMAKE_CURRENT_SOURCE_DIR}/static/contributors.txt"
)
add_dependencies(sol-engine_pk3 copy_metadata)
add_custom_command(
	TARGET sol-engine_pk3
	POST_BUILD
	COMMAND ${CMAKE_COMMAND} -E remove
		"${CMAKE_CURRENT_SOURCE_DIR}/static/meta.xml"
	COMMAND ${CMAKE_COMMAND} -E remove
		"${CMAKE_CURRENT_SOURCE_DIR}/static/contributors.txt"
)
