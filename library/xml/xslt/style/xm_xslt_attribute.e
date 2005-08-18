indexing

	description:

		"xsl:attribute element nodes"

	library: "Gobo Eiffel XSLT Library"
	copyright: "Copyright (c) 2004, Colin Adams and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class XM_XSLT_ATTRIBUTE

inherit

	XM_XSLT_STRING_CONSTRUCTOR
		redefine
			validate
		end

create {XM_XSLT_NODE_FACTORY}

	make_style_element

feature -- Element change

	prepare_attributes is
			-- Set the attribute list for the element.
		local
			a_cursor: DS_ARRAYED_LIST_CURSOR [INTEGER]
			a_name_code: INTEGER
			an_expanded_name, a_name_attribute, a_namespace_attribute, a_type_attribute: STRING
			a_select_attribute, a_separator_attribute, a_validation_attribute: STRING
			an_error: XM_XPATH_ERROR_VALUE
		do
			validation_action := Validation_strip
			from
				a_cursor := attribute_collection.name_code_cursor
				a_cursor.start
			variant
				attribute_collection.number_of_attributes + 1 - a_cursor.index				
			until
				a_cursor.after
			loop
				a_name_code := a_cursor.item
				an_expanded_name := shared_name_pool.expanded_name_from_name_code (a_name_code)
				if STRING_.same_string (an_expanded_name, Name_attribute) then
					a_name_attribute := attribute_value_by_index (a_cursor.index)
				elseif STRING_.same_string (an_expanded_name, Namespace_attribute) then
					a_namespace_attribute := attribute_value_by_index (a_cursor.index)
				elseif STRING_.same_string (an_expanded_name, Select_attribute) then
					a_select_attribute := attribute_value_by_index (a_cursor.index)
				elseif STRING_.same_string (an_expanded_name, Separator_attribute) then
					a_separator_attribute := attribute_value_by_index (a_cursor.index)
				elseif STRING_.same_string (an_expanded_name, Validation_attribute) then
					a_validation_attribute := attribute_value_by_index (a_cursor.index)
				elseif STRING_.same_string (an_expanded_name, Type_attribute) then
					a_type_attribute := attribute_value_by_index (a_cursor.index)
				else
					check_unknown_attribute (a_name_code) 		
				end
				a_cursor.forth
			end
			if a_name_attribute = Void then
				report_absence ("name")
			else
				generate_attribute_value_template (a_name_attribute, static_context)
				attribute_name := last_generated_expression
				if attribute_name.is_error then
					report_compile_error (attribute_name.error_value)
				else
					if attribute_name.is_string_value then
						if not is_qname (attribute_name.as_string_value.string_value) then
							create an_error.make_from_string ("Attribute name is not a valid QName",
																		 Xpath_errors_uri, "XTDE0850", Static_error)
							report_compile_error (an_error)
							
							-- Prevent a duplicate error message.
							
							create {XM_XPATH_STRING_VALUE} attribute_name.make ("gexslt-error-attribute")
						end
					end
				end
			end
			if a_namespace_attribute /= Void then
				generate_attribute_value_template (a_namespace_attribute, static_context)
				namespace := last_generated_expression
				if namespace.is_error then
					report_compile_error (namespace.error_value)
				end
			end
			if a_select_attribute /= Void then
				generate_attribute_value_template (a_select_attribute, static_context)
				select_expression := last_generated_expression
				if select_expression.is_error then
					report_compile_error (select_expression.error_value)
				end
			end
			if a_separator_attribute /= Void then
				generate_attribute_value_template (a_separator_attribute, static_context)
				separator_expression := last_generated_expression
				if separator_expression.is_error then
					report_compile_error (separator_expression.error_value)
				end
			else
				if a_select_attribute = Void then
					create {XM_XPATH_STRING_VALUE} separator_expression.make ("")
				else
					create {XM_XPATH_STRING_VALUE} separator_expression.make (" ")
				end
			end
			prepare_attributes_2 (a_validation_attribute, a_type_attribute)
			attributes_prepared := True
		end

	validate is
			-- Check that the stylesheet element is valid.
		local
			an_attribute_set: XM_XSLT_ATTRIBUTE_SET
		do
			an_attribute_set ?= parent
			if an_attribute_set = Void then
				check_within_template
			end
			type_check_expression ("name", attribute_name)
			if attribute_name.was_expression_replaced then
				attribute_name := attribute_name.replacement_expression
			end
			if namespace /= Void then
				type_check_expression ("namespace", namespace)
				if namespace.was_expression_replaced then
					namespace := namespace.replacement_expression
				end
			end
			if select_expression /= Void then
				type_check_expression ("select", select_expression)
				if select_expression.was_expression_replaced then
					select_expression := select_expression.replacement_expression
				end
			end
			if separator_expression /= Void then
				type_check_expression ("separator", separator_expression)
				if separator_expression.was_expression_replaced then
					separator_expression := separator_expression.replacement_expression
				end
			end
			Precursor
		end
			
	compile (an_executable: XM_XSLT_EXECUTABLE) is
			-- Compile `Current' to an excutable instruction.
		local
			a_name_code: INTEGER
			a_namespace_context: XM_XSLT_NAMESPACE_CONTEXT
			an_attribute: XM_XSLT_COMPILED_ATTRIBUTE
		do
			last_generated_expression := Void
			
			-- Deal specially with the case where the attribute name is known statically.
			
			if attribute_name.is_string_value then
				set_qname_parts (attribute_name.as_string_value)
				if not any_compile_errors then
					if shared_name_pool.is_name_code_allocated (qname_prefix, namespace_uri, local_name) then
						a_name_code := shared_name_pool.name_code (qname_prefix, namespace_uri, local_name)
					else
						shared_name_pool.allocate_name (qname_prefix, namespace_uri, local_name)
						a_name_code := shared_name_pool.last_name_code
					end
					compile_fixed_attribute (an_executable, a_name_code)
				end
			else
				if namespace.is_string_value then
					namespace_uri := namespace.as_string_value.string_value
					if namespace_uri.count = 0 then
						qname_prefix := ""
					elseif qname_prefix.count = 0 then
						choose_arbitrary_qname_prefix
					end
					if shared_name_pool.is_name_code_allocated (qname_prefix, namespace_uri, local_name) then
						a_name_code := shared_name_pool.name_code (qname_prefix, namespace_uri, local_name)
					else
						shared_name_pool.allocate_name (qname_prefix, namespace_uri, local_name)
						a_name_code := shared_name_pool.last_name_code
					end
					compile_fixed_attribute (an_executable, a_name_code)
				end
			end
			
			if last_generated_expression = Void then
				
				-- If the namespace URI must be deduced at run-time from the attribute name prefix,
				--  we need to save the namespace context of the instruction.
				
				if namespace = Void then
					a_namespace_context := namespace_context
				end

				create an_attribute.make (an_executable, attribute_name, namespace, a_namespace_context, validation_action, Void, -1)
				compile_content (an_executable, an_attribute, separator_expression)
				last_generated_expression := an_attribute
			end
		end

feature {NONE} -- Implementation

	validation_action: INTEGER
	
	attribute_name: XM_XPATH_EXPRESSION
			-- Value of name attribute

	namespace: XM_XPATH_EXPRESSION
			-- Value of namespace attribute

	separator_expression: XM_XPATH_EXPRESSION
			-- Value of separator attribute

	qname_prefix, namespace_uri, local_name, qname: STRING
			-- Used for communicating with `compile'
	
	prepare_attributes_2 (a_validation_attribute, a_type_attribute: STRING) is
			-- Continue prparing attributes.
		local
			an_error: XM_XPATH_ERROR_VALUE
		do
			if a_validation_attribute /= Void then
				validation_action := validation_code (a_validation_attribute)
				if validation_action /= Validation_strip then
					create an_error.make_from_string ("To perform validation, a schema-aware XSLT processor is needed",
																 Xpath_errors_uri, "XTSE1660", Static_error)
				report_compile_error (an_error)
				elseif validation_action = Validation_invalid then
					create an_error.make_from_string ("Invalid value of validation attribute",
																 Xpath_errors_uri, "XTSE0020", Static_error)
					report_compile_error (an_error)
				end
			end

			if a_type_attribute /= Void then
				create an_error.make_from_string ("The type attribute is available only with a schema-aware XSLT processor",
															 Xpath_errors_uri, "XTSE1660", Static_error)
				report_compile_error (an_error)
			end

			if a_type_attribute /= Void and then a_validation_attribute /= Void then
				create an_error.make_from_string ("The validation and type attributes are mutually exclusive",
															 Xpath_errors_uri, "XTSE1505", Static_error)
				report_compile_error (an_error)
			end
		end

	set_qname_parts (a_string_value: XM_XPATH_STRING_VALUE) is
			-- Analyze and set qname parts.
		require
			string_value_not_void: a_string_value /= Void
		local
			a_parser: XM_XPATH_QNAME_PARSER
			an_error: XM_XPATH_ERROR_VALUE
		do
			namespace_uri := ""
			qname_prefix := Void
			local_name := Void
			qname := a_string_value.string_value
			STRING_.left_adjust (qname)
			STRING_.right_adjust (qname)
			if qname.count = 0 then
				create an_error.make_from_string ("Attribute name must not be zero length", Xpath_errors_uri, "XTSE0020", Static_error)
				report_compile_error (an_error)
			elseif STRING_.same_string (qname, "xmlns") and namespace = Void then
				create an_error.make_from_string ("Invalid attribute name: xmlns", Xpath_errors_uri, "XTSE0020", Static_error)
				report_compile_error (an_error)
			else
				create a_parser.make (qname)
				if a_parser.is_valid then
					local_name := a_parser.local_name
					qname_prefix := a_parser.optional_prefix
				else
					create an_error.make_from_string (STRING_.concat ("Invalid attribute name: ", qname), Xpath_errors_uri, "XTSE0020", Static_error)
					report_compile_error (an_error)
				end
				if STRING_.same_string (qname_prefix, "xmlns") then
					if namespace = Void then
						create an_error.make_from_string (STRING_.concat ("Invalid attribute name: ", qname), Xpath_errors_uri, "XTSE0020", Static_error)
						report_compile_error (an_error)
					else
						qname_prefix := "" -- We ignore it anyway when the namespace attribute is present
					end
				end
				if namespace = Void then
					namespace_uri := uri_for_prefix (qname_prefix, False)
				end
			end
		ensure
			parts_set_or_error: not any_compile_errors implies qname_prefix /= Void and then local_name /= Void and then namespace_uri /= Void
		end

	compile_fixed_attribute (an_executable: XM_XSLT_EXECUTABLE; a_name_code: INTEGER) is
			-- Compile to a fixed attribute.
		require
			executable_not_void: an_executable /= Void
		local
			a_fixed_attribute: XM_XSLT_FIXED_ATTRIBUTE
		do
			create a_fixed_attribute.make (an_executable, a_name_code, validation_action, Void, -1)
			compile_content (an_executable, a_fixed_attribute, separator_expression)
			last_generated_expression := a_fixed_attribute
		end

	choose_arbitrary_qname_prefix is
			-- Choose an arbitrary XML prefix.
		do
			todo ("choose arbitrary_qname_prefix", False)
		end

end
