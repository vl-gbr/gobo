indexing

	description:

		"Objects that define one component of a sort key"

	library: "Gobo Eiffel XSLT Library"
	copyright: "Copyright (c) 2004, Colin Adams and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class XM_XSLT_SORT_KEY_DEFINITION

inherit

	XM_XPATH_DEBUGGING_ROUTINES

	-- Note that most attributes defining the sort key can be attribute value templates,
	-- and can therefore vary from one invocation to another. We hold them as expressions. As
	-- soon as they are all known (which in general is only at run-time), the XM_XSLT_SORT_KEY_DEFINITION
	-- is replaced by a XM_XSLT_FIXED_SORT_KEY_DEFINITION in which all these values are fixed.

	-- TODO - optimizations (Review - see comments in Saxon 8.0 code for details)

	-- TODO Sequence constructor - in the mean time, a select expression is assumed to be the sort key

creation

	make

feature {NONE} -- Initialization

	make (a_sort_key, an_order, a_case_order, a_language, a_data_type, a_collation_name: XM_XPATH_EXPRESSION; ) is
			-- Establish invariant.
		require
			sort_key_not_void: a_sort_key /= Void			
		do
			sort_key := a_sort_key
			order_expression := an_order
			case_order_expression := a_case_order
			language_expression := a_language
			data_type_expression := a_data_type
			collation_name_expression := a_collation_name
		ensure
		end

feature -- Access

	sort_key: XM_XPATH_EXPRESSION
			-- Sort key

	reduced_definition (a_context: XM_XSLT_EVALUATION_CONTEXT):  XM_XSLT_FIXED_SORT_KEY_DEFINITION is
			-- Sort key definition without any dependencies on the context except for the sort key itself;
			-- For the AVTs used to select data type, case order, language, it means
			--  all dependencies: after reduction, these values will be constants.
		require
			context_not_void: a_context /= Void
			reducible: is_reducible
		local
			a_collator: ST_COLLATOR
		do
			if collation_name /= Void then a_collator := a_context.collation (collation_name) end
			create Result.make (sort_key, order, data_type, case_order, language, a_collator, a_context)
		ensure
			reduced_definition_not_void: Result /= Void
		end

feature -- Status_report

	is_reducible: BOOLEAN is
			-- May `reduced_definition' be called?
		do
			Result := order /= Void and then
			case_order /= Void and then
			language /= Void and then
			data_type /= Void			
		end

feature -- Element change

	evaluate_expressions (a_context: XM_XSLT_EVALUATION_CONTEXT) is
			-- Evaluate all AVTs
		require
			context_not_void: a_context /= Void
			not_already_reduced: not is_reducible
		do
			evaluate_order (a_context)
			evaluate_case_order (a_context)
			evaluate_language (a_context)
			evaluate_data_type (a_context)
			evaluate_collation_name (a_context)			
		ensure
			order_not_void: order /= Void
			case_order_not_void: case_order /= Void
			language_not_void: language /= Void
			data_type_not_void: data_type /= Void
		end

feature {NONE} -- Implementation

	order_expression: XM_XPATH_EXPRESSION
			-- Order (ascending or descending)

	case_order_expression: XM_XPATH_EXPRESSION
			-- Case order (upper-first or lower-first)

	language_expression: XM_XPATH_EXPRESSION
			-- Language

	data_type_expression: XM_XPATH_EXPRESSION
			-- Data type to which sort-key-values will be coerced (text, number or QName (but not NCName)

	collation_name_expression: XM_XPATH_EXPRESSION
			-- Name of collation (a URI) as an AVT

	collation_name: STRING
			-- Name of collation (a URI)

	order: STRING
			-- Value of order attribute (ascending or descending)

	language: STRING
			--  Value of language attribute

	case_order: STRING
			-- Value of case-order attribute ("lower-first" or "upper-first")

	data_type: STRING
			-- Value of data-type attribute ("text" or "number" or a QName)

	evaluate_collation_name (a_context: XM_XSLT_EVALUATION_CONTEXT) is
			-- Evaluate `collation_name_expression'
		require
			context_not_void: a_context /= Void
		do
			if collation_name_expression /= Void then
				collation_name_expression.evaluate_item (a_context)
				collation_name := collation_name_expression.last_evaluated_item.string_value
			end
		end

	evaluate_order (a_context: XM_XSLT_EVALUATION_CONTEXT) is
			-- Evaluate `order_expression'
		require
			context_not_void: a_context /= Void
		do
			if order_expression = Void then
				order := "ascending"
			else
				order_expression.evaluate_item (a_context)
				order := order_expression.last_evaluated_item.string_value
			end
		ensure
			order_not_void: order /= Void
		end
	
	evaluate_case_order (a_context: XM_XSLT_EVALUATION_CONTEXT) is
			-- Evaluate `case_order_expression'
		require
			context_not_void: a_context /= Void
		do
			if case_order_expression = Void then
				case_order := "#default"
			else
				case_order_expression.evaluate_item (a_context)
				case_order := case_order_expression.last_evaluated_item.string_value
			end
		ensure
			case_order_not_void: case_order /= Void
		end
	
	evaluate_language (a_context: XM_XSLT_EVALUATION_CONTEXT) is
			-- Evaluate `language_expression'
		require
			context_not_void: a_context /= Void
		do
			if language_expression = Void then
				language := ""
			else
				language_expression.evaluate_item (a_context)
				language := language_expression.last_evaluated_item.string_value
			end
		ensure
			language_not_void: language /= Void
		end
	
	evaluate_data_type (a_context: XM_XSLT_EVALUATION_CONTEXT) is
			-- Evaluate `data_type_expression'
		require
			context_not_void: a_context /= Void
		do
			if data_type_expression = Void then
				data_type := ""
			else
				data_type_expression.evaluate_item (a_context)
				if data_type_expression.last_evaluated_item = Void then
					data_type := ""
				else
					data_type := data_type_expression.last_evaluated_item.string_value
				end
			end
		ensure
			data_type_not_void: data_type /= Void
		end
	
invariant

	sort_key_not_void: sort_key /= Void -- for now - this will have to change to support a sequence constructor

end
