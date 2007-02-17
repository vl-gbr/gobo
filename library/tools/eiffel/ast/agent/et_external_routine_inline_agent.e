indexing

	description:

		"Eiffel inline agents with an external routine as associated feature"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 2007, Eric Bezault and others"
	license: "MIT License"
	date: "$Date$"
	revision: "$Revision$"

deferred class ET_EXTERNAL_ROUTINE_INLINE_AGENT

inherit

	ET_ROUTINE_INLINE_AGENT

feature -- Access

	language: ET_EXTERNAL_LANGUAGE
			-- External language

	alias_clause: ET_EXTERNAL_ALIAS
			-- Alias clause

feature -- Setting

	set_alias_clause (an_alias: like alias_clause) is
			-- Set `alias_clause' to `an_alias'.
		do
			alias_clause := an_alias
		ensure
			alias_clause_set: alias_clause = an_alias
		end

invariant

	language_not_void: language /= Void

end
