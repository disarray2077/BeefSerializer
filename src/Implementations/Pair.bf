using System;
using System.Diagnostics;

namespace BeefSerializer
{
	extension Serializer
	{
		[Inline]
		public void Put<K, V>((K key, V value) obj) where K : var where V : var
		{
			Put(obj.key);
			Put(obj.value);
		}
		
		[Inline]
		public SerializerResult Get<K, V>(ref (K key, V value) obj) where K : var where V : var
		{
			Try!(Get(ref obj.key));
			Try!(Get(ref obj.value));
			return .Ok;
		}

		[Inline]
		public void Put<K, V>((K key, V* valueRef) obj) where K : var where V : var
		{
			Put(obj.key);
			Put(*obj.valueRef);
		}
		
		[Inline]
		public SerializerResult Get<K, V>(ref (K key, V* valueRef) obj) where K : var where V : var
		{
			Try!(Get(ref obj.key));
			Try!(Get(ref *obj.valueRef));
			return .Ok;
		}
	}
}
