using System;
using System.Diagnostics;

namespace BeefSerializer
{
	extension Serializer
	{
		[Inline]
		public void Put<T>(Span<T> x) where T : var
		{
			Debug.Assert(x.Length <= 0xffffffff);

			for(int i = 0; i < x.Length; ++i)
				Put(x[i]);
		}

		[Inline]
		public SerializerResult Get<T>(ref Span<T> x) where T : var
		{
			Debug.Assert(x.Length <= 0xffffffff);

#if	!BFSERIALIZER_EXCLUDE_RUNTIME_CHECKS
		    if (typeof(T).IsPrimitive && ReadLength < (uint32)sizeof(T) * x.Length)
		        return .Err(.NotEnoughData);
#endif

			for(int i = 0; i < x.Length; ++i)
			    Try!(Get(ref x[i]));

			return .Ok;
		}
	}
}
