namespace BeefSerializer
{
	extension Serializer
	{
		private static bool IsNullStrict<T>(T t)
		    where T: class
		{
		    return t === null;
		}

		private static bool IsNullStrict<T>(T? t)
		    where T: struct
		{
		    return !t.HasValue;
		}
	}
}
