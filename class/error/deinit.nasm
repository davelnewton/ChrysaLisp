%include 'inc/func.inc'
%include 'class/class_error.inc'

	def_function class/error/deinit
		;inputs
		;r0 = error object
		;trashes
		;all but r0, r4

		vp_push r0
		s_call ref, deref, {[r0 + error_description]}
		vp_cpy [r4], r0
		s_call ref, deref, {[r0 + error_object]}
		vp_pop r0
		p_jmp error, deinit, {r0}

	def_function_end