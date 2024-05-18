using System;
using System.Collections;
using System.Diagnostics;

namespace BeefSerializer
{
	extension Serializer
	{
		public void Put<T>(HashSet<T> objs) where T : var
		{
			Debug.Assert(UseNullSign ? (objs == null || objs.Count >= 0 && objs.Count <= 0xffffffff) : (objs != null && objs.Count >= 0 && objs.Count <= 0xffffffff));

			PutNullSign!(objs);

			Put((uint32)objs.Count);

			//if (typeof(T).Size > sizeof(int))
			//{
			//	for (let obj in ref objs)
			//		Put(obj);
			//}
			//else
			//{
			for (let obj in objs)
				Put(obj);
			//}
		}

		public SerializerResult Get<T>(ref HashSet<T> obj) where T : var
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
				//obj.Capacity = numItems;
			}
			
			for (int i < (int)numItems)
			{
				// Maybe this creates a copy, but I don't think that there's a better way to do this...
				T x = default;
				Try!(Get(ref x));
				obj.Add(x);
			}

			return .Ok;
		}
	}
}