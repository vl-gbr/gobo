-- system:     "Gobo Eiffel Time Library Tester"
-- compiler:   "ISE Eiffel 4.5"
-- author:     "Eric Bezault <ericb@gobosoft.com>"
-- copyright:  "Copyright (c) 2000, Eric Bezault and others"
-- license:    "Eiffel Forum Freeware License v1 (see forum.txt)"
-- date:       "$Date$"
-- revision:   "$Revision$"

system

	xtime

root

	XTIME: "make"

default

	console_application (yes);
	--debug (yes);
#ifdef ASSERTION
	assertion (all);
#else
	--assertion (all);
#endif
	--precompiled ("$EIFFEL4/precomp/spec/$PLATFORM/base")

cluster

	dt_testgen:			"TESTGEN";
	dt_tester:			"$GOBO/test/time";

#include "$GOBO/library/time/ise.ace"

#include "$GOBO/library/test/ise-skl.ace"

#include "$GOBO/library/kernel/ise.ace"

#include "$GOBO/library/structure/ise.ace"

#include "$GOBO/library/utility/ise.ace"

		-- EiffelBase
	kernel:				"$EIFFEL4/library/base/kernel";
	support:			"$EIFFEL4/library/base/support";
	access:				"$EIFFEL4/library/base/structures/access";
	cursors:			"$EIFFEL4/library/base/structures/cursors";
	cursor_trees:		"$EIFFEL4/library/base/structures/cursor_tree";
	dispenser:			"$EIFFEL4/library/base/structures/dispenser";
	iteration:			"$EIFFEL4/library/base/structures/iteration";
	list:				"$EIFFEL4/library/base/structures/list";
	set:				"$EIFFEL4/library/base/structures/set";
	sort:				"$EIFFEL4/library/base/structures/sort";
	storage:			"$EIFFEL4/library/base/structures/storage";
	table:				"$EIFFEL4/library/base/structures/table";
	traversing:			"$EIFFEL4/library/base/structures/traversing";
	tree:				"$EIFFEL4/library/base/structures/tree";

external

	include_path: "$GOBO/library/kernel/include"

end
