using System;
using System.Diagnostics;

namespace BeefSerializer
{
	extension Serializer
	{
		[Inline]
		public void Put(DateTime x)
		{
			Put(x.Ticks);
		}

		[Inline]
		public SerializerResult Get(ref DateTime x)
		{
			Try!(Get(ref x.[Friend]dateData));
			return .Ok;
		}
	}
}
