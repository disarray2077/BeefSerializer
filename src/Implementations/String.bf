using System;
using System.Diagnostics;

namespace BeefSerializer
{
	extension Serializer
	{
		public void Put(String x)
		{
			Debug.Assert(UseNullSign ? (x == null || x.Length >= 0 && x.Length <= 0xffff) : (x != null && x.Length >= 0 && x.Length <= 0xffff));

			PutNullSign!(x);

		    uint32 size = (.)x.Length;
			Put(size);

			if (size == 0)
				return;

		    PutMemory(.((uint8*)x.Ptr, size));
		}

		public SerializerResult Get(ref String x)
		{
			GetNullSign!(x);

		    uint32 size = ?;
			Try!(Get(ref size));

#if	!BFSERIALIZER_EXCLUDE_RUNTIME_CHECKS
		    if (ReadLength < size)
		        return .Err(.NotEnoughData);
#endif

			if (x == null)
			{
				if (mAllocator != null)
					x = new:mAllocator .(size);
				else
					x = new .(size);
			}
			else
			{
				x.Clear();
				x.Reserve(size);
			}

		    if (size == 0)
		        return .Ok;

			x.[Friend]mLength = (.)size;
		    return GetMemory(.((uint8*)x.Ptr, size));
		}
	}
}
