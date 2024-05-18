using System;
using System.Collections;
using System.Diagnostics;

namespace BeefSerializer
{
	extension Serializer
	{
		public void Put<K, V>(Dictionary<K, V> objs) where K : IHashable
		{
			Debug.Assert(UseNullSign ? (objs == null || objs.Count >= 0 && objs.Count <= 0xffffffff) : (objs != null && objs.Count >= 0 && objs.Count <= 0xffffffff));

			PutNullSign!(objs);

			Put((uint32)objs.Count);

			if (typeof(V).Size > sizeof(int))
			{
				for (let obj in ref objs)
					Put(obj);
			}
			else
			{
				for (let obj in objs)
					Put(obj);
			}
		}
		
		public SerializerResult Get<K, V>(ref Dictionary<K, V> objs) where K : var, IHashable where V : var
		{
			GetNullSign!(objs);

			uint32 numItems = ?;
			Try!(Get(ref numItems));

#if	!BFSERIALIZER_EXCLUDE_RUNTIME_CHECKS
		    if ((typeof(K).IsPrimitive && typeof(V).IsPrimitive) &&
				ReadLength < (uint32)(sizeof(K) + sizeof(V)) * numItems)
		        return .Err(.NotEnoughData);
#endif

			if (objs == null)
			{
				if (mAllocator != null)
					objs = new:mAllocator .((int32)numItems);
				else
					objs = new .((int32)numItems);
			}
			else
			{
				objs.Clear();
				// Idk how to change the capacity of a dictionary...
			}

			for (int i < (int)numItems)
			{
				K key = default;
				Try!(Get(ref key));

				V* valuePtr = ?;
				let inserted = objs.TryAdd(key, ?, out valuePtr);
				Debug.Assert(inserted);

				Try!(Get(ref *valuePtr));
			}

			return .Ok;
		}
	}
}