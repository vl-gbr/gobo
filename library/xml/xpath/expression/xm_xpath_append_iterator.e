indexing

	description:

		"Objects that concatenate the results of two iterators."

	library: "Gobo Eiffel XPath Library"
	copyright: "Copyright (c) 2004, Colin Adams and others"
	license: "MIT License"
	date: "$Date$"
	revision: "$Revision$"

class XM_XPATH_APPEND_ITERATOR

inherit

	XM_XPATH_SEQUENCE_ITERATOR [XM_XPATH_ITEM]

create

	make

feature {NONE} -- Initialization

	make (a_base_iterator, a_second_iterator: XM_XPATH_SEQUENCE_ITERATOR [XM_XPATH_ITEM]; a_context: XM_XPATH_CONTEXT) is
			-- Establish invariant.
		require
			base_iterator_before: a_base_iterator /= Void and then a_base_iterator.before
			second_iterator_before: a_second_iterator /= Void and then a_second_iterator.before
		do
			base_iterator := a_base_iterator
			second_iterator := a_second_iterator
			if base_iterator.is_error then
				set_last_error (base_iterator.error_value)
			elseif second_iterator.is_error then
				set_last_error (second_iterator.error_value)
			end
			context := a_context
			current_iterator := base_iterator
			if current_iterator.is_error then
				set_last_error (current_iterator.error_value)
			end
		ensure
			base_set: base_iterator = a_base_iterator
			second_iterator_set: second_iterator = a_second_iterator
			context_set: context = a_context
		end

feature -- Access

	item: XM_XPATH_ITEM is
			-- Value or node at the current position
		do
			Result := current_iterator.item
		end

feature -- Status report

	after: BOOLEAN is
			-- Are there any more items in the sequence?
		do
			Result := not current_iterator.before and then current_iterator.after
			if Result and then current_iterator = base_iterator then
				Result := not second_iterator.before and then second_iterator.after
			end
		end

feature -- Cursor movement

	forth is
			-- Move to next position
		do
			index := index + 1
			if current_iterator.before then
				current_iterator.start
			elseif current_iterator.after then
				if second_iterator.before then
					second_iterator.start
					current_iterator := second_iterator
				end
			else
				current_iterator.forth
			end
			if current_iterator.is_error then
				set_last_error (current_iterator.error_value)
			end
			if base_iterator.after and then second_iterator.before then
				current_iterator := second_iterator
				current_iterator.start
			end
		end

feature -- Duplication

	another: like Current is
			-- Another iterator that iterates over the same items as the original
		do
			create Result.make (base_iterator.another, second_iterator.another, context)
		end

feature {NONE} -- Implementation

	base_iterator: XM_XPATH_SEQUENCE_ITERATOR [XM_XPATH_ITEM]
			-- The underlying iterator

	context: XM_XPATH_CONTEXT
			-- Optional dynamic context

	second_iterator: XM_XPATH_SEQUENCE_ITERATOR [XM_XPATH_ITEM]
			-- Iterator over second expression

	current_iterator: like base_iterator
			-- Iterator currently being used

invariant

	base_iterator_not_void: base_iterator /= Void
	second_iterator_not_void: second_iterator /= Void
	current_iterator_not_void: current_iterator /= Void

end