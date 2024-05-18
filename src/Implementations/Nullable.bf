using System;
using System.Diagnostics;

namespace BeefSerializer
{
	extension Serializer
	{
		public void Put<T>(T? x) where T : struct, new
		{
			PutNullSign!(x);
					
			//return Put(x.Value);
			VarPut(x);
		}
		
		[Inline]
		// FIXME: This should be removed when the compiler bug is resolved
		private void VarPut<T>(T? x) where T : var
		{
			Put(x.Value);
		}

		public SerializerResult Get<T>(ref T? x) where T : struct, new
		{
			GetNullSign!(ref x);

			// Avoid "Value requested for null nullable." error
			if (!x.HasValue)
				x = (T)(default);

			//return Get(ref x.ValueRef);
			return VarGet(ref x);
		}
		
		[Inline]
		// FIXME: This should be removed when the compiler bug is resolved
		private void VarGet<T>(ref T? x) where T : var
		{
			Get(ref x.ValueRef);
		}
	}
}
