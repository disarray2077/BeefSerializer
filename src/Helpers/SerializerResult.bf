using BeefSerializer;

namespace System;

#if BFSERIALIZER_EXCLUDE_RUNTIME_CHECKS
extension Result<T, TErr>
	where T : void
	where TErr : ErrorType
{
	new T Unwrap()
	{
		return this.IgnoreError();
	}
}
#endif