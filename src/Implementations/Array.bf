using System;
using System.Diagnostics;

namespace BeefSerializer
{
	extension Serializer
	{
		public void Put<T>(T[] x) where T : var
		{
			Debug.Assert(UseNullSign ? (x == null || x.Count >= 0 && x.Count <= 0xffffffff) : (x != null && x.Count >= 0 && x.Count <= 0xffffffff));

			PutNullSign!(x);

			Put((uint32)x.Count);
			
			if (Endianess == PlatformEndianess && typeof(T).IsPrimitive)
			{
				if (x.IsEmpty)
					return;
#unwarn
				PutMemory(.((uint8*)x.Ptr, sizeof(T) * x.Count));
				return;
			}

			for (int i < x.Count)
				Put(x[i]);
		}

		public SerializerResult Get<T>(ref T[] x) where T : var
		{
			GetNullSign!(x);

			uint32 numItems = ?;
			Try!(Get(ref numItems));

#if	!BFSERIALIZER_EXCLUDE_RUNTIME_CHECKS
		    if (typeof(T).IsPrimitive && ReadLength < sizeof(T) * (.)numItems)
		        return .Err(.NotEnoughData);
#endif

			if (x != null && x.Count != numItems)
			{
				if (x.Count > numItems)
					x.Count = numItems;
				else
				{
					Debug.AssertNotStack(x);
					delete x;
					x = null;
				}
			}

			if (x == null)
			{
				if (mAllocator != null)
				{
					x = new:mAllocator T[numItems];
				}
				else
				{
					x = new T[numItems];
				}
			}

			if (Endianess == PlatformEndianess && typeof(T).IsPrimitive)
			{
				if (numItems == 0)
					return .Ok;
				return GetMemory(.((uint8*)x.Ptr, sizeof(T) * (.)numItems));
			}

			for (int i < (int)numItems)
			    Try!(Get(ref x[i]));

			return .Ok;
		}

		public void Put<T, U>(T[U] x) where T : var where U : const int
		{
			Debug.Assert(U <= 0xffffffff);

			if (U == 0)
				return;

			if (Endianess == PlatformEndianess && typeof(T).IsPrimitive)
			{
#unwarn
				PutMemory(.((.)&x, sizeof(T) * x.Count));
				return;
			}

			for (int i < U)
				Put(x[i]);
		}

		public SerializerResult Get<T, U>(ref T[U] x) where T : var where U : const int
		{
			Debug.Assert(U <= 0xffffffff);

			if (U == 0)
				return .Ok;

#if	!BFSERIALIZER_EXCLUDE_RUNTIME_CHECKS
		    if (typeof(T).IsPrimitive && ReadLength < (uint32)sizeof(T) * U)
		        return .Err(.NotEnoughData);
#endif
			
			if (Endianess == PlatformEndianess && typeof(T).IsPrimitive)
			{
				return GetMemory(.((uint8*)&x, sizeof(T) * x.Count));
			}

			T* xPtr = (.)&x;
			for (int i < U)
			    Try!(Get(ref xPtr[i]));

			return .Ok;
		}
	}
}
