indexing

	description:

		"Test features of class ARRAY"

	library: "Gobo Eiffel Kernel Library"
	copyright: "Copyright (c) 2004, Eric Bezault and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

deferred class KS_TEST_ARRAY

inherit

	KL_TEST_CASE
	KL_SHARED_EIFFEL_COMPILER

feature -- Test

	test_subarray is
			-- Test feature `subarray'.
			-- Note: ELKS 2000 ARRAY and VE 4.1 return an 'ARRAY [G]'
			-- whereas SE 1.0 and ISE 5.4/5.5 return a 'like Current'.
			-- Note2: ISE 5.4/5.5 does not allow subarrays of empty array,
			-- and does not work with empty subarrays.
		local
			l_ai1: ARRAY [INTEGER]
			l_ai2: ARRAY [INTEGER]
		do
			l_ai1 := <<1, 2, 3, 4, 5, 6>>
			l_ai2 := l_ai1.subarray (3, 5)
			assert_iarrays_same ("same_items", <<3, 4, 5>>, l_ai2)
			assert_integers_equal ("lower_set", 3, l_ai2.lower)
			assert_integers_equal ("upper_set", 5, l_ai2.upper)
				-- Not allowed by ISE 5.4/5.5.
			if not eiffel_compiler.is_ise then
					-- Empty subarray.
				l_ai2 := l_ai1.subarray (6, 5)
				assert_integers_equal ("same_items2", 0, l_ai2.count)
				assert_integers_equal ("lower_set2", 6, l_ai2.lower)
				assert_integers_equal ("upper_set2", 5, l_ai2.upper)
					-- Subarray of an empty array.
				create l_ai1.make (4, 3)
				l_ai2 := l_ai1.subarray (4, 3)
				assert_integers_equal ("same_items3", 0, l_ai2.count)
				assert_integers_equal ("lower_set3", 4, l_ai2.lower)
				assert_integers_equal ("upper_set3", 3, l_ai2.upper)
			end
		end

	test_clear_all is
			-- Test feature `clear_all'.
		local
			l_ai: ARRAY [INTEGER]
			l_as: ARRAY [STRING]
		do
			create l_ai.make (4, 7)
			l_ai.put (1, 4)
			l_ai.put (2, 5)
			l_ai.put (3, 6)
			l_ai.put (4, 7)
			assert_iarrays_same ("ai_initialized", <<1, 2, 3, 4>>, l_ai)
			assert_integers_equal ("ai_lower_set", 4, l_ai.lower)
			assert_integers_equal ("ai_upper_set", 7, l_ai.upper)
			l_ai.clear_all
			assert_iarrays_same ("ai_all_cleared", <<0, 0, 0, 0>>, l_ai)
			assert_integers_equal ("ai_same_lower", 4, l_ai.lower)
			assert_integers_equal ("ai_same_upper", 7, l_ai.upper)
			l_as := <<"1", "2", "3", "4">>
			assert_arrays_equal ("as_initialized", <<"1", "2", "3", "4">>, l_as)
			l_as.clear_all
			assert_arrays_same ("as_all_cleared", <<Void, Void, Void, Void>>, l_as)
				-- Empty array.
			create l_as.make (3, 2)
			assert_integers_equal ("as_empty2", 0, l_as.count)
			l_as.clear_all
			assert_integers_equal ("as_still_empty2", 0, l_as.count)
			assert_integers_equal ("as_same_lower2", 3, l_as.lower)
			assert_integers_equal ("as_same_upper2", 2, l_as.upper)
		end

end
