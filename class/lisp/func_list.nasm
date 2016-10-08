%include 'inc/func.inc'
%include 'class/class_vector.inc'
%include 'class/class_lisp.inc'

	def_function class/lisp/func_list
		;inputs
		;r0 = lisp object
		;r1 = args
		;outputs
		;r0 = lisp object
		;r1 = 0, else value

		ptr this, args
		ulong length

		push_scope
		retire {r0, r1}, {this, args}

		static_call vector, get_length, {args}, {length}
		static_call vector, slice, {args, 1, length}, {args}

		eval {this, args}, {r0, r1}
		pop_scope
		return

	def_function_end
