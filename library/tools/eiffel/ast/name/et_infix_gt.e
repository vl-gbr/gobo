indexing

	description:

		"Eiffel infix '>' feature names"

	library:    "Gobo Eiffel Tools Library"
	author:     "Eric Bezault <ericb@gobosoft.com>"
	copyright:  "Copyright (c) 1999-2001, Eric Bezault and others"
	license:    "Eiffel Forum Freeware License v1 (see forum.txt)"
	date:       "$Date$"
	revision:   "$Revision$"

class ET_INFIX_GT

inherit

	ET_INFIX_NAME

creation

	make

feature -- Access

	name: STRING is "infix %">%""
			-- Name of feature

	hash_code: INTEGER is 7
			-- Hash code

end -- class ET_INFIX_GT
