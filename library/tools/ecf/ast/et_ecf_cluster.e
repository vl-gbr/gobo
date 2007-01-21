indexing

	description:

		"ECF Eiffel clusters"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 2006, Eric Bezault and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class ET_ECF_CLUSTER

inherit

	ET_CLUSTER
		redefine
			parent, subclusters,
			is_valid_eiffel_filename,
			is_valid_directory_name
		end

create

	make

feature {NONE} -- Initialization

	make (a_name: like name; a_pathname: like pathname) is
			-- Create a new cluster.
		require
			a_name_not_void: a_name /= Void
			a_name_not_empty: a_name.count > 0
		do
			name := a_name
			pathname := a_pathname
			is_relative := (a_pathname = Void)
			set_overridden_constraint_enabled (True)
		ensure
			name_set: name = a_name
			pathname_set: pathname = a_pathname
			prefixed_name_set: prefixed_name = a_name
			is_relative: is_relative = (a_pathname = Void)
			overridden_constraint_enabled: overridden_constraint_enabled
		end

feature -- Access

	name: STRING
			-- Name

	pathname: STRING
			-- Directory pathname (may be Void)

	file_rule: ET_ECF_FILE_RULE
			-- File rule

feature -- Status report

	is_valid_eiffel_filename (a_filename: STRING): BOOLEAN is
			-- Is `a_filename' an Eiffel filename which has
			-- not been excluded?
		do
			if precursor (a_filename) then
				Result := (file_rule = Void or else file_rule.is_included (unix_file_system.pathname_from_file_system (file_system.pathname (full_pathname, a_filename), file_system)))
			end
		end

	is_valid_directory_name (a_dirname: STRING): BOOLEAN is
			-- Is `a_dirname' a directory name other than "." and
			-- ".." and which has not been excluded?
		do
			if precursor (a_dirname) then
				Result := (file_rule = Void or else file_rule.is_included (unix_file_system.pathname_from_file_system (file_system.pathname (full_pathname, a_dirname), file_system)))
			end
		end

feature -- Nested

	parent: ET_ECF_CLUSTER
			-- Parent cluster

	subclusters: ET_ECF_CLUSTERS
			-- Subclusters

feature -- Setting

	set_file_rule (a_file_rule: like file_rule) is
			-- Set `file_rule' to `a_file_rule'.
		do
			file_rule := a_file_rule
		ensure
			file_rule_set: file_rule = a_file_rule
		end

feature {NONE} -- Implementation

	new_recursive_cluster (a_name: STRING): like Current is
			-- New recursive cluster
		do
			create Result.make (a_name, Void)
			Result.set_parent (Current)
			Result.set_file_rule (file_rule)
			Result.set_recursive (True)
			Result.set_implicit (True)
			Result.set_override (is_override)
			Result.set_read_only (is_read_only)
		end

end
