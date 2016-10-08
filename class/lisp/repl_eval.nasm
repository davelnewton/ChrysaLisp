%include 'inc/func.inc'
%include 'class/class_boxed_ptr.inc'
%include 'class/class_boxed_long.inc'
%include 'class/class_symbol.inc'
%include 'class/class_vector.inc'
%include 'class/class_unordered_set.inc'
%include 'class/class_unordered_map.inc'
%include 'class/class_pair.inc'
%include 'class/class_lisp.inc'

	def_function class/lisp/repl_eval
		;inputs
		;r0 = lisp object
		;r1 = ast
		;outputs
		;r0 = lisp object
		;r1 = 0, else value

		ptr this, ast, value, func, args
		ulong length

		push_scope
		retire {r0, r1}, {this, ast}

		;evaluate based on type
		assign {0}, {value}
		assign {ast->obj_vtable}, {func}
		switch
		case {func == @class/class_symbol}
			;eval to symbol value
			static_call lisp, env_get, {this, ast}, {value}
			breakif {value}
			static_call lisp, error, {this, "variable not defined", ast}
			break
		case {func == @class/class_boxed_ptr \
		 	|| func == @class/class_boxed_long \
			|| func == @class/class_pair \
			|| func == @class/class_string \
			|| func == @class/class_unordered_set \
			|| func == @class/class_unordered_map}
			;eval to self
			assign {ast}, {value}
			static_call ref, ref, {value}
			break
		case {func == @class/class_vector}
			static_call vector, get_length, {ast}, {length}
			ifnot {length}
				;eval to nil
				assign {this->lisp_sym_nil}, {value}
				static_call ref, ref, {value}
			else
				;apply function or special form
				static_call vector, get_element, {ast, 0}, {func}
				static_call lisp, repl_eval, {this, func}, {func}
				breakifnot {func}
				if {func->obj_vtable != @class/class_boxed_ptr}
					static_call lisp, repl_apply, {this, func, ast}, {value}
				elseif {func->boxed_ptr_flags}
					static_call lisp, repl_apply, {this, func, ast}, {value}
				else
					static_call vector, slice, {ast, 0, length}, {args}
					static_call lisp, repl_eval_list, {this, args}, {length}
					if {length}
						static_call lisp, repl_apply, {this, func, args}, {value}
					endif
					static_call ref, deref, {args}
				endif
				static_call ref, deref, {func}
			endif
			break
		default
			static_call lisp, error, {this, "unknown type", ast}
		endswitch

		eval {this, value}, {r0, r1}
		pop_scope
		return

	def_function_end
