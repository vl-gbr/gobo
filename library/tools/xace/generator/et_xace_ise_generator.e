indexing

	description:

		"Ace file generators for ISE Eiffel"

	library:    "Gobo Eiffel Tools Library"
	author:     "Andreas Leitner <nozone@sbox.tugraz.at>"
	copyright:  "Copyright (c) 2001, Andreas Leitner and others"
	license:    "Eiffel Forum Freeware License v1 (see forum.txt)"
	date:       "$Date$"
	revision:   "$Revision$"

class ET_XACE_ISE_GENERATOR 

inherit

	ET_XACE_GENERATOR

creation

	make

feature -- Access

	ace_filename: STRING is "ise.ace"
			-- Name of generated Ace file

feature -- Output

	generate (a_system: ET_XACE_UNIVERSE) is
			-- Generate a new Ace file from `a_system'.
		local
			a_file: KL_OUTPUT_FILE
			an_externals: ET_XACE_EXTERNALS
		do
			!! a_file.make (ace_filename)
			a_file.open_write
			if a_file.is_open_write then
				an_externals := a_system.externals
				if an_externals /= Void then
					an_externals := an_externals.cloned_externals
				end
				a_system.merge_externals
				print_ace_file (a_system, a_file)
				a_file.close
				a_system.set_externals (an_externals)
			else
				error_handler.report_cannot_write_file_error (ace_filename)
			end
		end

feature {NONE} -- Output

	print_ace_file (a_system: ET_XACE_UNIVERSE; a_file: KL_OUTPUT_FILE) is
			-- Print Ace `a_system' to `a_file'.
		require
			a_system_not_void: a_system /= Void
			system_name_not_void: a_system.system_name /= Void
			root_class_name_not_void: a_system.root_class_name /= Void
			creation_procedure_name_not_void: a_system.creation_procedure_name /= Void
			a_file_not_void: a_file /= Void
			a_file_open_write: a_file.is_open_write
		local
			an_option: ET_XACE_OPTIONS
			a_clusters: ET_XACE_CLUSTERS
			an_external: ET_XACE_EXTERNALS
		do
			a_file.put_string ("system")
			a_file.put_new_line
			a_file.put_new_line
			print_indentation (1, a_file)
			a_file.put_string (a_system.system_name)
			a_file.put_new_line
			a_file.put_new_line
			a_file.put_string ("root")
			a_file.put_new_line
			a_file.put_new_line
			print_indentation (1, a_file)
			a_file.put_string (a_system.root_class_name)
			a_file.put_string (": %"")
			a_file.put_string (a_system.creation_procedure_name)
			a_file.put_character ('%"')
			a_file.put_new_line
			a_file.put_new_line
			a_file.put_string ("default")
			a_file.put_new_line
			a_file.put_new_line
			print_indentation (1, a_file)
			a_file.put_string ("console_application (yes)")
			a_file.put_new_line
			an_option := a_system.options
			if an_option /= Void then
				print_options (an_option, 1, a_file)
			end
			a_file.put_new_line
			a_file.put_string ("cluster")
			a_file.put_new_line
			a_file.put_new_line
			a_clusters := a_system.clusters
			if a_clusters /= Void then
				print_clusters (a_clusters, a_file)
				a_file.put_new_line
			end
			an_external := a_system.externals
			if
				an_external /= Void and then
				(an_external.has_include_directories or an_external.has_link_libraries)
			then
				a_file.put_string ("external")
				a_file.put_new_line
				a_file.put_new_line
				print_include_directories (an_external.include_directories, a_file)
				print_link_libraries (an_external.link_libraries, a_file)
			end
			a_file.put_string ("end")
			a_file.put_new_line
		end

	print_options (an_option: ET_XACE_OPTIONS; indent: INTEGER; a_file: KL_OUTPUT_FILE) is
			-- Print `an_option' to `a_file'.
		require
			an_option_not_void: an_option /= Void
			indent_positive: indent >= 0
			a_file_not_void: a_file /= Void
			a_file_open_write: a_file.is_open_write
		local
			no_assertion: BOOLEAN
		do
			if an_option.has_optimize.is_true then
				print_indentation (indent, a_file)
				a_file.put_string ("assertion (no)")
				a_file.put_new_line
			elseif an_option.has_optimize.is_false then
				print_indentation (indent, a_file)
				a_file.put_string ("assertion (all)")
				a_file.put_new_line
			else
				no_assertion := True
				if an_option.has_check.is_true then
					print_indentation (indent, a_file)
					a_file.put_string ("assertion (check)")
					a_file.put_new_line
					no_assertion := False
				elseif an_option.has_check.is_undefined then
					no_assertion := False
				end
				if an_option.has_loop.is_true then
					print_indentation (indent, a_file)
					a_file.put_string ("assertion (loop)")
					a_file.put_new_line
					no_assertion := False
				elseif an_option.has_loop.is_undefined then
					no_assertion := False
				end
				if an_option.has_invariant.is_true then
					print_indentation (indent, a_file)
					a_file.put_string ("assertion (invariant)")
					a_file.put_new_line
					no_assertion := False
				elseif an_option.has_invariant.is_undefined then
					no_assertion := False
				end
				if an_option.has_ensure.is_true then
					print_indentation (indent, a_file)
					a_file.put_string ("assertion (ensure)")
					a_file.put_new_line
					no_assertion := False
				elseif an_option.has_ensure.is_undefined then
					no_assertion := False
				end
				if an_option.has_require.is_true then
					print_indentation (indent, a_file)
					a_file.put_string ("assertion (require)")
					a_file.put_new_line
					no_assertion := False
				elseif an_option.has_require.is_undefined then
					no_assertion := False
				end
				if no_assertion then
					print_indentation (indent, a_file)
					a_file.put_string ("assertion (no)")
					a_file.put_new_line
				end
			end
		end

	print_clusters (a_clusters: ET_XACE_CLUSTERS; a_file: KL_OUTPUT_FILE) is
			-- Print `a_clusters' to `a_file'.
		require
			a_clusters_not_void: a_clusters /= Void
			a_file_not_void: a_file /= Void
			a_file_open_write: a_file.is_open_write
		local
			i, nb: INTEGER
			cluster_list: DS_ARRAYED_LIST [ET_XACE_CLUSTER]
		do
			cluster_list := a_clusters.clusters
			nb := cluster_list.count
			from i := 1 until i > nb loop
				print_cluster (cluster_list.item (i), a_file)
				i := i + 1
			end
		end

	print_cluster (a_cluster: ET_XACE_CLUSTER; a_file: KL_OUTPUT_FILE) is
			-- Print `a_cluster' to `a_file'.
		require
			a_cluster_not_void: a_cluster /= Void
			a_file_not_void: a_file /= Void
			a_file_open_write: a_file.is_open_write
		local
			an_option: ET_XACE_OPTIONS
			subclusters: ET_XACE_CLUSTERS
			need_end_keyword: BOOLEAN
			an_externals: ET_XACE_EXTERNALS
			a_cursor: DS_LINKED_LIST_CURSOR [ET_XACE_EXPORTED_CLASS]
		do
			if not a_cluster.is_abstract then
				print_indentation (1, a_file)
				a_file.put_string (a_cluster.full_name ('_'))
				a_file.put_string (": %"")
				a_file.put_string (a_cluster.full_pathname)
				a_file.put_character ('%"')
				a_file.put_new_line
				an_option := a_cluster.options
				if an_option /= Void then
					print_indentation (2, a_file)
					a_file.put_string ("default")
					a_file.put_new_line
					print_options (an_option, 3, a_file)
					a_file.put_new_line
					need_end_keyword := True
				end
				an_externals := a_cluster.externals
				if an_externals /= Void and then not an_externals.exported_classes.is_empty then
					print_indentation (2, a_file)
					a_file.put_string ("visible")
					a_file.put_new_line
					a_cursor := an_externals.exported_classes.new_cursor
					from a_cursor.start until a_cursor.after loop
						print_exported_class (a_cursor.item, 3, a_file)
						a_cursor.forth
					end
					need_end_keyword := True
				end
				if need_end_keyword then
					print_indentation (2, a_file)
					a_file.put_string ("end")
					a_file.put_new_line
				end
			end
			subclusters := a_cluster.subclusters
			if subclusters /= Void then
				print_clusters (subclusters, a_file)
			end
		end

	print_exported_class (a_class: ET_XACE_EXPORTED_CLASS; indent: INTEGER; a_file: KL_OUTPUT_FILE) is
			-- Print `a_class' to `a_file'.
		require
			a_class_not_void: a_class /= Void
			indent_positive: indent >= 0
			a_file_not_void: a_file /= Void
			a_file_open_write: a_file.is_open_write
		local
			a_cursor: DS_LINKED_LIST_CURSOR [ET_XACE_EXPORTED_FEATURE]
		do
			print_indentation (indent, a_file)
			a_file.put_string (a_class.class_name)
			a_file.put_new_line
			if not a_class.features.is_empty then
				print_indentation (indent + 1, a_file)
				a_file.put_string ("export")
				a_file.put_new_line
				a_cursor := a_class.features.new_cursor
				from a_cursor.start until a_cursor.after loop
					print_indentation (indent + 2, a_file)
					a_file.put_string (a_cursor.item.feature_name)
					if not a_cursor.is_last then
						a_file.put_character (',')
					end
					a_file.put_new_line
					a_cursor.forth
				end
			end
			print_indentation (indent + 1, a_file)
			a_file.put_string ("end")
			a_file.put_new_line
		end

	print_include_directories (a_directories: DS_LINKED_LIST [STRING]; a_file: KL_OUTPUT_FILE) is
			-- Print `a_directories' to `a_file'.
		require
			a_directories_not_void: a_directories /= Void
			no_void_directory: not a_directories.has (Void)
			a_file_not_void: a_file /= Void
			a_file_open_write: a_file.is_open_write
		local
			a_cursor: DS_LINKED_LIST_CURSOR [STRING]
		do
			if not a_directories.is_empty then
				print_indentation (1, a_file)
				a_file.put_string ("include_path:")
				a_file.put_new_line
				a_cursor := a_directories.new_cursor
				from a_cursor.start until a_cursor.after loop
					print_indentation (2, a_file)
					a_file.put_character ('%"')
					a_file.put_string (a_cursor.item)
					if a_cursor.is_last then
						a_file.put_string ("%";")
					else
						a_file.put_string ("%",")
					end
					a_file.put_new_line
					a_cursor.forth
				end
				a_file.put_new_line
			end
		end

	print_link_libraries (a_libraries: DS_LINKED_LIST [STRING]; a_file: KL_OUTPUT_FILE) is
			-- Print `a_libraries' to `a_file'.
		require
			a_libraries_not_void: a_libraries /= Void
			no_void_library: not a_libraries.has (Void)
			a_file_not_void: a_file /= Void
			a_file_open_write: a_file.is_open_write
		local
			a_cursor: DS_LINKED_LIST_CURSOR [STRING]
		do
			if not a_libraries.is_empty then
				print_indentation (1, a_file)
				a_file.put_string ("object:")
				a_file.put_new_line
				a_cursor := a_libraries.new_cursor
				from a_cursor.start until a_cursor.after loop
					print_indentation (2, a_file)
					a_file.put_character ('%"')
					a_file.put_string (a_cursor.item)
					if a_cursor.is_last then
						a_file.put_string ("%";")
					else
						a_file.put_string ("%",")
					end
					a_file.put_new_line
					a_cursor.forth
				end
				a_file.put_new_line
			end
		end

end -- class ET_XACE_ISE_GENERATOR
