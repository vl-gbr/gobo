indexing

	description:

		"Objects that implement the XPath tokenize() function"

	library: "Gobo Eiffel XPath Library"
	copyright: "Copyright (c) 2004, Colin Adams and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class XM_XPATH_TOKENIZE

inherit

	XM_XPATH_SYSTEM_FUNCTION
		redefine
			simplified_expression, iterator
		end

creation

	make

feature {NONE} -- Initialization

	make is
			-- Establish invariant
		do
			name := "tokenize"
			minimum_argument_count := 2
			maximum_argument_count := 3
			create arguments.make (3)
			arguments.set_equality_tester (expression_tester)
			compute_static_properties
		end

feature -- Access

	item_type: XM_XPATH_ITEM_TYPE is
			-- Data type of the expression, where known
		do
			Result := type_factory.string_type
			if Result /= Void then
				-- Bug in SE 1.0 and 1.1: Make sure that
				-- that `Result' is not optimized away.
			end
		end

feature -- Status report

	required_type (argument_number: INTEGER): XM_XPATH_SEQUENCE_TYPE is
			-- Type of argument number `argument_number'
		do
			inspect
				argument_number
			when 1 then
				create Result.make_optional_string
			when 2 then
				create Result.make_single_string
			when 3 then
				create Result.make_single_string
			end
		end

feature -- Optimization

	simplified_expression: XM_XPATH_EXPRESSION is
			-- Simplified expression as a result of context-independent static optimizations
		local
			a_result_expression: XM_XPATH_TOKENIZE
			a_simplifier: XM_XPATH_ARGUMENT_SIMPLIFIER
			n: INTEGER
		do
			a_result_expression := clone (Current)
			create a_simplifier
			a_simplifier.simplify_arguments (arguments)
			if not a_simplifier.is_error then
				a_result_expression.set_arguments (a_simplifier.simplified_arguments)
				if arguments.count = 3 then n := 3 end
				try_to_compile (n)
			else
				a_result_expression.set_last_error (a_simplifier.error_value)
			end
			Result := a_result_expression
		end
		
feature -- Evaluation

	iterator (a_context: XM_XPATH_CONTEXT): XM_XPATH_SEQUENCE_ITERATOR [XM_XPATH_ITEM] is
			-- An iterator over the values of a sequence
		local
			an_atomic_value: XM_XPATH_ATOMIC_VALUE
			an_input_string, a_pattern_string, a_flags_string: STRING
		do
			arguments.item (1).evaluate_item (a_context)
			an_atomic_value ?= arguments.item (1).last_evaluated_item
			if an_atomic_value = Void then
				create {XM_XPATH_EMPTY_ITERATOR [XM_XPATH_ITEM]} Result.make
			else
				an_input_string := an_atomic_value.string_value
				if regexp = Void then
					arguments.item (2).evaluate_item (a_context)
					an_atomic_value ?= arguments.item (2).last_evaluated_item
					check
						atomic_pattern: an_atomic_value /= Void
						-- Statically typed as a single string
					end
					a_pattern_string := an_atomic_value.string_value
					if arguments.count = 2 then
						a_flags_string := ""
					else
						arguments.item (3).evaluate_item (a_context)
						an_atomic_value ?= arguments.item (3).last_evaluated_item
						check
							atomic_pattern: an_atomic_value /= Void
							-- Statically typed as a single string
						end
						a_flags_string := an_atomic_value.string_value
					end
					create regexp.make
					set_flags (a_flags_string)
					regexp.compile (a_pattern_string)
					if regexp.is_compiled then
						if regexp.matches ("") then
							create {XM_XPATH_INVALID_ITERATOR} Result.make_from_string ("Regular expression matches zero-length string", 3, Dynamic_error)
						else
							create {XM_XPATH_TOKEN_ITERATOR} Result.make (an_input_string, regexp)
						end
					else
						create {XM_XPATH_INVALID_ITERATOR} Result.make_from_string ("Invalid regular expression", 2, Dynamic_error)
					end
				else
					create {XM_XPATH_TOKEN_ITERATOR} Result.make (an_input_string, regexp)
				end
			end
		end

feature {XM_XPATH_EXPRESSION} -- Restricted

	compute_cardinality is
			-- Compute cardinality.
		do
			set_cardinality_zero_or_more
		end

feature {NONE} -- Implementation

	regexp: RX_PCRE_REGULAR_EXPRESSION

	try_to_compile (a_flag_argument_position: INTEGER) is
			-- Attempt to compile `regexp'.
		require
			flag_argument_number: a_flag_argument_position = 0
				or else ( a_flag_argument_position > 2 and then a_flag_argument_position <= arguments.count)
		local
			a_flag_string: STRING
			a_string_value: XM_XPATH_STRING_VALUE
		do
			if a_flag_argument_position = 0 then
				a_flag_string := ""
			else
				a_string_value ?= arguments.item (a_flag_argument_position)
				if a_string_value /= Void then
					a_flag_string := a_string_value.string_value
				end
			end
			a_string_value ?= arguments.item (2) -- the pattern
			if a_string_value /= Void and then a_flag_string /= Void then
				create regexp.make
				set_flags (a_flag_string)
				if not is_error then
					regexp.compile (a_string_value.string_value)
					if not regexp.is_compiled then
						regexp := Void
					else
						if regexp.matches ("") then
							set_last_error_from_string ("Regular expression matches zero-length string", 3, Static_error)
						end
					end
				end
			end
		end

	set_flags (a_flag_string: STRING) is
			-- Set regular expression flags.
		require
			flag_string_not_void: a_flag_string /= Void
		local
			an_index: INTEGER
		do
			regexp.set_default_options
			regexp.set_strict (True)
			-- TODO regexp.set_unicode
			from
				an_index := 1
			variant
				a_flag_string.count + 1 - an_index
			until
				an_index > a_flag_string.count
			loop
				inspect
					a_flag_string.item (an_index)
				when 'm' then
					regexp.set_multiline (True)
				when 'i' then
					regexp.set_caseless (True)
				when 's' then
					regexp.set_dotall (True)
				when 'x' then
					regexp.set_extended (True)
				else
					set_last_error_from_string ("Unknown flags in regular expression", 1, Static_error)
					regexp := Void
				end
				an_index := an_index + 1
			end
		end
	
end
	