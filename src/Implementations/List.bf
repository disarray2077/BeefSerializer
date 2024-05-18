using System;
using System.Collections;
using System.Diagnostics;

namespace BeefSerializer
{
	extension Serializer
	{
		public void Put<T>(List<T> objs) where T : var
		{
			Debug.Assert(UseNullSign ? (objs == null || objs.Count >= 0 && objs.Count <= 0xffffffff) : (objs != null && objs.Count >= 0 && objs.Count <= 0xffffffff));

			PutNullSign!(objs);

			Put((uint32)objs.Count);
			
			if (Endianess == PlatformEndianess && typeof(T).IsPrimitive)
			{
				if (objs.IsEmpty)
					return;
#unwarn
				PutMemory(.((uint8*)objs.Ptr, sizeof(T) * objs.Count));
				return;
			}

			for (int i < objs.Count)
				Put(objs[i]);
		}

		public SerializerResult Get<T>(ref List<T> obj) where T : var
		{
			GetNullSign!(obj);

			uint32 numItems = ?;
			Try!(Get(ref numItems));

#if	!BFSERIALIZER_EXCLUDE_RUNTIME_CHECKS
		    if (typeof(T).IsPrimitive && ReadLength < (uint32)sizeof(T) * numItems)
		        return .Err(.NotEnoughData);
#endif

			if (obj == null)
			{
				if (mAllocator != null)
					obj = new:mAllocator .(numItems);
				else
					obj = new .(numItems);
			}
			else
			{
				obj.Clear();
				obj.Capacity = numItems;
			}

			if (Endianess == PlatformEndianess && typeof(T).IsPrimitive)
			{
				if (numItems == 0)
					return .Ok;
				return GetMemory(.((uint8*)obj.GrowUnitialized((.)numItems), sizeof(T) * (.)numItems));
			}
			
			for (int i < (int)numItems)
			{
				obj.Add(default);
				Try!(Get(ref obj.Back));
			}

			return .Ok;
		}
	}
}