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

creation {XM_XSLT_NODE_FACTORY}

	make_style_element

feature -- Element change

	prepare_attributes is
			-- Set the attribute list for the element.
		local
			a_cursor: DS_ARRAYED_LIST_CURSOR [INTEGER]
			a_name_code: INTEGER
			an_expanded_name, a_name_attribute, a_namespace_attribute, a_type_attribute: STRING
			a_select_attribute, a_separator_attribute, a_validation_attribute: STRING
			a_string_value: XM_XPATH_STRING_VALUE
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
					report_compile_error (attribute_name.error_value.error_message)
				else
					a_string_value ?= attribute_name
					if a_string_value /= Void then
						if not is_qname (a_string_value.string_value) then
							report_compile_error ("Attribute name is not a valid QName")
							
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
					report_compile_error (namespace.error_value.error_message)
				end
			end
			if a_select_attribute /= Void then
				generate_attribute_value_template (a_select_attribute, static_context)
				select_expression := last_generated_expression
				if select_expression.is_error then
					report_compile_error (select_expression.error_value.error_message)
				end
			end
			if a_separator_attribute /= Void then
				generate_attribute_value_template (a_separator_attribute, static_context)
				separator_expression := last_generated_expression
				if separator_expression.is_error then
					report_compile_error (separator_expression.error_value.error_message)
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
		do
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
			a_string_value: XM_XPATH_STRING_VALUE
			a_name_code: INTEGER
			a_namespace_context: XM_XSLT_NAMESPACE_CONTEXT
			an_attribute: XM_XSLT_COMPILED_ATTRIBUTE
		do
			
			last_generated_instruction := Void
			
			-- Deal specially with the case where the attribute name is known statically.
			
			a_string_value ?= attribute_name
			if a_string_value /= Void then
				set_qname_parts (a_string_value)
				if not any_compile_errors then
					if shared_name_pool.is_name_code_allocated (xml_prefix, namespace_uri, local_name) then
						a_name_code := shared_name_pool.name_code (xml_prefix, namespace_uri, local_name)
					else
						shared_name_pool.allocate_name (xml_prefix, namespace_uri, local_name)
						a_name_code := shared_name_pool.last_name_code
					end
					compile_fixed_attribute (an_executable, a_name_code)
				end
			else
				a_string_value ?= namespace
				if a_string_value /= Void then
					namespace_uri := a_string_value.string_value
					if namespace_uri.count = 0 then
						xml_prefix := ""
					elseif xml_prefix.count = 0 then
						choose_arbitrary_xml_prefix
					end
					if shared_name_pool.is_name_code_allocated (xml_prefix, namespace_uri, local_name) then
						a_name_code := shared_name_pool.name_code (xml_prefix, namespace_uri, local_name)
					else
						shared_name_pool.allocate_name (xml_prefix, namespace_uri, local_name)
						a_name_code := shared_name_pool.last_name_code
					end
					compile_fixed_attribute (an_executable, a_name_code)
				end
			end
			
			if last_generated_instruction = Void then
				
				-- If the namespace URI must be deduced at run-time from the attribute name prefix,
				--  we need to save the namespace context of the instruction.
				
				if namespace = Void then
					a_namespace_context := namespace_context
				end

				create an_attribute.make (an_executable, attribute_name, namespace, a_namespace_context, validation_action, Void, -1)
				last_generated_instruction := an_attribute
				compile_children (an_executable, last_generated_instruction)
				an_attribute.set_separator_expression (separator_expression)
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

	xml_prefix, namespace_uri, local_name, qname: STRING
			-- Used for communicating with `compile'
	
	prepare_attributes_2 (a_validation_attribute, a_type_attribute: STRING) is
			-- Continue prparing attributes.
		do
			if a_validation_attribute /= Void then
				validation_action := validation_code (a_validation_attribute)
				if validation_action /= Validation_strip then
					report_compile_error ("To perform validation, a schema-aware XSLT processor is needed")
				elseif validation_action = Validation_invalid then
					report_compile_error ("Invalid value of validation attribute")
				end
			end

			if a_type_attribute /= Void then
				report_compile_error ("The type attribute is available only with a schema-aware XSLT processor")
			end

			if a_type_attribute /= Void and then a_validation_attribute /= Void then
				report_compile_error ("The validation and type attributes are mutually exclusive")
			end
		end

	set_qname_parts (a_string_value: XM_XPATH_STRING_VALUE) is
			-- Analyze and set qname parts.
		require
			string_value_not_void: a_string_value /= Void
		local
			a_string_splitter: ST_SPLITTER
			qname_parts: DS_LIST [STRING]
		do
			qname := a_string_value.string_value
			STRING_.left_adjust (qname)
			STRING_.right_adjust (qname)
			if qname.count = 0 then
				report_compile_error ("Attribute name must not be zero length")
			elseif STRING_.same_string (qname, "xmlns") and namespace = Void then
				report_compile_error ("Invalid attribute name: xmlns")
			else
				create a_string_splitter.make
				a_string_splitter.set_separators (":")
				qname_parts := a_string_splitter.split (qname)
				if qname_parts.count = 1 then
					local_name := qname_parts.item (1)
					xml_prefix := ""
				elseif qname_parts.count = 2 then
					local_name := qname_parts.item (2)
					xml_prefix := qname_parts.item (1)
				else
					report_compile_error (STRING_.concat ("Invalid attribute name: ", qname))
				end
				if STRING_.same_string (xml_prefix, "xmlns") then
					if namespace = Void then
						report_compile_error (STRING_.concat ("Invalid attribute name: ", qname))
					else
						xml_prefix := "" -- We ignore it anyway when the namespace attribute is present
					end
				end
				if namespace = Void then
					namespace_uri := uri_for_prefix (xml_prefix, False)
				end
			end
		end

	compile_fixed_attribute (an_executable: XM_XSLT_EXECUTABLE; a_name_code: INTEGER) is
			-- Compile to a fixed attribute.
		require
			executable_not_void: an_executable /= Void
		local
			a_fixed_attribute: XM_XSLT_FIXED_ATTRIBUTE
		do
			create a_fixed_attribute.make (an_executable, a_name_code, validation_action, Void, -1)
			last_generated_instruction := a_fixed_attribute
			compile_children (an_executable, last_generated_instruction)
			a_fixed_attribute.set_separator_expression (separator_expression)
		end

	choose_arbitrary_xml_prefix is
			-- Choose an arbitrary XML prefix.
		do
			todo ("choose arbitrary_xml_prefix", False)
		end

end